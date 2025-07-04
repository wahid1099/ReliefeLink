import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          title: Row(
            children: const [
              Icon(Icons.settings, color: Colors.white),
              SizedBox(width: 8),
              Text('SETTINGS'),
            ],
          ),
          backgroundColor: const Color(0xFFE31837),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            tabs: const [Tab(text: 'Profile'), Tab(text: 'Settings')],
          ),
        ),
        body: TabBarView(
          children: [
            _ProfileTab(),
            Center(
              child: Text('Settings Tab', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // Profile photo and name
        Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/women/68.jpg',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MD WAHID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SAFEMODE',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ID Number
        _ProfileInfoCard(label: 'ID NUMBER', value: 'REL-2023-FC-1024'),
        const SizedBox(height: 16),
        // Emergency Contact
        _ProfileInfoCard(
          label: 'EMERGENCY CONTACT',
          value: 'Rahim Uddin\n+880 1711-123456',
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View Full Profile'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Language
        const Text(
          'LANGUAGE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 244, 241, 241),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.language, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'App Language',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('English'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('বাংলা'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Connection Settings
        const Text(
          'CONNECTION SETTINGS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bluetooth, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Bluetooth Sync',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Switch(value: true, onChanged: (v) {}),
                  ],
                ),
                const Text(
                  'Connected',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sync data with nearby team members when internet is unavailable',
                  style: TextStyle(fontSize: 13),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.battery_alert, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'SMS Sync',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Switch(value: false, onChanged: (v) {}),
                  ],
                ),
                const Text(
                  'Disabled',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send critical updates via SMS when data connection is limited',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Storage Management
        const Text(
          'STORAGE MANAGEMENT',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.apps, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Offline Storage',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text(
                      '3.2 GB / 5 GB',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 3.2 / 5,
                  color: Colors.purple,
                  backgroundColor: Colors.purple[50],
                ),
                const SizedBox(height: 12),
                _StorageBar(label: 'Messages', value: 1.2, color: Colors.blue),
                _StorageBar(label: 'Maps', value: 0.8, color: Colors.green),
                _StorageBar(label: 'Images', value: 1.2, color: Colors.orange),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Clear Cache',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileInfoCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StorageBar({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 5,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(1)} GB',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
