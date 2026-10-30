class OrderModel {
  final String id;
  final String description;
  final int    totalQuantity;
  final double pricePerUnit;
  final DateTime deadline;
  final String status; // 'open' | 'allocating' | 'closed'
  final String createdBy;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.description,
    required this.totalQuantity,
    required this.pricePerUnit,
    required this.deadline,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isOpen       => status == 'open';
  bool get isExpired    => DateTime.now().isAfter(deadline);
  bool get isAvailable  => isOpen && !isExpired;

  double get totalValue => totalQuantity * pricePerUnit;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id:            json['_id']?.toString() ?? json['id']?.toString() ?? '',
      description:   json['description']  as String? ?? '',
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      pricePerUnit:  (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      deadline:      json['deadline'] != null
          ? DateTime.parse(json['deadline'].toString())
          : DateTime.now(),
      status:        json['status'] as String? ?? 'open',
      createdBy:     json['createdBy'] is Map
          ? (json['createdBy'] as Map)['_id']?.toString() ?? ''
          : json['createdBy']?.toString() ?? '',
      createdAt:     json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'description': description,
    'totalQuantity': totalQuantity, 'pricePerUnit': pricePerUnit,
    'deadline': deadline.toIso8601String(), 'status': status,
    'createdBy': createdBy, 'createdAt': createdAt.toIso8601String(),
  };
}
