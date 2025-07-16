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
    await _fetchActiveEmergencies();
    final user = await SessionService.getCurrentUser();
    if (user != null && _activeEmergencies.isNotEmpty) {
      final hasSubmitted = await _service.hasSubmittedWelfareCheck(
        user.userId,
        _activeEmergencies[0]['emergency_id'] ?? 0,
      );
      if (hasSubmitted) {
        setState(() {
          _hasSubmitted = true;
          // Optionally, fetch and display the actual submission data if needed
        });
      }
    }
  }

  Future<void> _fetchActiveEmergencies() async {
    setState(() => _loadingEmergencies = true);
    final emergencies = await WelfareCheckApi.fetchActiveEmergencies();
    setState(() {
      _activeEmergencies = emergencies;
      _loadingEmergencies = false;
    });
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
              else ...[
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
                      final result = await _service.submitWelfareCheck(check.toApiJson());
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
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _submittedData!['status'] == 'SAFE' ? Icons.check_circle : Icons.error,
                color: _submittedData!['status'] == 'SAFE' ? Colors.green : Colors.red,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Welfare Check Submission',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900], letterSpacing: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Status: ${_submittedData!['status'] == 'SAFE' ? "I'm Safe" : "Need Help"}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              if ((_submittedData!['remarks'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Notes: ${_submittedData!['remarks']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



