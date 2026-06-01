import 'package:geolocator/geolocator.dart';
import 'package:equatable/equatable.dart';
import '../../../buildings/data/building_model.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final Position currentPosition;
  final List<Building> visibleBuildings;
  final List<String> unlockedBuildingIds;
  final int totalBuildingsCount;

  const MapReady({
    required this.currentPosition,
    required this.visibleBuildings,
    required this.unlockedBuildingIds,
    required this.totalBuildingsCount,
  });

  MapReady copyWith({
    Position? currentPosition,
    List<Building>? visibleBuildings,
    List<String>? unlockedBuildingIds,
    int? totalBuildingsCount,
  }) {
    return MapReady(
      currentPosition: currentPosition ?? this.currentPosition,
      visibleBuildings: visibleBuildings ?? this.visibleBuildings,
      unlockedBuildingIds: unlockedBuildingIds ?? this.unlockedBuildingIds,
      totalBuildingsCount: totalBuildingsCount ?? this.totalBuildingsCount,
    );
  }
  
  @override
  List<Object?> get props => [
        currentPosition,
        unlockedBuildingIds,
        visibleBuildings,
        totalBuildingsCount,
      ];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}