import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'building_model.dart';

class GeojsonParserService {
  
  static List<Building> parseGeojson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<Building> buildings = [];

    if (data['type'] != 'FeatureCollection' || data['features'] == null) {
      return buildings;
    }

    for (var feature in data['features']) {
      final geometry = feature['geometry'];
      if (geometry == null) continue;

      final type = geometry['type'];
      
      if (type == 'Polygon') {
        final coordinates = geometry['coordinates'] as List;
        if (coordinates.isNotEmpty) {
          final List<dynamic> exteriorRing = coordinates[0];
          
          final List<LatLng> polygonPoints = [];
          for (var point in exteriorRing) {
            final lng = (point[0] is int) ? (point[0] as int).toDouble() : point[0] as double;
            final lat = (point[1] is int) ? (point[1] as int).toDouble() : point[1] as double;
            
            polygonPoints.add(LatLng(lat, lng));
          }

          final id = feature['id']?.toString() ?? 'building_${DateTime.now().microsecondsSinceEpoch}_${buildings.length}';

          try {
            buildings.add(Building.fromCoordinates(id, polygonPoints));
          } catch (e) {
            continue;
          }
        }
      }
    }
    
    return buildings;
  }
}