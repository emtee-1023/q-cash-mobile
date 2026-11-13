import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/models/business.dart';
import '../../core/models/business_type.dart';
import '../../core/models/location.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/phone_field.dart';
import 'mpesa_connection_screen.dart';

class BusinessRegistrationScreen extends ConsumerStatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  ConsumerState<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends ConsumerState<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _registration = TextEditingController();
  final _address = TextEditingController();
  BusinessType? _businessType;
  County? _county;
  SubCounty? _subCounty;
  Ward? _ward;
  bool _hasPhysicalLocation = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _registration.dispose();
    _address.dispose();
    super.dispose();
  }

  void _setPhysicalLocation(bool value) {
    setState(() {
      _hasPhysicalLocation = value;
      if (!value) {
        _county = null;
        _subCounty = null;
        _ward = null;
        _address.clear();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_businessType == null) {
      _showError('Select a business type.');
      return;
    }
    setState(() => _busy = true);
    final phone = normalizeKenyanPhone(_phone.text);
    try {
      final business = await ref.read(businessesProvider.notifier).create({
        'business_name': _name.text.trim(),
        'business_type_id': _businessType!.id,
        'has_physical_location': _hasPhysicalLocation,
        if (_registration.text.trim().isNotEmpty)
          'registration_number': _registration.text.trim(),
        'phone_number': ?phone,
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        if (_hasPhysicalLocation && _county != null) 'county_id': _county!.id,
        if (_hasPhysicalLocation && _subCounty != null)
          'sub_county_id': _subCounty!.id,
        if (_hasPhysicalLocation && _ward != null) 'ward_id': _ward!.id,
        if (_hasPhysicalLocation && _address.text.trim().isNotEmpty)
          'physical_address': _address.text.trim(),
      });
      if (!mounted) return;
      _goToMpesa(business);
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not register your business. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goToMpesa(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MpesaConnectionScreen(business: business),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(businessTypesProvider);
    final types = typesAsync.value ?? const <BusinessType>[];
    final countiesAsync = ref.watch(countiesProvider);
    final counties = countiesAsync.value ?? const <County>[];
    final subCounties = _county == null
        ? const <SubCounty>[]
        : ref.watch(subCountiesProvider(_county!.id)).value ??
              const <SubCounty>[];
    final wards = _subCounty == null
        ? const <Ward>[]
        : ref.watch(wardsProvider(_subCounty!.id)).value ?? const <Ward>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Business Name',
                        hint: 'Wanjiru\'s General Store',
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Business name is required'
                            : null,
                      ),
                      AppSelectField<BusinessType>(
                        label: 'Business Type',
                        hint: 'Select type',
                        items: types,
                        labelOf: (t) => t.name,
                        value: _businessType,
                        loading: typesAsync.isLoading,
                        onChanged: (v) => setState(() => _businessType = v),
                      ),
                      AppTextField(
                        label: 'Registration Number (optional)',
                        hint: 'BRS/XXXX/2024',
                        controller: _registration,
                      ),
                      AppTextField(
                        label: 'Business Phone (optional)',
                        hint: '0712 345 678',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [KenyanPhoneInputFormatter()],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return normalizeKenyanPhone(v) == null
                              ? 'Enter a valid phone number'
                              : null;
                        },
                      ),
                      AppTextField(
                        label: 'Email (optional)',
                        hint: 'you@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _locationToggle(),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _hasPhysicalLocation
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 16),
                                  AppSelectField<County>(
                                    label: 'County',
                                    hint: 'Select county',
                                    items: counties,
                                    labelOf: (c) => c.name,
                                    value: _county,
                                    loading: countiesAsync.isLoading,
                                    onChanged: (v) => setState(() {
                                      _county = v;
                                      _subCounty = null;
                                      _ward = null;
                                    }),
                                  ),
                                  AppSelectField<SubCounty>(
                                    label: 'Sub-County',
                                    hint: 'Select sub-county',
                                    items: subCounties,
                                    labelOf: (s) => s.name,
                                    value: _subCounty,
                                    onChanged: (v) => setState(() {
                                      _subCounty = v;
                                      _ward = null;
                                    }),
                                  ),
                                  AppSelectField<Ward>(
                                    label: 'Ward',
                                    hint: 'Select ward',
                                    items: wards,
                                    labelOf: (w) => w.name,
                                    value: _ward,
                                    onChanged: (v) => setState(() => _ward = v),
                                  ),
                                  AppTextField(
                                    label: 'Physical Address',
                                    hint: 'Street, building, room',
                                    controller: _address,
                                  ),
                                ],
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Continue',
                        color: QcashColors.green,
                        onPressed: _busy ? null : _submit,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: QcashColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text: 'Business ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.navy,
                  ),
                ),
                TextSpan(
                  text: 'Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a little about your business so we can set you up.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: QcashColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationToggle() {
    final enabled = _hasPhysicalLocation;
    return InkWell(
      onTap: () => _setPhysicalLocation(!enabled),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? QcashColors.green.withValues(alpha: 0.08)
              : QcashColors.iconBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? QcashColors.green.withValues(alpha: 0.4)
                : QcashColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: enabled
                    ? QcashColors.green.withValues(alpha: 0.15)
                    : QcashColors.border.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 18,
                color: enabled ? QcashColors.green : QcashColors.textGray,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Physical location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: QcashColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add your county, ward and address',
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? QcashColors.green : QcashColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              activeTrackColor: QcashColors.green,
              onChanged: _setPhysicalLocation,
            ),
          ],
        ),
      ),
    );
  }
}
