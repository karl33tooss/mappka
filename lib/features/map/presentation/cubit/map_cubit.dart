import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/local_database_service.dart';
import '../../../buildings/data/geojson_parser_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final LocationService _locationService;
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;
  
  StreamSubscription<Position>? _positionSubscription;

  MapCubit(this._locationService) : super(MapInitial());

  Future<void> startTracking() async {
    emit(MapLoading());

    final initialCheck = await _dbService.getBuildingsInBounds(
      minLat: 49.0, maxLat: 50.0, minLng: 24.0, maxLng: 25.0
    );

    if (initialCheck.isEmpty) {
      try {
        final geojsonString = await rootBundle.loadString('assets/map/lviv_test.geojson');
        final parsedBuildings = GeojsonParserService.parseGeojson(geojsonString);
        await _dbService.insertBuildings(parsedBuildings);
        print('Successful imported ${parsedBuildings.length} test buildings to SQLite!');
      } catch (e) {
        print('Import error: $e');
      }
    }

    // Get initial position
    final initialPosition = await _locationService.getCurrentPosition();
    
    if (initialPosition != null) {
      // Get unlocked ID
      final unlockedIds = await _dbService.getUnlockedBuildingIds();
      
      emit(MapReady(
        currentPosition: initialPosition,
        unlockedBuildingIds: unlockedIds,
        visibleBuildings: [],
      ));
    } else {
      emit(MapError('Can not get location. Check your GPS.'));
      return;
    }

    _positionSubscription = _locationService.getPositionStream().listen(
      (newPosition) {
        if (state is MapReady) {
          final currentState = state as MapReady;
          emit(currentState.copyWith(currentPosition: newPosition));
        }
      },
      onError: (error) => emit(MapError('Втрачено сигнал GPS')),
    );
  }

  // The method that the UI will call whenever the map camera moves
  Future<void> updateVisibleBuildings({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    if (state is MapReady) {
      final currentState = state as MapReady;
      final buildings = await _dbService.getBuildingsInBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
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