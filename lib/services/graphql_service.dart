import 'package:graphql_flutter/graphql_flutter.dart';

import '../config.dart';

class GraphQLService {
  static GraphQLClient? _client;
  static String? _cachedToken;

  static const bool enableDebugLogging = false;

  static GraphQLClient client(String token) {
    // Only rebuild if token changed
    if (_client != null && _cachedToken == token) {
      return _client!;
    }

    _cachedToken = token;

    final url = Config.getGraphqlUrl();

    // ignore: avoid_print
    print('[GraphQLService] url=$url tokenPresent=${token.isNotEmpty}');

    final httpLink = HttpLink(
      url,
      defaultHeaders: {'Authorization': 'Bearer $token'},
    );

    final link = Link.from([
      _GraphQLErrorLogLink(),
      httpLink,
    ]);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,

      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );

    return _client!;
  }

  static void reset() {
    _client = null;
    _cachedToken = null;
  }
}

class _GraphQLErrorLogLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    if (forward == null) return const Stream.empty();

    return forward(request).map((response) {
      if (response.errors != null && response.errors!.isNotEmpty) {
        final operation = request.operation.operationName ?? 'anonymous';
        final messages = response.errors!.map((error) => error.message).join('; ');
        // ignore: avoid_print
        print('[GraphQLService] $operation failed: $messages');
      }
      return response;
    });
  }
}
