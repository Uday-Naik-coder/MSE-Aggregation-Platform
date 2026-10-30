import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../services/api_service.dart';

final adminDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  final client = ref.read(apiClientProvider);
  return ApiService(client).getAdminDashboard();
});
