import 'dart:async';
import 'dart:convert';

import 'package:auto_irrigation/weather.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ESP32 WebSocket to Firestore',
      home: WebSocketFirebaseScreen(),
    );
  }
}

class WebSocketFirebaseScreen extends StatefulWidget {
  const WebSocketFirebaseScreen({super.key});

  @override
  State<WebSocketFirebaseScreen> createState() =>
      _WebSocketFirebaseScreenState();
}

class _WebSocketFirebaseScreenState extends State<WebSocketFirebaseScreen> {
  WebSocketChannel? _channel;
  final _esp32IpController = TextEditingController(text: 'ESP32_IP');

  String _receivedData = '';

  //database collection ka name n id
  final String firestoreCollection = 'data_collected';
  final String firestoreDocumentId = 'RM7vSjdLyJvMJa8uSLbh';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _connectWebSocket() {
    setState(() {
      _receivedData = 'Connecting...';
    });
    try {
      _channel?.sink.close();

      // Connect to ESP32 via WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${_esp32IpController.text}/ws'),
      );

      // receiving data
      _channel!.stream.listen(
        (data) {
          setState(() {
            _receivedData = data;
          });
          _storeDataInFirestore(data);
        },
        onError: (error) {
          setState(() {
            _receivedData = 'Error: $error';
          });
        },
        onDone: () {
          setState(() {
            _receivedData = 'WebSocket connection closed.';
          });
        },
      );
    } catch (e) {
      setState(() {
        _receivedData = 'Failed to connect: $e';
      });
    }
  }

  Future<void> _storeDataInFirestore(String data) async {
    try {
      // load incoming JSON string
      final parsedData = jsonDecode(data);

      // Extracting data
      final soilTemp = parsedData['soil_temp'];
      final moisture = parsedData['moisture'];
      final humidity = parsedData['humidity'];

      await _firestore
          .collection(firestoreCollection)
          .doc(firestoreDocumentId)
          .set({
            'soil_temp': soilTemp,
            'moisture': moisture,
            'humidity': humidity,
          }, SetOptions(merge: true));

      debugPrint('Data stored in Firestore: $parsedData');
    } catch (e) {
      debugPrint('Error storing data in Firestore: $e');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _esp32IpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ESP32 WebSocket to Firestore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ESP32 IP
            TextField(
              controller: _esp32IpController,
              decoration: const InputDecoration(
                labelText: 'ESP32 IP Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Connect Button
            ElevatedButton(
              onPressed: _connectWebSocket,
              child: const Text('Connect/Reconnect'),
            ),
            const SizedBox(height: 20),

            // Received Data Display
            const Text(
              'Received Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(_receivedData),
            ),
            SizedBox(height: 50),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeatherScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: 15,
                    horizontal: 100,
                  ),
                  shadowColor: Colors.black,
                  elevation: 5,
                ),
                child: Text('View weather'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
