import 'package:flutter/material.dart';
import 'package:sql_ai_app/services/sql_database.dart'; // Import Helper functions for SQL manipulation
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
  // late Future<List<Map<String, dynamic>>> _queryResult;
  
  void _generateQuery() async {
    ApiService apiService = ApiService('http://192.168.0.2:5001'); // Replace with your backend URL, e.g 'http://localhost:5001' for Chrome web, http://10.0.2.2:5001/ for virtual android simulator and http://192.168.0.8:5001 for my actual huawei
    try {
      // Obtain response from LLM
      final response = await apiService.generateQuery(_controller.text);
      setState(() {
        _generatedQuery = response.query;
      });
      // Initialize a database and execute query from LLM on SQLite database
      //final result = await executeQuery(_generatedQuery);
      List<Map<String, dynamic>> results = await executeQuery(_generatedQuery);
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
      appBar: AppBar(title: const Text('Consulta SQL automático')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Ingresa tu pregunta: '),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQuery,
              child: const Text('Generar consulta en SQL'),
            ),
            const SizedBox(height: 20),
            Text('Consulta generada: $_generatedQuery'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _queryResult.length,
                itemBuilder: (context, index) {
                  final row = _queryResult[index];
                  return ListTile(
                    title: Text('Respuesta: ${row.toString()}'), // Display each row as a string
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
