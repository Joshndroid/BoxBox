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

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:boxbox/helpers/platform_adaptive.dart';
import 'package:boxbox/helpers/team_background_color.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  // ─────────────────────────────────────── helpers ──────────────────────────

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> values,
    required T current,
    required String Function(T) labelFor,
    required void Function(T) onSelected,
  }) {
    if (isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: Text(title),
          actions: values
              .map(
                (v) => CupertinoActionSheetAction(
                  isDefaultAction: v == current,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onSelected(v);
                  },
                  child: Text(labelFor(v)),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: values
                .map(
                  (v) => ListTile(
                    title: Text(labelFor(v)),
                    trailing:
                        v == current ? const Icon(Icons.check) : null,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onSelected(v);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────── build ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    int themeMode =
        Hive.box('settings').get('themeMode', defaultValue: 0) as int;
    String teamTheme = Hive.box('settings')
        .get('teamTheme', defaultValue: 'default') as String;
    String fontUsedInArticles = Hive.box('settings')
        .get('fontUsedInArticles', defaultValue: 'Formula1') as String;

    final Map<String, String?> layoutValueToLabel = {
      'big': l10n.articleFull,
      'medium': l10n.articleTitleAndImage,
      'condensed': l10n.articleTitleAndDescription,
      'small': l10n.articleTitle,
    };
    final List<String> themeOptions = [
      l10n.followSystem,
      l10n.lightMode,
      l10n.darkMode,
    ];
    final Map<String, String> teamInternalToLabel = {
      'default': l10n.defaultValue ?? 'Default',
      'navyBlue': 'Navy Blue',
      'blueGrey': 'Blue Grey',
      'sauber': 'Kick Sauber',
      'rb': 'RB',
      'alpine': 'Alpine',
      'aston_martin': 'Aston Martin',
      'ferrari': 'Ferrari',
      'haas': 'Haas',
      'mclaren': 'McLaren',
      'mercedes': 'Mercedes',
      'red_bull': 'Red Bull',
      'williams': 'Williams',
    };
    final Map<String, String> fontInternalToLabel = {
      'Formula1': 'Formula 1',
      'Titilium': 'Titilium',
      'Roboto': l10n.defaultValue ?? 'Default',
    };

    String themeLabel = themeOptions[themeMode];
    String teamLabel = teamInternalToLabel[teamTheme] ?? teamTheme;
    String newsLayoutLabel = layoutValueToLabel[newsLayout] ?? newsLayout;
    String fontLabel = fontInternalToLabel[fontUsedInArticles] ?? fontUsedInArticles;

    // ── iOS layout ──────────────────────────────────────────────────────────
    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            l10n.appearance,
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
              // Theme
              CupertinoListSection.insetGrouped(
                header: Text(l10n.theme),
                children: [
                  CupertinoListTile.notched(
                    title: Text(l10n.theme),
                    trailing: Text(
                      themeLabel,
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey),
                    ),
                    onTap: () => _showPicker<int>(
                      context: context,
                      title: l10n.theme,
                      values: [0, 1, 2],
                      current: themeMode,
                      labelFor: (v) => themeOptions[v],
                      onSelected: (newMode) {
                        setState(() {
                          themeMode = newMode;
                          bool newValue;
                          if (newMode == 0) {
                            final brightness =
                                MediaQuery.of(context).platformBrightness;
                            newValue = brightness == Brightness.dark;
                            newValue
                                ? AdaptiveTheme.of(context).setDark()
                                : AdaptiveTheme.of(context).setLight();
                          } else if (newMode == 1) {
                            newValue = false;
                            AdaptiveTheme.of(context).setLight();
                          } else {
                            newValue = true;
                            AdaptiveTheme.of(context).setDark();
                          }
                          Hive.box('settings').put('darkMode', newValue);
                          Hive.box('settings').put('themeMode', newMode);
                          useDarkMode = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Team colours
              CupertinoListSection.insetGrouped(
                header: Text(l10n.teamColors),
                footer: Text(l10n.needsRestart),
                children: [
                  CupertinoListTile.notched(
                    title: Text(l10n.teamColors),
                    trailing: Text(
                      teamLabel,
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey),
                    ),
                    onTap: () => _showPicker<String>(
                      context: context,
                      title: l10n.teamColors,
                      values: teamInternalToLabel.keys.toList(),
                      current: teamTheme,
                      labelFor: (v) => teamInternalToLabel[v] ?? v,
                      onSelected: (newInternal) {
                        setState(() {
                          teamTheme = newInternal;
                          Hive.box('settings')
                              .put('teamTheme', newInternal);
                          final Color color = TeamBackgroundColor()
                              .getTeamColor(newInternal);
                          AdaptiveTheme.of(context).setTheme(
                            light: ThemeData(
                              useMaterial3: true,
                              brightness: Brightness.light,
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: color,
                                brightness: Brightness.light,
                              ),
                              fontFamily: 'Formula1',
                            ),
                            dark: ThemeData(
                              useMaterial3: true,
                              brightness: Brightness.dark,
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: color,
                                brightness: Brightness.dark,
                              ),
                              fontFamily: 'Formula1',
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),

              // News layout
              CupertinoListSection.insetGrouped(
                header: Text(l10n.newsLayout),
                children: [
                  CupertinoListTile.notched(
                    title: Text(l10n.newsLayout),
                    trailing: Text(
                      newsLayoutLabel,
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey),
                    ),
                    onTap: () => _showPicker<String>(
                      context: context,
                      title: l10n.newsLayout,
                      values: ['big', 'medium', 'condensed', 'small'],
                      current: newsLayout,
                      labelFor: (v) => layoutValueToLabel[v] ?? v,
                      onSelected: (newLayout) {
                        setState(() {
                          newsLayout = newLayout;
                          Hive.box('settings')
                              .put('newsLayout', newLayout);
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Font
              CupertinoListSection.insetGrouped(
                header: Text(l10n.font),
                footer: Text(l10n.fontDescription),
                children: [
                  CupertinoListTile.notched(
                    title: Text(l10n.font),
                    trailing: Text(
                      fontLabel,
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey),
                    ),
                    onTap: () => _showPicker<String>(
                      context: context,
                      title: l10n.font,
                      values: ['Formula1', 'Titilium', 'Roboto'],
                      current: fontUsedInArticles,
                      labelFor: (v) => fontInternalToLabel[v] ?? v,
                      onSelected: (newFont) {
                        setState(() {
                          fontUsedInArticles = newFont;
                          Hive.box('settings')
                              .put('fontUsedInArticles', newFont);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ── Android / Web layout ───────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appearance),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(l10n.theme),
            onTap: () {},
            trailing: DropdownButton<int>(
              value: themeMode,
              onChanged: (int? newThemeMode) {
                if (newThemeMode != null) {
                  setState(() {
                    bool newValue;
                    if (newThemeMode == 0) {
                      final Brightness brightnessValue =
                          MediaQuery.of(context).platformBrightness;
                      newValue = brightnessValue == Brightness.dark;
                      newValue
                          ? AdaptiveTheme.of(context).setDark()
                          : AdaptiveTheme.of(context).setLight();
                    } else if (newThemeMode == 1) {
                      newValue = false;
                      AdaptiveTheme.of(context).setLight();
                    } else {
                      newValue = true;
                      AdaptiveTheme.of(context).setDark();
                    }
                    Hive.box('settings').put('darkMode', newValue);
                    Hive.box('settings').put('themeMode', newThemeMode);
                    themeMode = newThemeMode;
                    useDarkMode = newValue;
                  });
                }
              },
              items: [0, 1, 2]
                  .map((v) => DropdownMenuItem<int>(
                        value: v,
                        child: Text(themeOptions[v],
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: Text(l10n.teamColors),
            subtitle: Text(l10n.needsRestart,
                style: const TextStyle(fontSize: 12)),
            onTap: () {},
            trailing: DropdownButton<String>(
              value: teamLabel,
              onChanged: (String? newLabel) {
                if (newLabel != null) {
                  final newInternal = teamInternalToLabel.entries
                      .firstWhere((e) => e.value == newLabel,
                          orElse: () =>
                              MapEntry('default', newLabel))
                      .key;
                  setState(() {
                    Hive.box('settings').put('teamTheme', newInternal);
                    final Color color =
                        TeamBackgroundColor().getTeamColor(newInternal);
                    AdaptiveTheme.of(context).setTheme(
                      light: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.light,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: color,
                          onPrimary: color,
                          brightness: Brightness.light,
                        ),
                        fontFamily: 'Formula1',
                      ),
                      dark: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.dark,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: color,
                          onPrimary:
                              HSLColor.fromColor(color)
                                  .withLightness(0.4)
                                  .toColor(),
                          brightness: Brightness.dark,
                        ),
                        fontFamily: 'Formula1',
                      ),
                    );
                    teamTheme = newInternal;
                  });
                }
              },
              items: teamInternalToLabel.values
                  .map((label) => DropdownMenuItem<String>(
                        value: label,
                        child: Text(label,
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: Text(l10n.newsLayout),
            onTap: () {},
            trailing: DropdownButton<String>(
              value: newsLayoutLabel,
              onChanged: (newLabel) {
                if (newLabel != null) {
                  final newLayout = layoutValueToLabel.entries
                      .firstWhere((e) => e.value == newLabel,
                          orElse: () => MapEntry('big', newLabel))
                      .key;
                  setState(() {
                    newsLayout = newLayout;
                    Hive.box('settings').put('newsLayout', newsLayout);
                  });
                }
              },
              items: layoutValueToLabel.values
                  .map((v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(
                          v ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: useDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: Text(l10n.font),
            subtitle: Text(l10n.fontDescription,
                style: const TextStyle(fontSize: 12)),
            trailing: DropdownButton<String>(
              value: fontLabel,
              onChanged: (newLabel) {
                if (newLabel != null) {
                  final newFont = fontInternalToLabel.entries
                      .firstWhere((e) => e.value == newLabel,
                          orElse: () => MapEntry('Roboto', newLabel))
                      .key;
                  setState(() {
                    fontUsedInArticles = newFont;
                    Hive.box('settings')
                        .put('fontUsedInArticles', fontUsedInArticles);
                  });
                }
              },
              items: fontInternalToLabel.values
                  .map((v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(v,
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
