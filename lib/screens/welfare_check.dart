import 'package:flutter/material.dart';
import '../services/welfare_check_service.dart';

import '../api/welfare_check_api.dart';
import '../models/welfare_check.dart';
import '../services/session_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loadingEmergencies)
              const Center(child: CircularProgressIndicator()),
            if (!_loadingEmergencies && _activeEmergencies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  color: Colors.red[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: Text(
                          (_activeEmergencies[0]['emergency_type'] ?? 'EMERGENCY').toString().toUpperCase(),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.red),
                      ..._activeEmergencies.map((e) => ListTile(
                        title: Text(
                          e['emergency_type'] != null ? e['emergency_type'].toString() : 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (e['description'] != null && e['description'].toString().isNotEmpty)
                              Text(e['description'].toString()),
                            if (e['triggered_at'] != null)
                              Text('Started: ${e['triggered_at']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.priority_high, color: Colors.red),
                      )),
                    ],
                  ),
                ),
              ),
            if (_hasSubmitted && _submittedData != null)
              _buildSubmittedInfo()
            else ...[
              // Status Selection
              const Text(
                'Please Update Your Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  // I'm Safe Card
                  Expanded(
                    child: AnimatedScale(
                      scale: _isSafe == true ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => setState(() => _isSafe = true),
                        child: Card(
                          elevation: _isSafe == true ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _isSafe == true ? Colors.green : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          color: _isSafe == true ? Colors.green[50] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700], size: 48),
                                const SizedBox(height: 10),
                                Text(
                                  "I'm Safe",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
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
                  ),
                  const SizedBox(width: 12),
                  // Need Help Card
                  Expanded(
                    child: AnimatedScale(
                      scale: _isSafe == false ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => setState(() => _isSafe = false),
                        child: Card(
                          elevation: _isSafe == false ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _isSafe == false ? Colors.red : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          color: _isSafe == false ? Colors.red[50] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red[700], size: 48),
                                const SizedBox(height: 10),
                                Text(
                                  "Need Help",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
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
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Additional Info
              Text(
                'Additional Information (Optional)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.blueGrey[800], letterSpacing: 0.2),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _infoController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Please provide any additional details about your situation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSafe == null || _isSubmitting ? null : () async {
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Welfare Check Submission:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.blue[900], letterSpacing: 0.2),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  _submittedData!['status'] == 'SAFE' ? Icons.check_circle : Icons.error,
                  color: _submittedData!['status'] == 'SAFE' ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Status: ${_submittedData!['status'] == 'SAFE' ? "I'm Safe" : "Need Help"}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if ((_submittedData!['remarks'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Notes: ${_submittedData!['remarks']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



