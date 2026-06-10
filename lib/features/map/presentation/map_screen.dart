import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/config/app_config.dart';
import 'cubit/map_cubit.dart';
import 'cubit/map_state.dart';
import '../../weather/presentation/cubit/weather_cubit.dart';
import '../../weather/presentation/cubit/weather_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 17;

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mappka', style: AppTextStyles.heading1),
      ),
      body: BlocListener<MapCubit, MapState>(
        listenWhen: (previous, current) =>
            previous is! MapReady && current is MapReady,
        listener: (context, state) {
          if (state is MapReady) {
            context.read<WeatherCubit>().fetchWeather(
              state.currentPosition.latitude,
              state.currentPosition.longitude,
            );
          }
        },
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            if (state is MapInitial || state is MapLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is MapError) {
              return Center(
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyInput,
                ),
              );
            }
            if (state is MapReady) {
              final position = state.currentPosition;
              final userLocation = LatLng(
                position.latitude,
                position.longitude,
              );
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: userLocation,
                      initialZoom: _currentZoom,
                      minZoom: 10,
                      maxZoom: 20,
                      onPositionChanged:
                          (MapPosition position, bool hasGesture) {
                            final zoom = position.zoom ?? 17.0;
                            if (_currentZoom != zoom) {
                              setState(() {
                                _currentZoom = zoom;
                              });
                            }
                            if (_currentZoom > -16.0 &&
                                position.bounds != null) {
                              final bounds = position.bounds!;
                              context.read<MapCubit>().updateVisibleBuildings(
                                minLat: bounds.south,
                                maxLat: bounds.north,
                                minLng: bounds.west,
                                maxLng: bounds.east,
                              );
                            }
                          },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.jawg.io/jawg-matrix/{z}/{x}/{y}.png?access-token=${AppConfig.jawgToken}',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        maxNativeZoom: 22,
                        userAgentPackageName: 'com.example.mappka',
                      ),

                      if (state.visibleBuildings.isNotEmpty &&
                          _currentZoom >= 16.0)
                        PolygonLayer(
                          polygons: state.visibleBuildings.map((building) {
                            final isUnlocked = state.unlockedBuildingIds
                                .contains(building.id);
                            return Polygon(
                              points: building.coordinates,
                              color: isUnlocked
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderColor: isUnlocked
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.4),
                              borderStrokeWidth: 2.0,
                              isFilled: true,
                            );
                          }).toList(),
                        ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.domain,
                              color: AppColors.inactive,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${state.unlockedBuildingIds.length} / ${state.totalBuildingsCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: BlocBuilder<WeatherCubit, WeatherState>(
                        builder: (context, weatherState) {
                          if (weatherState is WeatherLoading || weatherState is WeatherInitial) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                            );
                          }
                          if (weatherState is WeatherLoaded){
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${weatherState.weather.temperature.round()}°C',
                                    style: AppTextStyles.textButton
                                  ),
                                ],
                              ),
                            );
                          }
                          if (weatherState is WeatherError) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      backgroundColor: AppColors.primary,
                      onPressed: () {
                        _mapController.move(userLocation, 17.0);
                      },
                      child: const Icon(Icons.center_focus_strong, color: Colors.white),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
