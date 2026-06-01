import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/local_database_service.dart';
import '../../../buildings/data/geojson_parser_service.dart';
import '../../../buildings/data/building_model.dart'; 
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final LocationService _locationService;
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;
  
  StreamSubscription<Position>? _positionSubscription;

  MapCubit(this._locationService) : super(MapInitial());

  Future<void> startTracking() async {
    emit(MapLoading());

    // 1. Read our file with the real center of Lviv
    final initialCheck = await _dbService.getBuildingsInBounds(
      minLat: 49.835, maxLat: 49.845, minLng: 24.020, maxLng: 24.035
    );

    if (initialCheck.isEmpty) {
      try {
        print('Parsing real GeoJSON of Lviv center... This will take a second.');
        final geojsonString = await rootBundle.loadString('assets/map/lviv_test.geojson');
        final parsedBuildings = GeojsonParserService.parseGeojson(geojsonString);
        await _dbService.insertBuildings(parsedBuildings);
        print('Successfully imported ${parsedBuildings.length} real buildings!');
      } catch (e) {
        print('Import error: $e');
      }
    }

    final initialPosition = await _locationService.getCurrentPosition();
    
    if (initialPosition != null) {
      final unlockedIds = await _dbService.getUnlockedBuildingIds();
      final totalCount = await _dbService.getTotalBuildingsCount();

      emit(MapReady(
        currentPosition: initialPosition,
        unlockedBuildingIds: unlockedIds,
        visibleBuildings: [], 
        totalBuildingsCount: totalCount,
      ));
    } else {
      emit(MapError('Failed to get location.'));
      return;
    }

    // 2. LISTEN TO GPS AND START RADAR
    _positionSubscription = _locationService.getPositionStream().listen(
      (newPosition) {
        if (state is MapReady) {
          final currentState = state as MapReady;
          // Update user position
          emit(currentState.copyWith(currentPosition: newPosition));
          // Call area scanning function
          _checkRadar(newPosition, currentState.visibleBuildings, currentState.unlockedBuildingIds);
        }
      },
      onError: (error) => emit(MapError('GPS signal lost')),
    );
  }

  // RADAR: Checks distance to buildings on the screen
  Future<void> _checkRadar(Position pos, List<Building> visibleBuildings, List<String> unlockedIds) async {
    bool stateChanged = false;
    final newUnlockedIds = List<String>.from(unlockedIds);

    for (var building in visibleBuildings) {
      // If building is already unlocked - skip
      if (newUnlockedIds.contains(building.id)) continue;

      // Check distance from user to each point of the building polygon
      for (var point in building.coordinates) {
        final distance = Geolocator.distanceBetween(
          pos.latitude, pos.longitude,
          point.latitude, point.longitude,
        );

        // If at least one point is closer than 50 meters - UNLOCKED!
        if (distance <= 50.0) {
          newUnlockedIds.add(building.id);
          stateChanged = true;
          
          // Save progress to SQLite database
          await _dbService.unlockBuilding(building.id);
          break; // Move to the next building
        }
      }
    }

    // If we found new buildings, update the screen so they turn green
    if (stateChanged && state is MapReady) {
      emit((state as MapReady).copyWith(unlockedBuildingIds: newUnlockedIds));
    }
  }

  Future<void> updateVisibleBuildings({
    required double minLat, required double maxLat, required double minLng, required double maxLng,
  }) async {
    if (state is MapReady) {
      final currentState = state as MapReady;
      final buildings = await _dbService.getBuildingsInBounds(
        minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng,
      );
      emit(currentState.copyWith(visibleBuildings: buildings));
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}