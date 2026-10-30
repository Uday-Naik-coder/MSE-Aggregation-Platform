import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/selection_model.dart';
import '../models/rating_model.dart';
import '../models/user_model.dart';

class ApiService {
  final ApiClient _client;
  ApiService(this._client);

  // ── ADMIN ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _client.get(ApiConstants.adminDashboard);
    ApiClient.checkResponse(res);
    return res.data as Map<String, dynamic>;
  }

  Future<List<OrderModel>> getAdminOrders() async {
    final res = await _client.get(ApiConstants.adminOrders);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> body) async {
    final res = await _client.post(ApiConstants.adminOrders, data: body);
    ApiClient.checkResponse(res);
    return OrderModel.fromJson(res.data['order'] as Map<String, dynamic>);
  }

  Future<List<UserModel>> getPendingMses() async {
    final res = await _client.get(ApiConstants.adminPendingMses);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveMse(String id) async {
    final res = await _client.patch(ApiConstants.adminApproveMse(id));
    ApiClient.checkResponse(res);
  }

  Future<List<SelectionModel>> getPendingSelections() async {
    final res = await _client.get(ApiConstants.adminPendingSelections);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => SelectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveSelection(String id) async {
    final res = await _client.patch(ApiConstants.adminApproveSelection(id));
    ApiClient.checkResponse(res);
  }

  Future<void> rejectSelection(String id) async {
    final res = await _client.patch(ApiConstants.adminRejectSelection(id));
    ApiClient.checkResponse(res);
  }

  Future<List<SelectionModel>> getCompletedSelections() async {
    final res = await _client.get(ApiConstants.adminCompletedSelections);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => SelectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RatingModel> submitRating(Map<String, dynamic> body) async {
    final res = await _client.post(ApiConstants.adminRatings, data: body);
    ApiClient.checkResponse(res);
    return RatingModel.fromJson(res.data['rating'] as Map<String, dynamic>);
  }

  Future<List<RatingModel>> getAdminRatings() async {
    final res = await _client.get(ApiConstants.adminRatings);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => RatingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── MSE ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMseDashboard() async {
    final res = await _client.get(ApiConstants.mseDashboard);
    ApiClient.checkResponse(res);
    return res.data as Map<String, dynamic>;
  }

  Future<List<OrderModel>> getOpenOrders() async {
    final res = await _client.get(ApiConstants.mseOrders);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getMseOrderDetail(String id) async {
    final res = await _client.get(ApiConstants.mseOrderDetail(id));
    ApiClient.checkResponse(res);
    return OrderModel.fromJson(res.data['order'] as Map<String, dynamic>);
  }

  Future<SelectionModel> submitSelection(String orderId, int quantity) async {
    final res = await _client.post(ApiConstants.mseSelections,
        data: {'orderId': orderId, 'selectedQuantity': quantity});
    ApiClient.checkResponse(res);
    return SelectionModel.fromJson(res.data['selection'] as Map<String, dynamic>);
  }

  Future<List<SelectionModel>> getMySelections() async {
    final res = await _client.get(ApiConstants.mseSelections);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => SelectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SelectionModel> completeSelection(String id) async {
    final res = await _client.patch(ApiConstants.mseCompleteSelection(id));
    ApiClient.checkResponse(res);
    return SelectionModel.fromJson(res.data['selection'] as Map<String, dynamic>);
  }

  Future<List<RatingModel>> getMyRatings() async {
    final res = await _client.get(ApiConstants.mseRatings);
    ApiClient.checkResponse(res);
    return (res.data as List).map((e) => RatingModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
