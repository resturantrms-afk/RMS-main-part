import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_bloc.dart';
import 'package:rmss/features/auth/bloc/auth_event.dart';
import 'package:rmss/features/auth/bloc/auth_state.dart';
import 'package:rmss/role_router_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_services.dart';
import '../../../core/constants/app_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isUploadingImage = false;

  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() {
      _isUploadingImage = true;
    });

    String finalImageUrl = '';
    if (_profileImage != null) {
      var image = await ApiServices.uploadImage(_profileImage!);
      finalImageUrl = image ?? '';
    }
    if (_profileImage == null || finalImageUrl == '') {
      finalImageUrl =
          'https://ui-avatars.com/api/?name=${_nameController.text.trim().replaceAll(' ', '+')}&background=random';
    }

    _completeSignup(finalImageUrl);

    setState(() {
      _isUploadingImage = false;
    });
  }

  void _completeSignup(String finalImageUrl) {
    context.read<AuthBloc>().add(
      SignUpRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
        password: _passwordController.text.trim(),
        photoUrl: finalImageUrl,
      ),
    );
  }

  Future<void> _pickImage() async {
    var pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleRouterScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Container(
            width: isDesktop ? 450 : double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  // Animated Logo
                  Center(
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween<double>(begin: 0.8, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Text(
                        AppConfig.appName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Fade in text animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 40 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Account",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Sign up to start managing your restaurant",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name Field
                  textFiled(controller: _nameController, hintText: "Full name"),

                  const SizedBox(height: 20),

                  // Email Field
                  textFiled(
                    controller: _emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),
                  // address
                  textFiled(
                    controller: _addressController,
                    hintText: 'Address',
                  ),

                  const SizedBox(height: 20),

                  // phone number
                  textFiled(
                    controller: _phoneNumberController,
                    hintText: "Phone number",
                    keyboardType: TextInputType.number,
                    textInputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  textFiled(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 40),

                  // Animated Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: state is AuthLoading ? 0 : 4,
                        ),
                        onPressed: state is AuthLoading || _isUploadingImage
                            ? null
                            : _signup,
                        child: state is AuthLoading || _isUploadingImage
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bottom Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Go back to login screen
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFiled({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.name,
    List<TextInputFormatter>? textInputFormatters,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: textInputFormatters ?? [],
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
