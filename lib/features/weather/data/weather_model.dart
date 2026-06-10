class WeatherModel {
  final double temperature;
  final String condition;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.cityName,
    required this.condition,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json)
  {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      cityName: json['name'] as String,
      condition: json['weather'][0]['main'] as String,
    );
  }
}