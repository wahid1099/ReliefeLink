import 'package:flutter/material.dart';

class EmergencyTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const EmergencyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  Widget _buildEmergencyType({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE31837) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildEmergencyType(
            icon: Icons.medical_services,
            label: 'Injury',
            isSelected: selectedType == 'Injury',
            onTap: () => onTypeSelected('Injury'),
          ),
          _buildEmergencyType(
            icon: Icons.door_front_door,
            label: 'Trapped',
            isSelected: selectedType == 'Trapped',
            onTap: () => onTypeSelected('Trapped'),
          ),
          _buildEmergencyType(
            icon: Icons.local_fire_department,
            label: 'Fire',
            isSelected: selectedType == 'Fire',
            onTap: () => onTypeSelected('Fire'),
          ),
          _buildEmergencyType(
            icon: Icons.water_drop,
            label: 'Flood',
            isSelected: selectedType == 'Flood',
            onTap: () => onTypeSelected('Flood'),
          ),
          _buildEmergencyType(
            icon: Icons.home_work,
            label: 'Building\nDamage',
            isSelected: selectedType == 'Building\nDamage',
            onTap: () => onTypeSelected('Building\nDamage'),
          ),
        ],
      ),
    );
  }
}
