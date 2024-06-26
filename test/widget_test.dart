import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Sensor Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loadscreen.png'),
                fit: BoxFit.cover, // Ensures the image covers the entire screen
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter, // Align to the bottom center
            child: Padding(
              padding: const EdgeInsets.only(bottom: 215.0), // Padding from bottom
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  String temperature = '';
  String humidity = '';
  String motionStatus = 'No Motion Detected';
  String soundStatus = 'No Sound Detected';
  bool soundDetected = false;
  late DateTime soundDetectedTime;

  @override
  void initState() {
    super.initState();
    // Replace IP and port with your ESP8266 WebSocket server details
    channel = WebSocketChannel.connect(
      Uri.parse('ws://172.20.10.5:81'),
    );

    channel.stream.listen((data) {
      final sensorData = jsonDecode(data);
      setState(() {
        temperature = sensorData['temperature'].toString();
        humidity = sensorData['humidity'].toString();

        bool motionValue = sensorData['motion'] == true;
        motionStatus = motionValue ? 'Motion Detected' : 'No Motion Detected';

        if (sensorData['sound'] == 'Sound Detected') {
          soundDetected = true;
          soundDetectedTime = DateTime.now();
        }

        if (soundDetected && DateTime.now().difference(soundDetectedTime).inSeconds <= 10) {
          soundStatus = 'Sound Detected';
        } else {
          soundDetected = false;
          soundStatus = 'No Sound Detected';
        }
      });
    }, onError: (error) {
      setState(() {
        print('Error: $error');
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Widget buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.7), // Translucent color
      shape: CircleBorder(), // Circular shape
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value == 'No Motion Detected' || value == 'No Sound Detected' ? 0.0 : 1.0,
                  color: color,
                  backgroundColor: Colors.grey[200],
                  strokeWidth: 10,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 14), // Smaller text size
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 12), // Smaller text size
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircularIndicator(String title, String value, IconData icon, double percentage, Color color) {
    return Card(
      color: color.withOpacity(0.7), // Translucent color
      shape: CircleBorder(), // Circular shape
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  color: color,
                  backgroundColor: Colors.grey[200],
                  strokeWidth: 10,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double tempValue = double.tryParse(temperature) ?? 0.0;
    double humValue = double.tryParse(humidity) ?? 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend background behind AppBar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0, // Remove shadow below AppBar
        backgroundColor: Colors.transparent, // Make AppBar transparent
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mainbg.png'),
            fit: BoxFit.fill, // Cover screen with image and adjust to fit screen size
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: buildCircularIndicator('Temperature', '$temperature°C', Icons.thermostat, tempValue, Colors.orange),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: buildCircularIndicator('Humidity', '$humidity%', Icons.water_drop, humValue, Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: buildSensorCard('Sound', soundStatus, Icons.volume_up, Colors.red),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: buildSensorCard('Motion', motionStatus, Icons.directions_run, Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 100),
                Align(
                  alignment: Alignment.center, // Align image to center
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/thermostat.png',
                              width: 30, // Smaller image size
                              height: 30, // Smaller image size
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 100),
                            Image.asset(
                              'assets/water.png',
                              width: 30, // Smaller image size
                              height: 30, // Smaller image size
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/audio.png',
                              width: 30, // Smaller image size
                              height: 30, // Smaller image size
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 100), // Spacing between icons
                            Image.asset(
                              'assets/motion.png',
                              width: 30, // Smaller image size
                              height: 30, // Smaller image size
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
