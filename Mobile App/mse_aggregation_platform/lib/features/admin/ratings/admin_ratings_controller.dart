import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/rating_model.dart';
import '../../../services/api_service.dart';

final adminRatingsProvider = FutureProvider.autoDispose<List<RatingModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getAdminRatings();
});
