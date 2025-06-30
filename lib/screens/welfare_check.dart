import 'package:flutter/material.dart';

class WelfareCheckScreen extends StatefulWidget {
  const WelfareCheckScreen({super.key});

  @override
  State<WelfareCheckScreen> createState() => _WelfareCheckScreenState();
}

class _WelfareCheckScreenState extends State<WelfareCheckScreen> {
  bool? _isSafe; // null = not selected, true = safe, false = need help
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _infoController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      backgroundColor: Colors.grey[50],
      body: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white, size: 32),
                          const SizedBox(width: 10),
                          const Text(
                            'EARTHQUAKE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 1.2, 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'AaAaAaAaAa',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.info, color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Issued: June 6, 2025 2:48 pm',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Selection
                const Text(
                  'Please Update Your Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    // I'm Safe Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSafe = true),
                        child: Container(
                          height: 160,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _isSafe == true ? Colors.green[100] : Colors.white,
                            border: Border.all(
                              color: _isSafe == true ? Colors.green : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green, size: 48),
                              SizedBox(height: 10),
                              Text(
                                "I'm Safe",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(height: 4),
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
                    // Need Help Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSafe = false),
                        child: Container(
                          height: 160,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: _isSafe == false ? Colors.red[100] : Colors.white,
                            border: Border.all(
                              color: _isSafe == false ? Colors.red : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 10),
                              Text(
                                "Need Help",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(height: 4),
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
                  ],
                ),
                const SizedBox(height: 24),
                // Additional Info
                const Text(
                  'Additional Information (Optional)',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _infoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Please provide any additional details about your situation...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSafe == null ? null : () {
                      // Handle submit
                      // You can add your logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isSafe == true ? "Status: I'm Safe" : "Status: Need Help"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Submit Response', style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 