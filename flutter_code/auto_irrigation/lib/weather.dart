import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Weather data variables
  String? _temperature;
  String? _humidity;
  String? _pressure;
  String? _windSpeed;
  String? _windDirection;
  String? _weatherDescription;
  String? _errorMessage;
  String? _locationName; // Displays the name of the location from API

  // This variable is used to store a custom city entered by the user.
  // If null, the app uses the device's current location.
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _getCurrentWeather();
  }

  // Fetch weather data based either on current position or custom city name.
  Future<void> _getCurrentWeather() async {
    setState(() {
      _errorMessage = null;
      _temperature = null;
      _humidity = null;
      _pressure = null;
      _windSpeed = null;
      _windDirection = null;
      _weatherDescription = null;
      _locationName = null;
    });

    const apiKey = '54c6c581dacc8afdc9d1e08190237263';
    String apiUrl;

    // If the user selected a city, use that in the API call.
    if (_selectedCity != null && _selectedCity!.trim().isNotEmpty) {
      apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=${_selectedCity!.trim()}&appid=$apiKey&units=metric';
    } else {
      // Otherwise, check location permissions and use the device's current location.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
        });
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final latitude = position.latitude;
        final longitude = position.longitude;
        apiUrl =
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
      } catch (e) {
        setState(() {
          _errorMessage = 'Error getting current location: $e';
        });
        return;
      }
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Use API 'name' field to display the location
        setState(() {
          _locationName = data['name'] as String?;
          _temperature = (data['main']['temp'] as num).toStringAsFixed(1);
          _humidity = (data['main']['humidity'] as num).toString();
          _pressure = (data['main']['pressure'] as num).toString();
          _windSpeed = (data['wind']['speed'] as num).toString();
          _windDirection = (data['wind']['deg'] as num).toString();
          _weatherDescription = data['weather'][0]['description'] as String;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch weather data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching weather data: $e';
      });
    }
  }

  // Returns an icon based on the weather description.
  IconData _getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('rain')) {
      return Icons.beach_access;
    } else if (description.contains('cloud')) {
      return Icons.cloud;
    } else if (description.contains('sun')) {
      return Icons.wb_sunny;
    } else if (description.contains('snow')) {
      return Icons.ac_unit;
    } else {
      return Icons.wb_cloudy;
    }
  }

  // Opens a dialog to let the user enter a city name.
  Future<void> _showLocationDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _selectedCity,
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter City Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g. London'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear the custom city to use current location.
                setState(() {
                  _selectedCity = null;
                });
                Navigator.pop(context);
                _getCurrentWeather();
              },
              child: const Text('Use Current Location'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCity = controller.text;
                });
                Navigator.pop(context);
                _getCurrentWeather();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display either the location name (if available) or a default message.
    final locationDisplay =
        _locationName ??
        (_selectedCity != null && _selectedCity!.trim().isNotEmpty
            ? _selectedCity
            : 'Using current location');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showLocationDialog,
            tooltip: 'Change Location',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _errorMessage != null
                      ? Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                      : _temperature != null &&
                          _humidity != null &&
                          _pressure != null &&
                          _windSpeed != null &&
                          _windDirection != null &&
                          _weatherDescription != null
                      ? Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Location: $locationDisplay',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_weatherDescription![0].toUpperCase()}${_weatherDescription!.substring(1)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                _getWeatherIcon(_weatherDescription!),
                                size: 64,
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Temperature: $_temperature°C',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Humidity: $_humidity%',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pressure: $_pressure hPa',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Wind Speed: $_windSpeed m/s',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Wind Direction: $_windDirection°',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      )
                      : const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentWeather,
        tooltip: 'Refresh Weather',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void openWeatherApp(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const WeatherScreen()),
  );
}
