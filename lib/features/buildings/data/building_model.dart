import 'dart:convert';
import 'package:latlong2/latlong.dart';

class Building {
  final String id;
  final List<LatLng> coordinates;
  
  // Bounding Box
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  Building({
    required this.id,
    required this.coordinates,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  factory Building.fromCoordinates(String id, List<LatLng> coords) {
    if (coords.isEmpty) {
      throw ArgumentError('List of coordinates can not be empty');
    }

    double minLat = coords.first.latitude;
    double maxLat = coords.first.latitude;
    double minLng = coords.first.longitude;
    double maxLng = coords.first.longitude;

    // Countinng Bounding Box for current building
    for (var point in coords) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return Building(
      id: id,
      coordinates: coords,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }

  Map<String, dynamic> toMap() {
    final coordsList = coordinates.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
    
    return {
      'id': id,
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
      'coordinates': jsonEncode(coordsList),
    };
  }

  factory Building.fromMap(Map<String, dynamic> map) {
    final List<dynamic> decoded = jsonDecode(map['coordinates'] as String);
    final coords = decoded.map((p) => LatLng(p['lat'] as double, p['lng'] as double)).toList();

    return Building(
      id: map['id'] as String,
      coordinates: coords,
      minLat: map['minLat'] as double,
      maxLat: map['maxLat'] as double,
      minLng: map['minLng'] as double,
      maxLng: map['maxLng'] as double,
    );
  }
}