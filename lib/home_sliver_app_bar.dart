import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotix/app_env.dart';
import 'package:spotix/app_theme_controller.dart';
import 'package:spotix/home_app_bar_title.dart';

class HomeSliverAppBar extends StatefulWidget {
  const HomeSliverAppBar({Key? key}) : super(key: key);

  @override
  State<HomeSliverAppBar> createState() => _HomeSliverAppBarState();
}

class _HomeSliverAppBarState extends State<HomeSliverAppBar> {
  bool _isChangingDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const HomeAppBarTitle(),
      actions: <Widget>[
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.fastLinearToSlowEaseIn,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
            ) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
            },
            child: context.watch<AppThemeController>().isDarkMode
                ? const Icon(
                    Icons.dark_mode_rounded,
                    key: ValueKey<bool>(true),
                  )
                : const Icon(
                    Icons.light_mode_rounded,
                    key: ValueKey<bool>(false),
                  ),
          ),
          onPressed: _toggleDarkMode,
        ),
        IconButton(
          icon: const Icon(Icons.info_rounded),
          onPressed: () => _onInfoPressed(context),
        ),
      ],
    );
  }

  Future<void> _toggleDarkMode() async {
    if (_isChangingDarkMode) return;
    _isChangingDarkMode = true;

    context.read<AppThemeController>().toggleDarkMode();
    
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isChangingDarkMode = false;
  }

  void _onInfoPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return const AboutDialog(
          applicationName: 'Spotix',
          applicationVersion: AppEnv.versionName,
          applicationLegalese: 'Copyright 2022 Iandi Santulus. '
              'Protected under the BSD 3-Clause "New" or "Revised" License.',
        );
      },
    );
  }
}
