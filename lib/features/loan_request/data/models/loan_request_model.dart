// lib/features/loan_request/data/models/loan_request_model.dart

import 'dart:convert';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/loan_request_entity.dart';

/// Mô hình dữ liệu (Data Model) cho các yêu cầu mượn thiết bị.
/// Xử lý việc chuyển đổi qua lại JSON cho API và bộ nhớ cục bộ.
class LoanRequestModel {
  final String deviceId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String purpose;
  final double deposit;
  final String status;

  const LoanRequestModel({
    required this.deviceId,
    required this.studentId,
    required this.borrowDate,
    required this.returnDate,
    required this.purpose,
    required this.deposit,
    this.status = 'pending',
  });

  /// Tạo model từ thực thể Domain (Entity)
  factory LoanRequestModel.fromEntity(LoanRequestEntity entity) {
    return LoanRequestModel(
      deviceId: entity.deviceId,
      studentId: entity.studentId,
      borrowDate: entity.borrowDate,
      returnDate: entity.returnDate,
      purpose: entity.purpose,
      deposit: entity.deposit,
      status: entity.status,
    );
  }

  /// Chuyển đổi thành thực thể Domain (Entity)
  LoanRequestEntity toEntity() {
    return LoanRequestEntity(
      deviceId: deviceId,
      studentId: studentId,
      borrowDate: borrowDate,
      returnDate: returnDate,
      purpose: purpose,
      deposit: deposit,
      status: status,
    );
  }

  /// Chuyển đổi sang định dạng body của API POST khớp với yêu cầu đề thi:
  /// {
  ///   "name": "Campus Equipment Loan Request",
  ///   "data": {
  ///     "deviceId": "7",
  ///     "studentId": "SE1819",
  ///     "borrowDate": "2026-08-01",
  ///     "returnDate": "2026-08-07",
  ///     "purpose": "Mobile app demo",
  ///     "deposit": 50,
  ///     "status": "pending"
  ///   }
  /// }
  Map<String, dynamic> toApiJson({required String deviceName}) {
    return {
      'name': 'Campus Equipment Loan Request',
      'data': {
        'deviceId': deviceId,
        'studentId': studentId,
        'borrowDate': AppDateUtils.formatApi(borrowDate),
        'returnDate': AppDateUtils.formatApi(returnDate),
        'purpose': purpose,
        'deposit': deposit,
        'status': status,
        'deviceName': deviceName,
      },
    };
  }

  /// Chuyển đổi sang JSON để lưu trữ bản nháp cục bộ
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'studentId': studentId,
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'purpose': purpose,
      'deposit': deposit,
      'status': status,
    };
  }

  /// Tạo model từ JSON bản nháp cục bộ
  factory LoanRequestModel.fromJson(Map<String, dynamic> json) {
    return LoanRequestModel(
      deviceId: json['deviceId'] as String,
      studentId: json['studentId'] as String,
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      returnDate: DateTime.parse(json['returnDate'] as String),
      purpose: json['purpose'] as String,
      deposit: (json['deposit'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
    );
  }

  /// Chuyển đổi thành chuỗi JSON để lưu trữ
  String toJsonString() => json.encode(toJson());

  /// Tạo model từ chuỗi JSON
  factory LoanRequestModel.fromJsonString(String jsonString) {
    return LoanRequestModel.fromJson(json.decode(jsonString));
  }
}
