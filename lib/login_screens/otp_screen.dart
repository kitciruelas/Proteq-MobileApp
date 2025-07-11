import 'package:flutter/material.dart';
import 'new_password_screen.dart';
import '../api/authentication.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _timer;
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  Future<void> _resendOtp() async {
    _startResendCooldown();
    final result = await AuthenticationApi.forgotPassword(widget.email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'OTP resent.'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _submit() async {
    if (_otpController.text.length != 6) return;
    setState(() { _isLoading = true; _errorText = null; });
    final result = await AuthenticationApi.verifyOtp(widget.email, _otpController.text.trim());
    setState(() { _isLoading = false; });
    if (result['success'] == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(email: widget.email, otp: _otpController.text.trim()),
        ),
      );
    } else {
      setState(() { _errorText = result['message'] ?? 'Invalid or expired OTP.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify account with OTP'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              "We've sent 6 code to ${widget.email}",
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 30),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 50,
                activeColor: _errorText != null ? Colors.red : Colors.black,
                selectedColor: Colors.black,
                inactiveColor: _errorText != null ? Colors.red : Colors.grey,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                borderWidth: 2,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onChanged: (value) {
                setState(() { _errorText = null; });
              },
              onCompleted: (value) {
                if (!_isLoading) _submit();
              },
              errorTextSpace: 0,
              cursorColor: Colors.black,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              autoFocus: true,
              showCursor: true,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? 'Resend code' : 'Resend in $_resendCooldown s',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_otpController.text.length == 6 && !_isLoading) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By entering your number you agree to our ',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'Terms & Privacy Policy',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      // Add gesture recognizer if you want to handle tap
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} 