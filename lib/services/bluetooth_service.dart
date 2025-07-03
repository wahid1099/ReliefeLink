import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static Future<bool> initialize() async {
    try {
      // Request each permission individually
      final bluetoothStatus = await Permission.bluetooth.request();
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      final advertiseStatus = await Permission.bluetoothAdvertise.request();
      final locationStatus = await Permission.location.request();

      // Check if all permissions are granted
      return bluetoothStatus.isGranted &&
          scanStatus.isGranted &&
          connectStatus.isGranted &&
          advertiseStatus.isGranted &&
          locationStatus.isGranted;
    } catch (e) {
      print('Bluetooth initialization error: $e');
      return false;
    }
  }
}
