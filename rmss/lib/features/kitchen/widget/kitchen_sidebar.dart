import 'package:flutter/material.dart';

class KitchenSidebar extends StatefulWidget {
  // Callback function to communicate which menu index was clicked
  final Function(int) onMenuSelected; 

  const KitchenSidebar({super.key, required this.onMenuSelected});

  @override
  State<KitchenSidebar> createState() => _KitchenSidebarState();
}

class _KitchenSidebarState extends State<KitchenSidebar> {
  // State variable to track whether the sidebar is expanded or collapsed
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth animation timing
      curve: Curves.easeInOut, // Smooth acceleration curve
      width: _isExpanded ? 200 : 85, // Dynamic width toggling based on state
      color: const Color(0xFF1A1A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ==========================================
          // TOP SECTION: Interactive Logo Toggle Button
          // ==========================================
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded; // Invert the expansion state on tap
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click, // Changes cursor to hand pointer
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isExpanded ? "CROWN" : "C",
                    key: ValueKey<bool>(_isExpanded), // Forces animation switch on text change
                    style: TextStyle(
                      color: Colors.orange[400],
                      fontSize: _isExpanded ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // MIDDLE SECTION: Navigation Options
          // ==========================================
          Column(
            children: [
              _buildSidebarButton(Icons.restaurant_menu, "Orders", true, () {
                widget.onMenuSelected(0); // Switch to Dashboard (Index 0)
              }),
              const SizedBox(height: 20),
              _buildSidebarButton(Icons.calendar_today, "Availability", false, () {
                widget.onMenuSelected(1); // Switch to Availability (Index 1)
              }),
              const SizedBox(height: 20),
              _buildSidebarButton(Icons.notifications, "Notifications", false, () {
                widget.onMenuSelected(2); // Switch to Notifications (Index 2)
              }),
            ],
          ),

          // ==========================================
          // BOTTOM SECTION: Administrative Profiles
          // ==========================================
          Column(
            children: [
              _buildSidebarButton(Icons.person_outline, "Profile", false, () {
                widget.onMenuSelected(3); // Switch to Profile (Index 3)
              }),
              const SizedBox(height: 20),
              _buildSidebarButton(Icons.logout, "Logout", false, () {
                print("Logout clicked"); // Will handle Firebase logout later
              }),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  // Dynamic helper method that reshapes the layout based on the sidebar's expansion state
  Widget _buildSidebarButton(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.orange.withOpacity(0.1),
        child: Container(
          width: _isExpanded ? 180 : 70, // Expands button width dynamically
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: _isExpanded
              ? Row(
                  // Horizontal layout when expanded
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.orange[400] : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.orange[400] : Colors.grey[300],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                )
              : Column(
                  // Vertical compact layout when collapsed
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.orange[400] : Colors.grey[600],
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.orange[400] : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}