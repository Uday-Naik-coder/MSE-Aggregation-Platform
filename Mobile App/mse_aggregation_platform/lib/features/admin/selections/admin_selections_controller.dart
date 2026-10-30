import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/selection_model.dart';
import '../../../services/api_service.dart';

final pendingSelectionsProvider = FutureProvider.autoDispose<List<SelectionModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getPendingSelections();
});

final completedSelectionsProvider = FutureProvider.autoDispose<List<SelectionModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getCompletedSelections();
});
