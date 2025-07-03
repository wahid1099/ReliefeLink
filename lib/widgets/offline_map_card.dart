import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/nearby_user.dart';
import '../utils/user_status_utils.dart';

class OfflineMapCard extends StatelessWidget {
  final LatLng? currentPosition;
  final List<NearbyUser> nearbyUsers;
  final bool isMapDownloaded;
  final double downloadProgress;
  final VoidCallback onDownloadMap;
  final VoidCallback onUpdateLocation;
  final MapController mapController;
  final Function(NearbyUser) onUserTap;

  const OfflineMapCard({
    super.key,
    this.currentPosition,
    required this.nearbyUsers,
    required this.isMapDownloaded,
    required this.downloadProgress,
    required this.onDownloadMap,
    required this.onUpdateLocation,
    required this.mapController,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.map, color: Color(0xFFE31837)),
                const SizedBox(width: 8),
                const Text(
                  'Offline Map (2km radius)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (isMapDownloaded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Downloaded',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Map View
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child:
                currentPosition != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          // FIXED: Changed from 'center' to 'initialCenter'
                          initialCenter: currentPosition!,
                          // FIXED: Changed from 'zoom' to 'initialZoom'
                          initialZoom: 15.0,
                          maxZoom: 18.0,
                          minZoom: 10.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            tileProvider: NetworkTileProvider(),
                            // FIXED: Removed 'mapState' and 'stream' parameters
                            // These are no longer needed in the new API
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentPosition!,
                                width: 40,
                                height: 40,
                                // FIXED: Changed from 'builder' to 'child'
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE31837),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              ...nearbyUsers.map(
                                (user) => Marker(
                                  point: user.position,
                                  width: 30,
                                  height: 30,
                                  // FIXED: Changed from 'builder' to 'child'
                                  child: GestureDetector(
                                    onTap: () => onUserTap(user),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: getUserStatusColor(user.status),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        getUserStatusIcon(user.status),
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: currentPosition!,
                                radius: 2000,
                                color: const Color(0xFFE31837).withOpacity(0.1),
                                borderColor: const Color(
                                  0xFFE31837,
                                ).withOpacity(0.3),
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),

          // Download Progress
          if (downloadProgress > 0 && downloadProgress < 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: downloadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE31837),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading... ${(downloadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isMapDownloaded ? null : onDownloadMap,
                    icon: Icon(
                      isMapDownloaded ? Icons.check : Icons.download,
                      size: 16,
                    ),
                    label: Text(
                      isMapDownloaded ? 'Map Downloaded' : 'Download Map',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE31837),
                      side: const BorderSide(color: Color(0xFFE31837)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpdateLocation,
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text('Update Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE31837),
                      side: const BorderSide(color: Color(0xFFE31837)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
