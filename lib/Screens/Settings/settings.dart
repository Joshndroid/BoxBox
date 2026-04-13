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
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  final Function? update;
  const SettingsScreen({Key? key, this.update}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _settingsSetState() {
    setState(() {});
    if (widget.update != null) widget.update!();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            l10n.settings,
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
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile.notched(
                    title: Text(l10n.appearance),
                    leading: const Icon(CupertinoIcons.paintbrush),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed('appearance-settings'),
                  ),
                  CupertinoListTile.notched(
                    title: Text(l10n.player),
                    leading: const Icon(CupertinoIcons.play_circle),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed('player-settings'),
                  ),
                  CupertinoListTile.notched(
                    title: Text(l10n.notifications),
                    leading: const Icon(CupertinoIcons.bell),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () =>
                        context.pushNamed('notifications-settings'),
                  ),
                  CupertinoListTile.notched(
                    title: Text(l10n.other),
                    leading: const Icon(CupertinoIcons.ellipsis_circle),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => context.pushNamed(
                      'other-settings',
                      extra: {'update': _settingsSetState},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ── Android / Web ─────────────────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        children: [
          ListTile(
            title: Text(l10n.appearance),
            leading: const Icon(Icons.format_paint_outlined),
            onTap: () => context.pushNamed('appearance-settings'),
          ),
          ListTile(
            title: Text(l10n.player),
            leading: const Icon(Icons.play_arrow_outlined),
            onTap: () => context.pushNamed('player-settings'),
          ),
          ListTile(
            title: Text(l10n.notifications),
            leading: const Icon(Icons.notifications_outlined),
            onTap: () => context.pushNamed('notifications-settings'),
          ),
          ListTile(
            title: Text(l10n.other),
            leading: const Icon(Icons.miscellaneous_services_outlined),
            onTap: () => context.pushNamed(
              'other-settings',
              extra: {'update': _settingsSetState},
            ),
          ),
        ],
      ),
    );
  }
}
