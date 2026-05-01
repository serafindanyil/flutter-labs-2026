import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/logout_dialog.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isEditing = false;
  String _currentName = 'Користувач';
  String _currentEmail = 'email@example.com';

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

  void _loadUser() {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _currentName = user.displayName ?? 'Користувач';
      _currentEmail = user.email ?? 'no-email@example.com';
      _nameController.text = _currentName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final shouldLogout = await LogoutDialog.show(context);
    if (shouldLogout == true && mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
      AppToast.success(context, 'Виконано вихід з акаунту');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
        (_) => false,
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_isEditing) return;

    final newName = _nameController.text.trim();

    if (newName.isEmpty || RegExp(r'\d').hasMatch(newName)) {
      AppToast.error(context, 'Некоректне ім\'я (порожнє або містить цифри)');
      setState(() {
        _isEditing = false;
        _nameController.text = _currentName;
      });
      return;
    }

    if (newName == _currentName) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    if (!context.hasNetworkAccess) {
      setState(() {
        _isEditing = false;
        _nameController.text = _currentName;
      });
      return;
    }

    try {
      context.read<AuthBloc>().add(AuthUpdateProfileRequested(name: newName));
      setState(() {
        _currentName = newName;
        _isEditing = false;
      });
      AppToast.success(context, 'Зміни збережено!');
    } catch (_) {
      AppToast.error(context, 'ПОмилка збереження');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkAccess =
        context.watch<NetworkCubit>().state.status == NetworkStatus.online;

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
                  ? _EditProfileButton(
                      isEnabled: hasNetworkAccess,
                      onTap: () => _startEditing(hasNetworkAccess),
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
                      _currentName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.black400),
                    ),
            ),
            const SizedBox(height: 16),
            _ProfileFieldCard(
              label: 'Email',
              child: Text(
                _currentEmail,
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
          ],
        ),
      ),
    );
  }

  void _startEditing(bool hasNetworkAccess) {
    if (!hasNetworkAccess) return;

    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }
}

class _EditProfileButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const _EditProfileButton({required this.isEnabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.blue100 : AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          LucideIcons.pencil,
          color: isEnabled ? AppColors.blue500 : AppColors.gray500,
          size: 24,
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
