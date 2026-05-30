import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared bottom navigation shell for all Fast Delivery apps.
///
/// Provides a [NavigationBar] with three tabs:
/// - **Home** — app-specific dashboard (Branch 0)
/// - **Orders** — `OrdersListScreen` from `fast_delivery_orders` (Branch 1)
/// - **Account** — placeholder, tappable but no-op (Branch 2)
///
/// The Orders tab shows a count [Badge] with [activeOrdersCount] when > 0.
/// Each app is responsible for watching the provider and passing the count.
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

  /// Number of active orders to display as a badge on the Orders tab.
  ///
  /// Pass `0` (default) to hide the badge. Each app watches
  /// `activeOrdersCountProvider` from `fast_delivery_orders` and passes
  /// the value here.
  final int activeOrdersCount;

  const MainShell({
    super.key,
    required this.navigationShell,
    this.overlayWidget,
    this.activeOrdersCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = overlayWidget;
    final showOverlay =
        overlay != null && navigationShell.currentIndex == 0;

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
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: activeOrdersCount > 0,
              label: Text(
                '$activeOrdersCount',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
