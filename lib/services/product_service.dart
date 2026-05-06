import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class ProductService {
  Future<QueryResult> getProducts(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql('''
          query {
            products {
              productId
              name
              price
            }
          }
        '''),
      ),
    );
  }
}
