import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmss/core/services/api_services.dart';
import 'package:rmss/core/blocs/app_branding_cubit/app_branding_cubit.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AppBrandingPage extends StatefulWidget {
  const AppBrandingPage({super.key});

  @override
  State<AppBrandingPage> createState() => _AppBrandingPageState();
}

class _AppBrandingPageState extends State<AppBrandingPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isUploadingImage = false;
  String? _pendingLogoUrl;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final branding = context.read<AppBrandingCubit>().state;
    _nameController.text = branding.appName;
    _pendingLogoUrl = branding.appLogoUrl;

    // Parse hex to color
    String hex = branding.brandColorHex.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    _selectedColor = Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _isUploadingImage = true;
      });
      try {
        final String? url = await ApiServices.uploadImage(File(image.path));
        if (url != null && mounted) {
          setState(() {
            _pendingLogoUrl = url;
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  void _saveBranding() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("App Name cannot be empty.")),
      );
      return;
    }

    String hexColor =
        '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
    context.read<AppBrandingCubit>().updateBranding(
      name,
      _pendingLogoUrl ?? '',
      hexColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("App branding updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 32),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "App Branding",
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Change the global application name and logo.",
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

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
                    "Application Logo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 2,
                          ),
                          image:
                              _pendingLogoUrl != null &&
                                  _pendingLogoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    _pendingLogoUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            _pendingLogoUrl == null || _pendingLogoUrl!.isEmpty
                            ? Icon(
                                Icons.storefront,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton.icon(
                        onPressed: _isUploadingImage
                            ? null
                            : _pickAndUploadImage,
                        icon: _isUploadingImage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload),
                        label: Text(
                          _isUploadingImage
                              ? "UPLOADING..."
                              : "UPLOAD NEW LOGO",
                        ),
                      ),
                      if (_pendingLogoUrl != null &&
                          _pendingLogoUrl!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _pendingLogoUrl = '';
                            });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("REMOVE"),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 48),

                  Text(
                    "Application Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "App Name",
                      hintText: "Enter the new name for your application",
                    ),
                  ),

                  const SizedBox(height: 48),

                  Text(
                    "Brand Color",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pick a primary brand color to be applied globally across the POS system.",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        ColorPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: (Color color) {
                            setState(() => _selectedColor = color);
                          },
                          enableAlpha: false,
                          displayThumbColor: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _saveBranding,
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
        ),
      ),
    );
  }
}
