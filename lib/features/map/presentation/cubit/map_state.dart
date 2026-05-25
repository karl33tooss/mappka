import 'package:geolocator/geolocator.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final Position currentPosition;
  
  MapReady(this.currentPosition);
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}