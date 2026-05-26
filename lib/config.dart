class Config {
  static const String _productionUrl =
      'https://inventorymanagementsystem-ybwm.onrender.com';
  static const String _graphqlPath = '/graphql';

  static String getApiUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _productionUrl;
  }

  static String getGraphqlUrl() => '${getApiUrl()}$_graphqlPath';
}
