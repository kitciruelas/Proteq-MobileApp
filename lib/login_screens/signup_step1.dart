import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';  // Removed - causes web package issues
import 'login_screen.dart';
import 'signup_step2.dart';

class SignUpStep1 extends StatefulWidget {
  const SignUpStep1({super.key});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRole;
  String? selectedDepartment;
  String? selectedCollege;
  String? selectedFile;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  final departments = ["ICT", "Engineering", "Nursing"];
  final colleges = ["BSIT", "BSCpE", "BSN"];

  Future<void> _pickFile() async {
    // This method is removed as per the instructions
  }

  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your department'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCollege == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your college/course'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare user data
    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'user_type': selectedRole!.toUpperCase(),
      'department': selectedDepartment!,
      'college': selectedCollege!,
      'profile_picture': selectedFile,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpStep2(userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SignUpAppBar(
        currentStep: 1,
        title: 'Sign Up - Step 1',
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16).copyWith(bottom: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔵 Stepper (Static)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          StepCircle(index: 1, isActive: true, label: "General Information"),
                          StepCircle(index: 2, isActive: false, label: "Security"),
                          StepCircle(index: 3, isActive: false, label: "Review"),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Name fields (stacked vertically for mobile)
                      TextFormField(
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your first name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your last name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "I am a",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Student", child: Text("Student")),
                          DropdownMenuItem(value: "Faculty", child: Text("Faculty")),
                          DropdownMenuItem(value: "University Employee", child: Text("University Employee")),
                        ],
                        value: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                            if (value == "University Employee") {
                              selectedDepartment = "N/A";
                              selectedCollege = "N/A";
                            } else {
                              if (selectedDepartment == "N/A") selectedDepartment = null;
                              if (selectedCollege == "N/A") selectedCollege = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your role';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdowns stacked vertically for mobile
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Department",
                          prefixIcon: Icon(Icons.apartment_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: (selectedRole == "University Employee")
                            ? [const DropdownMenuItem(value: "N/A", child: Text("N/A"))]
                            : departments.map((dep) {
                                return DropdownMenuItem(value: dep, child: Text(dep));
                              }).toList(),
                        value: selectedDepartment,
                        onChanged: (selectedRole == "University Employee")
                            ? null
                            : (value) => setState(() => selectedDepartment = value),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "College/Course",
                          prefixIcon: Icon(Icons.school_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: (selectedRole == "University Employee")
                            ? [const DropdownMenuItem(value: "N/A", child: Text("N/A"))]
                            : colleges.map((col) {
                                return DropdownMenuItem(value: col, child: Text(col));
                              }).toList(),
                        value: selectedCollege,
                        onChanged: (selectedRole == "University Employee")
                            ? null
                            : (value) => setState(() => selectedCollege = value),
                      ),

                      const SizedBox(height: 4),

                      const SizedBox(height: 32),
                      // Navigation Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _goToNextStep,
                            child: const Text("Next"),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton(
                              onPressed: () {
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Add this custom AppBar widget at the top of the file
class SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final String title;
  final int totalSteps;
  final VoidCallback? onBack;

  const SignUpAppBar({
    super.key,
    required this.currentStep,
    required this.title,
    this.totalSteps = 3,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      color: Colors.red,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/logo-w.png',
                height: 40,
                width: 40 ,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalSteps, (i) {
                      final isActive = i < currentStep;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 18,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40), // To balance the logo
          ],
        ),
      ),
    );
  }
}

class StepCircle extends StatelessWidget {
  final int index;
  final bool isActive;
  final String label;
  final double size;

  const StepCircle({
    super.key,
    required this.index,
    required this.isActive,
    required this.label,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: isActive ? Colors.blue : Colors.grey[300],
          child: Text(
            index.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontSize: size * 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
          style: TextStyle(fontSize: size * 0.28),
        ),
      ],
    );
  }
}
