import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Not tested';
  String _envStatus = 'Not checked';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      // First test ping
      final pingSuccess = await ApiService.pingServer();
      if (pingSuccess) {
        setState(() {
          _status = 'Ping successful! Testing products endpoint...';
        });

        // Then test products endpoint
        final products = await ApiService.fetchProducts();
        setState(() {
          _status = 'Connection successful! Found ${products.length} products';
        });
      } else {
        setState(() {
          _status = 'Ping failed - server might be down or unreachable';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEnvironment() async {
    setState(() {
      _envStatus = 'Checking environment...';
    });

    try {
      final envData = await ApiService.checkEnvironment();
      if (envData != null) {
        setState(() {
          _envStatus = 'Environment check successful: ${envData.toString()}';
        });
      } else {
        setState(() {
          _envStatus = 'Environment check failed';
        });
      }
    } catch (e) {
      setState(() {
        _envStatus = 'Environment check error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: Colors.blue,
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
                      'Backend Connection Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _status.contains('successful')
                                ? Colors.green
                                : _status.contains('failed')
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Environment Check:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _envStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _envStatus.contains('successful')
                                ? Colors.green
                                : _envStatus.contains('failed')
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkEnvironment,
                    child: const Text('Check Environment'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Setup Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. Make sure your backend server is running on port 8001',
                    ),
                    Text('2. Verify these endpoints are accessible:'),
                    Text('   • GET /ping - Server health check'),
                    Text('   • GET /check-env - Environment info'),
                    Text('   • GET /products - List products'),
                    Text('   • POST /products - Create product'),
                    Text('   • PUT /products/{id} - Update product'),
                    Text('   • DELETE /products/{id} - Delete product'),
                    Text(
                      '3. For real devices, update the IP address in ApiConfig',
                    ),
                    Text('4. Ensure CORS is enabled on your backend'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
