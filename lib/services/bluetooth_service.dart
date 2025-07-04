import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothService {
  static StreamSubscription<ScanResult>? _scanSubscription;
  static final List<ScanResult> _nearbyDevices = [];

  static Future<bool> initialize() async {
    // Permissions should be handled elsewhere if needed
    return true;
  }

  static void startScan({void Function(List<ScanResult>)? onUpdate}) {
    _nearbyDevices.clear();
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scan().listen((scanResult) {
      final idx = _nearbyDevices.indexWhere(
        (d) => d.device.id == scanResult.device.id,
      );
      if (idx == -1) {
        _nearbyDevices.add(scanResult);
      } else {
        _nearbyDevices[idx] = scanResult;
      }
      if (onUpdate != null) {
        onUpdate(List<ScanResult>.from(_nearbyDevices));
      }
    });
  }

  static void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  static List<ScanResult> get nearbyDevices =>
      List.unmodifiable(_nearbyDevices);

  static void dispose() {
    stopScan();
  }

  static Future<bool> requestBluetoothPermissions() async {
    // For Android 12+ (API 31+)
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.location.request();

    return bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        location.isGranted;
  }
}

void showBluetoothDevices(BuildContext context) async {
  bool granted = await BluetoothService.requestBluetoothPermissions();
  if (!granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bluetooth and Location permissions are required!'),
      ),
    );
    return;
  }

  BluetoothService.startScan(
    onUpdate: (devices) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Nearby Bluetooth Devices'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(
                        device.device.name.isNotEmpty
                            ? device.device.name
                            : device.device.id.id,
                      ),
                      subtitle: Text('${device.rssi} dBm'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    BluetoothService.stopScan();
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
      );
    },
  );
}
