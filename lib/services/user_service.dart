import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class UserService {
  Future<QueryResult> getUsers(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql(r'''
          query {
            users {
              userId
              name
              email
              role
            }
          }
        '''),
        // ✅ Always fetch fresh from network, not cache
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }

  Future<QueryResult> createUser(
    String token,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateUser($input: CreateUserInput!) {
            createUser(input: $input) {
              userId
              name
              email
              role
            }
          }
        '''),
        variables: {'input': input},
      ),
    );
  }

  Future<QueryResult> updateUser(
    String token,
    Map<String, dynamic> input,
  ) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateUser($input: UpdateUserInput!) {
            updateUser(input: $input) {
              userId
              name
              email
              role
            }
          }
        '''),
        variables: {'input': input},
      ),
    );
  }

  Future<QueryResult> deleteUser(String token, int userId) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation DeleteUser($userId: Int!) {
            deleteUser(userId: $userId)
          }
        '''),
        variables: {'userId': userId},
      ),
    );
  }
}
