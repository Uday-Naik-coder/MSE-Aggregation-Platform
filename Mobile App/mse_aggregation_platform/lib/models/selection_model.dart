import 'user_model.dart';
import 'order_model.dart';

class SelectionModel {
  final String id;
  final String orderId;
  final String mseId;
  final int    selectedQuantity;
  final String status; // 'pending' | 'approved' | 'rejected' | 'completed'
  final DateTime? completedAt;
  final DateTime? adminApprovedAt;
  final DateTime  createdAt;

  // Populated references
  final OrderModel? order;
  final UserModel?  mse;

  const SelectionModel({
    required this.id,
    required this.orderId,
    required this.mseId,
    required this.selectedQuantity,
    required this.status,
    this.completedAt,
    this.adminApprovedAt,
    required this.createdAt,
    this.order,
    this.mse,
  });

  bool get isPending   => status == 'pending';
  bool get isApproved  => status == 'approved';
  bool get isRejected  => status == 'rejected';
  bool get isCompleted => status == 'completed';

  factory SelectionModel.fromJson(Map<String, dynamic> json) {
    // orderId might be a populated object or just an ID string
    final orderData = json['orderId'];
    final mseData   = json['mseId'];

    return SelectionModel(
      id:               json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderId:          orderData is Map ? orderData['_id']?.toString() ?? '' : orderData?.toString() ?? '',
      mseId:            mseData   is Map ? mseData['_id']?.toString()   ?? '' : mseData?.toString()   ?? '',
      selectedQuantity: (json['selectedQuantity'] as num?)?.toInt() ?? 0,
      status:           json['status'] as String? ?? 'pending',
      completedAt:      json['completedAt'] != null
          ? DateTime.parse(json['completedAt'].toString()) : null,
      adminApprovedAt:  json['adminApprovedAt'] != null
          ? DateTime.parse(json['adminApprovedAt'].toString()) : null,
      createdAt:        json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      order:  orderData is Map ? OrderModel.fromJson(orderData as Map<String, dynamic>) : null,
      mse:    mseData   is Map ? UserModel.fromJson(mseData   as Map<String, dynamic>) : null,
    );
  }
}
