class QueryResponse {
  final String query;

  QueryResponse({required this.query});

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    return QueryResponse(query: json['query']);
  }
}
