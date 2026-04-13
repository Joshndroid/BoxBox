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

import 'package:boxbox/helpers/platform_adaptive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a platform-appropriate bottom sheet.
///
/// On iOS the content is wrapped in a [CupertinoActionSheet]-style modal popup.
/// On Android / Web it uses the standard [ModalBottomSheet].
Future<String?> showCustomBottomSheet(
    BuildContext context, Widget builder) async {
  if (isIOS) {
    return await showCupertinoModalPopup<String?>(
      context: context,
      builder: (ctx) => _IosBottomSheetWrapper(builder),
    );
  }

  return await showModalBottomSheet<String?>(
    context: context,
    builder: (ctx) => _AndroidBottomSheet(builder),
    isScrollControlled: true,
    useSafeArea: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS wrapper — a rounded card that slides up from the bottom
// ─────────────────────────────────────────────────────────────────────────────

class _IosBottomSheetWrapper extends StatelessWidget {
  final Widget child;
  const _IosBottomSheetWrapper(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Android bottom sheet (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _AndroidBottomSheet extends StatelessWidget {
  final Widget builder;
  const _AndroidBottomSheet(this.builder);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      onClosing: () {},
      builder: (ctx) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: builder,
      ),
    );
  }
}

// Keep old name for compatibility
class CustomBottomSheet extends StatelessWidget {
  final Widget builder;
  const CustomBottomSheet(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return _AndroidBottomSheet(builder);
  }
}
