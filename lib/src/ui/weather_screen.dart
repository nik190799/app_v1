import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController(text: "London");
  Weather? _weather;
  bool _loading = false;
  String? _error;

  Future<void> _searchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await WeatherService().fetchWeather(_cityController.text.trim());
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _weather = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter city name',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F8FE),
                    ),
                    onSubmitted: (_) {
                      if (!_loading) _searchWeather();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _loading ? null : _searchWeather,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading && _weather == null)
              const Padding(
                padding: EdgeInsets.all(28.0),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            if (_error != null && !_loading)
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if (_weather != null && !_loading)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_weather!.city}',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${_weather!.icon} ${_weather!.temperature.toStringAsFixed(1)}°C",
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _weather!.description,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 19),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Next hours:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 9),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _weather!.forecast.length,
                        itemBuilder: (context, idx) {
                          final f = _weather!.forecast[idx];
                          return Card(
                            margin: const EdgeInsets.only(right: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              width: 86,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(f.icon, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(height: 5),
                                  Text('${f.temperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 3),
                                  Text(
                                    DateFormat('H:mm').format(f.date),
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (_weather == null && !_loading && _error == null)
              const Center(
                child: Text(
                  'Enter a city name and tap search to view weather.',
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
