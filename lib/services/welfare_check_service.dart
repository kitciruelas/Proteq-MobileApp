import '../api/welfare_check_api.dart';

class WelfareCheckService {
  Future<Map<String, dynamic>> submitWelfareCheck(Map<String, dynamic> check) async {
    return await WelfareCheckApi.submitWelfareCheck(check);
  }

  Future<bool> hasSubmittedWelfareCheck(int userId, int emergencyId) async {
    return await WelfareCheckApi.hasSubmittedWelfareCheck(userId, emergencyId);
  }

  Future<Map<String, dynamic>?> getUserWelfareCheck(int userId, int emergencyId) async {
    return await WelfareCheckApi.getUserWelfareCheck(userId, emergencyId);
  }
}
