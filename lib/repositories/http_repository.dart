import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchWeather(String city) async {
  final geoUrl = Uri.parse(
    'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1',
  );
  final geoRes = await http.get(geoUrl);
  final geoData = jsonDecode(geoRes.body);

  if (geoData['results'] == null || (geoData['results'] as List).isEmpty) {
    throw Exception('City not found: $city');
  }

  final location = geoData['results'][0];
  final double lat = location['latitude'];
  final double lon = location['longitude'];
  final String name = location['name'];

  final weatherUrl = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$lat'
    '&longitude=$lon'
    '&current=temperature_2m,wind_speed_10m,relative_humidity_2m',
  );
  final weatherRes = await http.get(weatherUrl);
  final weatherData = jsonDecode(weatherRes.body);

  final current = weatherData['current'];

  return '$name: ${current['temperature_2m']}°C, '
      'wind ${current['wind_speed_10m']} km/h, '
      'humidity ${current['relative_humidity_2m']}%';
}
