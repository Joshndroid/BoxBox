/*
 *  This file is part of BoxBox (https://github.com/BrightDV/BoxBox).
 *
 * BoxBox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BoxBox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BoxBox.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2022-2025, BrightDV
 */

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Returns true when running natively on iOS/iPadOS.
bool get isIOS => !kIsWeb && Platform.isIOS;

// ---------------------------------------------------------------------------
// Adaptive AppBar
// ---------------------------------------------------------------------------

/// Returns a platform-appropriate [PreferredSizeWidget]:
/// • iOS  → [CupertinoNavigationBar]
/// • Other → [AppBar]
///
/// [previousPageTitle] is only used on iOS to customise the back-button label.
PreferredSizeWidget adaptiveAppBar({
  required BuildContext context,
  required String title,
  List<Widget>? actions,
  Widget? leading,
  bool centerTitle = true,
  Color? backgroundColor,
  String? previousPageTitle,
  bool automaticallyImplyLeading = true,
}) {
  if (isIOS) {
    final theme = Theme.of(context);
    final bg = backgroundColor ??
        CupertinoTheme.of(context).barBackgroundColor;
    Widget? trailingWidget;
    if (actions != null && actions.isNotEmpty) {
      trailingWidget = actions.length == 1
          ? actions.first
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            );
    }
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(
          fontFamily: 'Formula1',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.brightness == Brightness.dark
              ? CupertinoColors.white
              : CupertinoColors.black,
        ),
      ),
      leading: leading,
      trailing: trailingWidget,
      backgroundColor: bg,
      previousPageTitle: previousPageTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  return AppBar(
    title: Text(title),
    leading: leading,
    actions: actions,
    centerTitle: centerTitle,
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.onPrimary,
    automaticallyImplyLeading: automaticallyImplyLeading,
  );
}

// ---------------------------------------------------------------------------
// Adaptive Scaffold
// ---------------------------------------------------------------------------

/// A thin wrapper that wraps [body] in either [CupertinoPageScaffold] (iOS)
/// or [Scaffold] (other platforms).
///
/// On iOS [appBar] should be a [CupertinoNavigationBar]; supply it via
/// [adaptiveAppBar] above.  [floatingActionButton] is ignored on iOS (no FAB
/// pattern in Cupertino).
class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: appBar is CupertinoNavigationBar
            ? appBar as CupertinoNavigationBar
            : null,
        backgroundColor: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: body,
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}

// ---------------------------------------------------------------------------
// Adaptive Switch
// ---------------------------------------------------------------------------

/// Returns [CupertinoSwitch] on iOS, [Switch] elsewhere.
Widget adaptiveSwitch({
  required bool value,
  required ValueChanged<bool> onChanged,
  Color? activeColor,
}) {
  if (isIOS) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor,
    );
  }
  return Switch(
    value: value,
    onChanged: onChanged,
    activeColor: activeColor,
  );
}

// ---------------------------------------------------------------------------
// Adaptive Progress Indicator
// ---------------------------------------------------------------------------

/// Returns [CupertinoActivityIndicator] on iOS, [CircularProgressIndicator]
/// elsewhere.
Widget adaptiveProgressIndicator({Color? color, double? radius}) {
  if (isIOS) {
    return CupertinoActivityIndicator(
      color: color,
      radius: radius ?? 10,
    );
  }
  return CircularProgressIndicator(
    color: color,
    strokeWidth: 2.5,
  );
}

// ---------------------------------------------------------------------------
// Adaptive Dialog
// ---------------------------------------------------------------------------

/// Shows a [CupertinoAlertDialog] on iOS or an [AlertDialog] elsewhere.
Future<T?> showAdaptiveAlertDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  List<AdaptiveDialogAction> actions = const [],
}) {
  if (isIOS) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: actions
            .map(
              (a) => CupertinoDialogAction(
                isDefaultAction: a.isDefault,
                isDestructiveAction: a.isDestructive,
                onPressed: a.onPressed,
                child: Text(a.label),
              ),
            )
            .toList(),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actions: actions
          .map(
            (a) => TextButton(
              onPressed: a.onPressed,
              child: Text(
                a.label,
                style: a.isDestructive
                    ? const TextStyle(color: Colors.red)
                    : null,
              ),
            ),
          )
          .toList(),
    ),
  );
}

class AdaptiveDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AdaptiveDialogAction({
    required this.label,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}

// ---------------------------------------------------------------------------
// Adaptive Bottom Sheet / Action Sheet
// ---------------------------------------------------------------------------

/// Shows a [CupertinoActionSheet] on iOS or a [ModalBottomSheet] elsewhere.
///
/// [actions] is a list of (label, onTap) pairs.
/// [cancelLabel] is the iOS cancel button text (ignored on Android).
Future<void> showAdaptiveActionSheet({
  required BuildContext context,
  String? title,
  String? message,
  required List<AdaptiveSheetAction> actions,
  String cancelLabel = 'Cancel',
}) {
  if (isIOS) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: title != null ? Text(title) : null,
        message: message != null ? Text(message) : null,
        actions: actions
            .map(
              (a) => CupertinoActionSheetAction(
                isDestructiveAction: a.isDestructive,
                isDefaultAction: a.isDefault,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  a.onPressed?.call();
                },
                child: Text(a.label),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(cancelLabel),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                title,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(message),
            ),
          ...actions.map(
            (a) => ListTile(
              title: Text(
                a.label,
                style: a.isDestructive
                    ? const TextStyle(color: Colors.red)
                    : null,
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                a.onPressed?.call();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class AdaptiveSheetAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AdaptiveSheetAction({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

// ---------------------------------------------------------------------------
// iOS-style List Section helper
// ---------------------------------------------------------------------------

/// On iOS wraps children in a [CupertinoListSection.insetGrouped].
/// On other platforms renders plain children in a [Column].
class AdaptiveListSection extends StatelessWidget {
  final String? header;
  final List<Widget> children;

  const AdaptiveListSection({
    super.key,
    this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoListSection.insetGrouped(
        header: header != null ? Text(header!) : null,
        children: children,
      );
    }
    return Column(children: children);
  }
}

// ---------------------------------------------------------------------------
// iOS-style List Tile helper
// ---------------------------------------------------------------------------

/// On iOS renders a [CupertinoListTile.notched].
/// On other platforms renders a [ListTile].
class AdaptiveListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AdaptiveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoListTile.notched(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing ?? (onTap != null
            ? const Icon(CupertinoIcons.chevron_right,
                size: 14, color: CupertinoColors.systemGrey2)
            : null),
        onTap: onTap,
      );
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
