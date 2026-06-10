import '../../../core/network/dio_client.dart';
import 'weather_model.dart';
import '../../../core/config/app_config.dart';

class WeatherApiService {
  final DioClient _dioClient;
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  WeatherApiService(this._dioClient);

  Future<WeatherModel> getCurrentWeather(double lat, double lon)
  async {
    final responseData = await _dioClient.get(
      _baseUrl,
      queryParameters: {'lat': lat, 'lon': lon, 'appid': AppConfig.openWeatherMapApiKey, 'units': 'metric'},
    );
    return WeatherModel.fromJson(responseData);
  }
}