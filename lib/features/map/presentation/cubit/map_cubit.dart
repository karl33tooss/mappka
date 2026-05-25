import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final LocationService _locationService;
  
  StreamSubscription<Position>? _positionSubscription;

  MapCubit(this._locationService) : super(MapInitial());

  // Method for tracking location
  Future<void> startTracking() async {
    emit(MapLoading()); 

    // Firstly, we should find start position
    final initialPosition = await _locationService.getCurrentPosition();
    
    if (initialPosition != null) {
      emit(MapReady(initialPosition));
    } else {
      emit(MapError('Can not get location. Check GPS.'));
      return;
    }

    // Connecting to Stream, which will give new position
    _positionSubscription = _locationService.getPositionStream().listen(
      (newPosition) {
        emit(MapReady(newPosition));
      },
      onError: (error) {
        emit(MapError('Losing GPS signal'));
      },
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}