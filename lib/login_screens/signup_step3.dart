import 'package:flutter/material.dart';
import 'signup_step2.dart';
import 'login_screen.dart';
import '../api/authentication.dart';

class SignUpStep3 extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const SignUpStep3({super.key, required this.userData});

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  bool isPolicyAgreed = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!isPolicyAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthenticationApi.signup(widget.userData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Account Created"),
              content: const Text("Your account has been successfully created. You can now log in."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Go to Login"),
                ),
              ],
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                StepCircle(index: 1, isActive: true, label: "General Info"),
                StepCircle(index: 2, isActive: true, label: "Security"),
                StepCircle(index: 3, isActive: true, label: "Review"),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "🔍 Review Your Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // General Info Card
            _buildInfoCard(
              title: "📁 General Information",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${widget.userData['first_name']} ${widget.userData['last_name']}"),
                  Text("Email: ${widget.userData['email']}"),
                  Text("Department: ${widget.userData['department']}"),
                  Text("College: ${widget.userData['college']}"),
                  Text("Role: ${widget.userData['user_type']}"),
                  Text("Profile Picture: ${widget.userData['profile_picture'] ?? 'No file selected'}"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Security Info Card
            _buildInfoCard(
              title: "🔒 Security Information",
              content: const Text("Password: ********"),
            ),

            const SizedBox(height: 10),

            // Privacy Policy Consent
            _buildInfoCard(
              title: "📜 Privacy Policy Consent",
              content: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                value: isPolicyAgreed,
                onChanged: (value) => setState(() => isPolicyAgreed = value!),
                title: const Text.rich(
                  TextSpan(
                    text: "I have read and agree to the ",
                    children: [
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Final Notes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("✅ Final Step:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("• Please review all information carefully"),
                  Text("• Ensure all details are accurate"),
                  Text("• Read and accept the Privacy Policy"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pop(context); // Go back to Step 2
                    },
                    child: const Text("Previous"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("Confirm & Sign Up"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    children: [
                      TextSpan(
                        text: "Log In here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  // Card builder
  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}

// Reusable Step Circle
class StepCircle extends StatelessWidget {
  final int index;
  final bool isActive;
  final String label;

  const StepCircle({
    super.key,
    required this.index,
    required this.isActive,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive ? Colors.blue : Colors.grey[300],
          child: Text(
            index.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
