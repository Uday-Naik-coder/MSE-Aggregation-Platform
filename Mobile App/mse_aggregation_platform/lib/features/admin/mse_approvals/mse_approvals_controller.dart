import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';

final pendingMsesProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getPendingMses();
});
