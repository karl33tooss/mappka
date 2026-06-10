import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_state.dart';
import '../../data/weather_api_service.dart';

class WeatherCubit extends Cubit<WeatherState>{
  final WeatherApiService _weaterApiService;
  WeatherCubit(this._weaterApiService) : super(WeatherInitial());

  Future<void> fetchWeather(double lat, double lon) async{
    emit(WeatherLoading());
    try{
      final weather = await _weaterApiService.getCurrentWeather(lat, lon);
      emit(WeatherLoaded(weather));
    }
    catch(e){
      emit(WeatherError(e.toString()));
    }
  }
}
