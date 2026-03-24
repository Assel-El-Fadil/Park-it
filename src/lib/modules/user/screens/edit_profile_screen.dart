import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/repositories/auth_repository.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  
  Uint8List? _imageBytes;
  String? _imagePreviewPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).value?.currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePreviewPath = pickedFile.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authNotifierProvider).value?.currentUser;
      if (user == null) throw Exception("User not found");

      String? photoUrl = user.profilePhoto;
      
      if (_imageBytes != null) {
        photoUrl = await ref.read(authRepositoryProvider).uploadProfilePhoto(user.id, _imageBytes!);
      }

      final updatedUser = UserModel(
        id: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: user.email,
        phone: _phoneController.text.trim(),
        profilePhoto: photoUrl,
        averageRating: user.averageRating,
        totalReviews: user.totalReviews,
        fcmToken: user.fcmToken,
        role: user.role,
      );

      await ref.read(authRepositoryProvider).updateProfile(updatedUser);
      await ref.read(authNotifierProvider.notifier).checkAuthState();

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value?.currentUser;
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: user == null ? const Center(child: CircularProgressIndicator()) : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: context.surfaceColor,
                        backgroundImage: _imageBytes != null 
                             ? MemoryImage(_imageBytes!) as ImageProvider
                             : (user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                                  ? NetworkImage(user.profilePhoto!)
                                  : null),
                        child: (_imageBytes == null && (user.profilePhoto == null || user.profilePhoto!.isEmpty))
                            ? Icon(Icons.person, size: 56, color: context.colorScheme.textTertiary)
                            : null,
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.backgroundColor, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'First Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                     labelText: 'Last Name',
                     prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Last Name is required' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Account Security',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Change Email Address'),
                  subtitle: Text(user?.email ?? 'No email set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUpdateDialog(context, 'email'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your password securely'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUpdateDialog(context, 'password'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Change Phone Number'),
                  subtitle: Text(user?.phone ?? 'No phone number set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showUpdateDialog(context, 'phone'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String type) {
    bool isPassword = type == 'password';
    bool isPhone = type == 'phone';
    final controller = TextEditingController();         // used for 'new email' OR 'new password' OR 'new phone'
    final oldPasswordController = TextEditingController(); // used only if isPassword
    final confirmController = TextEditingController();  // used only if isPassword
    final formKey = GlobalKey<FormState>();

    String dialogTitle = isPassword ? 'Update Password' : (isPhone ? 'Update Phone Number' : 'Update Email');
    String labelText = isPassword ? 'New Password' : (isPhone ? 'New Phone Number' : 'New Email Address');
    String hintText = isPassword ? 'Enter new password' : (isPhone ? 'Enter new phone' : 'Enter new email');
    TextInputType keyboardType = isPassword ? TextInputType.text : (isPhone ? TextInputType.phone : TextInputType.emailAddress);

    // We can't use a StatefulBuilder easily without breaking Riverpod mounts, 
    // but simple forms are fine. To toggle visibility inside dialog, it's better 
    // to use a local StatefulWidget or just not allow toggling visibility in this simple version, 
    // but let's keep it simple.

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPassword) ...[
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: controller,
                obscureText: isPassword,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'This field is required';
                  if (isPassword && value.length < AppConstants.minPasswordLength) {
                    return AppConstants.validationPassword;
                  }
                  if (!isPassword && !isPhone && !RegExp(AppConstants.emailRegex).hasMatch(value)) {
                    return AppConstants.validationEmail;
                  }
                  if (isPhone && value.length < 8) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              if (isPassword) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Re-enter new password',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'This field is required';
                    if (value != controller.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              try {
                if (isPassword) {
                  await ref.read(authNotifierProvider.notifier).updatePassword(
                    oldPassword: oldPasswordController.text,
                    newPassword: controller.text,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully!')),
                    );
                  }
                } else if (isPhone) {
                  await ref.read(authNotifierProvider.notifier).updatePhone(controller.text.trim());
                  await ref.read(authNotifierProvider.notifier).checkAuthState();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone number updated successfully.')),
                    );
                  }
                } else {
                  await ref.read(authNotifierProvider.notifier).updateEmail(controller.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('A confirmation link has been sent to your new email address.')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
