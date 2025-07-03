import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _messageController = TextEditingController();
  
  // Location and Map State
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isMapDownloaded = false;
  double _downloadProgress = 0.0;
  
  // Bluetooth Mesh State
  bool _isBluetoothEnabled = false;
  bool _isMeshActive = false;
  List<NearbyUser> _nearbyUsers = [];
  Timer? _scanTimer;
  
  // Emergency State
  String _selectedEmergencyType = 'Injury';
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeBluetooth();
    _startMeshScanning();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  // Initialize location services
  Future<void> _initializeLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
        setState(() {});
      }
    } catch (e) {
      print('Location error: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  // Initialize Bluetooth for mesh networking
  Future<void> _initializeBluetooth() async {
    try {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();
      
      bool allGranted = permissions.values.every(
        (status) => status == PermissionStatus.granted
      );
      
      if (allGranted) {
        setState(() => _isBluetoothEnabled = true);
        _startMeshNetwork();
      }
    } catch (e) {
      print('Bluetooth initialization error: $e');
    }
  }

  // Start mesh network
  void _startMeshNetwork() {
    if (!_isBluetoothEnabled) return;
    
    setState(() => _isMeshActive = true);
    
    // Simulate mesh network activity
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isMeshActive) {
        _updateNearbyUsers();
      } else {
        timer.cancel();
      }
    });
  }

  // Simulate scanning for nearby users
  void _startMeshScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _updateNearbyUsers();
      }
    });
  }

  // Update nearby users (simulated)
  void _updateNearbyUsers() {
    if (_currentPosition == null) return;
    
    final random = Random();
    final users = <NearbyUser>[];
    
    // Generate 3-8 random nearby users
    final userCount = 3 + random.nextInt(6);
    
    for (int i = 0; i < userCount; i++) {
      // Generate random position within 1-2km
      final distance = 0.5 + random.nextDouble() * 1.5; // 0.5 to 2km
      final bearing = random.nextDouble() * 360; // 0 to 360 degrees
      
      final lat = _currentPosition!.latitude + 
          (distance / 111.32) * cos(bearing * pi / 180);
      final lng = _currentPosition!.longitude + 
          (distance / (111.32 * cos(_currentPosition!.latitude * pi / 180))) * 
          sin(bearing * pi / 180);
      
      users.add(NearbyUser(
        id: 'user_$i',
        name: 'User ${i + 1}',
        position: LatLng(lat, lng),
        distance: distance,
        status: UserStatus.values[random.nextInt(UserStatus.values.length)],
        batteryLevel: 20 + random.nextInt(80),
        lastSeen: DateTime.now().subtract(Duration(minutes: random.nextInt(10))),
      ));
    }
    
    setState(() => _nearbyUsers = users);
  }

  // Download offline map
  Future<void> _downloadOfflineMap() async {
    setState(() => _downloadProgress = 0.0);
    
    // Simulate download progress
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
                  // Mesh Network Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isMeshActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMeshActive ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_nearbyUsers.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                    // Send Emergency Alert Button
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

                    // Type of Emergency
                    const Text(
                      'Type of Emergency',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildEmergencyType(
                            icon: Icons.medical_services,
                            label: 'Injury',
                            isSelected: _selectedEmergencyType == 'Injury',
                            onTap: () => setState(() => _selectedEmergencyType = 'Injury'),
                          ),
                          _buildEmergencyType(
                            icon: Icons.door_front_door,
                            label: 'Trapped',
                            isSelected: _selectedEmergencyType == 'Trapped',
                            onTap: () => setState(() => _selectedEmergencyType = 'Trapped'),
                          ),
                          _buildEmergencyType(
                            icon: Icons.local_fire_department,
                            label: 'Fire',
                            isSelected: _selectedEmergencyType == 'Fire',
                            onTap: () => setState(() => _selectedEmergencyType = 'Fire'),
                          ),
                          _buildEmergencyType(
                            icon: Icons.water_drop,
                            label: 'Flood',
                            isSelected: _selectedEmergencyType == 'Flood',
                            onTap: () => setState(() => _selectedEmergencyType = 'Flood'),
                          ),
                          _buildEmergencyType(
                            icon: Icons.home_work,
                            label: 'Building\nDamage',
                            isSelected: _selectedEmergencyType == 'Building\nDamage',
                            onTap: () => setState(() => _selectedEmergencyType = 'Building\nDamage'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Optional Message
                    const Text(
                      'Optional Message',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

                    // Offline Map Section
                    _buildOfflineMapSection(),
                    const SizedBox(height: 24),

                    // Nearby Users Section
                    _buildNearbyUsersSection(),
                    const SizedBox(height: 24),

                    // Sync Status
                    _buildSyncStatusSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineMapSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                if (_isMapDownloaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          
          // Map Display
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _currentPosition != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 15.0,
                        maxZoom: 18.0,
                        minZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.relieflink',
                        ),
                        MarkerLayer(
                          markers: [
                            // Current user marker
                            Marker(
                              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              width: 40,
                              height: 40,
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE31837),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                            ),
                            // Nearby users markers
                            ..._nearbyUsers.map((user) => Marker(
                              point: user.position,
                              width: 30,
                              height: 30,
                              builder: (context) => GestureDetector(
                                onTap: () => _showUserDetails(user),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getUserStatusColor(user.status),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    _getUserStatusIcon(user.status),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              radius: 2000, // 2km radius
                              color: const Color(0xFFE31837).withOpacity(0.1),
                              borderColor: const Color(0xFFE31837).withOpacity(0.3),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          
          // Download Progress
          if (_downloadProgress > 0 && _downloadProgress < 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading... ${(_downloadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isMapDownloaded ? null : _downloadOfflineMap,
                    icon: Icon(
                      _isMapDownloaded ? Icons.check : Icons.download,
                      size: 16,
                    ),
                    label: Text(_isMapDownloaded ? 'Map Downloaded' : 'Download Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE31837),
                      side: const BorderSide(color: Color(0xFFE31837)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _initializeLocation,
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

  Widget _buildNearbyUsersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFFE31837)),
                const SizedBox(width: 8),
                const Text(
                  'Nearby Users',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isMeshActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_nearbyUsers.length} found',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          if (_nearbyUsers.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = _nearbyUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getUserStatusColor(user.status),
                    child: Icon(
                      _getUserStatusIcon(user.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.distance.toStringAsFixed(1)}km away • ${_getStatusText(user.status)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.battery_std,
                        color: _getBatteryColor(user.batteryLevel),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.batteryLevel}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getBatteryColor(user.batteryLevel),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showUserDetails(user),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No nearby users found. Make sure Bluetooth is enabled.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sync Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildSyncStatus(
          icon: Icons.bluetooth,
          title: 'Mesh Network Active',
          subtitle: 'Connected to ${_nearbyUsers.length} nearby devices',
          color: _isMeshActive ? Colors.green : Colors.grey,
          backgroundColor: _isMeshActive ? const Color(0xFFEDF7ED) : Colors.grey[100]!,
        ),
        const SizedBox(height: 8),
        _buildSyncStatus(
          icon: Icons.wifi_off,
          title: 'Internet Connection',
          subtitle: 'No internet - using mesh network',
          color: Colors.orange,
          backgroundColor: const Color(0xFFFFF4EC),
        ),
        const SizedBox(height: 8),
        _buildSyncStatus(
          icon: Icons.map,
          title: 'Offline Map',
          subtitle: _isMapDownloaded ? 'Map cached locally' : 'Download map for offline use',
          color: _isMapDownloaded ? Colors.green : Colors.grey,
          backgroundColor: _isMapDownloaded ? const Color(0xFFEDF7ED) : Colors.grey[100]!,
        ),
      ],
    );
  }

  Widget _buildEmergencyType({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE31837) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE31837) : Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getUserStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.safe:
        return Colors.green;
      case UserStatus.needsHelp:
        return Colors.red;
      case UserStatus.unknown:
        return Colors.grey;
    }
  }

  IconData _getUserStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.safe:
        return Icons.check;
      case UserStatus.needsHelp:
        return Icons.warning;
      case UserStatus.unknown:
        return Icons.person;
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.safe:
        return 'Safe';
      case UserStatus.needsHelp:
        return 'Needs Help';
      case UserStatus.unknown:
        return 'Unknown';
    }
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  void _showUserDetails(NearbyUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusText(user.status)}'),
            Text('Distance: ${user.distance.toStringAsFixed(1)}km'),
            Text('Battery: ${user.batteryLevel}%'),
            Text('Last seen: ${user.lastSeen.toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Send message to user
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  void _sendEmergencyAlert() {
    final message = _messageController.text.trim();
    
    // Send alert via mesh network
    if (_isMeshActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Emergency alert sent to ${_nearbyUsers.length} nearby users via mesh network',
          ),
          backgroundColor: const Color(0xFFE31837),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No mesh network connection available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

// Data models
class NearbyUser {
  final String id;
  final String name;
  final LatLng position;
  final double distance;
  final UserStatus status;
  final int batteryLevel;
  final DateTime lastSeen;

  NearbyUser({
    required this.id,
    required this.name,
    required this.position,
    required this.distance,
    required this.status,
    required this.batteryLevel,
    required this.lastSeen,
  });
}

enum UserStatus {
  safe,
  needsHelp,
  unknown,
}import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Emergency Alert Header
            Container(
              color: const Color(0xFFE31837),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'EMERGENCY ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    // Send Emergency Alert Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
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

                    // Type of Emergency
                    const Text(
                      'Type of Emergency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildEmergencyType(
                            icon: Icons.medical_services,
                            label: 'Injury',
                            isSelected: true,
                          ),
                          _buildEmergencyType(
                            icon: Icons.door_front_door,
                            label: 'Trapped',
                          ),
                          _buildEmergencyType(
                            icon: Icons.local_fire_department,
                            label: 'Fire',
                          ),
                          _buildEmergencyType(
                            icon: Icons.water_drop,
                            label: 'Flood',
                          ),
                          _buildEmergencyType(
                            icon: Icons.home_work,
                            label: 'Building\nDamage',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Optional Message
                    const Text(
                      'Optional Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
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

                    // Location
                    const Text(
                      'Your Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Color(0xFFE31837),
                            ),
                            title: const Text('123 Main Street, Dhaka'),
                            subtitle: const Text(
                              'Lat: 23.8103° N, Long: 90.4125° E',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          Container(
                            height: 150,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // TODO: Implement actual map widget
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE31837),
                                side: const BorderSide(
                                  color: Color(0xFFE31837),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Update Location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sync Status
                    const Text(
                      'Sync Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSyncStatus(
                      icon: Icons.wifi_tethering,
                      title: 'Sending locally via mesh',
                      subtitle: 'Alert will be shared with nearby devices',
                      color: Colors.amber,
                      backgroundColor: const Color(0xFFFFF8E6),
                    ),
                    const SizedBox(height: 8),
                    _buildSyncStatus(
                      icon: Icons.sms,
                      title: 'SMS sync pending',
                      subtitle: 'Waiting for cellular connection',
                      color: Colors.orange,
                      backgroundColor: const Color(0xFFFFF4EC),
                    ),
                    const SizedBox(height: 8),
                    _buildSyncStatus(
                      icon: Icons.cloud_done,
                      title: 'Sent to cloud',
                      subtitle: 'Alert successfully delivered',
                      color: Colors.green,
                      backgroundColor: const Color(0xFFEDF7ED),
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

  Widget _buildEmergencyType({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE31837) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE31837) : Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}