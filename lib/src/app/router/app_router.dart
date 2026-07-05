import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/localization/app_localizations_extension.dart';
import '../../features/journal/application/providers/journal_providers.dart';
import '../../features/journal/application/state/journal_session_controller.dart';
import '../../features/journal/domain/entities/journal_entities.dart';
import '../../features/journal/presentation/components/journal_components.dart';
import '../../features/journal/presentation/screens/home_screen.dart';
import '../../features/journal/presentation/screens/letter_detail_screen.dart';
import '../../features/journal/presentation/screens/letters_screen.dart';
import '../../features/journal/presentation/screens/map_screen.dart';
import '../../features/journal/presentation/screens/memory_detail_screen.dart';
import '../../features/journal/presentation/screens/memory_form_screen.dart';
import '../../features/journal/presentation/screens/opening_gift_screen.dart';
import '../../features/journal/presentation/screens/recap_screen.dart';
import '../../features/journal/presentation/screens/timeline_screen.dart';
import '../navigation/main_navigation_shell.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>();
final timelineNavigatorKey = GlobalKey<NavigatorState>();
final mapNavigatorKey = GlobalKey<NavigatorState>();
final lettersNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier();
  final journalDataSubscription = ref.listen(
    journalDataProvider,
    (_, _) => refreshNotifier.refresh(),
  );
  final sessionSubscription = ref.listen(
    journalSessionControllerProvider,
    (_, _) => refreshNotifier.refresh(),
  );

  ref.onDispose(() {
    journalDataSubscription.close();
    sessionSubscription.close();
    refreshNotifier.dispose();
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (_, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        name: AppRouteNames.root,
        path: AppRoutePaths.root,
        builder: (_, _) => const _RouterLoadingScreen(),
      ),
      GoRoute(
        name: AppRouteNames.splash,
        path: AppRoutePaths.splash,
        builder: (_, _) => const _RouterLoadingScreen(),
      ),
      GoRoute(
        name: AppRouteNames.opening,
        path: AppRoutePaths.opening,
        builder: (context, _) {
          return OpeningGiftScreen(
            onOpenGift: () {
              unawaited(
                ref
                    .read(journalSessionControllerProvider.notifier)
                    .completeOpening(),
              );
              context.goNamed(AppRouteNames.home);
            },
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.error,
        path: AppRoutePaths.error,
        builder: (_, _) => const _RouterErrorScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(
            navigationShell: navigationShell,
            currentPath: state.uri.path,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                name: AppRouteNames.home,
                path: AppRoutePaths.home,
                builder: (context, _) {
                  return _JournalRouteBuilder(
                    builder: (context, ref, data, preferences) {
                      final now = DateTime.now();
                      return HomeScreen(
                        data: data,
                        now: now,
                        openedLetterIds: preferences.openedLetterIds,
                        onMemoryTap: (memory) => _openMemory(
                          context: context,
                          ref: ref,
                          routeName: AppRouteNames.homeMemory,
                          memory: memory,
                        ),
                        onLetterTap: (letter) => _openLetter(
                          context: context,
                          ref: ref,
                          routeName: AppRouteNames.homeLetter,
                          letter: letter,
                        ),
                        onRecapTap: () =>
                            context.pushNamed(AppRouteNames.homeRecap),
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    name: AppRouteNames.homeMemory,
                    path: AppRoutePaths.memoryDetailSegment,
                    builder: (_, state) {
                      return _MemoryDetailRoute(
                        memoryId: _requiredParam(
                          state,
                          AppRouteParams.memoryId,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    name: AppRouteNames.homeLetter,
                    path: AppRoutePaths.letterDetailSegment,
                    builder: (_, state) {
                      return _LetterDetailRoute(
                        letterId: _requiredParam(
                          state,
                          AppRouteParams.letterId,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    name: AppRouteNames.homeRecap,
                    path: AppRoutePaths.recapSegment,
                    builder: (_, _) => const _RecapRoute(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: timelineNavigatorKey,
            routes: [
              GoRoute(
                name: AppRouteNames.timeline,
                path: AppRoutePaths.timeline,
                builder: (context, _) {
                  return _JournalRouteBuilder(
                    builder: (context, ref, data, _) {
                      return TimelineScreen(
                        memories: data.visibleMemories,
                        tags: data.tags,
                        onMemoryTap: (memory) => _openMemory(
                          context: context,
                          ref: ref,
                          routeName: AppRouteNames.timelineMemory,
                          memory: memory,
                        ),
                        onAddMemory: () =>
                            context.pushNamed(AppRouteNames.timelineAddMemory),
                        onEditMemory: (memory) => context.pushNamed(
                          AppRouteNames.timelineEditMemory,
                          pathParameters: {AppRouteParams.memoryId: memory.id},
                        ),
                        onDeleteMemory: (memory) => unawaited(
                          ref
                              .read(journalDataProvider.notifier)
                              .softDeleteMemory(memory.id),
                        ),
                        onFeatureMemory: (memory) => unawaited(
                          ref
                              .read(journalDataProvider.notifier)
                              .setFeaturedMemory(memory.id),
                        ),
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    name: AppRouteNames.timelineAddMemory,
                    path: AppRoutePaths.addMemorySegment,
                    builder: (_, _) {
                      return const _MemoryFormRoute();
                    },
                  ),
                  GoRoute(
                    name: AppRouteNames.timelineEditMemory,
                    path: AppRoutePaths.editMemorySegment,
                    builder: (_, state) {
                      return _MemoryFormRoute(
                        memoryId: _requiredParam(
                          state,
                          AppRouteParams.memoryId,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    name: AppRouteNames.timelineMemory,
                    path: AppRoutePaths.memoryDetailSegment,
                    builder: (_, state) {
                      return _MemoryDetailRoute(
                        memoryId: _requiredParam(
                          state,
                          AppRouteParams.memoryId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: mapNavigatorKey,
            routes: [
              GoRoute(
                name: AppRouteNames.map,
                path: AppRoutePaths.map,
                builder: (context, _) {
                  return _JournalRouteBuilder(
                    builder: (context, ref, data, _) {
                      return MapScreen(
                        data: data,
                        onMemoryTap: (memory) => _openMemory(
                          context: context,
                          ref: ref,
                          routeName: AppRouteNames.mapMemory,
                          memory: memory,
                        ),
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    name: AppRouteNames.mapMemory,
                    path: AppRoutePaths.memoryDetailSegment,
                    builder: (_, state) {
                      return _MemoryDetailRoute(
                        memoryId: _requiredParam(
                          state,
                          AppRouteParams.memoryId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: lettersNavigatorKey,
            routes: [
              GoRoute(
                name: AppRouteNames.letters,
                path: AppRoutePaths.letters,
                builder: (context, _) {
                  return _JournalRouteBuilder(
                    builder: (context, ref, data, preferences) {
                      return LettersScreen(
                        letters: data.letters,
                        now: DateTime.now(),
                        openedLetterIds: preferences.openedLetterIds,
                        onLetterTap: (letter) => _openLetter(
                          context: context,
                          ref: ref,
                          routeName: AppRouteNames.letterDetail,
                          letter: letter,
                        ),
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    name: AppRouteNames.letterDetail,
                    path: AppRoutePaths.branchLetterDetailSegment,
                    builder: (_, state) {
                      return _LetterDetailRoute(
                        letterId: _requiredParam(
                          state,
                          AppRouteParams.letterId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String? _redirect(Ref ref, GoRouterState state) {
  final path = state.uri.path;
  final journalData = ref.read(journalDataProvider);
  final session = ref.read(journalSessionControllerProvider);

  final isSplash = path == AppRoutePaths.root || path == AppRoutePaths.splash;
  final isOpening = path == AppRoutePaths.opening;
  final isError = path == AppRoutePaths.error;

  if (journalData.isLoading || session.isLoading) {
    return isSplash ? null : AppRoutePaths.splash;
  }

  if (journalData.hasError || session.hasError) {
    return isError ? null : AppRoutePaths.error;
  }

  final hasSeenOpening = session.value?.hasSeenOpening ?? false;
  if (!hasSeenOpening) {
    return isOpening ? null : AppRoutePaths.opening;
  }

  if (isSplash || isOpening || isError) {
    return AppRoutePaths.home;
  }

  return null;
}

void _openMemory({
  required BuildContext context,
  required WidgetRef ref,
  required String routeName,
  required Memory memory,
}) {
  unawaited(
    ref
        .read(journalSessionControllerProvider.notifier)
        .markLastViewedMemory(memory.id),
  );
  context.pushNamed(
    routeName,
    pathParameters: {AppRouteParams.memoryId: memory.id},
  );
}

void _openLetter({
  required BuildContext context,
  required WidgetRef ref,
  required String routeName,
  required Letter letter,
}) {
  unawaited(
    ref
        .read(journalSessionControllerProvider.notifier)
        .markLetterOpened(letter.id),
  );
  context.pushNamed(
    routeName,
    pathParameters: {AppRouteParams.letterId: letter.id},
  );
}

String _requiredParam(GoRouterState state, String name) {
  final value = state.pathParameters[name];
  if (value == null || value.isEmpty) {
    throw GoException('Missing route parameter: $name');
  }
  return value;
}

class _GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _JournalRouteBuilder extends ConsumerWidget {
  const _JournalRouteBuilder({required this.builder});

  final Widget Function(
    BuildContext context,
    WidgetRef ref,
    JournalData data,
    JournalPreferences preferences,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(journalDataProvider);
    final session = ref.watch(journalSessionControllerProvider);

    return data.when(
      data: (journalData) {
        return session.when(
          data: (preferences) {
            return builder(context, ref, journalData, preferences);
          },
          loading: () => const _RouterLoadingScreen(),
          error: (error, _) => _RouterErrorScreen(error: error),
        );
      },
      loading: () => const _RouterLoadingScreen(),
      error: (error, _) => _RouterErrorScreen(error: error),
    );
  }
}

class _MemoryDetailRoute extends ConsumerWidget {
  const _MemoryDetailRoute({required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _JournalRouteBuilder(
      builder: (context, ref, data, preferences) {
        final memory = data.memoryById(memoryId);
        return MemoryDetailScreen(
          memory: memory,
          isFavorite: preferences.favoriteMemoryIds.contains(memory.id),
          onToggleFavorite: () => unawaited(
            ref
                .read(journalSessionControllerProvider.notifier)
                .toggleFavoriteMemory(memory.id),
          ),
        );
      },
    );
  }
}

class _MemoryFormRoute extends ConsumerWidget {
  const _MemoryFormRoute({this.memoryId});

  final String? memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _JournalRouteBuilder(
      builder: (_, ref, data, _) {
        final id = memoryId;
        final memory = id == null ? null : data.memoryById(id);
        return MemoryFormScreen(
          data: data,
          memory: memory,
          onCreateTag: (name) {
            return ref.read(journalDataProvider.notifier).createTag(name);
          },
          onSubmit: (draft) {
            if (id == null) {
              return ref.read(journalDataProvider.notifier).createMemory(draft);
            }
            return ref
                .read(journalDataProvider.notifier)
                .updateMemory(id, draft);
          },
        );
      },
    );
  }
}

class _LetterDetailRoute extends ConsumerWidget {
  const _LetterDetailRoute({required this.letterId});

  final String letterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _JournalRouteBuilder(
      builder: (_, _, data, _) {
        return LetterDetailScreen(letter: data.letterById(letterId));
      },
    );
  }
}

class _RecapRoute extends ConsumerWidget {
  const _RecapRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _JournalRouteBuilder(
      builder: (_, _, data, _) {
        return RecapScreen(data: data, now: DateTime.now());
      },
    );
  }
}

class _RouterLoadingScreen extends StatelessWidget {
  const _RouterLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppScaffold(
        child: Center(child: CircularProgressIndicator(color: AppColors.rose)),
      ),
    );
  }
}

class _RouterErrorScreen extends ConsumerWidget {
  const _RouterErrorScreen({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeError =
        error ??
        ref.watch(journalDataProvider).error ??
        ref.watch(journalSessionControllerProvider).error ??
        context.l10n.routerUnknownError;

    return Scaffold(
      body: AppScaffold(
        child: Center(
          child: EmptyStateCard(
            title: context.l10n.routerErrorTitle,
            body: '$routeError',
          ),
        ),
      ),
    );
  }
}
