import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:provider/provider.dart';
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/utils/constants.dart';

// Enum for Auth Mode
enum AuthMode { Login, SignUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // For registration
  AuthMode _authMode = AuthMode.Login; // Use the enum
  bool _isLoading = false;

  Uint8List? _imageBytes; // Store image bytes
  String? _imageName; // Store image name

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.Login ? AuthMode.SignUp : AuthMode.Login;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes(); // Read as bytes
      setState(() {
        _imageBytes = bytes; // Store the bytes
        _imageName = image.name;
      });
    }
  }

  void _submitForm(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await authProvider.signInWithEmailAndPassword(
            _emailController.text, _passwordController.text);
      } else {
        // Sign Up *with image*
        if (_imageBytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Please select an image'),
                  backgroundColor: AppColors.error),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        await authProvider.signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _imageBytes, // Pass image bytes
          _imageName!,
        );
      }
      // No navigation here; main.dart handles it based on AuthProvider state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Authentication failed: ${e.toString()}'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure loading indicator is hidden
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _authMode == AuthMode.Login ? 'Welcome!' : "Join us Today",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 20),

                // Image Picker (only in sign-up mode)
                if (_authMode == AuthMode.SignUp) ...[
                  GestureDetector(
                    onTap: _pickImage, // Call the image picker
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : null, // Use MemoryImage
                      child: _imageBytes == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null, // Show icon if no image
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_authMode == AuthMode.SignUp) // Name field for sign-up
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _submitForm(authProvider),
                        child: Text(
                            _authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
                      ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(_authMode == AuthMode.Login
                      ? 'Create an account'
                      : 'I already have an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
