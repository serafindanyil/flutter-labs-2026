import 'package:first_lab/modules/auth/auth_provider.dart';
import 'package:first_lab/modules/auth/models/user_model.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUser();

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthProvider.repository.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        if (user != null) {
          _nameController.text = user.name;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthProvider.repository.logout();
    if (!mounted) return;
    AppToast.success(context, 'Виконано вихід з акаунту');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    await AuthProvider.repository.deleteUser();
    if (!mounted) return;
    AppToast.success(context, 'Ваш акаунт успішно видалено');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
      (_) => false,
    );
  }

  Future<void> _saveChanges() async {
    if (_user == null || !_isEditing) return;

    final newName = _nameController.text.trim();

    if (newName.isEmpty || RegExp(r'\d').hasMatch(newName)) {
      AppToast.error(context, 'Некоректне ім\'я (порожнє або містить цифри)');
      setState(() {
        _isEditing = false;
        _nameController.text = _user!.name;
      });
      return;
    }

    if (newName == _user!.name) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    final updatedUser = _user!.copyWith(name: newName);
    await AuthProvider.repository.updateUser(updatedUser);

    if (mounted) {
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      AppToast.success(context, 'Зміни збережено!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue500),
      );
    }

    if (_user == null) {
      return const Center(child: Text('Користувача не знайдено'));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 120,
          left: 24,
          right: 24,
          top: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Персональні дані',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            _ProfileFieldCard(
              label: 'Ім\'я',
              hasStaticChildHeight: true,
              trailing: !_isEditing
                  ? GestureDetector(
                      onTap: () {
                        setState(() => _isEditing = true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _nameFocusNode.requestFocus();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.pencil,
                          color: AppColors.blue500,
                          size: 24,
                        ),
                      ),
                    )
                  : null,
              child: _isEditing
                  ? PrimaryTextField(
                      hintText: 'Введіть ім\'я',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: _saveChanges,
                    )
                  : Text(
                      _user!.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.black400),
                    ),
            ),
            const SizedBox(height: 16),
            _ProfileFieldCard(
              label: 'Email',
              child: Text(
                _user!.email,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.black400),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              title: 'Вийти з акаунту',
              onTap: _logout,
              icon: LucideIcons.logOut,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              title: 'Видалити акаунт',
              onTap: _deleteAccount,
              backgroundColor: AppColors.danger,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFieldCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;
  final bool hasStaticChildHeight;

  const _ProfileFieldCard({
    required this.label,
    required this.child,
    this.trailing,
    this.hasStaticChildHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: child),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );

    if (hasStaticChildHeight) {
      content = SizedBox(height: 60, child: content);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
