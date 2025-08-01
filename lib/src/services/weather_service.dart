import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final List<Forecast> forecast;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.forecast,
  });
}

class Forecast {
  final DateTime date;
  final double temperature;
  final String icon;

  Forecast({
    required this.date,
    required this.temperature,
    required this.icon,
  });
}

class WeatherService {
  static const _apiKey = 'demo'; // For real usage, get a free key from WeatherAPI or OpenWeatherMap
  static const _baseUrl =
      'https://api.open-meteo.com/v1/forecast?latitude={LAT}&longitude={LON}&current_weather=true&hourly=temperature_2m,weathercode';
  static const _cityApi =
      'https://geocoding-api.open-meteo.com/v1/search?name={CITY}&count=1';

  Future<Weather> fetchWeather(String city) async {
    final cityUrl = _cityApi.replaceFirst('{CITY}', Uri.encodeComponent(city));
    final cityResp = await http.get(Uri.parse(cityUrl));

    if (cityResp.statusCode != 200) {
      throw Exception('City not found');
    }
    final cityData = jsonDecode(cityResp.body);
    if (cityData['results'] == null || cityData['results'].isEmpty) {
      throw Exception('City not found');
    }
    final cityInfo = cityData['results'][0];
    final double lat = cityInfo['latitude'];
    final double lon = cityInfo['longitude'];

    final weatherUrl = _baseUrl.replaceFirst('{LAT}', '$lat').replaceFirst('{LON}', '$lon');
    final weatherResp = await http.get(Uri.parse(weatherUrl));
    if (weatherResp.statusCode != 200) {
      throw Exception('Failed to load weather');
    }
    final wd = jsonDecode(weatherResp.body);
    final temp = wd['current_weather']['temperature'].toDouble();
    final desc = _weatherCodeToDescription(wd['current_weather']['weathercode'] ?? 0);
    final icon = _weatherCodeToIcon(wd['current_weather']['weathercode'] ?? 0);

    List<Forecast> forecast = [];
    if (wd['hourly'] != null) {
      final List hourlyTemps = wd['hourly']['temperature_2m'];
      final List dates = wd['hourly']['time'];
      final List weatherCodes = wd['hourly']['weathercode'];
      for (int i = 0; i < hourlyTemps.length; i += 3) {
        // every 3rd hour for a short forecast
        forecast.add(
          Forecast(
            date: DateTime.parse(dates[i]),
            temperature: (hourlyTemps[i] as num).toDouble(),
            icon: _weatherCodeToIcon(weatherCodes[i] ?? 0),
          ),
        );
        if (forecast.length == 8) break;
      }
    }
    return Weather(
      city: cityInfo['name'],
      temperature: temp,
      description: desc,
      icon: icon,
      forecast: forecast,
    );
  }

  String _weatherCodeToDescription(int code) {
    // Simplified based on Open-Meteo codes (https://open-meteo.com/en/docs#api_form)
    switch (code) {
      case 0:
        return 'Clear and sunny';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  String _weatherCodeToIcon(int code) {
    switch (code) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌦️';
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 80:
      case 81:
      case 82:
        return '🌦️';
      case 95:
        return '⛈️';
      default:
        return '❓';
    }
  }
}
