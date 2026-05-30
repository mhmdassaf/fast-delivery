import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared bottom navigation shell for all Fast Delivery apps.
///
/// Provides a [NavigationBar] with three tabs:
/// - **Home** — app-specific dashboard (Branch 0)
/// - **Orders** — `OrdersListScreen` from `fast_delivery_orders` (Branch 1)
/// - **Account** — placeholder, tappable but no-op (Branch 2)
///
/// The [overlayWidget] parameter allows each app to render an optional
/// floating widget (e.g. `ViewCartBanner` in the User App) over the
/// active branch. The overlay only appears when the **Home** tab is
/// selected (index 0).
class MainShell extends StatelessWidget {
  /// The [StatefulNavigationShell] provided by [StatefulShellRoute.indexedStack].
  final StatefulNavigationShell navigationShell;

  /// Optional widget overlaid at the bottom of the active branch.
  ///
  /// The overlay is rendered only when the current tab index is 0 (Home).
  /// Use this for app-specific overlays such as [ViewCartBanner].
  final Widget? overlayWidget;

  const MainShell({
    super.key,
    required this.navigationShell,
    this.overlayWidget,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = overlayWidget;
    final showOverlay = overlay != null && navigationShell.currentIndex == 0;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          if (showOverlay)
            Align(
              alignment: Alignment.bottomCenter,
              child: overlay,
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Account tab (index 2) is a no-op placeholder for future use.
          if (index == 2) return;
          navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
