import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'dart:async';
import 'dart:math';
import 'package:relieflink/models/nearby_user.dart' as models;
import 'package:relieflink/services/location_service.dart';
import 'package:relieflink/services/bluetooth_service.dart';
import 'package:relieflink/services/mesh_service.dart';
import 'package:relieflink/widgets/emergency_type_selector.dart';
import 'package:relieflink/widgets/offline_map_card.dart';
import 'package:relieflink/widgets/sync_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _messageController = TextEditingController();
  MeshService? _meshService;

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isMapDownloaded = false;
  double _downloadProgress = 0.0;
  String _selectedEmergencyType = 'Injury';
  List<models.NearbyUser> _nearbyUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _meshService?.stopMeshNetwork();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoadingLocation = true);

    // Initialize location
    _currentPosition = await LocationService.getCurrentPosition();

    // Initialize Bluetooth
    bool isBluetoothEnabled = await BluetoothService.initialize();

    // Initialize Mesh Service
    if (isBluetoothEnabled && _currentPosition != null) {
      _meshService = MeshService(
        onUsersUpdated: (users) {
          if (mounted) setState(() => _nearbyUsers = users);
        },
      );
      _meshService?.updateCurrentPosition(_currentPosition!);
      _meshService?.startMeshNetwork();
    }

    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _downloadOfflineMap() async {
    setState(() => _downloadProgress = 0.0);

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _downloadProgress = i / 100);
    }

    setState(() => _isMapDownloaded = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline map downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showUserDetails(models.NearbyUser user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(user.id),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${user.status.name}'),
                Text('Distance: ${user.distance.toStringAsFixed(2)} km'),
                Text('Battery: ${user.batteryLevel}%'),
                Text('Last seen: ${user.lastSeen.toString()}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _sendEmergencyAlert() {
    // Implement emergency alert sending logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Emergency Alert Header
            Container(
              width: double.infinity,
              color: const Color(0xFFE31837),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'EMERGENCY ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _meshService?.isActive == true
                              ? Colors.green
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _meshService?.isActive == true
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_nearbyUsers.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _sendEmergencyAlert,
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text(
                        'Send Emergency Alert',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Type of Emergency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmergencyTypeSelector(
                      selectedType: _selectedEmergencyType,
                      onTypeSelected:
                          (type) =>
                              setState(() => _selectedEmergencyType = type),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Optional Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Describe your situation...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    OfflineMapCard(
                      currentPosition:
                          _currentPosition != null
                              ? latlong.LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )
                              : null,
                      nearbyUsers: _nearbyUsers,
                      isMapDownloaded: _isMapDownloaded,
                      downloadProgress: _downloadProgress,
                      onDownloadMap: _downloadOfflineMap,
                      onUpdateLocation: _initializeServices,
                      mapController: _mapController,
                      onUserTap: _showUserDetails,
                    ),

                    const SizedBox(height: 24),

                    SyncStatusCard(
                      isMeshActive: _meshService?.isActive ?? false,
                      nearbyUsersCount: _nearbyUsers.length,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
