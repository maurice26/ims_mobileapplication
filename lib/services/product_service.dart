import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class ProductService {
  // ================= GET PRODUCTS =================
  Future<QueryResult> getProducts(String token) async {
    final client = GraphQLService.client(token);

    return client.query(
      QueryOptions(
        document: gql(r'''
          query {
            products {
              productId
              name
              price
              stockQuantity
              categoryId
            }
          }
        '''),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }

  // ================= CREATE PRODUCT =================
  Future<QueryResult> createProduct(
    String token,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateProduct($input: CreateProductInput!) {
            createProduct(input: $input) {
              productId
              name
              price
              stockQuantity
              categoryId
            }
          }
        '''),
        variables: {
          'input': {
            'name': input['name'],
            'price': _toDouble(input['price']),
            'stockQuantity': _toInt(input['stockQuantity']),
            'categoryId': _toInt(input['categoryId'], fallback: 1),
          },
        },
      ),
    );

    _logError(result);
    return result;
  }

  // ================= UPDATE PRODUCT =================
  Future<QueryResult> updateProduct(
    String token,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateProduct($input: UpdateProductInput!) {
            updateProduct(input: $input) {
              productId
              name
              price
              stockQuantity
              categoryId
            }
          }
        '''),
        variables: {
          'input': {
            'productId': _toInt(input['productId']),
            'name': input['name'],
            'price': _toDouble(input['price']),
            'stockQuantity': _toInt(input['stockQuantity']),
            'categoryId': _toInt(input['categoryId'], fallback: 1),
          },
        },
      ),
    );

    _logError(result);
    return result;
  }

  // ================= DELETE PRODUCT =================
  Future<QueryResult> deleteProduct(String token, int productId) async {
    final client = GraphQLService.client(token);

    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation DeleteProduct($productId: Int!) {
            deleteProduct(productId: $productId)
          }
        '''),
        variables: {'productId': productId},
      ),
    );

    _logError(result);
    return result;
  }

  // ================= HELPERS =================
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    return (value as num).toInt();
  }

  void _logError(QueryResult result) {
    if (result.hasException) {
      // IMPORTANT: this is what caused your debugging confusion
      // Now you will see real GraphQL backend errors clearly
      print('GraphQL Error: ${result.exception}');
    }
  }
}
