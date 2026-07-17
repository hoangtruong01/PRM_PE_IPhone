// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/equipment/presentation/pages/equipment_catalogue_page.dart';
import '../features/equipment/presentation/pages/equipment_detail_page.dart';
import '../features/loan_request/presentation/pages/loan_request_page.dart';
import '../features/loan_request/presentation/pages/request_result_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'catalogue',
        builder: (context, state) => const EquipmentCataloguePage(),
      ),
      GoRoute(
        path: '/device/:id',
        name: 'device-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EquipmentDetailPage(deviceId: id);
        },
      ),
      GoRoute(
        path: '/loan-request/:deviceId',
        name: 'loan-request',
        builder: (context, state) {
          final deviceId = state.pathParameters['deviceId']!;
          return LoanRequestPage(deviceId: deviceId);
        },
      ),
      GoRoute(
        path: '/request-result',
        name: 'request-result',
        builder: (context, state) {
          final resultData = state.extra as Map<String, dynamic>;
          return RequestResultPage(resultData: resultData);
        },
      ),
    ],
  );
});
