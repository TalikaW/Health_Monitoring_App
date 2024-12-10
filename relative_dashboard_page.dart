import 'dart:async';
import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RelativeDashboardPage extends StatefulWidget {
  final String relativeName;

  const RelativeDashboardPage({Key? key, required this.relativeName}) : super(key: key);

  @override
  _RelativeDashboardPageState createState() => _RelativeDashboardPageState();
}

class _RelativeDashboardPageState extends State<RelativeDashboardPage> {
  double _heartRate = 0.0;
  double _oxygenLevel = 0.0;
  double _temperature = 0.0; // Temperature variable
  late Timer _timer;
  bool _isLoading = true;

  // Define threshold values
  final double _heartRateThreshold = 60.0;
  final double _oxygenLevelThreshold = 90.0;
  final double _temperatureThreshold = 38.0; // Example threshold for fever

  @override
  void initState() {
    super.initState();
    // Start the periodic timer to refresh every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      _fetchSensorData();
    });
  }

  // Fetch data from ESP8266
  Future<void> _fetchSensorData() async {
    try {
      // Replace with the IP address of your ESP8266
      var url = Uri.parse('http://192.168.137.248/');

      // Send GET request to the ESP8266
      var response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        var data = jsonDecode(response.body);
        setState(() {
          _heartRate = data['heart_rate'] ?? 0.0;
          _oxygenLevel = data['SpO2'] ?? 0.0;
          _temperature = data['temperature'] ?? 0.0; // Fetch temperature
          _isLoading = false;
        });

        // Check if any value exceeds the threshold and show an alert
        _checkThresholds();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to connect to the ESP8266: $e");
    }
  }

  // Check if any values exceed the defined thresholds
  void _checkThresholds() {
    if (_heartRate < _heartRateThreshold) {
      _showAlert('Low Heart Rate', 'Heart rate is too Low: $_heartRate bpm');
    } else if (_oxygenLevel < _oxygenLevelThreshold) {
      _showAlert('Low Oxygen Level', 'Oxygen level is too low: $_oxygenLevel%');
    } else if (_temperature > _temperatureThreshold) {
      _showAlert('High Temperature', 'Temperature is too high: $_temperature°C');
    }
  }

  // Show an alert popup with the given title and message
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.relativeName}'),
        backgroundColor: Colors.pinkAccent, // Light pink header
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.pink[200]!], // Light pink gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.pink, // Pink progress indicator
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heart Rate Card
              _buildCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title: 'Heart Rate',
                value: '$_heartRate bpm',
                valueColor: Colors.pinkAccent,
              ),
              const SizedBox(height: 20),
              // Oxygen Level Card
              _buildCard(
                icon: Icons.air,
                iconColor: Colors.blue,
                title: 'Oxygen Level',
                value: '$_oxygenLevel %',
                valueColor: Colors.pinkAccent,
              ),
              const SizedBox(height: 20),
              // Temperature Card
              _buildCard(
                icon: Icons.thermostat,
                iconColor: Colors.orange,
                title: 'Temperature',
                value: '$_temperature °C',
                valueColor: Colors.pinkAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
