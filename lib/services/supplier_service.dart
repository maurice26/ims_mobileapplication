import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class SupplierService {
  Future<QueryResult> getSuppliers(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql(r'''
          query {
            suppliers {
              supplierId
              name
              contactInfo
            }
          }
        '''),
      ),
    );
  }

  Future<QueryResult> createSupplier(
    String token,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateSupplier($input: SupplierInput!) {
            createSupplier(input: $input) {
              supplierId
              name
              contactInfo
            }
          }
        '''),
        variables: {'input': input},
      ),
    );
  }

  Future<QueryResult> updateSupplier(
    String token,
    int supplierId,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
        mutation UpdateSupplier($input: UpdateSupplierInput!) {
          updateSupplier(input: $input) {
            supplierId
            name
            contactInfo
          }
        }
      '''),
        variables: {
          'input': {
            'supplierId': supplierId, // moved inside input
            'name': input['name'],
            'contactInfo': input['contactInfo'],
          },
        },
      ),
    );
  }

  Future<QueryResult> deleteSupplier(String token, int supplierId) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation DeleteSupplier($supplierId: Int!) {
            deleteSupplier(supplierId: $supplierId)
          }
        '''),
        variables: {'supplierId': supplierId},
      ),
    );
  }
}
