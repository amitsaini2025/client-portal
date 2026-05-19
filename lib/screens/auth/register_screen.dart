import 'package:client/utils/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/theme_config.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/error_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(); // Added password controller

  String _gender = "Male";
  String _maritalStatus = "Single";
  String _countryCode = "+61";

  DateTime? _dob;

  bool _isLoading = false;

  String? _errorMessage;
  String? _successMessage;

  /// Show error dialog whenever there is an error
  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text("Error"),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      setState(() {
        _errorMessage = "Please select date of birth";
      });
      _showErrorDialog(_errorMessage!);
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a password";
      });
      _showErrorDialog(_errorMessage!);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,
        phone: _phoneController.text.trim(),
        countryCode: _countryCode,
        email: _emailController.text.trim(),
        dob: _dob!,
        maritalStatus: _maritalStatus,
        password: _passwordController.text.trim(),
      );

      if (result["success"]) {
        setState(() {
          _successMessage = result["message"];
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Success"),
              content: Text(result["message"] ?? "Registration successful"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = result["message"] ?? "Registration failed";
        });
        _showErrorDialog(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Unexpected error: ${e.toString()}";
      });
      _showErrorDialog(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: ThemeConfig.goldenYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 40,
                          color: ThemeConfig.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Register for the client portal",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: "First Name",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          validator:
                              (v) => v!.isEmpty ? "Enter first name" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: "Last Name",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          validator:
                              (v) => v!.isEmpty ? "Enter last name" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          validator: (v) => v!.isEmpty ? "Enter email" : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: TextFormField(
                                initialValue: _countryCode,
                                decoration: InputDecoration(
                                  labelText: "Code",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                onChanged: (v) {
                                  _countryCode = v;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                validator:
                                    (v) => v!.isEmpty ? "Enter phone" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController, // Password field
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          validator:
                              (v) => v!.isEmpty ? "Enter password" : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          initialValue: _gender,
                          decoration: InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Male",
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: "Female",
                              child: Text("Female"),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _gender = v!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          initialValue: _maritalStatus,
                          decoration: InputDecoration(
                            labelText: "Marital Status",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Single",
                              child: Text("Single"),
                            ),
                            DropdownMenuItem(
                              value: "Married",
                              child: Text("Married"),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _maritalStatus = v!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: _selectDob,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Date of Birth",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            child: Text(
                              _dob == null
                                  ? "Select Date"
                                  : DateFormat("dd/MM/yyyy").format(_dob!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.goldenYellow,
                            foregroundColor: ThemeConfig.navyBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: AppLoader(),
                                  )
                                  : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    CustomErrorWidget(message: _errorMessage!),
                  ],
                  if (_successMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeConfig.goldenYellow.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeConfig.goldenYellow.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: ThemeConfig.goldenYellow,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
