import 'package:flutter/material.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentTypes = [
      {'label': 'Theft', 'icon': Icons.lock_outline, 'color': Colors.orange},
      {'label': 'Injury', 'icon': Icons.healing, 'color': Colors.red},
      {'label': 'Missing', 'icon': Icons.person_off, 'color': Colors.purple},
      {'label': 'Need Food', 'icon': Icons.fastfood, 'color': Colors.green},
      {'label': 'Medical', 'icon': Icons.local_hospital, 'color': Colors.blue},
    ];
    final incidents = [
      {
        'type': 'Injury',
        'icon': Icons.healing,
        'color': Colors.red,
        'desc': 'Leg injury, needs urgent help',
        'time': '5 min ago',
        'location': 'Shelter #2',
        'reporter': 'Sharmin Akter',
      },
      {
        'type': 'Need Food',
        'icon': Icons.fastfood,
        'color': Colors.green,
        'desc': 'Food supplies running low',
        'time': '10 min ago',
        'location': 'Block C',
        'reporter': 'Rahim Uddin',
      },
      {
        'type': 'Missing',
        'icon': Icons.person_off,
        'color': Colors.purple,
        'desc': 'Child missing since morning',
        'time': '30 min ago',
        'location': 'Playground',
        'reporter': 'Fatema Begum',
      },
      {
        'type': 'Theft',
        'icon': Icons.lock_outline,
        'color': Colors.orange,
        'desc': 'Bag stolen from tent',
        'time': '1 hr ago',
        'location': 'Tent 12',
        'reporter': 'Jamal Hossain',
      },
      {
        'type': 'Medical',
        'icon': Icons.local_hospital,
        'color': Colors.blue,
        'desc': 'Diabetic patient needs insulin',
        'time': '2 hr ago',
        'location': 'Medical Camp',
        'reporter': 'Salma Khatun',
      },
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('RELIEFLINK'),
        backgroundColor: const Color(0xFFE31837),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Incident Types Row
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: incidentTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final t = incidentTypes[i];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: (t['color'] as Color).withOpacity(0.15),
                      child: Icon(
                        t['icon'] as IconData,
                        color: t['color'] as Color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t['label'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Reported Incidents List
          ...incidents.map((incident) => _IncidentCard(incident: incident)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFE31837),
        icon: const Icon(Icons.add),
        label: const Text('Report Incident'),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Map incident;
  const _IncidentCard({required this.incident});
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
              backgroundColor: (incident['color'] as Color).withOpacity(0.15),
              child: Icon(
                incident['icon'] as IconData,
                color: incident['color'] as Color,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        incident['type'],
                        style: TextStyle(
                          color: incident['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        incident['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(incident['desc'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        incident['location'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '- ${incident['reporter']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
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
