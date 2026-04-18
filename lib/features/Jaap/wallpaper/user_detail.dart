import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class UserDetailScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const UserDetailScreen({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Toggle states for each field
  bool _isNameEnabled = true;
  bool _isEmailEnabled = true;
  bool _isPhoneEnabled = true;
  bool _isWebsiteEnabled = true;

  // Image file
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected successfully'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show confirmation dialog before saving
  void _showConfirmationDialog() {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    // Get the values to display in dialog
    final name = _isNameEnabled ? _nameController.text.trim().toUpperCase() : 'Not provided';
    final email = _isEmailEnabled ? _emailController.text.trim().toLowerCase() : 'Not provided';
    final phone = _isPhoneEnabled ? _phoneController.text.trim() : 'Not provided';
    final website = _isWebsiteEnabled ? _websiteController.text.trim().toLowerCase() : 'Not provided';
    final hasImage = _selectedImage != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.deepOrange.shade400,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Confirm Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please confirm your details:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              if (_isNameEnabled) ...[
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: name,
                  color: Colors.deepOrange.shade400,
                ),
                const SizedBox(height: 12),
              ],

              // Email
              if (_isEmailEnabled) ...[
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: email,
                  color: Colors.deepOrange.shade400,
                ),
                const SizedBox(height: 12),
              ],

              // Phone
              if (_isPhoneEnabled) ...[
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: phone,
                  color: Colors.deepOrange.shade400,
                ),
                const SizedBox(height: 12),
              ],

              // Website
              if (_isWebsiteEnabled) ...[
                _buildDetailRow(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: website,
                  color: Colors.deepOrange.shade400,
                ),
                const SizedBox(height: 12),
              ],

              // Image
              _buildDetailRow(
                icon: Icons.image_outlined,
                label: 'Profile Image',
                value: hasImage ? 'Image selected' : 'No image selected',
                color: hasImage ? Colors.green : Colors.grey,
                valueColor: hasImage ? Colors.green : Colors.grey,
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.deepOrange.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please verify all details are correct before saving.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepOrange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _saveForm(); // Save the form
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm & Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Save form data
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _isNameEnabled ? _nameController.text.trim().toUpperCase() : '',
        'email': _isEmailEnabled ? _emailController.text.trim().toLowerCase() : '',
        'phone': _isPhoneEnabled ? _phoneController.text.trim() : '',
        'website': _isWebsiteEnabled ? _websiteController.text.trim().toLowerCase() : '',
        'image': _selectedImage,
        'fieldStates': {
          'name': _isNameEnabled,
          'email': _isEmailEnabled,
          'phone': _isPhoneEnabled,
          'website': _isWebsiteEnabled,
        }
      };

      // Call the onSave callback
      widget.onSave(userData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Profile saved successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap anywhere to dismiss keyboard
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'User Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          actions: [
            // Save Button in AppBar
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _showConfirmationDialog, // Show confirmation first
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Profile Image Section
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange.shade300,
                                Colors.deepOrange.shade400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                                : Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  _nameController.text.isNotEmpty && _isNameEnabled
                                      ? _nameController.text[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _selectedImage == null ? Icons.add_a_photo : Icons.edit,
                              color: Colors.deepOrange.shade400,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Name Field with Toggle
                    _buildToggleableTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      isEnabled: _isNameEnabled,
                      onToggle: (value) {
                        setState(() {
                          _isNameEnabled = value;
                          if (!value) _nameController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Email Field with Toggle
                    _buildToggleableTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: _isEmailEnabled,
                      onToggle: (value) {
                        setState(() {
                          _isEmailEnabled = value;
                          if (!value) _emailController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Phone Field with Toggle
                    _buildToggleableTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      isEnabled: _isPhoneEnabled,
                      onToggle: (value) {
                        setState(() {
                          _isPhoneEnabled = value;
                          if (!value) _phoneController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Website Field with Toggle
                    _buildToggleableTextField(
                      controller: _websiteController,
                      label: 'Website',
                      hint: 'Enter your website URL',
                      icon: Icons.language_outlined,
                      keyboardType: TextInputType.url,
                      textCapitalization: TextCapitalization.none,
                      isEnabled: _isWebsiteEnabled,
                      onToggle: (value) {
                        setState(() {
                          _isWebsiteEnabled = value;
                          if (!value) _websiteController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 40),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Toggleable Text Field Builder
  Widget _buildToggleableTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    required bool isEnabled,
    required Function(bool) onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Field
          Expanded(
            child: AbsorbPointer(
              absorbing: !isEnabled,
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  inputFormatters: inputFormatters,
                  enabled: isEnabled,
                  validator: (value) => null, // No validation
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    prefixIcon: Icon(
                      icon,
                      color: isEnabled ? Colors.deepOrange.shade400 : Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isEnabled ? Colors.grey.shade50 : Colors.grey.shade100,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.deepOrange.shade400,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    labelStyle: TextStyle(
                      color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: TextStyle(
                      color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Toggle Switch
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8),
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: Colors.deepOrange.shade400,
                activeTrackColor: Colors.deepOrange.shade100,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
