import 'package:hive_flutter/hive_flutter.dart';
import 'weather_api_service.dart';
import 'weather_model.dart';

class WeatherRepository {
  final WeatherApiService _weatherApiService;
  static final String _boxName = 'weather_box';
  static final String _weatherKey = 'weather';

  WeatherRepository(this._weatherApiService);

  Future<WeatherModel> getWeather(double lat, double lon) async{
    final box = Hive.box<WeatherModel>(_boxName);
    try{
      final weatherFromApi = await _weatherApiService.getCurrentWeather(lat, lon);
      await box.put(_weatherKey, weatherFromApi);
      return weatherFromApi;
    }
    catch(e)
    {
      final cachedWeather = box.get(_weatherKey);
      if (cachedWeather != null)
      {
        return cachedWeather;
      }
      else{
        throw Exception('No internet connection and no cached data loaded before');
      }
    }
  }
}