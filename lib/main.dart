import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      title: 'Cloudy',
      home: ColumnLayoutScreen(),
    ),
  );
}

class ColumnLayoutScreen extends StatelessWidget {
  const ColumnLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromARGB(255, 29, 212, 212),
        child: Column(children: <Widget>[
          SizedBox(
              height: 300,
              child: Center(
                  child: FutureBuilder<Weather>(
                      future: fetchWeather(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Weather> snapshot) {
                        return Scaffold(
                            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                            body: Center(
                                child: Text(
                                    "${snapshot.data?.temperature[0]}${snapshot.data?.unit}")));
                      }))),
          Expanded(
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                  child: Material(
                      color: Color.fromARGB(255, 241, 241, 241),
                      child: FutureBuilder<Weather>(
                        future: fetchWeather(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Weather> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.time.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      'Time: ${snapshot.data!.time[index]}'),
                                  subtitle: Text(
                                      'Temperature: ${snapshot.data!.temperature[index]} ${snapshot.data!.unit}'),
                                );
                              },
                            );
                          }
                        },
                      ))))
        ]));
  }
}

Future<Position> getPosition() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

Future<Weather> fetchWeather() async {
  Position position = await getPosition();
  double latitude = position.latitude;
  double longitude = position.longitude;

  final response = await http.get(Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weather_code'));

  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to contact server. Please try again later');
  }
}

class Weather {
  final List<String> time;
  final String unit;
  final List<double> temperature;
  final List<int> weatherCode;

  const Weather(
      {required this.time,
      required this.unit,
      required this.temperature,
      required this.weatherCode});

  factory Weather.fromJson(Map<String, dynamic> json) {
    var hourlyData = json['hourly'];
    var timeList = List<String>.from(hourlyData['time']);
    var temperatureList = List<double>.from(
        hourlyData['temperature_2m'].map((x) => x.toDouble()));
    var weatherCodeList =
        List<int>.from(hourlyData['weather_code'].map((x) => x.toInt()));
    var unitData = json['hourly_units'];
    var units = unitData['temperature_2m'].toString();
    return Weather(
      time: timeList,
      unit: units,
      temperature: temperatureList,
      weatherCode: weatherCodeList,
    );
  }
}
