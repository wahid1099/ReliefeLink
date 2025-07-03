import 'package:flutter/material.dart';
import 'home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Services Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.emergency, color: Colors.white),
                  label: const Text(
                    'Emergency Services',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE31837),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE31837),
                      width: 8,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE31837),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'RL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title and Subtitle
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you will use ReliefLink',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Role Options
              _buildRoleOption(
                icon: Icons.person_outline,
                title: 'Civilian',
                subtitle: 'Get help during emergencies',
                isSelected: _selectedRole == 'civilian',
                isHighlighted: _selectedRole == 'civilian',
                onTap: () => _handleRoleSelection('civilian'),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                icon: Icons.volunteer_activism,
                title: 'Volunteer',
                subtitle: 'Assist in relief operations',
                isSelected: _selectedRole == 'volunteer',
                isHighlighted: _selectedRole == 'volunteer',
                onTap: () => _handleRoleSelection('volunteer'),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                icon: Icons.business,
                title: 'NGO Admin',
                subtitle: 'Manage relief resources',
                isSelected: _selectedRole == 'ngo_admin',
                isHighlighted: _selectedRole == 'ngo_admin',
                onTap: () => _handleRoleSelection('ngo_admin'),
              ),
              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _selectedRole != null ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRoleSelection(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _handleContinue() {
    if (_selectedRole != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFE31837) : Colors.white,
        border: Border.all(color: const Color(0xFFE31837), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isHighlighted ? Colors.white : const Color(0xFFE31837),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isHighlighted
                                  ? Colors.white
                                  : const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isHighlighted
                                  ? Colors.white70
                                  : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isHighlighted ? Colors.white : const Color(0xFFE31837),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
