import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';

// ─────────────────────────────────────────────
// Mock data model
// ─────────────────────────────────────────────
enum StaffRole { admin, manager, staff }

enum StaffStatus { active, inactive }

class StaffMember {
  final String id;
  final String name;
  final String address;
  final String email;
  final String phone;
  final StaffStatus status;
  final StaffRole role;
  final String? avatarInitials; // used when no image
  final String? avatarUrl;

  const StaffMember({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    required this.status,
    required this.role,
    this.avatarInitials,
    this.avatarUrl,
  });
}

const _mockStaff = [
  StaffMember(
    id: '#ER-123',
    name: 'Eleanor Richards',
    address: '123 Maple St, NY',
    email: 'e.richards@bistro.com',
    phone: '(555) 123-4567',
    status: StaffStatus.active,
    role: StaffRole.admin,
    avatarInitials: 'ER',
  ),
  StaffMember(
    id: '#MC-456',
    name: 'Marcus Chen',
    address: '456 Oak Rd, CA',
    email: 'm.chen@bistro.com',
    phone: '(555) 987-6543',
    status: StaffStatus.active,
    role: StaffRole.manager,
    avatarInitials: 'MC',
  ),
  StaffMember(
    id: '#SJ-789',
    name: 'Sarah Jenkins',
    address: '789 Pine Ave, TX',
    email: 's.jenkins@bistro.com',
    phone: '(555) 234-5678',
    status: StaffStatus.inactive,
    role: StaffRole.staff,
    avatarInitials: 'SJ',
  ),
  StaffMember(
    id: '#TL-321',
    name: 'Tom Lawson',
    address: '10 River Dr, FL',
    email: 't.lawson@bistro.com',
    phone: '(555) 456-7890',
    status: StaffStatus.active,
    role: StaffRole.staff,
    avatarInitials: 'TL',
  ),
  StaffMember(
    id: '#AI-654',
    name: 'Aida Ivers',
    address: '22 Sunset Blvd, CA',
    email: 'a.ivers@bistro.com',
    phone: '(555) 654-3210',
    status: StaffStatus.active,
    role: StaffRole.manager,
    avatarInitials: 'AI',
  ),
];

// ─────────────────────────────────────────────
// Page widget
// ─────────────────────────────────────────────
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  StaffMember? _selectedStaff;

  // Search
  final TextEditingController _searchCtrl = TextEditingController();

  // Edit-panel form state (mock only)
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  StaffRole _editRole = StaffRole.admin;
  StaffStatus _editStatus = StaffStatus.active;
  bool _accountEnabled = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _selectStaff(StaffMember member) {
    setState(() {
      _selectedStaff = member;
      _nameCtrl.text = member.name;
      _emailCtrl.text = member.email;
      _addressCtrl.text = member.address;
      _editRole = member.role;
      _editStatus = member.status;
      _accountEnabled = member.status == StaffStatus.active;
    });
  }

  List<StaffMember> get _filteredStaff {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _mockStaff;
    return _mockStaff.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q) ||
          s.role.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 32),
            // ── Top bar ──────────────────────────────────────
            _TopBar(searchController: _searchCtrl),
            const SizedBox(height: 24),

            // ── Page heading ─────────────────────────────────
            Text(
              'Users Management',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Body (table + optional side panel) ───────────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table section
                  Expanded(
                    child: _StaffTable(
                      staff: _filteredStaff,
                      selectedStaff: _selectedStaff,
                      onSelect: _selectStaff,
                      onEdit: _selectStaff,
                      onDelete: (member) async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => _ConfirmDialog(
                            title: 'Delete User',
                            message:
                                'Are you sure you want to delete "${member.name}"? This action cannot be undone.',
                            confirmLabel: 'DELETE',
                            isDanger: true,
                          ),
                        );
                        if (confirm == true) {
                          setState(() => _selectedStaff = null);
                        }
                      },
                    ),
                  ),

                  // Edit panel
                  if (_selectedStaff != null) ...[
                    const SizedBox(width: 20),
                    _EditPanel(
                      staff: _selectedStaff!,
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      addressCtrl: _addressCtrl,
                      role: _editRole,
                      status: _editStatus,
                      accountEnabled: _accountEnabled,
                      onRoleChanged: (r) => setState(() => _editRole = r),
                      onStatusChanged: (s) => setState(() => _editStatus = s),
                      onToggleEnabled: (v) =>
                          setState(() => _accountEnabled = v),
                      onCancel: () => setState(() => _selectedStaff = null),
                      onSave: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => const _ConfirmDialog(
                            title: 'Save Changes',
                            message:
                                'Are you sure you want to save the changes made to this user?',
                            confirmLabel: 'SAVE',
                            isDanger: false,
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Changes saved (mock)'),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => _ConfirmDialog(
                            title: 'Delete User',
                            message:
                                'Are you sure you want to delete "${_selectedStaff!.name}"? This action cannot be undone.',
                            confirmLabel: 'DELETE',
                            isDanger: true,
                          ),
                        );
                        if (confirm == true) {
                          setState(() => _selectedStaff = null);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Top bar widget
// ─────────────────────────────────────────────
class _TopBar extends StatefulWidget {
  final TextEditingController searchController;
  const _TopBar({required this.searchController});

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Animated search field — left-aligned, expands on focus
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: _searchFocusNode.hasFocus ? 500 : 300,
          child: TextField(
            controller: widget.searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hoverColor: colorScheme.surfaceContainerHigh,
              hintText: 'Search users…',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Spacer(),
        // New user button — right next to search
        FilledButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const _AddUserDialog(),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'NEW USER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Staff table with header + rows + pagination
// ─────────────────────────────────────────────
class _StaffTable extends StatefulWidget {
  final List<StaffMember> staff;
  final StaffMember? selectedStaff;
  final ValueChanged<StaffMember> onSelect;
  final ValueChanged<StaffMember> onEdit;
  final ValueChanged<StaffMember> onDelete;

  const _StaffTable({
    required this.staff,
    required this.selectedStaff,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_StaffTable> createState() => _StaffTableState();
}

class _StaffTableState extends State<_StaffTable> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Table toolbar ────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Staff Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'EXPORT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Column headers ───────────────────────────
            Container(
              color: colorScheme.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  _headerCell('NAME', flex: 22),
                  _headerCell('ID', flex: 12),
                  _headerCell('EMAIL', flex: 22),
                  _headerCell('PHONE', flex: 16),
                  _headerCell('STATUS', flex: 13),
                  _headerCell('ROLE', flex: 13),
                  _headerCell('ACTIONS', flex: 16, align: TextAlign.right),
                ],
              ),
            ),

            // ── Rows ─────────────────────────────────────
            Expanded(
              child: widget.staff.isEmpty
                  ? Center(
                      child: Text(
                        'No staff members found.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.staff.length,
                      itemBuilder: (context, index) {
                        final member = widget.staff[index];
                        final isSelected =
                            widget.selectedStaff?.id == member.id;
                        final isInactive =
                            member.status == StaffStatus.inactive;
                        return _StaffRow(
                          member: member,
                          isSelected: isSelected,
                          isInactive: isInactive,
                          onTap: () => widget.onSelect(member),
                          onEdit: () => widget.onEdit(member),
                          onDelete: () => widget.onDelete(member),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Single staff row
// ─────────────────────────────────────────────
class _StaffRow extends StatefulWidget {
  final StaffMember member;
  final bool isSelected;
  final bool isInactive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StaffRow({
    required this.member,
    required this.isSelected,
    required this.isInactive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_StaffRow> createState() => _StaffRowState();
}

class _StaffRowState extends State<_StaffRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInactive = widget.isInactive;

    Color rowBg = Colors.transparent;
    if (widget.isSelected) {
      rowBg = colorScheme.primary.withValues(alpha: 0.08);
    } else if (_hovered) {
      rowBg = Colors.white.withValues(alpha: 0.04);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: rowBg,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Opacity(
                  opacity: isInactive ? 0.55 : 1.0,
                  child: Row(
                    children: [
                      // Name + avatar
                      Expanded(
                        flex: 22,
                        child: Row(
                          children: [
                            _Avatar(member: widget.member),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.member.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    widget.member.address,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ID
                      Expanded(
                        flex: 12,
                        child: Text(
                          widget.member.id,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      // Email
                      Expanded(
                        flex: 22,
                        child: Text(
                          widget.member.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Phone
                      Expanded(
                        flex: 16,
                        child: Text(
                          widget.member.phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      // Status
                      Expanded(
                        flex: 13,
                        child: _StatusBadge(status: widget.member.status),
                      ),

                      // Role
                      Expanded(
                        flex: 13,
                        child: _RoleBadge(role: widget.member.role),
                      ),

                      // Actions
                      Expanded(
                        flex: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _ActionBtn(
                              icon: Icons.edit_outlined,
                              onTap: widget.onEdit,
                              color: colorScheme.primary,
                              hoverColor: colorScheme.onPrimary,
                              bg: colorScheme.primary.withValues(alpha: 0.18),
                              hoverBg: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            _ActionBtn(
                              icon: Icons.delete_outline,
                              onTap: widget.onDelete,
                              color: colorScheme.onSurfaceVariant,
                              hoverColor: Colors.red.shade400,
                              bg: colorScheme.surfaceContainerLow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final StaffMember member;
  const _Avatar({required this.member});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          member.avatarInitials ?? member.name.substring(0, 2).toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final StaffStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == StaffStatus.active;
    final dotColor = isActive
        ? const Color(0xFF4ade80)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.7),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive
                ? const Color(0xFF4ade80)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Role badge
// ─────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final StaffRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Action icon button
// ─────────────────────────────────────────────
class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color hoverColor;
  final Color bg;
  final Color? hoverBg;

  const _ActionBtn({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.hoverColor,
    required this.bg,
    this.hoverBg,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered ? (widget.hoverBg ?? widget.bg) : widget.bg;
    final color = _hovered ? widget.hoverColor : widget.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(widget.icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Edit / detail panel (right side)
// ─────────────────────────────────────────────
class _EditPanel extends StatefulWidget {
  final StaffMember staff;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final StaffRole role;
  final StaffStatus status;
  final bool accountEnabled;
  final ValueChanged<StaffRole> onRoleChanged;
  final ValueChanged<StaffStatus> onStatusChanged;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _EditPanel({
    required this.staff,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.role,
    required this.status,
    required this.accountEnabled,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onToggleEnabled,
    required this.onCancel,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends State<_EditPanel> {
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Accent gradient top bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),

            // Panel header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EDIT STAFF MEMBER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Edit Staff: ${widget.staff.name.split(' ').first}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + change button
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surfaceContainerHigh,
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.staff.avatarInitials ??
                                  widget.staff.name
                                      .substring(0, 2)
                                      .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _pickImage,
                          child: Text(
                            _pickedImage != null
                                ? 'Photo Selected ✓'
                                : 'Change Picture',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    _FormField(label: 'FULL NAME', controller: widget.nameCtrl),
                    const SizedBox(height: 12),

                    // Email
                    _FormField(
                      label: 'EMAIL',
                      controller: widget.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Address
                    _FormField(
                      label: 'ADDRESS',
                      controller: widget.addressCtrl,
                    ),
                    const SizedBox(height: 12),

                    // Role dropdown
                    _DropdownField<StaffRole>(
                      label: 'ROLE',
                      value: widget.role,
                      items: StaffRole.values,
                      itemLabel: (r) => r.name.toUpperCase(),
                      onChanged: widget.onRoleChanged,
                    ),
                    const SizedBox(height: 16),

                    // Status — Active / Inactive animated toggle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              _StatusToggleOption(
                                label: 'Active',
                                icon: Icons.check_circle_outline,
                                isSelected: widget.status == StaffStatus.active,
                                selectedColor: const Color(0xFF4ade80),
                                onTap: () =>
                                    widget.onStatusChanged(StaffStatus.active),
                              ),
                              _StatusToggleOption(
                                label: 'Inactive',
                                icon: Icons.cancel_outlined,
                                isSelected:
                                    widget.status == StaffStatus.inactive,
                                selectedColor: colorScheme.error,
                                onTap: () => widget.onStatusChanged(
                                  StaffStatus.inactive,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    const _PasswordField(),
                    const SizedBox(height: 16),

                    // Footer info row
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Profile Created on: 2021',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Switch(
                          value: widget.accountEnabled,
                          onChanged: widget.onToggleEnabled,
                          activeThumbColor: colorScheme.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.8),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            side: BorderSide(color: colorScheme.outline),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.onSave,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        'DELETE USER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────
// Form field (label + text input inside a pill)
// ─────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dropdown field
// ─────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final Color? valueColor;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainer,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.onSurface,
              ),
              icon: Icon(
                Icons.expand_more,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Password field (mock – shows dots, edit icon)
// ─────────────────────────────────────────────
class _PasswordField extends StatefulWidget {
  const _PasswordField();

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  final _ctrl = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  obscureText: _obscure,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: _obscure ? 4 : 0,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.edit_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add New User dialog
// ─────────────────────────────────────────────
class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  StaffRole _role = StaffRole.manager;
  StaffStatus _status = StaffStatus.active;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.18),
                      colorScheme.primary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Fill in the details to create a new staff account.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form body ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Row 1: Full name + Email
                    Row(
                      children: [
                        Expanded(
                          child: _DialogField(
                            label: 'Full Name',
                            controller: _nameCtrl,
                            hint: 'e.g. Jane Smith',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogField(
                            label: 'Email',
                            controller: _emailCtrl,
                            hint: 'jane@example.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 2: Phone + Address
                    Row(
                      children: [
                        Expanded(
                          child: _DialogField(
                            label: 'Phone',
                            controller: _phoneCtrl,
                            hint: '+1 234 567 8900',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogField(
                            label: 'Address',
                            controller: _addressCtrl,
                            hint: '123 Main St',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Role + Status dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: _DialogDropdown<StaffRole>(
                            label: 'Role',
                            value: _role,
                            items: StaffRole.values,
                            itemLabel: (r) =>
                                r.name[0].toUpperCase() + r.name.substring(1),
                            onChanged: (r) => setState(() => _role = r!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogDropdown<StaffStatus>(
                            label: 'Status',
                            value: _status,
                            items: StaffStatus.values,
                            itemLabel: (s) =>
                                s == StaffStatus.active ? 'Active' : 'Inactive',
                            onChanged: (s) => setState(() => _status = s!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _DialogField(
                      label: 'Password',
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Actions ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        // mock — just close
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'User "${_nameCtrl.text}" created (mock)',
                            ),
                            backgroundColor: colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'CREATE USER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper: labelled text field for dialog
class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// Helper: labelled dropdown for dialog
class _DialogDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DialogDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainer,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              onChanged: onChanged,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Status toggle option (Active / Inactive pill)
// ─────────────────────────────────────────────
class _StatusToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _StatusToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isSelected
                ? Border.all(color: selectedColor.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? selectedColor
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? selectedColor
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Confirmation dialog
// ─────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmColor = isDanger ? colorScheme.error : colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: confirmColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDanger
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: confirmColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.outlineVariant),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: isDanger
                          ? colorScheme.onError
                          : colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
