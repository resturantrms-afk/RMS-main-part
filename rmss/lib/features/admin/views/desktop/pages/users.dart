import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_bloc.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_event.dart';
import 'package:rmss/features/admin/blocs/users_bloc/admin_users_state.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';

// ─────────────────────────────────────────────
// Page widget
// ─────────────────────────────────────────────
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  UserModel? _selectedUser;

  final TextEditingController _searchCtrl = TextEditingController();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  UserRoles _editRole = UserRoles.waiter;
  UserStatus _editStatus = UserStatus.active;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    context.read<AdminUsersBloc>().add(LoadAllUsers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUser = user;
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _addressCtrl.text = user.address;
      _phoneCtrl.text = user.phoneNumber;
      _editRole = user.role;
      _editStatus = user.status;
    });
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.id.toLowerCase().contains(q) ||
          u.role.name.toLowerCase().contains(q);
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
            const SizedBox(height: 24),

            // ── Header row ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Breadcrumb + title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        Text(
                          'Users',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        children: [
                          const TextSpan(text: 'Staff '),
                          TextSpan(
                            text: 'Management',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Search
                _SearchBar(searchController: _searchCtrl),
                const SizedBox(width: 16),

                // Add user button
                _AddUserButton(),
              ],
            ),

            const SizedBox(height: 32),

            // ── Body (table + optional side panel) ───────────
            Expanded(
              child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                builder: (context, state) {
                  if (state is AdminUsersLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Users...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AdminUsersError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              size: 48,
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Users',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allUsers =
                      state is AdminUsersLoaded ? state.allUsers : <UserModel>[];
                  final filtered = _filterUsers(allUsers);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Staff table ───────────────────────────────
                      Expanded(
                        child: _StaffTable(
                          users: filtered,
                          selectedUser: _selectedUser,
                          onSelect: _selectUser,
                          onEdit: _selectUser,
                          onDelete: (user) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => _ConfirmDialog(
                                title: 'Delete User',
                                message:
                                    'Are you sure you want to delete "${user.name}"? This action cannot be undone.',
                                confirmLabel: 'DELETE',
                                isDanger: true,
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context
                                  .read<AdminUsersBloc>()
                                  .add(DeleteUser(userId: user.id));
                              setState(() => _selectedUser = null);
                            }
                          },
                        ),
                      ),

                      // ── Edit panel ───────────────────────────────
                      if (_selectedUser != null) ...[
                        const SizedBox(width: 20),
                        _EditPanel(
                          user: _selectedUser!,
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          addressCtrl: _addressCtrl,
                          phoneCtrl: _phoneCtrl,
                          role: _editRole,
                          status: _editStatus,
                          onRoleChanged: (r) => setState(() => _editRole = r),
                          onStatusChanged: (s) =>
                              setState(() => _editStatus = s),
                          onCancel: () =>
                              setState(() => _selectedUser = null),
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
                              final updated = _selectedUser!.copyWith(
                                name: _nameCtrl.text,
                                email: _emailCtrl.text,
                                address: _addressCtrl.text,
                                phoneNumber: _phoneCtrl.text,
                                role: _editRole,
                                status: _editStatus,
                              );
                              context
                                  .read<AdminUsersBloc>()
                                  .add(UpdateUser(user: updated));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('User updated successfully'),
                                  backgroundColor: colorScheme.primary,
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
                                    'Are you sure you want to delete "${_selectedUser!.name}"? This action cannot be undone.',
                                confirmLabel: 'DELETE',
                                isDanger: true,
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context
                                  .read<AdminUsersBloc>()
                                  .add(DeleteUser(userId: _selectedUser!.id));
                              setState(() => _selectedUser = null);
                            }
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  final TextEditingController searchController;
  const _SearchBar({required this.searchController});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: _focus.hasFocus ? 420 : 260,
      child: TextField(
        controller: widget.searchController,
        focusNode: _focus,
        decoration: InputDecoration(
          hintText: 'Search users…',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add user button (opens dialog)
// ─────────────────────────────────────────────
class _AddUserButton extends StatefulWidget {
  @override
  State<_AddUserButton> createState() => _AddUserButtonState();
}

class _AddUserButtonState extends State<_AddUserButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<AdminUsersBloc>(),
              child: const _AddUserDialog(),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_outlined,
                    color: colorScheme.onPrimary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'NEW USER',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Staff table – payments-style row layout
// ─────────────────────────────────────────────
class _StaffTable extends StatelessWidget {
  final List<UserModel> users;
  final UserModel? selectedUser;
  final ValueChanged<UserModel> onSelect;
  final ValueChanged<UserModel> onEdit;
  final ValueChanged<UserModel> onDelete;

  const _StaffTable({
    required this.users,
    required this.selectedUser,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Column headers (payments-style) ───────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 18, child: _headerText('Name')),
              Expanded(flex: 10, child: _headerText('ID')),
              Expanded(flex: 18, child: _headerText('Email')),
              Expanded(flex: 13, child: _headerText('Phone')),
              Expanded(flex: 10, child: _headerText('Status')),
              Expanded(flex: 10, child: _headerText('Role')),
              Expanded(
                flex: 10,
                child: _headerText('Actions', textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Rows ─────────────────────────────────────────
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = selectedUser?.id == user.id;
                    return _UserRow(
                      user: user,
                      isSelected: isSelected,
                      onTap: () => onSelect(user),
                      onEdit: () => onEdit(user),
                      onDelete: () => onDelete(user),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _headerText(String text, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Single user row – payments-style card
// ─────────────────────────────────────────────
class _UserRow extends StatefulWidget {
  final UserModel user;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserRow({
    required this.user,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInactive = widget.user.status == UserStatus.inactive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : _hovered
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.06),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Opacity(
          opacity: isInactive ? 0.6 : 1.0,
          child: Row(
            children: [
              // ── Name + avatar ───────────────────────────
              Expanded(
                flex: 18,
                child: Row(
                  children: [
                    _Avatar(user: widget.user),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.user.address,
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

              // ── ID ──────────────────────────────────────
              Expanded(
                flex: 10,
                child: Text(
                  widget.user.id.length > 6
                      ? '#${widget.user.id.substring(0, 6).toUpperCase()}'
                      : '#${widget.user.id.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // ── Email ────────────────────────────────────
              Expanded(
                flex: 18,
                child: Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Phone ────────────────────────────────────
              Expanded(
                flex: 13,
                child: Text(
                  widget.user.phoneNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // ── Status ───────────────────────────────────
              Expanded(
                flex: 10,
                child: _StatusBadge(status: widget.user.status),
              ),

              // ── Role ─────────────────────────────────────
              Expanded(
                flex: 10,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      widget.user.role.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Actions ──────────────────────────────────
              Expanded(
                flex: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: colorScheme.primary,
                      tooltip: 'Edit User',
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: colorScheme.error,
                      tooltip: 'Delete User',
                      onPressed: widget.onDelete,
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

// ─────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final UserModel user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '??';
    final hasUrl = user.photoUrl.isNotEmpty && user.photoUrl != 'invalid';

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? CachedNetworkImage(
              imageUrl: user.photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initials,
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
  final UserStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == UserStatus.active;
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
// Edit / detail panel (right side)
// ─────────────────────────────────────────────
class _EditPanel extends StatefulWidget {
  final UserModel user;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final UserRoles role;
  final UserStatus status;
  final ValueChanged<UserRoles> onRoleChanged;
  final ValueChanged<UserStatus> onStatusChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _EditPanel({
    required this.user,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.role,
    required this.status,
    required this.onRoleChanged,
    required this.onStatusChanged,
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
    final initials = widget.user.name.isNotEmpty
        ? widget.user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '??';

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
                    'Edit: ${widget.user.name.split(' ').first}',
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
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: Text(
                              initials,
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

                    // Phone
                    _FormField(
                      label: 'PHONE',
                      controller: widget.phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Address
                    _FormField(
                      label: 'ADDRESS',
                      controller: widget.addressCtrl,
                    ),
                    const SizedBox(height: 12),

                    // Role dropdown
                    _DropdownField<UserRoles>(
                      label: 'ROLE',
                      value: widget.role,
                      items: UserRoles.values,
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
                            border: Border.all(color: colorScheme.outlineVariant),
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
                                isSelected:
                                    widget.status == UserStatus.active,
                                selectedColor: const Color(0xFF4ade80),
                                onTap: () =>
                                    widget.onStatusChanged(UserStatus.active),
                              ),
                              _StatusToggleOption(
                                label: 'Inactive',
                                icon: Icons.cancel_outlined,
                                isSelected:
                                    widget.status == UserStatus.inactive,
                                selectedColor: colorScheme.error,
                                onTap: () => widget.onStatusChanged(
                                  UserStatus.inactive,
                                ),
                              ),
                            ],
                          ),
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
// Form field (label + text input)
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

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
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
                color: colorScheme.onSurface,
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
  UserRoles _role = UserRoles.waiter;
  UserStatus _status = UserStatus.active;
  bool _isLoading = false;

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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
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
                          'New Staff Member',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Fill in the details to create a new account.',
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
                          child: _DialogDropdown<UserRoles>(
                            label: 'Role',
                            value: _role,
                            items: UserRoles.values,
                            itemLabel: (r) =>
                                r.name[0].toUpperCase() + r.name.substring(1),
                            onChanged: (r) => setState(() => _role = r!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogDropdown<UserStatus>(
                            label: 'Status',
                            value: _status,
                            items: UserStatus.values,
                            itemLabel: (s) =>
                                s == UserStatus.active ? 'Active' : 'Inactive',
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
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_nameCtrl.text.trim().isEmpty ||
                                  _emailCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Name and Email are required.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => _isLoading = true);
                              final userData = {
                                'name': _nameCtrl.text.trim(),
                                'email': _emailCtrl.text.trim(),
                                'phoneNumber': _phoneCtrl.text.trim(),
                                'address': _addressCtrl.text.trim(),
                                'role': _role.name,
                                'status': _status.name,
                                'photoUrl': '',
                                'deviceToken': '',
                                'createdDate': Timestamp.now(),
                                'lastLoginDate': Timestamp.now(),
                              };
                              if (context.mounted) {
                                context.read<AdminUsersBloc>().add(
                                  AddUser(
                                    userData: userData,
                                    password: _passwordCtrl.text,
                                  ),
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'User "${_nameCtrl.text.trim()}" created successfully',
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
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
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
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
            prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                      foregroundColor:
                          isDanger ? colorScheme.onError : colorScheme.onPrimary,
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
