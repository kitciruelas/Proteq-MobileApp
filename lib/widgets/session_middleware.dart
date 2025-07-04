import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../api/authentication.dart';
import '../login_screens/login_screen.dart';

class SessionMiddleware extends StatefulWidget {
  final Widget child;
  final bool requireAuth;
  final VoidCallback? onSessionExpired;

  const SessionMiddleware({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.onSessionExpired,
  });

  @override
  State<SessionMiddleware> createState() => _SessionMiddlewareState();
}

class _SessionMiddlewareState extends State<SessionMiddleware> {
  bool _isValidating = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _validateSession();
  }

  Future<void> _validateSession() async {
    if (!widget.requireAuth) {
      setState(() {
        _isValidating = false;
        _isValid = true;
      });
      return;
    }

    try {
      // Check if user is logged in
      final isLoggedIn = await SessionService.isLoggedIn();
      
      if (!isLoggedIn) {
        _handleSessionExpired();
        return;
      }

      // Validate session with server
      final validationResult = await AuthenticationApi.validateSession();
      
      if (validationResult['success']) {
        setState(() {
          _isValidating = false;
          _isValid = true;
        });
      } else {
        _handleSessionExpired();
      }
    } catch (e) {
      _handleSessionExpired();
    }
  }

  void _handleSessionExpired() {
    setState(() {
      _isValidating = false;
      _isValid = false;
    });

    // Call custom callback if provided
    widget.onSessionExpired?.call();

    // Show session expired message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please log in again.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate to login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-r.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Validating session...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isValid) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-r.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Redirecting to login...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

// Extension to easily wrap widgets with session middleware
extension SessionMiddlewareExtension on Widget {
  Widget withSessionMiddleware({
    bool requireAuth = true,
    VoidCallback? onSessionExpired,
  }) {
    return SessionMiddleware(
      requireAuth: requireAuth,
      onSessionExpired: onSessionExpired,
      child: this,
    );
  }
} 