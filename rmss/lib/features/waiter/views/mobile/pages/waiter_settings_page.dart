import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/services/api_services.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaiterSettingsPage extends StatefulWidget {
  const WaiterSettingsPage({super.key});

  @override
  State<WaiterSettingsPage> createState() => _WaiterSettingsPageState();
}

class _WaiterSettingsPageState extends State<WaiterSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  bool _soundAlerts = true;
  bool _cleaningAlerts = true;
  double _alertVolume = 75.0;

  bool _isEditingName = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundAlerts = prefs.getBool('soundAlerts') ?? true;
      _cleaningAlerts = prefs.getBool('cleaningAlerts') ?? true;
      _alertVolume = prefs.getDouble('alertVolume') ?? 75.0;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colorScheme.onPrimary,
          activeTrackColor: colorScheme.primary,
        ),
      ],
    );
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your account profile and system preferences.",
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: _isUploadingImage
                              ? null
                              : () => _pickAndUploadImage(context),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: photoUrl.isNotEmpty
                                        ? CachedNetworkImageProvider(photoUrl)
                                        : const NetworkImage(
                                                "https://ui-avatars.com/api/?name=Staff&background=E88328&color=fff",
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (_isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                )
                              else
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.outlineVariant,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Editable Name
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
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

                        const SizedBox(height: 24),
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
                              role == "noRole" ? "Admin" : role,
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

                  const SizedBox(height: 24),

                  // Preferences Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preferences",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: colorScheme.surfaceContainerHigh),
                        const SizedBox(height: 24),

                        // Theme Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Appearance",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Switch between light and dark modes.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
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

                        const SizedBox(height: 32),

                        // Notification Alerts Group
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notification Alerts",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Toggle: Ready Orders
                              _buildNotificationToggle(
                                "Ready Orders",
                                "Sound alert for tickets.",
                                Icons.notifications_active,
                                _soundAlerts,
                                (val) {
                                  setState(() {
                                    _soundAlerts = val;
                                  });
                                },
                                colorScheme,
                              ),
                              const SizedBox(height: 16),

                              // Toggle: Cleaning Tables
                              _buildNotificationToggle(
                                "Cleaning Tables",
                                "Alert when a table needs cleaning.",
                                Icons.cleaning_services,
                                _cleaningAlerts,
                                (val) {
                                  setState(() {
                                    _cleaningAlerts = val;
                                  });
                                },
                                colorScheme,
                              ),

                              const SizedBox(height: 16),
                              Divider(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 16),

                              // Volume Slider
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Alert Volume",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${_alertVolume.toInt()}%",
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.volume_mute,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 20,
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
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('soundAlerts', _soundAlerts);
                              await prefs.setBool('cleaningAlerts', _cleaningAlerts);
                              await prefs.setDouble('alertVolume', _alertVolume);
                              
                              if (context.mounted) {
                                context.read<AuthBloc>().add(
                                  UpdateProfileRequested(
                                    pushNotificationsEnabled: _soundAlerts,
                                    pushCleaningAlertsEnabled: _cleaningAlerts,
                                  ),
                                );

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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
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
    );
  }
}
