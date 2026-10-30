import 'user_model.dart';
import 'order_model.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String mseId;
  final String adminId;
  final int    timelinessScore;
  final int    qualityScore;
  final int?   communicationScore;
  final double overallRating;
  final String? comment;
  final DateTime createdAt;

  // Populated references
  final OrderModel? order;
  final UserModel?  mse;

  const RatingModel({
    required this.id,
    required this.orderId,
    required this.mseId,
    required this.adminId,
    required this.timelinessScore,
    required this.qualityScore,
    this.communicationScore,
    required this.overallRating,
    this.comment,
    required this.createdAt,
    this.order,
    this.mse,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    final orderData = json['orderId'];
    final mseData   = json['mseId'];
    return RatingModel(
      id:                 json['_id']?.toString() ?? '',
      orderId:            orderData is Map ? orderData['_id']?.toString() ?? '' : orderData?.toString() ?? '',
      mseId:              mseData   is Map ? mseData['_id']?.toString()   ?? '' : mseData?.toString()   ?? '',
      adminId:            json['adminId']?.toString() ?? '',
      timelinessScore:    (json['timelinessScore']    as num?)?.toInt()    ?? 0,
      qualityScore:       (json['qualityScore']       as num?)?.toInt()    ?? 0,
      communicationScore: (json['communicationScore'] as num?)?.toInt(),
      overallRating:      (json['overallRating']      as num?)?.toDouble() ?? 0,
      comment:            json['comment'] as String?,
      createdAt:          json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      order: orderData is Map ? OrderModel.fromJson(orderData as Map<String, dynamic>) : null,
      mse:   mseData   is Map ? UserModel.fromJson(mseData   as Map<String, dynamic>) : null,
    );
  }
}
