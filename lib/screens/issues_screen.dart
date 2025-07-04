import 'package:flutter/material.dart';
import 'package:relieflink/models/incident.dart';
import 'package:relieflink/services/incident_service.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final IncidentService _incidentService = IncidentService();
  List<Incident> _incidents = [];
  bool _loading = true;

  final List<Map<String, dynamic>> incidentTypes = [
    {'label': 'Theft', 'icon': Icons.lock_outline, 'color': Colors.orange},
    {'label': 'Injury', 'icon': Icons.healing, 'color': Colors.red},
    {'label': 'Missing', 'icon': Icons.person_off, 'color': Colors.purple},
    {'label': 'Need Food', 'icon': Icons.fastfood, 'color': Colors.green},
    {'label': 'Medical', 'icon': Icons.local_hospital, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    final incidents = await _incidentService.getIncidents();
    setState(() {
      _incidents = incidents;
      _loading = false;
    });
  }

  Future<void> _showReportIncidentDialog() async {
    String? selectedType = incidentTypes[0]['label'];
    String description = '';
    String location = '';
    String reporter = '';
    Color selectedColor = incidentTypes[0]['color'];
    IconData selectedIcon = incidentTypes[0]['icon'];

    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Incident'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items:
                          incidentTypes
                              .map(
                                (t) => DropdownMenuItem<String>(
                                  value: t['label'] as String,
                                  child: Row(
                                    children: [
                                      Icon(
                                        t['icon'] as IconData,
                                        color: t['color'] as Color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(t['label'] as String),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        final t = incidentTypes.firstWhere(
                          (e) => e['label'] == val,
                        );
                        selectedType = t['label'];
                        selectedColor = t['color'];
                        selectedIcon = t['icon'];
                      },
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: (val) => description = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      onChanged: (val) => location = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Your Name'),
                      onChanged: (val) => reporter = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final incident = Incident(
                      type: selectedType!,
                      description: description,
                      location: location,
                      reporter: reporter,
                      timestamp: DateTime.now(),
                      color: selectedColor,
                      icon: selectedIcon,
                    );
                    await _incidentService.addIncident(incident);
                    // TODO: Check for internet/mesh and sync if available
                    Navigator.pop(context);
                    _loadIncidents();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('RELIEFLINK'),
        backgroundColor: const Color(0xFFE31837),
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
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
                              backgroundColor: (t['color'] as Color)
                                  .withOpacity(0.15),
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
                  ..._incidents.map(
                    (incident) => _IncidentCard(incident: incident),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportIncidentDialog,
        backgroundColor: const Color(0xFFE31837),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Report Incident'),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
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
              backgroundColor: incident.color.withOpacity(0.15),
              child: Icon(incident.icon, color: incident.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        incident.type,
                        style: TextStyle(
                          color: incident.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(incident.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incident.description,
                    style: const TextStyle(fontSize: 15),
                  ),
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
                        incident.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '- ${incident.reporter}',
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

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}
