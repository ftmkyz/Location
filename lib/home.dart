import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/text.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '',
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic> weatherData = {};
  // ignore: non_constant_identifier_names
  String Address = 'search';
  double lat = 0.0;
  double lon = 0.0;
  bool showBottomNav = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position position = await _getGeoLocationPosition();
      lat = position.latitude;
      lon = position.longitude;
      await GetAddressFromLatLong(position);
      await fetchWeatherData(lat, lon);
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled.';
    }
    permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // ignore: non_constant_identifier_names
  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
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
      'X-RapidAPI-Key': 'key',
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logos/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0)),
                          ),
                        ),
                        TextPage(
                          value: 'Country: ${weatherData['sys']['country']} ',
                        ),
                        TextPage(
                          value: 'Location: ${weatherData['name']} ',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.brightness_medium),
                  label: '${weatherData['weather'][0]['description']}',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.thermostat),
                  label: ' ${weatherData['main']['temp']} K',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.water_drop),
                  label: ' ${weatherData['main']['humidity']} humidity',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.wind_power_outlined),
                  label: '${weatherData['wind']['speed']} m/s',
                ),
              ],
            ),
    );
  }
}
