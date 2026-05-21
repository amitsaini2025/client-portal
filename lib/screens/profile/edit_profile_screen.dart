import 'package:client/config/theme_config.dart';
import 'package:client/services/api_service.dart';
import 'package:client/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_loader.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _countryController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedMaritalStatus;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;
  String? _submitError;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final response = await ApiService.getClientProfile();
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _firstNameController.text = (data['first_name'] ?? '').toString();
        _lastNameController.text = (data['last_name'] ?? '').toString();
        _emailController.text = (data['email'] ?? '').toString();
        _phoneController.text = (data['phone'] ?? '').toString();
        _addressController.text = (data['address'] ?? '').toString();
        _cityController.text = (data['city'] ?? '').toString();
        _stateController.text = (data['state'] ?? '').toString();
        _postCodeController.text =
            (data['zip'] ?? data['post_code'] ?? '').toString();
        _countryController.text = (data['country'] ?? '').toString();

        final dobValue = data['dob'] ?? data['date_of_birth'];
        if (dobValue is String && dobValue.isNotEmpty) {
          final parsed = DateTime.tryParse(dobValue);
          _selectedDateOfBirth = parsed;
        }

        final genderValue = data['gender']?.toString();
        if (genderValue != null && _genders.contains(genderValue)) {
          _selectedGender = genderValue;
        }

        final maritalStatusValue = data['marital_status']?.toString();
        if (maritalStatusValue != null &&
            _maritalStatuses.contains(maritalStatusValue)) {
          _selectedMaritalStatus = maritalStatusValue;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _loadError =
              response['message']?.toString() ?? 'Failed to load profile data.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate =
        _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final payload = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      if (_lastNameController.text.trim().isNotEmpty)
        'last_name': _lastNameController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'email': _emailController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_cityController.text.trim().isNotEmpty)
        'city': _cityController.text.trim(),
      if (_stateController.text.trim().isNotEmpty)
        'state': _stateController.text.trim(),
      if (_postCodeController.text.trim().isNotEmpty)
        'post_code': _postCodeController.text.trim(),
      if (_countryController.text.trim().isNotEmpty)
        'country': _countryController.text.trim(),
      if (_selectedDateOfBirth != null)
        'dob': DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
      if (_selectedGender != null) 'gender': _selectedGender,
      if (_selectedMaritalStatus != null)
        'marital_status': _selectedMaritalStatus,
    };

    try {
      final response = await ApiService.updateClientProfile(payload);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _submitError =
              response['message']?.toString() ?? 'Failed to update profile.';
        });
      }
    } catch (e) {
      setState(() {
        _submitError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usable viewport height (minus AppBar and safe areas) for centering
    // loader/error states inside the scroll view.
    final viewportHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client Information'),
        backgroundColor: ThemeConfig.goldenYellow,
        foregroundColor: Colors.white,
      ),
      // ── KEY CHANGE ──────────────────────────────────────────────────────────
      // SafeArea + SingleChildScrollView are now the outermost body widgets so
      // the entire page scrolls on web/desktop. Center + ConstrainedBox inside
      // keep content width-capped and centred on large screens.
      // ────────────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppResponsive.maxFormWidth,
              ),
              child: _isLoading
                  ? SizedBox(
                height: viewportHeight,
                child: const Center(child: AppLoader()),
              )
                  : _loadError != null
                  ? SizedBox(
                height: viewportHeight,
                child: _ErrorState(
                  message: _loadError!,
                  onRetry: _fetchProfile,
                ),
              )
                  : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: AppResponsive.pagePadding(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(text: 'Personal Information'),
                        const SizedBox(height: 12),
                        _buildFirstNameField(),
                        const SizedBox(height: 16),
                        _buildLastNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildDateOfBirthField(),
                        const SizedBox(height: 16),
                        _buildGenderField(),
                        const SizedBox(height: 16),
                        _buildMaritalStatusField(),
                        const SizedBox(height: 28),
                        _SectionTitle(text: 'Contact Information'),
                        const SizedBox(height: 12),
                        _buildPhoneField(),
                        const SizedBox(height: 16),
                        _buildAddressField(),
                        const SizedBox(height: 16),
                        _buildCityField(),
                        const SizedBox(height: 16),
                        _buildStateField(),
                        const SizedBox(height: 16),
                        _buildPostCodeField(),
                        const SizedBox(height: 16),
                        _buildCountryField(),
                        if (_submitError != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            _submitError!,
                            style:
                            const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                            _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: AppLoader(size: 20,),
                            )
                                : const Icon(Icons.save),
                            label: Text(
                              _isSubmitting
                                  ? 'Saving...'
                                  : 'Update Profile',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              backgroundColor:
                              ThemeConfig.goldenYellow,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name *',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'First name is required';
        }
        if (trimmed.length > 255) {
          return 'First name must be less than 255 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 255) {
          return 'Last name must be less than 255 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isNotEmpty &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(trimmed)) {
          return 'Enter a valid email address';
        }
        if (trimmed.length > 255) {
          return 'Email must be less than 255 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDateOfBirthField() {
    final formattedDate = _selectedDateOfBirth != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
        : 'Select Date';
    return InkWell(
      onTap: _pickDateOfBirth,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            color: _selectedDateOfBirth != null
                ? Colors.black87
                : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
      items: _genders
          .map(
            (gender) => DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        ),
      )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildMaritalStatusField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMaritalStatus,
      decoration: const InputDecoration(
        labelText: 'Marital Status',
        border: OutlineInputBorder(),
      ),
      items: _maritalStatuses
          .map(
            (status) => DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        ),
      )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedMaritalStatus = value;
        });
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 255) {
          return 'Phone must be less than 255 characters';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: 'Address',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 500) {
          return 'Address must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      decoration: const InputDecoration(
        labelText: 'City',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 255) {
          return 'City must be less than 255 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildStateField() {
    return TextFormField(
      controller: _stateController,
      decoration: const InputDecoration(
        labelText: 'State',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 255) {
          return 'State must be less than 255 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildPostCodeField() {
    return TextFormField(
      controller: _postCodeController,
      decoration: const InputDecoration(
        labelText: 'Post Code / ZIP Code',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 20) {
          return 'Post code must be less than 20 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCountryField() {
    return TextFormField(
      controller: _countryController,
      decoration: const InputDecoration(
        labelText: 'Country',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 255) {
          return 'Country must be less than 255 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: ThemeConfig.navyBlue,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.goldenYellow,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}