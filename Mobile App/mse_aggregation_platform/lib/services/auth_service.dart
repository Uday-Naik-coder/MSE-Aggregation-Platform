import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  Future<UserModel> login(String email, String password) async {
    final res = await _client.post(ApiConstants.login, data: {
      'email': email.trim(),
      'password': password,
    });
    ApiClient.checkResponse(res);
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  Future<void> register({
    required String name,
    required String businessName,
    required String registrationId,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(ApiConstants.register, data: {
      'name': name.trim(),
      'businessName': businessName.trim(),
      'registrationId': registrationId.trim(),
      'email': email.trim(),
      'password': password,
    });
    ApiClient.checkResponse(res);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
    await _client.clearCookies();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final res = await _client.get(ApiConstants.me);
      if (res.statusCode == 200 && res.data['user'] != null) {
        return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
