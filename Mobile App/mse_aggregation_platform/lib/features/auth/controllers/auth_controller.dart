import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

// Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // Initialize the Dio client (cookie jar) first
    await ref.read(apiClientProvider).initialize();
    // Then try to restore session
    return await ref.read(authServiceProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).login(email, password);
      await SecureStorage().saveUserMeta(
        id: user.id, role: user.role, name: user.name,
      );
      return user;
    });
  }

  Future<void> register({
    required String name,
    required String businessName,
    required String registrationId,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    await ref.read(authServiceProvider).register(
      name: name, businessName: businessName,
      registrationId: registrationId, email: email, password: password,
    );
    // After registration: navigate to pending approval
    state = const AsyncData(null);
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    await SecureStorage().clear();
    state = const AsyncData(null);
  }

  UserModel? get currentUser => state.valueOrNull;
  bool get isAuthenticated => currentUser != null;
  String? get role => currentUser?.role;
}
