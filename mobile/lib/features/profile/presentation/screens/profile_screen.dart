import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/tulip_button.dart';
import '../../../../shared/widgets/tulip_text_field.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deletePasswordController = TextEditingController();

  bool _profileEdited = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  void _populateForm(UserProfile profile) {
    if (!_profileEdited) {
      _displayNameController.text = profile.displayName ?? '';
      _emailController.text = profile.email;
    }
  }

  String _getGravatarUrl(String email) {
    final trimmedEmail = email.trim().toLowerCase();
    final hash = md5.convert(utf8.encode(trimmedEmail)).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=mp';
  }

  Future<void> _handleSaveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final request = UpdateProfileRequest(
      displayName: _displayNameController.text.trim().isEmpty
          ? null
          : _displayNameController.text.trim(),
      email: _emailController.text.trim(),
    );

    final success = await ref.read(profileFormProvider.notifier).updateProfile(request);

    if (success && mounted) {
      setState(() => _profileEdited = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: TulipColors.sage,
        ),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final request = ChangePasswordRequest(
      currentPassword: _currentPasswordController.text,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    final success = await ref.read(profileFormProvider.notifier).changePassword(request);

    if (success && mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully'),
          backgroundColor: TulipColors.sage,
        ),
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteAccountDialog(
        passwordController: _deletePasswordController,
        onConfirm: () async {
          final password = _deletePasswordController.text;
          if (password.isEmpty) return;

          final success = await ref.read(profileFormProvider.notifier).deleteAccount(password);

          if (success && mounted) {
            await ref.read(authStateProvider.notifier).signOut();
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          }
        },
      ),
    );

    if (confirmed == true && mounted) {
      context.go('/login');
    }

    _deletePasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final formState = ref.watch(profileFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings', style: TulipTextStyles.heading3),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load profile', style: TulipTextStyles.body),
              const SizedBox(height: 16),
              TulipButton(
                onPressed: () => ref.read(profileProvider.notifier).refresh(),
                label: 'Retry',
              ),
            ],
          ),
        ),
        data: (profile) {
          _populateForm(profile);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error message
                  if (formState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TulipColors.roseLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: TulipColors.roseDark, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formState.error!,
                              style: TulipTextStyles.bodySmall.copyWith(
                                color: TulipColors.roseDark,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: TulipColors.roseDark, size: 18),
                            onPressed: () => ref.read(profileFormProvider.notifier).clearMessages(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: TulipColors.sageLight,
                          backgroundImage: NetworkImage(_getGravatarUrl(profile.email)),
                          onBackgroundImageError: (_, __) {},
                          child: null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gravatar',
                          style: TulipTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Section
                  Text('Profile', style: TulipTextStyles.heading3),
                  const SizedBox(height: 12),
                  Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        TulipTextField(
                          controller: _displayNameController,
                          label: 'Display Name',
                          hint: 'How others will see you',
                          onChanged: (_) => setState(() => _profileEdited = true),
                        ),
                        const SizedBox(height: 16),
                        TulipTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() => _profileEdited = true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TulipButton(
                            onPressed: formState.isLoading ? null : _handleSaveProfile,
                            isLoading: formState.isLoading,
                            label: 'Save Profile',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Password Section
                  Text('Change Password', style: TulipTextStyles.heading3),
                  const SizedBox(height: 12),
                  Form(
                    key: _passwordFormKey,
                    child: Column(
                      children: [
                        TulipTextField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          obscureText: !_showCurrentPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
                              color: TulipColors.brownLight,
                            ),
                            onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TulipTextField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          obscureText: !_showNewPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showNewPassword ? Icons.visibility_off : Icons.visibility,
                              color: TulipColors.brownLight,
                            ),
                            onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TulipTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          obscureText: !_showConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: TulipColors.brownLight,
                            ),
                            onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TulipButton(
                            onPressed: formState.isLoading ? null : _handleChangePassword,
                            isLoading: formState.isLoading,
                            label: 'Change Password',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Danger Zone Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TulipColors.roseLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TulipColors.rose),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danger Zone', style: TulipTextStyles.heading3.copyWith(
                          color: TulipColors.roseDark,
                        )),
                        const SizedBox(height: 8),
                        Text(
                          'Permanently delete your account and all associated data. This action cannot be undone.',
                          style: TulipTextStyles.bodySmall.copyWith(
                            color: TulipColors.roseDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TulipButton(
                            onPressed: _handleDeleteAccount,
                            label: 'Delete Account',
                            backgroundColor: TulipColors.roseDark,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: TulipButton(
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      isOutlined: true,
                      label: 'Sign Out',
                      icon: Icons.logout,
                      textColor: TulipColors.roseDark,
                      backgroundColor: TulipColors.roseDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  final TextEditingController passwordController;
  final VoidCallback onConfirm;

  const _DeleteAccountDialog({
    required this.passwordController,
    required this.onConfirm,
  });

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(profileFormProvider);

    return AlertDialog(
      title: Text('Delete Account', style: TulipTextStyles.heading3.copyWith(
        color: TulipColors.roseDark,
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action is permanent and cannot be undone. All your stays, bucket lists, and data will be deleted.',
            style: TulipTextStyles.body,
          ),
          const SizedBox(height: 16),
          if (formState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TulipColors.roseLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formState.error!,
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.roseDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text('Enter your password to confirm:', style: TulipTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: TulipColors.brownLight,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: TulipColors.brownLight)),
        ),
        TextButton(
          onPressed: formState.isLoading ? null : widget.onConfirm,
          child: formState.isLoading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TulipColors.roseDark,
                  ),
                )
              : Text('Delete', style: TextStyle(color: TulipColors.roseDark)),
        ),
      ],
    );
  }
}
