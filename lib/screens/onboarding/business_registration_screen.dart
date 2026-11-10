import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/models/business.dart';
import '../../core/providers/business_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/screen_header.dart';
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
  final _county = TextEditingController();
  final _town = TextEditingController();
  final _address = TextEditingController();
  String? _businessType;
  String? _businessCategory;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _registration.dispose();
    _county.dispose();
    _town.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final business = await ref.read(businessesProvider.notifier).create({
        'business_name': _name.text.trim(),
        if (_businessType != null) 'business_type': _businessType,
        if (_businessCategory != null) 'business_category': _businessCategory,
        if (_registration.text.trim().isNotEmpty)
          'registration_number': _registration.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone_number': _phone.text.trim(),
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        if (_county.text.trim().isNotEmpty) 'county': _county.text.trim(),
        if (_town.text.trim().isNotEmpty) 'town': _town.text.trim(),
        if (_address.text.trim().isNotEmpty)
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Business Details', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Business Name',
                        hint: 'Wanjiru General Store',
                        controller: _name,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Business name is required' : null,
                      ),
                      AppDropdownField(
                        label: 'Business Type',
                        hint: 'Select type',
                        value: _businessType,
                        items: const [
                          'Sole Proprietorship',
                          'Partnership',
                          'Limited Company',
                          'Informal Business',
                        ],
                        onChanged: (v) => setState(() => _businessType = v),
                      ),
                      AppDropdownField(
                        label: 'Business Category',
                        hint: 'Select category',
                        value: _businessCategory,
                        items: const [
                          'Retail',
                          'Wholesale',
                          'Food & Beverage',
                          'Services',
                          'Transport',
                          'Other',
                        ],
                        onChanged: (v) => setState(() => _businessCategory = v),
                      ),
                      AppTextField(
                        label: 'Registration Number (optional)',
                        hint: 'BRS/XXXX/2024',
                        controller: _registration,
                      ),
                      AppTextField(
                        label: 'Phone Number (optional)',
                        hint: '+2547XXXXXXXX',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),
                      AppTextField(
                        label: 'Email (optional)',
                        hint: 'you@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      AppTextField(
                        label: 'County',
                        hint: 'Nairobi',
                        controller: _county,
                      ),
                      AppTextField(
                        label: 'Town',
                        hint: 'Nairobi CBD',
                        controller: _town,
                      ),
                      AppTextField(
                        label: 'Physical Address',
                        hint: 'Street, building, room',
                        controller: _address,
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Continue',
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
}
