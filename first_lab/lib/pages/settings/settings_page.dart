import 'package:first_lab/modules/auth/auth_provider.dart';
import 'package:first_lab/modules/auth/models/user_model.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    await AuthProvider.repository.deleteUser();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
      (_) => false,
    );
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;
    final newName = _nameController.text.trim();
    if (newName.isEmpty || RegExp(r'\d').hasMatch(newName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Некоректне ім\'я (порожнє або містить цифри)'),
        ),
      );
      return;
    }

    final updatedUser = _user!.copyWith(name: newName);
    await AuthProvider.repository.updateUser(updatedUser);

    if (mounted) {
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Зміни збережено!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('Користувача не знайдено'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120, left: 24, right: 24, top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Профіль', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 32),
          Text(
            'Емейл: ${_user!.email}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text('Ім\'я:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_isEditing)
            PrimaryTextField(
              hintText: 'Введіть нове ім\'я',
              controller: _nameController,
            )
          else
            Text(_user!.name, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(title: 'Зберегти', onTap: _saveChanges),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    title: 'Скасувати',
                    onTap: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = _user!.name;
                      });
                    },
                  ),
                ),
              ],
            )
          else
            PrimaryButton(
              title: 'Редагувати профіль',
              onTap: () => setState(() => _isEditing = true),
            ),
          const SizedBox(height: 32),
          Divider(color: Colors.grey.shade400),
          const SizedBox(height: 32),
          PrimaryButton(title: 'Вийти', onTap: _logout),
          const SizedBox(height: 16),
          PrimaryButton(title: 'Видалити акаунт', onTap: _deleteAccount),
        ],
      ),
    );
  }
}
