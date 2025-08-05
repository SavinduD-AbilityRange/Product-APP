import 'package:flutter/material.dart';
import '../services/http_api_service.dart';
import '../config/api_config.dart';

class BackendSetupPage extends StatefulWidget {
  const BackendSetupPage({super.key});

  @override
  State<BackendSetupPage> createState() => _BackendSetupPageState();
}

class _BackendSetupPageState extends State<BackendSetupPage> {
  final HttpApiService _httpService = HttpApiService();
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isConnected = false;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiConfig.baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend API Setup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'External Backend API Configuration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Configure your Flutter app to connect to your backend API:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Backend API URL',
                        hintText: 'http://localhost:8000/api',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected ? 'Connected' : 'Not Connected',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  _isLoading
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
                          Text('Testing...'),
                        ],
                      )
                      : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color:
                        _isConnected
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                  ),
                ),
              ),
            const Spacer(),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setup Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('1. Make sure your backend server is running'),
                    SizedBox(height: 4),
                    Text('2. Update the API URL in lib/config/api_config.dart'),
                    SizedBox(height: 4),
                    Text('3. Test the connection using the button above'),
                    SizedBox(height: 4),
                    Text(
                      '4. In product_table_page.dart, change _dataSource to "backend"',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Required API Endpoints:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• GET /api/health - Health check'),
                    Text('• GET /api/products - Get all products'),
                    Text('• POST /api/products - Create product'),
                    Text('• PUT /api/products/{id} - Update product'),
                    Text('• DELETE /api/products/{id} - Delete product'),
                    Text('• GET /api/categories - Get categories'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing connection to ${_urlController.text}...';
    });

    try {
      final isConnected = await _httpService.testConnection();
      setState(() {
        _isConnected = isConnected;
        _statusMessage =
            isConnected
                ? '✅ Successfully connected to your backend API!\n'
                    'Your Flutter app can now communicate with your backend.'
                : '❌ Failed to connect to your backend API.\n'
                    'Please check:\n'
                    '• Is your backend server running?\n'
                    '• Is the API URL correct?\n'
                    '• Are there any CORS issues?\n'
                    '• Does the /health endpoint exist?';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage =
            '❌ Connection error: $e\n\n'
            'Common solutions:\n'
            '• Check if your backend server is running\n'
            '• Verify the API URL is correct\n'
            '• Ensure CORS is configured for your frontend\n'
            '• Check your network connection';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
