import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';

class ConnectivityGuard extends StatelessWidget {
  final Widget child;
  final String? offlineTooltip;

  const ConnectivityGuard({
    super.key,
    required this.child,
    this.offlineTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, state) {
        final isOffline = state == ConnectivityStatus.disconnected;

        if (!isOffline) return child;

        return Tooltip(
          message: offlineTooltip ?? "Internet connection required",
          child: Opacity(
            opacity: 0.5,
            child: AbsorbPointer(
              absorbing: true,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
