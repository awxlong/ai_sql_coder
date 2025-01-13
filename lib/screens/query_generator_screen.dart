import 'package:flutter/material.dart';
import 'package:sql_ai_app/services/sql_database_existing.dart'; // Import Helper functions for SQL manipulation
import '../services/api_service.dart'; // Import the API service

class QueryGeneratorScreen extends StatefulWidget {
  const QueryGeneratorScreen({super.key});

  @override
  _QueryGeneratorScreenState createState() => _QueryGeneratorScreenState();
}

class _QueryGeneratorScreenState extends State<QueryGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _generatedQuery = '';
  List<Map<String, dynamic>> _queryResult = []; // For storing query from LLM
  
  String convertIlikeToLike(String query) {
  // Replace 'ilike' with 'LIKE' in the query
  return query.replaceAll(RegExp(r'\bilike\b', caseSensitive: false), 'LIKE');
}

  void _generateQuery() async {
    ApiService apiService = ApiService('http://192.168.0.2:5001'); // Replace with your backend URL, e.g 'http://localhost:5001' for Chrome web, http://10.0.2.2:5001/ for virtual android simulator and http://192.168.0.8:5001 or http://192.168.0.2:5001 for my actual huawei
    try {
      // Obtain response from LLM
      final response = await apiService.generateQuery(_controller.text);
      setState(() {
        _generatedQuery = response.query;
      });
      // Execute the query on the SQLite database
      SQLDatabaseExisting sqlDatabase = SQLDatabaseExisting();
      // sqlDatabase.debugTableNames(); // for debugging what tables are there in the .db created
      _generatedQuery = convertIlikeToLike(_generatedQuery); // Convert 'ilike' to 'LIKE' for SQLite
      List<Map<String, dynamic>> results = await sqlDatabase.executeQueryExisting(_generatedQuery);

      setState(() {
        _queryResult = results;// Future.value(result); // result as Future<List<Map<String, dynamic>>>;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Text2SQL Query Generator',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 217, 154, 154),
      elevation: 4,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Field
          TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'What is your query?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              maxLines: 3,
            ),
          const SizedBox(height: 20),

          // Generate Query Button
          ElevatedButton(
            onPressed: _generateQuery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Generate SQL Query',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Generated Query Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              'SQLite Query: $_generatedQuery',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Query Results
          Expanded(
            child: _queryResult.isEmpty
                ? const Center(
                    child: Text(
                      'No results to display.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _queryResult.length,
                    itemBuilder: (context, index) {
                      final row = _queryResult[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            'Answer ${index + 1}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            row.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}


}
