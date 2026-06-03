import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api_app/secrets.dart'; // contains your API key

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Current weather API
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'tirunelveli';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openweatherAPIkey&units=metric',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != 200) throw 'Error: ${data['message']}';
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Forecast API (5-day / 3-hour)
  Future<List<dynamic>> getForecast() async {
    try {
      String cityName = 'tirunelveli';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openweatherAPIkey&units=metric',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") throw 'Error: ${data['message']}';
      return data['list'];
    } catch (e) {
      throw e.toString();
    }
  }

  // Map condition to icon
  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final weatherData = snapshot.data!;
          final temp = weatherData['main']['temp'];
          final condition = weatherData['weather'][0]['main'];
          final humidity = weatherData['main']['humidity'];
          final windSpeed = weatherData['wind']['speed'];
          final pressure = weatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current weather card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 25,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$temp °C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(getWeatherIcon(condition), size: 64),
                              Text(
                                condition,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Weather Forecast",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Forecast row
                FutureBuilder(
                  future: getForecast(),
                  builder: (context, forecastSnap) {
                    if (forecastSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    if (forecastSnap.hasError) {
                      return Text(forecastSnap.error.toString());
                    }

                    final forecastList = forecastSnap.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (index) {
                          final forecast = forecastList[index];
                          final time =
                              forecast['dt_txt']; // "2026-05-01 03:00:00"
                          final fTemp = forecast['main']['temp'];
                          final fCondition = forecast['weather'][0]['main'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Column(
                              children: [
                                Text(time.substring(11, 16)),
                                Icon(getWeatherIcon(fCondition), size: 32),
                                Text('$fTemp °C'),
                              ],
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.water_drop),
                        Text('Humidity'),
                        Text('$humidity %'),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.air),
                        Text('Wind'),
                        Text('$windSpeed m/s'),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.beach_access),
                        Text('Pressure'),
                        Text('$pressure hPa'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
