import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:adv_flutter_weather/flutter_weather_bg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(title: 'Cloudy', home: ColumnLayoutScreen()));
}

class WindMap extends StatefulWidget {
  const WindMap({Key? key}) : super(key: key);

  @override
  WindMapState createState() => WindMapState();
}

class WindMapState extends State<WindMap> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Location>(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot<Location> snapshot) {
          return Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: Column(children: [
                Text("Forecast", style: GoogleFonts.jost(fontSize: 30)),
                ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                        padding: const EdgeInsets.all(6),
                        color: const Color.fromARGB(255, 245, 249, 255),
                        child: Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(
                                            snapshot.data!.lat,
                                            snapshot.data!.long),
                                      ),
                                      children: [
                                        TileLayer(
                                            urlTemplate:
                                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                        MarkerLayer(markers: [
                                          Marker(
                                              point: LatLng(snapshot.data!.lat,
                                                  snapshot.data!.long),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white),
                                                  child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      0,
                                                                      145,
                                                                      255)))))
                                        ])
                                      ]))),
                          Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(children: [
                                Row(children: [
                                  const Icon(
                                    Icons.map_rounded,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                  Text("${snapshot.data!.city}")
                                ]),
                                Text("${snapshot.data!.country}")
                              ]))
                        ])))
              ]));
        });
  }
}

class ColumnLayoutScreen extends StatelessWidget {
  const ColumnLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Weather>(
        future: fetchWeather(),
        builder: (BuildContext context, AsyncSnapshot<Weather> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.red,
              child: Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: const Color.fromARGB(255, 0, 0, 0), size: 200),
              ),
            );
          } else if (snapshot.hasData) {
            DateTime now = DateTime.now();
            int currentHour = now.hour;
            int currentIndex = snapshot.data!.time.indexWhere((time) {
              DateTime dateTime = DateTime.parse(time);
              return dateTime.hour == currentHour;
            });
            return Stack(children: <Widget>[
              WeatherBg(
                  weatherType:
                      getBgOnWeather(snapshot.data!.weatherCode[currentIndex]),
                  width: MediaQuery.of(context).size.width,
                  height: 320),
              BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0))),
              Container(
                  color: const Color.fromARGB(0, 0, 0, 0),
                  child: Column(children: <Widget>[
                    SizedBox(
                        height: 300,
                        child: Center(
                            child: Scaffold(
                          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                          body: Center(
                              child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${snapshot.data?.temperature[currentIndex].toInt()}${snapshot.data?.unit[0]}",
                                  style: GoogleFonts.rubik(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 60,
                                      color: const Color.fromARGB(
                                          255, 50, 50, 50)),
                                ),
                                TextSpan(
                                  text: "${snapshot.data?.unit[1]}",
                                  style: GoogleFonts.rubik(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 30,
                                      color: const Color.fromARGB(
                                          255, 90, 90, 90)),
                                ),
                              ],
                            ),
                          )),
                        ))),
                    Expanded(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            child: Material(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: ListView.separated(
                                          itemCount:
                                              snapshot.data!.time.length ~/ 24,
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int dayIndex) =>
                                                  const SizedBox(width: 10),
                                          itemBuilder: (BuildContext context,
                                              int dayIndex) {
                                            if (dayIndex == 0) {
                                              return const WindMap();
                                            }
                                            return Column(children: [
                                              Text(
                                                  "${[
                                                    "Monday",
                                                    "Tuesday",
                                                    "Wednesday",
                                                    "Thursday",
                                                    "Friday",
                                                    "Saturday",
                                                    "Sunday"
                                                  ][DateTime.parse(snapshot.data!.time[dayIndex * 24]).weekday - 1]} ${DateTime.parse(snapshot.data!.time[dayIndex * 24]).day}.${DateTime.parse(snapshot.data!.time[dayIndex * 24]).month}.",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              50,
                                                              50,
                                                              50))),
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 10.0,
                                                      left: 10.0,
                                                      bottom: 8.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: const Color.fromARGB(
                                                        255, 242, 242, 242),
                                                  ),
                                                  height: 130,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: 24,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int hourIndex) {
                                                            int index =
                                                                dayIndex * 24 +
                                                                    hourIndex;
                                                            return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0,
                                                                        bottom:
                                                                            4.0,
                                                                        right:
                                                                            4.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: getColorBasedOnTemperature(
                                                                      snapshot
                                                                          .data!
                                                                          .temperature[index]),
                                                                ),
                                                                width: 115.5,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            6.0),
                                                                        child:
                                                                            Text(
                                                                          "${DateTime.parse(snapshot.data!.time[index]).hour}:00",
                                                                          style: GoogleFonts.dosis(
                                                                              fontSize: 15,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                50.0),
                                                                        child:
                                                                            Text(
                                                                          "${snapshot.data?.temperature[index].toInt()}${snapshot.data?.unit[0]}",
                                                                          style: GoogleFonts.rubik(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 20,
                                                                              color: const Color.fromARGB(255, 50, 50, 50)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ));
                                                          },
                                                        ),
                                                      )))
                                            ]);
                                          },
                                        ))))))
                  ]))
            ]);
          } else {
            return Text('Error: ${snapshot.error}');
          }
        });
  }
}

WeatherType getBgOnWeather(int weather) {
  switch (weather) {
    case 0:
      return WeatherType.sunny;
    case 1:
      return WeatherType.sunny;
    case 2:
      return WeatherType.cloudy;
    case 3:
      return WeatherType.overcast;
    case 45:
      return WeatherType.foggy;
    case 48:
      return WeatherType.hazy;
    case 51:
    case 53:
    case 55:
    case 61:
    case 80:
      return WeatherType.lightRainy;
    case 56:
    case 57:
    case 71:
      return WeatherType.lightSnow;
    case 63:
    case 81:
      return WeatherType.middleRainy;
    case 65:
    case 82:
      return WeatherType.heavyRainy;
    case 66:
    case 73:
    case 85:
      return WeatherType.middleSnow;
    case 67:
    case 75:
    case 77:
    case 86:
      return WeatherType.heavySnow;
    case 95:
    case 96:
    case 99:
      return WeatherType.storm;
    default:
      return WeatherType.sunny;
  }
}

Color? getColorBasedOnTemperature(double temperature) {
  if (temperature <= -2) {
    return Colors.blue[900]; // for temperatures -2°C and below
  } else if (temperature > -2 && temperature <= 0) {
    return Colors.blue[700]; // for temperatures between -2°C and 0°C
  } else if (temperature > 0 && temperature <= 2) {
    return Colors.blue[500]; // for temperatures between 1°C and 2°C
  } else if (temperature > 2 && temperature <= 4) {
    return Colors.lightBlue[700]; // for temperatures between 3°C and 4°C
  } else if (temperature > 4 && temperature <= 6) {
    return Colors.lightBlue[500]; // for temperatures between 5°C and 6°C
  } else if (temperature > 6 && temperature <= 8) {
    return const Color.fromARGB(
        255, 88, 193, 153); // for temperatures between 7°C and 8°C
  } else if (temperature > 8 && temperature <= 10) {
    return Colors.green[500]; // for temperatures between 9°C and 10°C
  } else if (temperature > 10 && temperature <= 12) {
    return const Color.fromARGB(
        255, 105, 155, 61); // for temperatures between 11°C and 12°C
  } else if (temperature > 12 && temperature <= 14) {
    return Colors.lightGreen[500]; // for temperatures between 13°C and 14°C
  } else if (temperature > 14 && temperature <= 16) {
    return Colors.yellow[700]; // for temperatures between 15°C and 16°C
  } else if (temperature > 16 && temperature <= 18) {
    return Colors.yellow[500]; // for temperatures between 17°C and 18°C
  } else if (temperature > 18 && temperature <= 20) {
    return Colors.orange[700]; // for temperatures between 19°C and 20°C
  } else if (temperature > 20 && temperature <= 22) {
    return Colors.orange[500]; // for temperatures between 21°C and 22°C
  } else if (temperature > 22 && temperature <= 24) {
    return Colors.deepOrange[700]; // for temperatures between 23°C and 24°C
  } else if (temperature > 24 && temperature <= 26) {
    return Colors.deepOrange[500]; // for temperatures between 25°C and 26°C
  } else if (temperature > 26 && temperature <= 28) {
    return Colors.red[700]; // for temperatures between 27°C and 28°C
  } else {
    return Colors.red[900]; // for temperatures 29°C and above
  }
}

Future<Location> getLocation() async {
  Position position = await getPosition();
  double latitude = position.latitude;
  double longitude = position.longitude;

  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

  Placemark place = placemarks[0];

  return Location(
      city: place.locality ?? '',
      country: place.country ?? '',
      lat: latitude,
      long: longitude);
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

class Location {
  final String city;
  final String country;
  final double lat;
  final double long;

  const Location(
      {required this.city,
      required this.country,
      required this.lat,
      required this.long});
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
