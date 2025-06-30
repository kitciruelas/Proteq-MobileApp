import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Proteq API Connection Test ===\n');
  
  const String baseUrl = 'http://localhost/proteq-backend/api';
  
  // Test 1: Basic connectivity
  print('1. Testing basic connectivity...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/test.php'));
    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      print('   ✅ Basic connectivity: PASSED\n');
    } else {
      print('   ❌ Basic connectivity: FAILED\n');
    }
  } catch (e) {
    print('   ❌ Basic connectivity: FAILED - $e\n');
  }
  
  // Test 2: Diagnostic
  print('2. Running diagnostic...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/diagnostic.php'));
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('   Overall Status: ${data['overall_status']}');
      print('   Summary: ${data['summary']}');
      
      if (data['overall_status'] == 'success') {
        print('   ✅ Diagnostic: PASSED\n');
      } else {
        print('   ❌ Diagnostic: FAILED - Check the details above\n');
      }
    } else {
      print('   ❌ Diagnostic: FAILED - Status ${response.statusCode}\n');
    }
  } catch (e) {
    print('   ❌ Diagnostic: FAILED - $e\n');
  }
  
  // Test 3: Login endpoint (should return error for missing data)
  print('3. Testing login endpoint...');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    );
    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == false) {
        print('   ✅ Login endpoint: PASSED (correctly rejected invalid data)\n');
      } else {
        print('   ❌ Login endpoint: FAILED (should reject invalid data)\n');
      }
    } else {
      print('   ❌ Login endpoint: FAILED - Status ${response.statusCode}\n');
    }
  } catch (e) {
    print('   ❌ Login endpoint: FAILED - $e\n');
  }
  
  print('=== Test Complete ===');
  print('\nIf any tests failed, please:');
  print('1. Check that XAMPP is running (Apache + MySQL)');
  print('2. Verify database "proteq_db" exists and is imported');
  print('3. Ensure backend files are in C:\\xampp\\htdocs\\proteq-backend\\');
  print('4. Check the setup guide: BACKEND_SETUP_GUIDE.md');
} 