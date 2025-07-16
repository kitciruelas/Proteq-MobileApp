import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/session_service.dart';
import '../api/authentication.dart';
import '../login_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Controllers for editing
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user;
      _initializeControllers();
      _isLoading = false;
    } else {
      _loadUser();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      // Replace 1 with the actual logged-in user's ID
      User? user = await UserService.getUserById(1);
      setState(() {
        _user = user;
        _isLoading = false;
      });
      _initializeControllers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    if (_user != null) {
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
      _emailController.text = _user!.email;
      _departmentController.text = _user!.department;
      _collegeController.text = _user!.college;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if canceling edit
        _initializeControllers();
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create updated user object
      final updatedUser = User(
        userId: _user!.userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userType: _user!.userType,
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        college: _collegeController.text.trim(),
        status: _user!.status,
        createdAt: _user!.createdAt,
      );

      // Debug: print outgoing data
      print('Updating user: \n' + updatedUser.toJson().toString());

      // Update user in service
      await UserService.updateUser(updatedUser);

      // Close loading dialog
      Navigator.of(context).pop();

      // Update local state
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      // Debug: print error
      print('Profile update error: \n' + e.toString());
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: \n' + e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call logout API
      await AuthenticationApi.logout();

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Even if logout API fails, clear local session and navigate
      await SessionService.clearSession();
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;
    String? currentPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;

    void clearFields() {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lock, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: currentPasswordController,
                            obscureText: !showCurrentPassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: Icon(showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => showCurrentPassword = !showCurrentPassword),
                              ),
                              errorText: currentPasswordError,
                            ),
                            onChanged: (_) => setState(() => currentPasswordError = null),
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: !showNewPassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: const Icon(Icons.vpn_key),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: Icon(showNewPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => showNewPassword = !showNewPassword),
                              ),
                              errorText: newPasswordError,
                            ),
                            onChanged: (_) => setState(() => newPasswordError = null),
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: !showConfirmPassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              prefixIcon: const Icon(Icons.vpn_key_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                              ),
                              errorText: confirmPasswordError,
                            ),
                            onChanged: (_) => setState(() => confirmPasswordError = null),
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          setState(() {
                                            currentPasswordError = null;
                                            newPasswordError = null;
                                            confirmPasswordError = null;
                                          });
                                          bool valid = true;
                                          if (currentPasswordController.text.isEmpty) {
                                            setState(() => currentPasswordError = 'Enter current password');
                                            valid = false;
                                          }
                                          if (newPasswordController.text.length < 6) {
                                            setState(() => newPasswordError = 'Password must be at least 6 characters');
                                            valid = false;
                                          }
                                          if (confirmPasswordController.text != newPasswordController.text) {
                                            setState(() => confirmPasswordError = 'Passwords do not match');
                                            valid = false;
                                          }
                                          if (!valid) return;
                                          setState(() => isLoading = true);
                                          final result = await UserService.changeUserPassword(
                                            userId: _user?.userId ?? 0,
                                            currentPassword: currentPasswordController.text,
                                            newPassword: newPasswordController.text,
                                          );
                                          setState(() => isLoading = false);
                                          if (result['success'] == true) {
                                            clearFields();
                                            Navigator.of(context).pop();
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(24),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: const [
                                                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                                                      SizedBox(height: 16),
                                                      Text('Password changed successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            if ((result['message'] ?? '').toLowerCase().contains('current')) {
                                              setState(() => currentPasswordError = result['message']);
                                            } else {
                                              setState(() => newPasswordError = result['message'] ?? 'Failed to change password');
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.white,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.red),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      color: Colors.red,
                    ),
                    onPressed: _toggleEditMode,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 50,
                  child: Icon(Icons.person, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Text(
                      'Loading...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    )
                  : Text(
                      _user?.fullName ?? 'User Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    )
                  : Text(
                      _user?.userType ?? 'User Type',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Personal Information',
            children: [
              _buildInfoRow('First Name', _firstNameController, Icons.person),
              _buildInfoRow('Last Name', _lastNameController, Icons.person),
              _buildInfoRow('Email', _emailController, Icons.email),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Academic Information',
            children: [
              _buildInfoRow('Department', null, Icons.business, value: _user?.department ?? ''),
              _buildInfoRow('College', null, Icons.school, value: _user?.college ?? ''),
              _buildInfoRow('User Type', null, Icons.category, value: _user?.userType ?? ''),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Account Information',
            children: [
              _buildInfoRow('User ID', null, Icons.badge, value: _user?.userId.toString() ?? ''),
              _buildInfoRow('Status', null, Icons.circle, 
                value: _user?.isActive == true ? 'Active' : 'Inactive',
                iconColor: _user?.isActive == true ? Colors.green : Colors.red,
              ),
              _buildInfoRow('Member Since', null, Icons.calendar_today, 
                value: _user?.createdAt ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 30),
          if (_isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleEditMode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          _buildActionCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController? controller, IconData icon, {String? value, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (controller != null && _isEditing)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                else
                  Text(
                    value ?? controller?.text ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionRow(
              'Change Password',
              Icons.lock,
              _showChangePasswordDialog,
            ),
            
            const Divider(height: 24),
            _buildActionRow(
              'Logout',
              Icons.logout,
              _logout,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(child: _buildProfileSection()),
        ],
      ),
    );
  }
} 