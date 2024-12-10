import 'dart:async';
import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDashboardPage extends StatefulWidget {
  final String relativeName;

  const UserDashboardPage({Key? key, required this.relativeName}) : super(key: key);

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  double _heartRate = 0.0;
  double _oxygenLevel = 0.0;
  double _temperature = 0.0; // New variable for temperature
  late Timer _timer;
  bool _isLoading = true;
  bool _isPopupVisible = false;

  final double _heartRateThreshold = 100.0; // Example threshold for heart rate
  final double _oxygenLevelThreshold = 95.0; // Example threshold for oxygen level
  final double _temperatureThreshold = 38.0; // Example threshold for temperature

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
          _temperature = data['temperature'] ?? 0.0; // Update temperature data
          _isLoading = false;

          // Check for threshold conditions and show pop-up if necessary
          if (_heartRate > _heartRateThreshold || _heartRate < 60.0) {
            _showThresholdPopup('Heart Rate Alert', 'Heart rate is out of the safe range!');
          } else if (_oxygenLevel < _oxygenLevelThreshold) {
            _showThresholdPopup('Oxygen Level Alert', 'Oxygen level is below the safe range!');
          } else if (_temperature > _temperatureThreshold) {
            _showThresholdPopup('Temperature Alert', 'Temperature is above the safe range!');
          }
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to connect to the ESP8266: $e");
    }
  }

  // Show pop-up dialog for alerts
  void _showThresholdPopup(String title, String message) {
    if (!_isPopupVisible) {
      _isPopupVisible = true; // Set pop-up as visible

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Automatically close the pop-up after 2 seconds
      Future.delayed(Duration(seconds: 10), () {
        if (mounted) {
          Navigator.of(context).pop();
          _isPopupVisible = false; // Reset the pop-up visibility
        }
      });
    }
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
        backgroundColor: Colors.teal, // Custom color for the app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heart Rate Card
              Card(
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
                          Icon(Icons.favorite, color: Colors.red, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            'Heart Rate',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_heartRate bpm',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Oxygen Level Card
              Card(
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
                          Icon(Icons.air, color: Colors.blue, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            'Oxygen Level',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_oxygenLevel %',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Temperature Card
              Card(
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
                          Icon(Icons.thermostat, color: Colors.orange, size: 30),
                          const SizedBox(width: 10),
                          Text(
                            'Temperature',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_temperature °C',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
