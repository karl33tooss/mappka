import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_state.dart';
import '../../data/weather_repository.dart';

class WeatherCubit extends Cubit<WeatherState>{
  final WeatherRepository _weatherRepository;
  WeatherCubit(this._weatherRepository) : super(WeatherInitial());

  Future<void> fetchWeather(double lat, double lon) async{
    emit(WeatherLoading());
    try{
      final weather = await _weatherRepository.getWeather(lat, lon);
      emit(WeatherLoaded(weather));
    }
    catch(e){
      emit(WeatherError(e.toString()));
    }
  }
}
