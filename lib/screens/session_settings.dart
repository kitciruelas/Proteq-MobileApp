import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../api/authentication.dart';

class SessionSettingsScreen extends StatefulWidget {
  const SessionSettingsScreen({super.key});

  @override
  State<SessionSettingsScreen> createState() => _SessionSettingsScreenState();
}

class _SessionSettingsScreenState extends State<SessionSettingsScreen> {
  Duration _sessionTimeout = const Duration(hours: 24);
  Duration? _remainingTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionSettings();
  }

  Future<void> _loadSessionSettings() async {
    try {
      final timeout = await SessionService.getSessionTimeout();
      final remaining = await SessionService.getRemainingSessionTime();
      
      setState(() {
        _sessionTimeout = timeout;
        _remainingTime = remaining;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSessionTimeout(Duration newTimeout) async {
    try {
      await SessionService.setSessionTimeout(newTimeout);
      setState(() {
        _sessionTimeout = newTimeout;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session timeout updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update session timeout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshSession() async {
    try {
      await SessionService.refreshSession();
      await _loadSessionSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session refreshed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _validateSession() async {
    try {
      final result = await AuthenticationApi.validateSession();
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session is valid'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Session validation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      await _loadSessionSettings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session validation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _remainingTime != null && _remainingTime!.inMinutes > 0
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _remainingTime != null && _remainingTime!.inMinutes > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _remainingTime != null && _remainingTime!.inMinutes > 0
                                    ? 'Active'
                                    : 'Expired',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _remainingTime != null && _remainingTime!.inMinutes > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (_remainingTime != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Time remaining: ${_formatDuration(_remainingTime!)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Session Timeout Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Timeout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Current timeout: ${_formatDuration(_sessionTimeout)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select new timeout:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildTimeoutChip(const Duration(hours: 1), '1 Hour'),
                              _buildTimeoutChip(const Duration(hours: 4), '4 Hours'),
                              _buildTimeoutChip(const Duration(hours: 8), '8 Hours'),
                              _buildTimeoutChip(const Duration(hours: 12), '12 Hours'),
                              _buildTimeoutChip(const Duration(hours: 24), '24 Hours'),
                              _buildTimeoutChip(const Duration(hours: 48), '48 Hours'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Session Actions Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _refreshSession,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Session'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _validateSession,
                              icon: const Icon(Icons.verified),
                              label: const Text('Validate Session'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeoutChip(Duration timeout, String label) {
    final isSelected = _sessionTimeout == timeout;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateSessionTimeout(timeout);
        }
      },
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red,
    );
  }
} 