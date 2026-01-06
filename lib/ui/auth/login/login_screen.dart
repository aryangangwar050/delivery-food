import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';

import '../../../utils/color_res.dart';
import '../../../utils/size_config.dart';
import '../../home/home_screen.dart';

/// LoginScreen supports two modes:
/// 1) Mobile number + OTP flow
/// 2) Email + Password flow
///
/// It is implemented with a single form, safe disposal of controllers,
/// simple validation, and small helper builders to reduce rebuild cost.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthMode { phoneOtp, emailPassword }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers and focus nodes
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.phoneOtp;
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Minimal validators
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter phone number';
    final cleaned = v.trim();
    // allow optional leading + and 10-13 digits (covers local and common country-code variations)
    if (!RegExp(r'^\+?\d{10,13}$').hasMatch(cleaned)) return 'Enter a valid phone number (10-13 digits, optional +)';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final email = v.trim();
    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Provide immediate feedback if form invalid
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix the errors in the form')));
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (_mode == _AuthMode.phoneOtp) {
      if (!_otpSent) {
        // Send OTP - simulated
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent (simulated)')),
        );
      } else {
        // Verify OTP - simulated; accept any non-empty
        if (_otpController.text.trim().isNotEmpty) {
          _onAuthSuccess('Phone');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter OTP')),
          );
        }
      }
    } else {
      // Email/password flow - simulated authentication
      _onAuthSuccess('Email');
    }

    setState(() => _isLoading = false);
  }

  void _onAuthSuccess(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in with $method (simulated)')),
    );
    // Navigate to home and replace the stack so user won't come back to login.
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  void _switchMode(_AuthMode m) {
    if (_mode == m) return;
    setState(() {
      _mode = m;
      _otpSent = false;
      _otpController.clear();
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        counterText: maxLength != null ? '' : null,
        contentPadding: EdgeInsets.symmetric(horizontal: SizeConfig.scale(12), vertical: SizeConfig.scale(14)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorRes.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ColorRes.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode toggle
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mode == _AuthMode.phoneOtp
                          ? ColorRes.primary
                          : null,
                      foregroundColor: _mode == _AuthMode.phoneOtp
                          ? ColorRes.white
                          : null,
                    ),
                    onPressed: () => _switchMode(_AuthMode.phoneOtp),
                    child: const Text('Mobile / OTP'),
                  ),
                ),
                SizedBox(width: SizeConfig.scale(8)),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mode == _AuthMode.emailPassword
                          ? ColorRes.primary
                          : null,
                      foregroundColor: _mode == _AuthMode.emailPassword
                          ? ColorRes.white
                          : null,
                    ),
                    onPressed: () => _switchMode(_AuthMode.emailPassword),
                    child: const Text('Email / Password'),
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.scale(20)),

            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: _buildPhoneOtpForm(),
                secondChild: _buildEmailPasswordForm(),
                crossFadeState: _mode == _AuthMode.phoneOtp
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),

            SizedBox(height: SizeConfig.scale(20)),
            SizedBox(
              height: SizeConfig.scale(48),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? SizedBox(
                        height: SizeConfig.scale(20),
                        width: SizeConfig.scale(20),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_mode == _AuthMode.phoneOtp
                        ? (_otpSent ? 'Verify OTP' : 'Send OTP')
                        : 'Login'),
              ),
            ),
            SizedBox(height: SizeConfig.scale(12)),
            TextButton(
              onPressed: () {
                // Demo: quickly switch mode
                _switchMode(_mode == _AuthMode.phoneOtp
                    ? _AuthMode.emailPassword
                    : _AuthMode.phoneOtp);
              },
              child: const Text('Switch login method'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneOtpForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Mobile number',
          keyboardType: TextInputType.phone,
          // validate only when phone/OTP mode is active
          validator: (v) => _mode == _AuthMode.phoneOtp ? _validatePhone(v) : null,
          // allow digits and an optional leading + for country code (e.g. +9198...)
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
          maxLength: 13,
        ),
        SizedBox(height: SizeConfig.scale(12)),
        // Show OTP field only after OTP is requested
        if (_otpSent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PinCodeTextField(
                appContext: context,
                length: 4,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: SizeConfig.scale(50),
                  fieldWidth: SizeConfig.scale(48),
                  activeColor: ColorRes.primary,
                  selectedColor: ColorRes.primary,
                  inactiveColor: ColorRes.grey,
                ),
                cursorColor: ColorRes.textPrimary,
                onChanged: (value) {},
                onCompleted: (value) {
                  // Auto-verify on complete input
                  if (value.trim().isNotEmpty) {
                    _onAuthSuccess('Phone');
                  }
                },
              ),
              SizedBox(height: SizeConfig.scale(8)),
            ],
          ),
      ],
    );
  }

  Widget _buildEmailPasswordForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          // validate only when email/password mode is active
          validator: (v) => _mode == _AuthMode.emailPassword ? _validateEmail(v) : null,
        ),
  SizedBox(height: SizeConfig.scale(12)),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          obscureText: true,
          // validate only when email/password mode is active
          validator: (v) => _mode == _AuthMode.emailPassword ? _validatePassword(v) : null,
        ),
      ],
    );
  }
}
