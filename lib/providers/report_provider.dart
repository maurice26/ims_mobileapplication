import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import '../services/report_service.dart';
import 'auth_provider.dart';

final reportProvider = FutureProvider.family<Report, String>((ref, type) async {
  final authState = ref.read(authProvider); // ✅ fixed: watch → read
  final token = authState?.token;
  if (token == null) throw UnimplementedError('Report requires authentication');
  final service = ReportService();
  final result = await service.getReport(token, type);
  if (result.hasException) {
    throw result.exception!;
  }
  return Report.fromJson(result.data!['report']);
});
