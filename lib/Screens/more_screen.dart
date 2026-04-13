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

import 'package:boxbox/Screens/LivetimingArchive/races_list.dart';
import 'package:boxbox/Screens/Compare/compare_home.dart';
import 'package:boxbox/helpers/platform_adaptive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// iOS-specific "More" tab — mirrors the content of [MainDrawer] but
/// rendered as a native-looking grouped list.
class MoreScreen extends StatelessWidget {
  final Function? homeSetState;
  const MoreScreen({super.key, this.homeSetState});

  @override
  Widget build(BuildContext context) {
    final bool enableExperimental = Hive.box('settings')
        .get('enableExperimentalFeatures', defaultValue: false) as bool;
    final String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    final l10n = AppLocalizations.of(context)!;
    // ignore: unused_local_variable — l10n used in ListTile labels below

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'More',
          style: const TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            // ── Box, Box! header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Box, Box!',
                style: TextStyle(
                  fontFamily: 'Formula1',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // ── Content group ─────────────────────────────────────────────
            CupertinoListSection.insetGrouped(
              children: [
                if (championship == 'Formula 1')
                  CupertinoListTile.notched(
                    title: const Text('Formula You'),
                    leading: const Icon(CupertinoIcons.person_circle),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed('formula-you'),
                  ),
                CupertinoListTile.notched(
                  title: Text(l10n.newsMix),
                  leading: const Icon(CupertinoIcons.square_stack_3d_up),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.pushNamed('mixed-news'),
                ),
                if (championship == 'Formula 1')
                  CupertinoListTile.notched(
                    title: Text(l10n.hallOfFame),
                    leading: const Icon(CupertinoIcons.rosette),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed('hall-of-fame'),
                  ),
                CupertinoListTile.notched(
                  title: Text(l10n.history),
                  leading: const Icon(CupertinoIcons.clock),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.pushNamed('history'),
                ),
                if (!kIsWeb)
                  CupertinoListTile.notched(
                    title: Text(l10n.downloads),
                    leading: const Icon(CupertinoIcons.arrow_down_circle),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed('downloads'),
                  ),
              ],
            ),

            // ── App group ─────────────────────────────────────────────────
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  title: Text(l10n.settings),
                  leading: const Icon(CupertinoIcons.settings),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.pushNamed(
                    'settings',
                    extra: {'update': homeSetState},
                  ),
                ),
                CupertinoListTile.notched(
                  title: Text(l10n.about),
                  leading: const Icon(CupertinoIcons.info_circle),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.pushNamed('about'),
                ),
              ],
            ),

            // ── Experimental group ────────────────────────────────────────
            if (enableExperimental)
              CupertinoListSection.insetGrouped(
                header: const Text('Experimental'),
                children: [
                  CupertinoListTile.notched(
                    title: const Text('Live Timing Feed'),
                    leading: const Icon(CupertinoIcons.timer),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const ArchiveRacesListScreen(),
                      ),
                    ),
                  ),
                  CupertinoListTile.notched(
                    title: const Text('Compare'),
                    leading: const Icon(CupertinoIcons.arrow_left_right),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const CompareHomeScreen(),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
