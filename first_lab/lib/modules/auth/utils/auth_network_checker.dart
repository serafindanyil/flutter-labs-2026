import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AuthNetworkExtension on BuildContext {
  bool get hasNetworkAccess {
    final networkStatus = read<NetworkCubit>().state.status;
    if (networkStatus != NetworkStatus.online) {
      AppToast.error(this, 'Немає підключення до інтернету');
      return false;
    }
    return true;
  }
}
