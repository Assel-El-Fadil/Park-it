import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final Widget? titleWidget;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool showSearch;
  final VoidCallback? onSearchTap;
  final bool showLocation;
  final String? locationText;
  final VoidCallback? onLocationTap;
  final bool showBottomBorder;
  final PreferredSizeWidget? bottom;
  final bool isTransparent;
  final bool isScrolled;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.titleWidget,
    this.onNotificationTap,
    this.onProfileTap,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.showSearch = false,
    this.onSearchTap,
    this.showLocation = false,
    this.locationText,
    this.onLocationTap,
    this.showBottomBorder = true,
    this.bottom,
    this.isTransparent = false,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Determine background color based on scroll state and transparency
    Color? effectiveBackgroundColor;
    if (isTransparent && !isScrolled) {
      effectiveBackgroundColor = Colors.transparent;
    } else {
      effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    }

    return AppBar(
      title:
          titleWidget ??
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  foregroundColor ??
                  (isTransparent && !isScrolled ? Colors.white : null),
            ),
          ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          leading ??
          (automaticallyImplyLeading ? _buildBackButton(context, theme) : null),
      actions: _buildActions(context, theme),
      elevation: isTransparent && !isScrolled ? 0 : elevation,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor:
          foregroundColor ??
          (isTransparent && !isScrolled ? Colors.white : null),
      centerTitle: centerTitle,
      flexibleSpace: showLocation ? _buildLocationBar(context, theme) : null,
      bottom: bottom ?? (showBottomBorder ? _buildBottomBorder(theme) : null),
      toolbarHeight: showLocation ? 80 : kToolbarHeight,
    );
  }

  Widget? _buildBackButton(BuildContext context, ThemeData theme) {
    final canPop = GoRouter.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isTransparent
              ? Colors.white.withOpacity(0.2)
              : theme.colorScheme.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color:
              foregroundColor ??
              (isTransparent ? Colors.white : theme.iconTheme.color),
        ),
      ),
      onPressed: () => context.pop(),
    );
  }

  List<Widget> _buildActions(BuildContext context, ThemeData theme) {
    final List<Widget> actionList = [];

    // Search action
    if (showSearch) {
      actionList.add(
        _buildActionButton(
          icon: Icons.search_rounded,
          onTap: onSearchTap ?? () {},
          theme: theme,
        ),
      );
    }

    // Notifications
    if (onNotificationTap != null) {
      actionList.add(
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildActionButton(
              icon: Icons.notifications_outlined,
              onTap: onNotificationTap!,
              theme: theme,
            ),
            if (showNotificationBadge && notificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTransparent
                          ? Colors.white
                          : theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Profile
    if (onProfileTap != null) {
      actionList.add(
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            margin: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isTransparent
                  ? Colors.white.withOpacity(0.2)
                  : theme.colorScheme.secondary.withOpacity(0.1),
              child: const Icon(Icons.person_rounded, size: 20),
            ),
          ),
        ),
      );
    }

    // Custom actions
    if (actions != null) {
      actionList.addAll(actions!);
    }

    return actionList;
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTransparent
                ? Colors.white.withOpacity(0.2)
                : theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color:
                foregroundColor ??
                (isTransparent ? Colors.white : theme.iconTheme.color),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onLocationTap,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isTransparent
                  ? Colors.white.withOpacity(0.2)
                  : theme.dividerColor,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 18,
              color:
                  foregroundColor ??
                  (isTransparent ? Colors.white : theme.primaryColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                locationText ?? 'Select your location',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      foregroundColor ?? (isTransparent ? Colors.white : null),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color:
                  foregroundColor ??
                  (isTransparent ? Colors.white : theme.iconTheme.color),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBottomBorder(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        color: isTransparent
            ? Colors.white.withOpacity(0.2)
            : theme.dividerColor,
        height: 0.5,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    showLocation
        ? 120
        : (bottom != null
              ? kToolbarHeight + bottom!.preferredSize.height
              : kToolbarHeight),
  );
}
