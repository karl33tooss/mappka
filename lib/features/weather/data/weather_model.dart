import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 1)
class WeatherModel extends Equatable{
  @HiveField(0)
  final double temperature;
  @HiveField(1)
  final String condition;
  @HiveField(2)
  final String cityName;

  const WeatherModel({
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

  @override
  List<Object?> get props =>[temperature,cityName,condition];
}