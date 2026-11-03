import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final void Function() onSidebarToggleButtonPressed;

  const TopBar({super.key, required this.onSidebarToggleButtonPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      child: Row(
        children: [
          const SizedBox(width: 4.0),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              onPressed: onSidebarToggleButtonPressed,
              child: Row(
                children: [
                  Icon(
                    Icons.view_sidebar_outlined,
                  ),
                  const SizedBox(width: 6.0),
                  Text('Toggle sidebar'),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
