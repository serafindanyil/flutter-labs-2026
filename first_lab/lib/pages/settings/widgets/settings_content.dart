import 'package:first_lab/pages/settings/bloc/settings_state.dart';
import 'package:first_lab/pages/settings/widgets/edit_profile_button.dart';
import 'package:first_lab/pages/settings/widgets/profile_field_card.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    required this.state,
    required this.hasNetworkAccess,
    required this.nameController,
    required this.nameFocusNode,
    required this.onLogout,
    required this.onStartEditing,
    required this.onSave,
    super.key,
  });

  final SettingsState state;
  final bool hasNetworkAccess;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final VoidCallback onLogout;
  final VoidCallback onStartEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Персональні дані',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        ProfileFieldCard(
          label: 'Ім\'я',
          hasStaticChildHeight: true,
          trailing: !state.isEditing
              ? EditProfileButton(
                  isEnabled: hasNetworkAccess,
                  onTap: onStartEditing,
                )
              : null,
          child: state.isEditing
              ? PrimaryTextField(
                  hintText: 'Введіть ім\'я',
                  controller: nameController,
                  focusNode: nameFocusNode,
                  onFieldSubmitted: onSave,
                )
              : Text(
                  state.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.black400,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        ProfileFieldCard(
          label: 'Email',
          child: Text(
            state.email,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.black400),
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          title: 'Вийти з акаунту',
          onTap: onLogout,
          icon: LucideIcons.logOut,
        ),
      ],
    );
  }
}
