import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketJsonViewer extends StatefulWidget {
  const SocketJsonViewer({Key? key}) : super(key: key);

  @override
  State<SocketJsonViewer> createState() => _SocketJsonViewerState();
}

class _SocketJsonViewerState extends State<SocketJsonViewer> {
  late IO.Socket socket;
  bool isConnected = false;
  List<JsonData> jsonLogs = [];

  final String userId = '6713653b613cf2d2c532ed0e';
  final String deviceId = "2707";
  final Map<String, String> credentials = {
    "username": "hansagroup",
    "password": "123456",
  };

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io(
        'http://63.142.251.13:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.onConnect((_) {
      setState(() {
        isConnected = true;
      });
    });

    socket.onDisconnect((_) {
      setState(() {
        isConnected = false;
      });
    });

    // Listen for single device data
    socket.on('single device data', (data) {
      _addJsonLog('Single Device Data', data);
    });

    // Listen for all device data
    socket.on('all device data', (data) {
      _addJsonLog('All Devices Data', data);
    });

    // Listen for alerts
    socket.on('alert', (data) {
      _addJsonLog('Alert', data);
    });
  }

  void _addJsonLog(String eventName, dynamic data) {
    try {
      // Convert the data to a properly formatted JSON string
      var jsonData = data is String ? json.decode(data) : data;
      var prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);

      setState(() {
        jsonLogs.insert(
          0,
          JsonData(
            eventName: eventName,
            timestamp: DateTime.now(),
            rawData: jsonData,
            prettyData: prettyJson,
          ),
        );
      });
    } catch (e) {
      print('Error parsing JSON: $e');
      setState(() {
        jsonLogs.insert(
          0,
          JsonData(
            eventName: eventName,
            timestamp: DateTime.now(),
            rawData: data,
            prettyData: data.toString(),
            isError: true,
          ),
        );
      });
    }
  }

  void handleConnectSingle() {
    socket.emit("deviceId", deviceId);
  }

  void handleConnectAll() {
    socket.emit("credentials", credentials);
  }

  void handleConnectSingleDeviceId() {
    socket.emit('registerUser', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket JSON Viewer'),
        actions: [
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: handleConnectSingle,
                  child: const Text('Connect Single'),
                ),
                ElevatedButton(
                  onPressed: handleConnectAll,
                  child: const Text('Connect All'),
                ),
                ElevatedButton(
                  onPressed: handleConnectSingleDeviceId,
                  child: const Text('Connect Device ID'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      jsonLogs.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: jsonLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No data received yet.\nTry connecting to a device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: jsonLogs.length,
                    itemBuilder: (context, index) {
                      final log = jsonLogs[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                log.eventName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                              ),
                              trailing: log.isError
                                  ? const Icon(Icons.error, color: Colors.red)
                                  : null,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              child: SelectableText(
                                log.prettyData,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
}

class JsonData {
  final String eventName;
  final DateTime timestamp;
  final dynamic rawData;
  final String prettyData;
  final bool isError;

  JsonData({
    required this.eventName,
    required this.timestamp,
    required this.rawData,
    required this.prettyData,
    this.isError = false,
  });
}
