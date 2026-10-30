import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/models/user_model.dart';
import 'package:mse_aggregation_platform/models/order_model.dart';
import 'package:mse_aggregation_platform/models/selection_model.dart';
import 'package:mse_aggregation_platform/models/rating_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        '_id': 'u123',
        'email': 'mse@test.com',
        'name': 'Test MSE',
        'role': 'mse',
        'businessName': 'Test Corp',
        'registrationId': 'REG-12345',
        'isApproved': true,
        'createdAt': '2026-09-01T10:00:00.000Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'u123');
      expect(user.email, 'mse@test.com');
      expect(user.isMse, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isApproved, isTrue);
      expect(user.businessName, 'Test Corp');
      expect(user.registrationId, 'REG-12345');

      final serialized = user.toJson();
      expect(serialized['id'], 'u123');
      expect(serialized['email'], 'mse@test.com');
      expect(serialized['isApproved'], isTrue);
    });

    test('copyWith updates fields correctly', () {
      final user = UserModel(
        id: '1',
        email: 'admin@mse.org',
        name: 'Admin',
        role: 'admin',
        isApproved: true,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(user.isAdmin, isTrue);

      final updated = user.copyWith(name: 'Super Admin');
      expect(updated.name, 'Super Admin');
      expect(updated.email, 'admin@mse.org');
    });
  });

  group('OrderModel', () {
    test('fromJson computes status and value correctly', () {
      final deadline = DateTime.now().add(const Duration(days: 3));
      final json = {
        '_id': 'o456',
        'description': 'Supply 1000 Cotton Bags',
        'totalQuantity': 1000,
        'pricePerUnit': 15.50,
        'deadline': deadline.toIso8601String(),
        'status': 'open',
        'createdBy': 'uAdmin',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, 'o456');
      expect(order.totalQuantity, 1000);
      expect(order.pricePerUnit, 15.50);
      expect(order.totalValue, 15500.0);
      expect(order.isOpen, isTrue);
      expect(order.isExpired, isFalse);
      expect(order.isAvailable, isTrue);
    });

    test('expired order is not available', () {
      final pastDeadline = DateTime.now().subtract(const Duration(days: 1));
      final json = {
        '_id': 'o789',
        'description': 'Old Order',
        'totalQuantity': 500,
        'pricePerUnit': 10.0,
        'deadline': pastDeadline.toIso8601String(),
        'status': 'open',
        'createdBy': 'uAdmin',
      };
      final order = OrderModel.fromJson(json);
      expect(order.isExpired, isTrue);
      expect(order.isAvailable, isFalse);
    });
  });

  group('SelectionModel', () {
    test('parses populated order and mse objects', () {
      final json = {
        '_id': 'sel001',
        'orderId': {
          '_id': 'ord100',
          'description': 'Paper boxes',
          'totalQuantity': 500,
          'pricePerUnit': 2.5,
          'status': 'open',
        },
        'mseId': {
          '_id': 'mse200',
          'email': 'boxmaker@mse.org',
          'name': 'Box Maker',
          'role': 'mse',
          'isApproved': true,
        },
        'selectedQuantity': 250,
        'status': 'pending',
      };

      final selection = SelectionModel.fromJson(json);
      expect(selection.id, 'sel001');
      expect(selection.orderId, 'ord100');
      expect(selection.mseId, 'mse200');
      expect(selection.selectedQuantity, 250);
      expect(selection.isPending, isTrue);
      expect(selection.order?.description, 'Paper boxes');
      expect(selection.mse?.name, 'Box Maker');
    });

    test('parses unpopulated string IDs gracefully', () {
      final json = {
        '_id': 'sel002',
        'orderId': 'ord100',
        'mseId': 'mse200',
        'selectedQuantity': 100,
        'status': 'approved',
      };

      final selection = SelectionModel.fromJson(json);
      expect(selection.orderId, 'ord100');
      expect(selection.mseId, 'mse200');
      expect(selection.order, isNull);
      expect(selection.mse, isNull);
      expect(selection.isApproved, isTrue);
    });
  });

  group('RatingModel', () {
    test('fromJson computes overall rating and scores', () {
      final json = {
        '_id': 'rat001',
        'orderId': 'ord100',
        'mseId': 'mse200',
        'adminId': 'adm001',
        'timelinessScore': 5,
        'qualityScore': 4,
        'communicationScore': 5,
        'overallRating': 4.67,
        'comment': 'Exceptional delivery speed',
      };

      final rating = RatingModel.fromJson(json);
      expect(rating.id, 'rat001');
      expect(rating.timelinessScore, 5);
      expect(rating.qualityScore, 4);
      expect(rating.communicationScore, 5);
      expect(rating.overallRating, 4.67);
      expect(rating.comment, 'Exceptional delivery speed');
    });
  });
}
