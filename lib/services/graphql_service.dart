import 'package:graphql_flutter/graphql_flutter.dart';

import '../config.dart';

class GraphQLService {
  static GraphQLClient client(String? token) {
    final HttpLink httpLink = HttpLink(
      Config.getGraphqlUrl(),
      defaultHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    return GraphQLClient(link: httpLink, cache: GraphQLCache());
  }
}
