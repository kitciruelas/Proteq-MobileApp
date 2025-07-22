import 'package:flutter/material.dart';
import '../services/welfare_check_service.dart';

import '../api/welfare_check_api.dart';
import '../models/welfare_check.dart';
import '../services/session_service.dart';
import 'package:intl/intl.dart';

class WelfareCheckScreen extends StatefulWidget {
  const WelfareCheckScreen({super.key});

  @override
  State<WelfareCheckScreen> createState() => _WelfareCheckScreenState();
}

class _WelfareCheckScreenState extends State<WelfareCheckScreen> with SingleTickerProviderStateMixin {
  bool? _isSafe; // null = not selected, true = safe, false = need help
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final WelfareCheckService _service = WelfareCheckService();
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  Map<String, dynamic>? _submittedData; 

  // Emergency state
  List<dynamic> _activeEmergencies = [];
  bool _loadingEmergencies = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _safeCardScale;
  late Animation<double> _helpCardScale;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _safeCardScale = Tween<double>(begin: 1.0, end: 1.05).animate(_animController);
    _helpCardScale = Tween<double>(begin: 1.0, end: 1.05).animate(_animController);
  }

  Future<void> _initializeScreen() async {
    await _fetchActiveEmergencies(checkSubmission: true);
  }

  Future<void> _fetchActiveEmergencies({bool checkSubmission = false}) async {
    setState(() {
      _loadingEmergencies = true;
      _errorMessage = null;
    });
    List<dynamic> emergencies = [];
    try {
      emergencies = await WelfareCheckApi.fetchActiveEmergencies()
          .timeout(const Duration(seconds: 10));
      print('[WelfareCheck] Fetched emergencies: ' + emergencies.toString());
      setState(() {
        _activeEmergencies = emergencies;
        _loadingEmergencies = false;
      });
    } catch (e) {
      print('[WelfareCheck] Error fetching emergencies: ' + e.toString());
      setState(() {
        _activeEmergencies = [];
        _loadingEmergencies = false;
        _errorMessage = 'Failed to load emergencies. Please check your connection.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load emergencies. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (checkSubmission && emergencies.isNotEmpty) {
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        try {
          final hasSubmitted = await _service.hasSubmittedWelfareCheck(
            user.userId,
            emergencies[0]['emergency_id'] ?? 0,
          );
          print('[WelfareCheck] Has submitted: ' + hasSubmitted.toString());
          if (hasSubmitted) {
            final submission = await _service.getUserWelfareCheck(
              user.userId,
              emergencies[0]['emergency_id'] ?? 0,
            );
            print('[WelfareCheck] User submission: ' + submission.toString());
            setState(() {
              _hasSubmitted = true;
              _submittedData = submission;
            });
          } else {
            setState(() {
              _hasSubmitted = false;
              _submittedData = null;
            });
          }
        } catch (e) {
          print('[WelfareCheck] Error checking submission: ' + e.toString());
          setState(() {
            _hasSubmitted = false;
            _submittedData = null;
          });
        }
      } else {
        print('[WelfareCheck] No user found');
        setState(() {
          _hasSubmitted = false;
          _submittedData = null;
        });
      }
    } else if (checkSubmission && emergencies.isEmpty) {
      print('[WelfareCheck] No emergencies found');
      setState(() {
        _hasSubmitted = false;
        _submittedData = null;
      });
    }
  }

  @override
  void dispose() {
    _infoController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('MMMM d, y hh:mm a').format(date); // e.g., April 27, 2024 02:35 PM
    } catch (e) {
      return dateStr.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingEmergencies)
                const Center(child: CircularProgressIndicator()),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (!_loadingEmergencies && _activeEmergencies.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 72, color: Colors.green[600]),
                        const SizedBox(height: 24),
                        Text(
                          'No Active Emergencies',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You are safe. If an emergency occurs, you can update your status here.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: _fetchActiveEmergencies,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Refresh', style: TextStyle(fontSize: 17, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_loadingEmergencies && _activeEmergencies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.warning, color: Colors.red, size: 32),
                          ),
                          title: Text(
                            (_activeEmergencies[0]['emergency_type'] ?? 'EMERGENCY').toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.red),
                        ..._activeEmergencies.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['emergency_type'] != null ? e['emergency_type'].toString() : 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                              ),
                              if (e['description'] != null && e['description'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(e['description'].toString(), style: const TextStyle(fontSize: 15)),
                                ),
                              if (e['triggered_at'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Created at :  ${_formatDate(e['triggered_at'])} ',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              if (_hasSubmitted && _submittedData != null)
                _buildSubmittedInfo()
              else if (_activeEmergencies.isNotEmpty && !_loadingEmergencies) ...[
                // Status Selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Update Your Status',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // I'm Safe Card
                    Expanded(
                      child: AnimatedScale(
                        scale: _isSafe == true ? 1.07 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: GestureDetector(
                          onTap: () => setState(() => _isSafe = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _isSafe == true ? Colors.green[50] : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _isSafe == true ? Colors.green : Colors.grey[300]!,
                                width: 2.2,
                              ),
                              boxShadow: _isSafe == true
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.13),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700], size: 50),
                                const SizedBox(height: 12),
                                Text(
                                  "I'm Safe",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: _isSafe == true ? Colors.green[900] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "I am in a safe location and don't need assistance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Need Help Card
                    Expanded(
                      child: AnimatedScale(
                        scale: _isSafe == false ? 1.07 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: GestureDetector(
                          onTap: () => setState(() => _isSafe = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _isSafe == false ? Colors.red[50] : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _isSafe == false ? Colors.red : Colors.grey[300]!,
                                width: 2.2,
                              ),
                              boxShadow: _isSafe == false
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.13),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red[700], size: 50),
                                const SizedBox(height: 12),
                                Text(
                                  "Need Help",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                    color: _isSafe == false ? Colors.red[900] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "I need assistance or am in an unsafe situation",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                // Additional Info
                Text(
                  'Additional Information (Optional)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _infoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Please provide any additional details about your situation...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSafe == null || _isSubmitting || _hasSubmitted ? null : () async {
                      setState(() => _isSubmitting = true);
                      final user = await SessionService.getCurrentUser();
                      if (user == null) {
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (_activeEmergencies.isEmpty) {
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No active emergency selected.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final check = WelfareCheck(
                        userId: user.userId,
                        emergencyId: _activeEmergencies[0]['emergency_id'] ?? 0,
                        status: _isSafe == true ? 'SAFE' : 'NEEDS_HELP',
                        remarks: _infoController.text.isNotEmpty ? _infoController.text : null,
                      );
                      try {
                        final result = await _service.submitWelfareCheck(check.toApiJson());
                        print('[WelfareCheck] Submit result: ' + result.toString());
                        final success = result['success'] == true;
                        final message = result['message'] ?? '';
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                        if (success) {
                          setState(() {
                            _hasSubmitted = true;
                            _submittedData = {
                              'status': check.status,
                              'remarks': check.remarks ?? '',
                            };
                            _isSafe = null;
                            _infoController.clear();
                          });
                        }
                      } catch (e) {
                        print('[WelfareCheck] Error submitting: ' + e.toString());
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Response',
                      style: const TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.blue[200],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedInfo() {
    final status = _submittedData != null && _submittedData!['status'] != null ? _submittedData!['status'].toString() : '';
    final remarks = _submittedData != null && _submittedData!['remarks'] != null ? _submittedData!['remarks'].toString() : '';
    final reportedAt = _submittedData != null && _submittedData!['reported_at'] != null ? _submittedData!['reported_at'].toString() : null;
    String formattedDate = '';
    if (reportedAt != null && reportedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(reportedAt);
        formattedDate = 'Submitted on: ' + DateFormat('MMMM d, y h:mm a').format(date);
      } catch (_) {
        formattedDate = '';
      }
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
        child: Card(
          color: const Color(0xFFDFF6DD), // light green
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047), // green
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Response Submitted',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.green[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have already submitted your status for this emergency:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9), // green-tinted row
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.green)),
                      const SizedBox(width: 8),
                      Text(
                        status == 'SAFE' ? 'Safe' : (status == 'NEEDS_HELP' ? 'Needs Help' : status),
                        style: TextStyle(fontSize: 17, color: status == 'SAFE' ? Colors.green[900] : Colors.red[900], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (remarks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Text(
                      remarks,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}



