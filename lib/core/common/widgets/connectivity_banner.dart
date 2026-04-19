import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isVisible;

  const ConnectivityBanner({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? 32 : 0,
      width: double.infinity,
      color: Colors.redAccent,
      child: isVisible
          ? const Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
