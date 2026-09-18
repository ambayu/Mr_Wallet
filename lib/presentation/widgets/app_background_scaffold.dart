import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

/// Reusable Background Wrapper yang menampilkan ambient background:
/// [AppAssets.appBackground] untuk Portrait dan [AppAssets.appBackgroundLandscape] untuk Landscape.
class AppBackgroundScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  const AppBackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8A7),
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Ambient Wallpaper Background (Portrait vs Landscape)
              Image.asset(
                isLandscape
                    ? AppAssets.appBackgroundLandscape
                    : AppAssets.appBackground,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: isLandscape ? Alignment.center : Alignment.topCenter,
              ),

              // Foreground Screen Body
              body,
            ],
          );
        },
      ),
    );
  }
}
