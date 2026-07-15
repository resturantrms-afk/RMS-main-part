import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/services/api_services.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  bool _soundAlerts = true;
  double _alertVolume = 75.0;

  bool _isEditingName = false;
  bool _isHoveringPhoto = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundAlerts = prefs.getBool('adminSoundAlerts') ?? true;
      _alertVolume = prefs.getDouble('adminAlertVolume') ?? 75.0;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && context.mounted) {
      setState(() {
        _isUploadingImage = true;
      });
      try {
        final String? url = await ApiServices.uploadImage(File(image.path));
        if (url != null && context.mounted) {
          context.read<AuthBloc>().add(UpdateProfileRequested(photoUrl: url));
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (context.mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 32),

            // Page Header
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Manage your account profile and system preferences.",
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            // Settings Grid (One column for now, can be responsive later)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String name = "Staff";
                String email = "unknown@domain.com";
                String role = "Staff";
                String photoUrl = "";

                if (authState is AuthSuccess) {
                  name = authState.user.name;
                  email = authState.user.email;
                  role = authState.user.role.name;
                  photoUrl = authState.user.photoUrl;

                  if (!_isEditingName) {
                    _nameController.text = name;
                  }
                }

                return Column(
                  children: [
                    // Profile Section
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar with Hover Overlay
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) =>
                                setState(() => _isHoveringPhoto = true),
                            onExit: (_) =>
                                setState(() => _isHoveringPhoto = false),
                            child: GestureDetector(
                              onTap: _isUploadingImage
                                  ? null
                                  : () => _pickAndUploadImage(context),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: photoUrl.isNotEmpty
                                            ? CachedNetworkImageProvider(
                                                photoUrl,
                                              )
                                            : const NetworkImage(
                                                    "https://ui-avatars.com/api/?name=Staff&background=E88328&color=fff",
                                                  )
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (_isHoveringPhoto || _isUploadingImage)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_isUploadingImage)
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            else ...[
                                              const Icon(
                                                Icons.photo_camera,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                "CHANGE",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Editable Name
                          SizedBox(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if (!_isEditingName) {
                                        setState(() {
                                          _isEditingName = true;
                                        });
                                      }
                                    },
                                    onSubmitted: (val) {
                                      setState(() {
                                        _isEditingName = false;
                                      });
                                      if (val.isNotEmpty && val != name) {
                                        context.read<AuthBloc>().add(
                                          UpdateProfileRequested(name: val),
                                        );
                                      }
                                    },
                                    onTapOutside: (_) {
                                      setState(() {
                                        _isEditingName = false;
                                      });
                                      if (_nameController.text.isNotEmpty &&
                                          _nameController.text != name) {
                                        context.read<AuthBloc>().add(
                                          UpdateProfileRequested(
                                            name: _nameController.text,
                                          ),
                                        );
                                      } else {
                                        _nameController.text = name;
                                      }
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.edit,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),

                          Text(
                            role,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 32),
                          Divider(color: colorScheme.surfaceContainerHigh),
                          const SizedBox(height: 24),

                          // Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Email",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Role",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                role == "noRole"
                                    ? "Admin"
                                    : role, // fallback for testing
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Preferences Section
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Preferences",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: colorScheme.surfaceContainerHigh),
                          const SizedBox(height: 32),

                          // Theme Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Appearance",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Switch between light and dark modes.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              BlocBuilder<ThemeCubit, ThemeMode>(
                                builder: (context, themeState) {
                                  return Switch(
                                    value: themeState == ThemeMode.dark,
                                    onChanged: (val) {
                                      context.read<ThemeCubit>().toggleTheme();
                                    },
                                    activeThumbColor: colorScheme.onPrimary,
                                    activeTrackColor: colorScheme.primary,
                                    inactiveThumbColor:
                                        colorScheme.onSurfaceVariant,
                                    inactiveTrackColor:
                                        colorScheme.surfaceContainerHighest,
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Notification Alerts Group
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                  spreadRadius: -2,
                                  // inner shadow effect conceptually
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notification Alerts",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Toggle: Served Orders
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: colorScheme.surfaceContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.notifications_active,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Served Orders",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              "Sound alert for incoming tickets.",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _soundAlerts,
                                      onChanged: (val) {
                                        setState(() {
                                          _soundAlerts = val;
                                        });
                                      },
                                      activeThumbColor: colorScheme.onPrimary,
                                      activeTrackColor: colorScheme.primary,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                Divider(color: colorScheme.surfaceContainer),
                                const SizedBox(height: 24),

                                // Volume Slider
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Alert Volume",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      "${_alertVolume.toInt()}%",
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.volume_mute,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _alertVolume,
                                        min: 0,
                                        max: 100,
                                        activeColor: colorScheme.primary,
                                        inactiveColor:
                                            colorScheme.surfaceContainerHighest,
                                        onChanged: (val) {
                                          setState(() {
                                            _alertVolume = val;
                                          });
                                        },
                                      ),
                                    ),
                                    Icon(
                                      Icons.volume_up,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                    'adminSoundAlerts',
                                    _soundAlerts,
                                  );
                                  await prefs.setDouble(
                                    'adminAlertVolume',
                                    _alertVolume,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Preferences Saved"),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  elevation: 8,
                                  shadowColor: colorScheme.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                                child: const Text(
                                  "SAVE CHANGES",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
