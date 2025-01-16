import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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
  bool _isLoading = false; // Track loading state

  String convertIlikeToLike(String query) {
  // Replace 'ilike' with 'LIKE' in the query
  return query.replaceAll(RegExp(r'\bilike\b', caseSensitive: false), 'LIKE');
}

  void _generateQuery() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

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

      try {
      List<Map<String, dynamic>> results = await sqlDatabase.executeQueryExisting(_generatedQuery);
      setState(() {
        _queryResult = results;
      });
    } on DatabaseException catch (e) {
      // Handle database errors
      if (e.toString().contains('no such column')) {
        // Extract the missing column name from the error message
        final regex = RegExp(r"no such column: (\w+)");
        final match = regex.firstMatch(e.toString());
        final missingColumn = match?.group(1) ?? 'unknown';

        // Display an error message and set the result to "Not Applicable"
        setState(() {
          _queryResult = [{'error': 'Missing column: $missingColumn', 'answer': 'Not Applicable'}];
        });
      } else {
        // Handle other database errors
        setState(() {
          _queryResult = [{'error': 'Database error: ${e.toString()}', 'answer': 'Not Applicable'}];
        });
      }
    }
  } catch (e) {
    // Handle other errors (e.g., API errors)
    setState(() {
      _queryResult = [{'error': 'An error occurred: ${e.toString()}', 'answer': 'Not Applicable'}];
    });
  } finally {
    setState(() {
        _isLoading = false; // Hide loading indicator
      });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'InQuery: Text to SQL Generator',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 237, 161, 161),
      elevation: 4,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Field (Larger TextField)
          TextField(
            controller: _controller,
            maxLines: 2, // Allow multiple lines for longer queries
            decoration: InputDecoration(
              labelText: 'What is your query?',
              labelStyle: TextStyle(color: Colors.blue.shade800),
              alignLabelWithHint: true, // Align label with the top of the TextField
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Increased vertical padding
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Generate Query Button
          ElevatedButton(
            onPressed: _isLoading ? null : _generateQuery, // Disable button while loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Text(
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

          // Query Results (Expanded to take remaining space)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Text(
                      'Generating SQL query...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _queryResult.isEmpty
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
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _queryResult.length,
                        itemBuilder: (context, index) {
                          final row = _queryResult[index];
                          if (row.containsKey('error')) {
                            // Display error message and "No Answer"
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.red.shade50, // Light red background for errors
                              child: ListTile(
                                title: Text(
                                  'Error: ${row['error']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                subtitle: Text(
                                  'Answer: ${row['answer']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          } else {
                            // Display normal query results
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
                          }
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}

}
