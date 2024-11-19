import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the API service

class QueryGeneratorScreen extends StatefulWidget {
  const QueryGeneratorScreen({super.key});

  @override
  _QueryGeneratorScreenState createState() => _QueryGeneratorScreenState();
}

class _QueryGeneratorScreenState extends State<QueryGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _generatedQuery = '';

  void _generateQuery() async {
    ApiService apiService = ApiService('http://10.0.2.2:5001/'); // Replace with your backend URL, e.g http://10.0.2.2:5001/ for virtual android simulator and http://192.168.0.8:5001 for my actual huawei
    try {
      final response = await apiService.generateQuery(_controller.text);
      setState(() {
        _generatedQuery = response.query;
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
          ],
        ),
      ),
    );
  }
}
