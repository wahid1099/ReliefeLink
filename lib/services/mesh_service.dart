import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:relieflink/models/nearby_user.dart';
import 'package:relieflink/models/user_status.dart';

class MeshService {
  final Function(List<NearbyUser>) onUsersUpdated;
  Timer? _scanTimer;
  bool _isMeshActive = false;
  Position? _currentPosition;
  List<NearbyUser> _nearbyUsers = [];

  MeshService({required this.onUsersUpdated});

  bool get isActive => _isMeshActive;
  List<NearbyUser> getNearbyUsers() => List.unmodifiable(_nearbyUsers);

  void startMeshNetwork() {
    _isMeshActive = true;
    _startPeriodicUpdates();
  }

  void stopMeshNetwork() {
    _isMeshActive = false;
    _scanTimer?.cancel();
  }

  void updateCurrentPosition(Position position) {
    _currentPosition = position;
  }

  void _startPeriodicUpdates() {
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isMeshActive) {
        _updateNearbyUsers();
      }
    });
  }

  void _updateNearbyUsers() {
    if (_currentPosition == null) return;

    try {
      final random = Random();
      final users = <NearbyUser>[];
      final userCount = 3 + random.nextInt(6);

      for (int i = 0; i < userCount; i++) {
        final distance = 0.5 + random.nextDouble() * 1.5; // Distance in km
        final bearing = random.nextDouble() * 360; // Bearing in degrees

        // More accurate coordinate calculation
        final bearingRad = bearing * pi / 180;
        final lat =
            _currentPosition!.latitude + (distance / 111.32) * cos(bearingRad);
        final lng =
            _currentPosition!.longitude +
            (distance / (111.32 * cos(_currentPosition!.latitude * pi / 180))) *
                sin(bearingRad);

        users.add(
          NearbyUser(
            id: 'user_$i',
            name: 'User ${i + 1}',
            position: LatLng(lat, lng),
            distance: distance,
            status: UserStatus.values[random.nextInt(UserStatus.values.length)],
            batteryLevel: 20 + random.nextInt(80),
            lastSeen: DateTime.now().subtract(
              Duration(minutes: random.nextInt(10)),
            ),
          ),
        );
      }

      _nearbyUsers = users;
      onUsersUpdated(users);
    } catch (e) {
      print('Error updating nearby users: $e');
    }
  }

  void dispose() {
    stopMeshNetwork();
    _currentPosition = null;
  }

  double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
          pos1.latitude,
          pos1.longitude,
          pos2.latitude,
          pos2.longitude,
        ) /
        1000; // Convert to kilometers
  }

  bool isUserInRange(NearbyUser user, double maxRange) {
    if (_currentPosition == null) return false;

    final distance =
        Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          user.position.latitude,
          user.position.longitude,
        ) /
        1000;

    return distance <= maxRange;
  }
}
