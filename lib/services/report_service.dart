import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../config.dart';
import 'graphql_service.dart';
import 'api_service.dart';

class ReportService {
  Future<QueryResult> getReport(String token, String type) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql('''
          query GetReport(\$type: String!) {
            report(type: \$type) {
              type
              period
              data
              totalSales
              totalRevenue
            }
          }
        '''),
        variables: {'type': type},
      ),
    );
  }

  Future<Uint8List> downloadReport(
    String token,
    String type,
    String format,
  ) async {
    final response = await ApiService.instance.get(
      '/api/reports/$type.$format',
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data;
  }
}
