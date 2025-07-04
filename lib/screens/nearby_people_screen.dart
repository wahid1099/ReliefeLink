import 'package:flutter/material.dart';

class NearbyPeopleScreen extends StatelessWidget {
  const NearbyPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = [
      {
        'name': 'Sarah Chen',
        'role': 'Medical',
        'distance': '15m',
        'status': 'Needs Help',
        'statusColor': Colors.red,
        'battery': 45,
        'isHelp': true,
      },
      {
        'name': 'Michael Rodriguez',
        'role': 'Volunteer',
        'distance': '30m',
        'status': 'Available',
        'statusColor': Colors.blue,
        'battery': 78,
        'isHelp': false,
      },
      {
        'name': 'David Kim',
        'role': 'Rescue',
        'distance': '50m',
        'status': 'Online',
        'statusColor': Colors.green,
        'battery': 92,
        'isHelp': false,
      },
      {
        'name': 'Lisa Johnson',
        'role': 'Medical',
        'distance': '75m',
        'status': 'Available',
        'statusColor': Colors.blue,
        'battery': 65,
        'isHelp': false,
      },
      {
        'name': 'James Wilson',
        'role': 'Coordinator',
        'distance': '100m',
        'status': 'Needs Help',
        'statusColor': Colors.red,
        'battery': 23,
        'isHelp': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('RELIEFLINK'),
        backgroundColor: const Color(0xFFE31837),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mesh Network Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi, color: Colors.red),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mesh Network:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '12 Devices Connected',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Network Visualization Placeholder
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network Visualization',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const Text(
                      'Network Graph Here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      CircleAvatar(radius: 6, backgroundColor: Colors.green),
                      SizedBox(width: 4),
                      Text('Online (7)', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 12),
                      CircleAvatar(radius: 6, backgroundColor: Colors.red),
                      SizedBox(width: 4),
                      Text('Needs Help (3)', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 12),
                      CircleAvatar(radius: 6, backgroundColor: Colors.blue),
                      SizedBox(width: 4),
                      Text('Volunteer (2)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Bar
          Row(
            children: [
              const Text(
                'Nearby People',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status Tabs
          Row(
            children: [
              _StatusTab(label: 'Status', selected: true),
              _StatusTab(label: 'Distance'),
              _StatusTab(label: 'Need help'),
            ],
          ),
          const SizedBox(height: 8),
          // People List
          ...people.map((person) => _NearbyPersonCard(person: person)),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _StatusTab({required this.label, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE31837) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NearbyPersonCard extends StatelessWidget {
  final Map person;
  const _NearbyPersonCard({required this.person});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              child: Text(
                person['name'][0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        person['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: person['statusColor'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          person['status'],
                          style: TextStyle(
                            color: person['statusColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${person['role']} • ${person['distance']} away',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.battery_full,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${person['battery']}%',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: List.generate(
                          4,
                          (i) => Icon(
                            Icons.circle,
                            size: 6,
                            color: i < 3 ? Colors.grey[700] : Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Message'),
                      ),
                      const SizedBox(width: 12),
                      if (person['isHelp'])
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE31837),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Offer Help'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
