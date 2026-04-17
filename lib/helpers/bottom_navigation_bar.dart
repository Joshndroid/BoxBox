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

import 'package:background_downloader/background_downloader.dart';
import 'package:boxbox/Screens/home.dart';
import 'package:boxbox/Screens/more_screen.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/search.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:boxbox/Screens/videos.dart';
import 'package:boxbox/helpers/drawer.dart';
import 'package:boxbox/helpers/news_feed_widget.dart';
import 'package:boxbox/helpers/platform_adaptive.dart';
import 'package:boxbox/providers/general/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — chooses the right shell based on platform
// ─────────────────────────────────────────────────────────────────────────────

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  bool _configuredDownloaderNotifications = false;

  void _homeSetState() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && !_configuredDownloaderNotifications) {
      _configuredDownloaderNotifications = true;
      FileDownloader().configureNotification(
        running: TaskNotification(
          AppLocalizations.of(context)!.downloadRunning,
          '{displayName}',
        ),
        complete: TaskNotification(
          AppLocalizations.of(context)!.downloadComplete,
          '{displayName}',
        ),
        error: TaskNotification(
          AppLocalizations.of(context)!.downloadFailed,
          '{displayName}',
        ),
        paused: TaskNotification(
          AppLocalizations.of(context)!.downloadPaused,
          '{displayName}',
        ),
        progressBar: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update dark-mode preference based on system / setting
    final settings = Hive.box('settings');
    int themeMode =
        Hive.box('settings').get('themeMode', defaultValue: 0) as int;
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = brightness == Brightness.dark;
    final bool darkMode = themeMode == 0
        ? isDark
        : themeMode == 1
            ? false
            : true;
    if (settings.get('darkMode') != darkMode) {
      settings.put('darkMode', darkMode);
    }

    if (isIOS) {
      return _IosTabShell(homeSetState: _homeSetState);
    }
    return _AndroidNavShell(homeSetState: _homeSetState);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Android / Web shell  (unchanged Material design)
// ─────────────────────────────────────────────────────────────────────────────

class _AndroidNavShell extends StatefulWidget {
  final VoidCallback homeSetState;
  const _AndroidNavShell({required this.homeSetState});

  @override
  State<_AndroidNavShell> createState() => _AndroidNavShellState();
}

class _AndroidNavShellState extends State<_AndroidNavShell> {
  int _selectedIndex = 0;
  List<Widget> actions = [];
  String? _championship;
  late List<ScrollController> _scrollControllers;
  late List<Widget> _screens;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    super.initState();
    _syncScreens();
  }

  void _syncScreens() {
    final championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (_championship == championship) {
      return;
    }

    if (_championship != null) {
      for (final controller in _scrollControllers) {
        controller.dispose();
      }
    }
    _championship = championship;
    _scrollControllers = [
      for (int i = 0; i < _tabCountForChampionship(championship); i++)
        ScrollController(),
    ];
    _screens = _buildScreens(championship);
    if (_selectedIndex >= _screens.length) {
      _selectedIndex = _screens.length - 1;
    }
  }

  int _tabCountForChampionship(String championship) {
    return championship == 'Formula 1' || championship == 'Formula E' ? 4 : 3;
  }

  List<Widget> _buildScreens(String championship) {
    if (championship == 'Formula 1' || championship == 'Formula E') {
      return [
        HomeScreen(_scrollControllers[0]),
        VideosScreen(_scrollControllers[1]),
        StandingsScreen(scrollController: _scrollControllers[2]),
        ScheduleScreen(scrollController: _scrollControllers[3]),
      ];
    }

    return [
      HomeScreen(_scrollControllers[0]),
      StandingsScreen(scrollController: _scrollControllers[1]),
      ScheduleScreen(scrollController: _scrollControllers[2]),
    ];
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncScreens();
    final List<Widget> appBarActions =
        _selectedIndex == 0 ? UIProvider().getNewsAppBarActions(context) : [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Box, Box!',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: appBarActions,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: MainDrawer(widget.homeSetState),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 4,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        elevation: 10.0,
        destinations: UIProvider().getBottomNavigationBarButtons(context),
        onDestinationSelected: _onItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS shell  (CupertinoTabScaffold + CupertinoTabBar)
// ─────────────────────────────────────────────────────────────────────────────

class _IosTabShell extends StatefulWidget {
  final VoidCallback homeSetState;
  const _IosTabShell({required this.homeSetState});

  @override
  State<_IosTabShell> createState() => _IosTabShellState();
}

class _IosTabShellState extends State<_IosTabShell> {
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  String get _championship =>
      Hive.box('settings').get('championship', defaultValue: 'Formula 1')
          as String;

  // ── Tab-bar items ──────────────────────────────────────────────────────────

  List<BottomNavigationBarItem> _tabBarItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool hasVideos =
        _championship == 'Formula 1' || _championship == 'Formula E';

    return [
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.news),
        label: l10n.news,
      ),
      if (hasVideos)
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.play_circle),
          label: l10n.videos,
        ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.rosette),
        label: l10n.standings,
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.calendar),
        label: l10n.schedule,
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.ellipsis_circle),
        label: 'More',
      ),
    ];
  }

  // ── Tab content builder ────────────────────────────────────────────────────

  Widget _buildTab(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final bool hasVideos =
        _championship == 'Formula 1' || _championship == 'Formula E';

    // Map tab index → logical role considering whether Videos tab exists
    //   hasVideos:  0=News 1=Videos 2=Standings 3=Schedule 4=More
    //   !hasVideos: 0=News 1=Standings 2=Schedule 3=More

    if (!hasVideos) {
      switch (index) {
        case 0:
          return _newsTab(context, l10n);
        case 1:
          return _standingsTab(context, l10n);
        case 2:
          return _scheduleTab(context, l10n);
        default:
          return _moreTab(context);
      }
    }

    switch (index) {
      case 0:
        return _newsTab(context, l10n);
      case 1:
        return _videosTab(context, l10n);
      case 2:
        return _standingsTab(context, l10n);
      case 3:
        return _scheduleTab(context, l10n);
      default:
        return _moreTab(context);
    }
  }

  // ── Individual tab wrappers ────────────────────────────────────────────────

  Widget _newsTab(BuildContext context, AppLocalizations l10n) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Box, Box!',
          style: TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                ),
                child: const Icon(CupertinoIcons.search, size: 22),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showNewsFilterSheet(context, l10n),
              child: const Icon(CupertinoIcons.line_horizontal_3_decrease,
                  size: 22),
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: HomeScreen(_scrollControllers[0]),
      ),
    );
  }

  Widget _videosTab(BuildContext context, AppLocalizations l10n) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          l10n.videos,
          style: const TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: VideosScreen(_scrollControllers[1]),
      ),
    );
  }

  Widget _standingsTab(BuildContext context, AppLocalizations l10n) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          l10n.standings,
          style: const TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: StandingsScreen(scrollController: _scrollControllers[2]),
      ),
    );
  }

  Widget _scheduleTab(BuildContext context, AppLocalizations l10n) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          l10n.schedule,
          style: const TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ScheduleScreen(scrollController: _scrollControllers[3]),
      ),
    );
  }

  Widget _moreTab(BuildContext context) {
    return MoreScreen(homeSetState: widget.homeSetState);
  }

  // ── News filter action sheet ───────────────────────────────────────────────

  void _showNewsFilterSheet(BuildContext context, AppLocalizations l10n) {
    final List<String> filterItems = [
      'Feature',
      'Image Gallery',
      'Interview',
      'News',
      'Opinion',
      'Podcast',
      'Poll',
      'Report',
      'Technical',
      'Video',
    ];

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.topics),
        actions: filterItems
            .map(
              (item) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => CupertinoPageScaffold(
                        navigationBar: CupertinoNavigationBar(
                          middle: Text(item),
                          previousPageTitle: l10n.news,
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: NewsFeed(articleType: item),
                        ),
                      ),
                    ),
                  );
                },
                child: Text(item),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.close),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _tabBarItems(context);
    final accentColor = Theme.of(context).colorScheme.primary;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: items,
        activeColor: accentColor,
      ),
      tabBuilder: (context, index) => CupertinoTabView(
        builder: (ctx) => _buildTab(ctx, index),
      ),
    );
  }
}
