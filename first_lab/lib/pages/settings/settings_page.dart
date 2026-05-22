import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/settings/bloc/settings_cubit.dart';
import 'package:first_lab/pages/settings/bloc/settings_state.dart';
import 'package:first_lab/pages/settings/widgets/secret_flashlight_listener.dart';
import 'package:first_lab/pages/settings/widgets/settings_content.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsCubit(authService: context.read<AuthService>()),
      child: const SecretFlashlightListener(child: _SettingsView()),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onNameFocusChange);
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onNameFocusChange);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: _listenState,
      builder: (context, state) {
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
            child: SettingsContent(
              state: state,
              hasNetworkAccess: hasNetworkAccess,
              nameController: _nameController,
              nameFocusNode: _nameFocusNode,
              onLogout: () => _logout(context),
              onStartEditing: () => _startEditing(context, hasNetworkAccess),
              onSave: () => _saveChanges(context, hasNetworkAccess),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await LogoutDialog.show(context);
    if (shouldLogout != true || !context.mounted) return;

    context.read<AuthBloc>().add(const AuthLogoutRequested());
    AppToast.success(context, 'Виконано вихід з акаунту');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
      (_) => false,
    );
  }

  void _startEditing(BuildContext context, bool hasNetworkAccess) {
    if (!hasNetworkAccess) return;

    context.read<SettingsCubit>().startEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  void _saveChanges(BuildContext context, bool hasNetworkAccess) {
    final name = _nameController.text.trim();
    final shouldUpdateProfile = context.read<SettingsCubit>().saveName(
      name: name,
      hasNetworkAccess: hasNetworkAccess,
    );
    if (!shouldUpdateProfile) return;

    context.read<AuthBloc>().add(AuthUpdateProfileRequested(name: name));
  }

  void _onNameFocusChange() {
    if (_nameFocusNode.hasFocus) return;

    final name = _nameController.text.trim();
    final shouldUpdateProfile = context.read<SettingsCubit>().saveName(
      name: _nameController.text.trim(),
      hasNetworkAccess:
          context.read<NetworkCubit>().state.status == NetworkStatus.online,
    );
    if (!shouldUpdateProfile) return;

    context.read<AuthBloc>().add(AuthUpdateProfileRequested(name: name));
  }

  void _listenState(BuildContext context, SettingsState state) {
    if (_nameController.text != state.name && !state.isEditing) {
      _nameController.text = state.name;
    }
    if (state.saveStatus == SettingsSaveStatus.success) {
      AppToast.success(context, 'Зміни збережено!');
    } else if (state.saveStatus == SettingsSaveStatus.failure) {
      AppToast.error(context, state.errorMessage ?? 'Помилка збереження');
    }
  }
}
