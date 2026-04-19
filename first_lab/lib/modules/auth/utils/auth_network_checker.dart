import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:flutter/widgets.dart';

extension AuthNetworkExtension on BuildContext {
  bool get hasNetworkAccess {
    if (Disabled.of(this)) {
      AppToast.error(this, 'Немає підключення до інтернету');
      return false;
    }
    return true;
  }
}
