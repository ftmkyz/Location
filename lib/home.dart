import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/text.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '',
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic> weatherData = {};
  // String location = 'Null, Press Button';
  // ignore: non_constant_identifier_names
  String Address = 'search';
  double lat = 0.0;
  double lon = 0.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position position = await _getGeoLocationPosition();
      lat = position.latitude;
      lon = position.longitude;
      GetAddressFromLatLong(position);
      fetchWeatherData(lat, lon);
    });
  }

  Future _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // ignore: non_constant_identifier_names
  Future GetAddressFromLatLong(Position position) async {
    List placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (kDebugMode) {
      print(placemarks);
    }
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    var url = Uri.parse(
        'https://open-weather13.p.rapidapi.com/city/latlon/$latitude/$longitude');
    var headers = {
      'X-RapidAPI-Key': 'Key',
      'X-RapidAPI-Host': 'host'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body);
      });
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: weatherData.isEmpty
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextPage(
                          textIcon: Icons.brightness_medium,
                          value:
                              'Weather: ${weatherData['weather'][0]['description']}'),
                      TextPage(
                          textIcon: Icons.thermostat,
                          value:
                              'Temperature: ${weatherData['main']['temp']} K'),
                      TextPage(
                          textIcon: Icons.thermostat,
                          value:
                              'Humidity: ${weatherData['main']['humidity']}%'),
                      TextPage(
                          textIcon: Icons.wind_power_outlined,
                          value:
                              'Wind Speed: ${weatherData['wind']['speed']} m/s'),
                      TextPage(
                        textIcon: Icons.location_city,
                        value: 'Country: ${weatherData['sys']['country']} ',
                      ),
                      TextPage(
                          textIcon: Icons.location_on,
                          value: 'Location: ${weatherData['name']} '),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
