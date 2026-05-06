import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class SupplierService {
  Future<QueryResult> getSuppliers(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql('''
          query {
            suppliers {
              supplierId
              name
              contact
              products
            }
          }
        '''),
      ),
    );
  }
}
