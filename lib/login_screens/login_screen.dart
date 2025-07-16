import 'package:flutter/material.dart';
import 'signup_step1.dart';
import '../screens/dashboard.dart';
import '../responders_screen/r_dashboard.dart';
import '../api/authentication.dart';
import '../models/user.dart';
import '../models/staff.dart';
import '../services/session_service.dart';
import 'forget_password.dart';
import '../responders_screen/responder_home_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final bool _loginAsStaff = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;
      result = await AuthenticationApi.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          final user = result['user'];
          final userType = user['user_type']?.toString().toLowerCase() ?? '';
          final role = user['role']?.toString().toLowerCase() ?? '';
          print('DEBUG: userType after login: ' + userType);
          print('DEBUG: role after login: ' + role);
          final userObj = User.fromJson(user);
          await SessionService.storeUser(userObj);

          // If this is a staff member, also store staff data
          if (userType == 'staff' || userType == 'responder' ||
              role == 'nurse' || role == 'paramedic' || role == 'security' || role == 'firefighter' || role == 'others') {
            
            print('[LoginScreen] Processing staff data for user type: $userType, role: $role');
            print('[LoginScreen] Result keys: ${result.keys.toList()}');
            
            // Check if staff data is provided in the response
            if (result['staff'] != null) {
              print('[LoginScreen] Using separate staff data from result[staff]');
              final staffObj = Staff.fromJson(result['staff']);
              await SessionService.storeStaff(staffObj);
            } else if (result['user'] != null && (userType == 'staff' || userType == 'responder' || 
                       role == 'nurse' || role == 'paramedic' || role == 'security' || role == 'firefighter' || role == 'others')) {
              // Create staff object from user data since API returns staff data in user field
              print('[LoginScreen] Using user data as staff data from result[user]');
              print('[LoginScreen] User data: ${result['user']}');
              final staffObj = Staff.fromJson(result['user']);
              print('[LoginScreen] Created staff object: ${staffObj.name}, role: ${staffObj.role}, status: ${staffObj.status}');
              await SessionService.storeStaff(staffObj);
            } else {
              // Create staff object from user data if staff data not provided
              print('[LoginScreen] Creating staff object from user data manually');
              final staffObj = Staff(
                staffId: user['staff_id'] ?? user['user_id'] ?? 1,
                name: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
                email: user['email'] ?? '',
                role: role.isNotEmpty ? role : 'others',
                availability: 'available',
                status: 'active',
                createdAt: user['created_at'] ?? DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              );
              await SessionService.storeStaff(staffObj);
            }
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResponderHomeTab()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(user: userObj)),
            );
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login failed'),
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
      // App background color
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔻 Logo at the top
                  Image.asset(
                    'assets/images/logo-r.png',
                    height: 120, // Adjust as needed
                  ),
                  const SizedBox(height: 40),

                  // 🔻 App Title
                  const Text(
                    "Proteq",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔻 Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🔻 Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                     
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🔻 Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  // 🔻 Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              "Login",
                              style: TextStyle(
                                color: Colors.white, // 🔴 Change text color here
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔻 Register Prompt
                  TextButton(
                    onPressed: () {
                      //Navigate to Signup Step 1
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpStep1()),
                      );
                    },
                    child: const Text("Don't have an account? Register here"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
