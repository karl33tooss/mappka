import 'package:geolocator/geolocator.dart';
import '../../../buildings/data/building_model.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final Position currentPosition;
  final List<Building> visibleBuildings;
  final List<String> unlockedBuildingIds;

  MapReady({
    required this.currentPosition,
    this.visibleBuildings = const [],
    this.unlockedBuildingIds = const [],
  });

  MapReady copyWith({
    Position? currentPosition,
    List<Building>? visibleBuildings,
    List<String>? unlockedBuildingIds,
  }) {
    return MapReady(
      currentPosition: currentPosition ?? this.currentPosition,
      visibleBuildings: visibleBuildings ?? this.visibleBuildings,
      unlockedBuildingIds: unlockedBuildingIds ?? this.unlockedBuildingIds,
    );
  }
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}