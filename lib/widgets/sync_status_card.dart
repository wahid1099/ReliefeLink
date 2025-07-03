import 'package:flutter/material.dart';

class SyncStatusCard extends StatelessWidget {
  final bool isMeshActive;
  final int nearbyUsersCount;

  const SyncStatusCard({
    super.key,
    required this.isMeshActive,
    required this.nearbyUsersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sync Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildCard(
          icon: Icons.wifi_tethering,
          color: Colors.yellow,
          bgColor: Colors.yellow[50]!,
          borderColor: Colors.yellow[100]!,
          title:
              isMeshActive
                  ? 'Connected to $nearbyUsersCount nearby devices'
                  : 'Mesh not active',
          subtitle:
              isMeshActive
                  ? 'Alert will be shared with nearby devices'
                  : 'Turn on Bluetooth/Mesh to share alert',
        ),
        const SizedBox(height: 8),
        _buildCard(
          icon: Icons.sms,
          color: Colors.orange,
          bgColor: Colors.orange[50]!,
          borderColor: Colors.orange[100]!,
          title: 'SMS sync pending',
          subtitle: 'Waiting for cellular connection',
        ),
        const SizedBox(height: 8),
        _buildCard(
          icon: Icons.cloud_done,
          color: Colors.green,
          bgColor: Colors.green[50]!,
          borderColor: Colors.green[100]!,
          title: 'Sent to cloud',
          subtitle: 'Alert successfully delivered',
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
