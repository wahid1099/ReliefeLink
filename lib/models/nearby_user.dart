import 'package:latlong2/latlong.dart';
import 'user_status.dart';

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
