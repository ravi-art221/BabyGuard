import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
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
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 215.0),
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
  late IOWebSocketChannel channel;
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
    channel = IOWebSocketChannel.connect('ws://172.20.10.5:81');

    channel.stream.listen((data) {
      final sensorData = jsonDecode(data);
      setState(() {
        temperature = sensorData['temperature'].toString();
        humidity = sensorData['humidity'].toString();

        bool motionValue = sensorData['motion'];
        motionStatus = motionValue? 'Motion Detected' : 'No Motion Detected';

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
      print('Error: $error');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Widget buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.7),
      shape: CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value == 'No Motion Detected' || value == 'No Sound Detected'? 0.0 : 1.0,
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
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircularIndicator(String title, String value, IconData icon, double percentage, Color color) {
    return Card(
      color: color.withOpacity(0.7),
      shape: CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:<Widget>[
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mainbg.png'),
            fit: BoxFit.fill,
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                tempValue > 25? 'assets/thermostat_hot.png' : 'assets/thermostat_cold.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            tempValue > 25? 'Hot' : 'Normal',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                humValue > 70? 'assets/water_high.png' : 'assets/water_low.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Kelembapan: $humidity%',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                soundDetected? 'assets/audio_on.png' : 'assets/audio_off.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            soundDetected? 'Sound Detected' : 'No Sound Detected',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/motion.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            motionStatus,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
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