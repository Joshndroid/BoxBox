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

import 'package:boxbox/Screens/404.dart';
import 'package:boxbox/Screens/FormulaYou/home.dart';
import 'package:boxbox/Screens/Settings/championship.dart';
import 'package:boxbox/Screens/Settings/formula_you.dart';
import 'package:boxbox/Screens/MixedNews/mixed_news.dart';
import 'package:boxbox/Screens/Settings/appearance.dart';
import 'package:boxbox/Screens/Settings/custom_home_feed.dart';
import 'package:boxbox/Screens/Settings/mixed_news.dart';
import 'package:boxbox/Screens/Settings/notifications.dart';
import 'package:boxbox/Screens/Settings/other.dart';
import 'package:boxbox/Screens/Settings/player.dart';
import 'package:boxbox/Screens/Settings/server.dart';
import 'package:boxbox/Screens/about.dart';
import 'package:boxbox/Screens/article.dart';
import 'package:boxbox/Screens/Racing/circuit.dart';
import 'package:boxbox/Screens/downloads.dart';
import 'package:boxbox/Screens/driver_details.dart';
import 'package:boxbox/Screens/free_practice.dart';
import 'package:boxbox/Screens/hall_of_fame.dart';
import 'package:boxbox/Screens/history.dart';
import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/Screens/racehub.dart';
import 'package:boxbox/Screens/schedule.dart';
import 'package:boxbox/Screens/Settings/settings.dart';
import 'package:boxbox/Screens/standings.dart';
import 'package:boxbox/Screens/team_details.dart';
import 'package:boxbox/Screens/video.dart';
import 'package:boxbox/Screens/videos.dart';
import 'package:boxbox/helpers/bottom_navigation_bar.dart';
import 'package:boxbox/helpers/platform_adaptive.dart';
import 'package:boxbox/helpers/route_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build a page with an adaptive (Cupertino / Material) app-bar shell.
// ─────────────────────────────────────────────────────────────────────────────
Widget _adaptivePage({
  required BuildContext context,
  required String title,
  required Widget body,
  List<Widget>? actions,
  bool centerTitle = true,
}) {
  if (isIOS) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Formula1',
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: actions != null && actions.isNotEmpty
            ? Row(mainAxisSize: MainAxisSize.min, children: actions)
            : null,
      ),
      child: SafeArea(bottom: false, child: body),
    );
  }
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
    ),
    body: body,
  );
}

class RouterLocalConfig {
  static final router = GoRouter(
    redirect: (context, state) {
      String url = state.uri.toString();
      if (url.startsWith('/')) url = url.replaceFirst('/', '');
      if (url.startsWith('https://www.formula1.com') ||
          url.startsWith('https://formula1.com')) {
        url = url
            .replaceAll('https://www.formula1.com', '')
            .replaceAll('https://formula1.com', '')
            .replaceAll('.html', '');
        if (url.startsWith('/en/latest/article/') ||
            url.startsWith('/en/latest/article.')) {
          return '/article/${url.split('.').last}';
        } else if (url.startsWith('/en/video/') ||
            url.startsWith('/en/latest/video.')) {
          return '/video/${url.split('.').last}';
        }
      }
      return null;
    },
    errorBuilder: (context, state) {
      String url = state.uri.toString();
      if (url.startsWith('/')) url = url.replaceFirst('/', '');
      if (url.startsWith('https://www.formula1.com') ||
          url.startsWith('https://formula1.com')) {
        return SharedLinkHandler(url);
      }
      return ErrorNotFoundScreen(route: state.uri.toString());
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainBottomNavigationBar(),
        routes: [
          // ── Article ────────────────────────────────────────────────────
          GoRoute(
            name: 'article',
            path: 'article/:id',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) extras = state.extra as Map;
              return ArticleScreen(
                state.pathParameters['id']!,
                extras?['articleName'] ?? '',
                extras == null ? true : extras['isFromLink'] ?? true,
                update: extras?['update'],
                news: extras?['news'],
                championshipOfArticle: extras?['championshipOfArticle'] ?? '',
              );
            },
          ),

          // ── Video ──────────────────────────────────────────────────────
          GoRoute(
            name: 'video',
            path: 'video/:id',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return VideoScreen(
                  extras['video'],
                  update: extras['update'],
                  videoChampionship: extras['videoChampionship'],
                );
              }
              return VideoScreenFromId(state.pathParameters['id']!);
            },
          ),

          // ── Drawer / More routes ───────────────────────────────────────
          GoRoute(
            name: 'formula-you',
            path: 'formula-you',
            builder: (context, state) => const PersonalizedHomeScreen(),
          ),
          GoRoute(
            name: 'mixed-news',
            path: 'mixed-news',
            builder: (context, state) => const MixedNewsScreen(),
          ),
          GoRoute(
            name: 'hall-of-fame',
            path: 'hall-of-fame',
            builder: (context, state) => const HallOfFameScreen(),
          ),
          GoRoute(
            name: 'history',
            path: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            name: 'downloads',
            path: 'downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),

          // ── Settings ───────────────────────────────────────────────────
          GoRoute(
            name: 'settings',
            path: 'settings',
            builder: (context, state) {
              Map? extras = state.extra as Map?;
              return SettingsScreen(update: extras?['update']);
            },
            routes: [
              GoRoute(
                name: 'appearance-settings',
                path: 'appearance',
                builder: (context, state) =>
                    const AppearanceSettingsScreen(),
              ),
              GoRoute(
                name: 'player-settings',
                path: 'player',
                builder: (context, state) => const PlayerSettingsScreen(),
              ),
              GoRoute(
                name: 'notifications-settings',
                path: 'notifications',
                builder: (context, state) =>
                    const NotificationsSettingsScreen(),
              ),
              GoRoute(
                name: 'other-settings',
                path: 'other',
                builder: (context, state) {
                  Map? extras = state.extra as Map?;
                  return OtherSettingsScreen(extras?['update']);
                },
              ),
              GoRoute(
                name: 'custom-home-feed-settings',
                path: 'custom-home-feed',
                builder: (context, state) {
                  Map? extras = state.extra as Map?;
                  return CustomeHomeFeedSettingsScreen(extras?['update']);
                },
              ),
              GoRoute(
                name: 'server-settings',
                path: 'server',
                builder: (context, state) {
                  Map? extras = state.extra as Map?;
                  return ServerSettingsScreen(extras?['update']);
                },
              ),
              GoRoute(
                name: 'formula-you-settings',
                path: 'formula-you',
                builder: (context, state) {
                  Map? extras = state.extra as Map?;
                  return FormulaYouSettingsScreen(update: extras?['update']);
                },
              ),
              GoRoute(
                name: 'mixed-news-settings',
                path: 'mixed-news',
                builder: (context, state) {
                  Map? extras = state.extra as Map?;
                  return EditOrderScreen(extras?['update']);
                },
              ),
              GoRoute(
                name: 'championship-settings',
                path: 'championship',
                builder: (context, state) => ChampionshipScreen(),
              ),
            ],
          ),
          GoRoute(
            name: 'about',
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),

          // ── Drivers & Teams ────────────────────────────────────────────
          GoRoute(
            name: 'drivers',
            path: 'drivers/:driverId',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return DriverDetailsScreen(
                  state.pathParameters['driverId']!,
                  extras['givenName'],
                  extras['familyName'],
                  detailsPath: extras['detailsPath'],
                );
              }
              return DriverDetailsFromIdScreen(
                  state.pathParameters['driverId']!);
            },
          ),
          GoRoute(
            name: 'teams',
            path: 'teams/:teamId',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return TeamDetailsScreen(
                  state.pathParameters['teamId']!,
                  extras['teamFullName'],
                  detailsPath: extras['detailsPath'],
                );
              }
              return TeamDetailsFromIdScreen(state.pathParameters['teamId']!);
            },
          ),

          // ── Circuits & Results ─────────────────────────────────────────
          GoRoute(
            name: 'racing',
            path: 'racing/:meetingId',
            builder: (context, state) {
              String championship = Hive.box('settings')
                  .get('championship', defaultValue: 'Formula 1') as String;
              if (championship == 'Formula 1') {
                try {
                  int.parse(state.pathParameters['meetingId']!);
                } catch (_) {
                  return CircuitScreenFromMeetingName(
                      state.pathParameters['meetingId']!);
                }
                return CircuitScreen(state.pathParameters['meetingId']!);
              }
              return CircuitScreen(state.pathParameters['meetingId']!);
            },
            routes: [
              GoRoute(
                name: 'starting-grid',
                path: 'starting-grid',
                builder: (context, state) => _adaptivePage(
                  context: context,
                  title: AppLocalizations.of(context)!.startingGrid,
                  body: StartingGridProvider(
                      state.pathParameters['meetingId']!),
                ),
              ),
              GoRoute(
                name: 'practice',
                path: 'practice/:sessionIndex',
                builder: (context, state) {
                  Map? extras;
                  if (state.extra != null) {
                    extras = state.extra as Map;
                    return FreePracticeScreen(
                      extras['sessionTitle'],
                      extras['sessionIndex'],
                      extras['circuitId'],
                      extras['meetingId'],
                      extras['raceYear'],
                      extras['raceName'],
                      raceUrl: extras['raceUrl'],
                      sessionId: extras['sessionId'],
                    );
                  }
                  return FreePracticeFromMeetingKeyScreen(
                    state.pathParameters['meetingId']!,
                    int.parse(state.pathParameters['sessionIndex']!),
                  );
                },
              ),
              GoRoute(
                name: 'sprint-shootout',
                path: 'sprint-shootout',
                builder: (context, state) => _adaptivePage(
                  context: context,
                  title: AppLocalizations.of(context)!.sprintQualifyings,
                  body: QualificationResultsProvider(
                    raceUrl: '',
                    sessionId: state.pathParameters['meetingId']!,
                    meetingId: state.pathParameters['meetingId']!,
                    hasSprint: true,
                    isSprintQualifying: true,
                  ),
                ),
              ),
              GoRoute(
                name: 'sprint',
                path: 'sprint',
                builder: (context, state) => _adaptivePage(
                  context: context,
                  title: AppLocalizations.of(context)!.sprint,
                  body: RaceResultsProvider(
                    raceUrl: 'sprint',
                    raceId: state.pathParameters['meetingId']!,
                  ),
                ),
              ),
              GoRoute(
                name: 'qualifyings',
                path: 'qualifyings',
                builder: (context, state) {
                  String? sessionId;
                  if (state.extra != null) {
                    sessionId = (state.extra as Map)['sessionId'] as String?;
                  }
                  return _adaptivePage(
                    context: context,
                    title: AppLocalizations.of(context)!.qualifyings,
                    body: QualificationResultsProvider(
                      raceUrl: '',
                      meetingId: state.pathParameters['meetingId']!,
                      isSprintQualifying: false,
                      sessionId: sessionId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: 'race',
                path: 'race',
                builder: (context, state) {
                  String? sessionId;
                  if (state.extra != null) {
                    sessionId = (state.extra as Map)['sessionId'] as String?;
                  }
                  return _adaptivePage(
                    context: context,
                    title: AppLocalizations.of(context)!.race,
                    body: RaceResultsProvider(
                      raceUrl: 'race',
                      raceId: state.pathParameters['meetingId']!,
                      sessionId: sessionId,
                    ),
                  );
                },
              ),
            ],
          ),

          // ── Standings ──────────────────────────────────────────────────
          GoRoute(
            name: 'standings',
            path: 'standings',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) extras = state.extra as Map;
              return _adaptivePage(
                context: context,
                title: AppLocalizations.of(context)!.standings,
                centerTitle: true,
                body: StandingsScreen(
                  switchToTeamStandings: extras?['switchToTeamStandings'],
                ),
              );
            },
          ),

          // ── Schedule ───────────────────────────────────────────────────
          GoRoute(
            name: 'schedule',
            path: 'schedule',
            builder: (context, state) => _adaptivePage(
              context: context,
              title: AppLocalizations.of(context)!.schedule,
              body: const ScheduleScreen(),
            ),
          ),

          // ── Race Hub ───────────────────────────────────────────────────
          GoRoute(
            name: 'race-hub',
            path: 'race-hub',
            builder: (context, state) {
              Map? extras;
              if (state.extra != null) {
                extras = state.extra as Map;
                return RaceHubScreen(extras['event']);
              }
              return RaceHubWithoutEventScreen();
            },
          ),

          // ── Videos list ────────────────────────────────────────────────
          GoRoute(
            name: 'videos',
            path: 'videos',
            builder: (context, state) => _adaptivePage(
              context: context,
              title: AppLocalizations.of(context)!.videos,
              body: VideosScreen(ScrollController()),
            ),
          ),
        ],
      ),
    ],
  );
}
