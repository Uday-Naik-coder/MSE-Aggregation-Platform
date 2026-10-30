import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';

final adminOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getAdminOrders();
});
