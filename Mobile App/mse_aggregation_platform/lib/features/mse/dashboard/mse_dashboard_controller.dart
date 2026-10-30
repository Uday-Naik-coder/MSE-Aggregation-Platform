import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../services/api_service.dart';

final mseDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getMseDashboard();
});
