import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/app_tokens.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/journal/data/local_journal_store.dart';
import '../features/journal/domain/journal_models.dart';
import '../features/journal/presentation/components/journal_components.dart';
import '../features/journal/presentation/screens/home_screen.dart';
import '../features/journal/presentation/screens/letter_detail_screen.dart';
import '../features/journal/presentation/screens/letters_screen.dart';
import '../features/journal/presentation/screens/map_screen.dart';
import '../features/journal/presentation/screens/memory_detail_screen.dart';
import '../features/journal/presentation/screens/opening_gift_screen.dart';
import '../features/journal/presentation/screens/recap_screen.dart';
import '../features/journal/presentation/screens/timeline_screen.dart';
import 'journal_app_config.dart';
import 'journal_app_controller.dart';

class LoveJournalApp extends StatelessWidget {
  const LoveJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: JournalAppConfig.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<JournalAppController> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _loadController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JournalAppController>(
      future: _controllerFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _OpeningGate(controller: snapshot.requireData);
        }

        if (snapshot.hasError) {
          return _BootstrapError(error: snapshot.error);
        }

        return const _BootstrapLoading();
      },
    );
  }

  Future<JournalAppController> _loadController() async {
    final repository = JournalRepository();
    final store = await LocalJournalStore.create();
    final data = await repository.load();
    return JournalAppController(data: data, store: store);
  }
}

class _OpeningGate extends StatelessWidget {
  const _OpeningGate({required this.controller});

  final JournalAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.hasSeenOpening) {
          return OpeningGiftScreen(
            onOpenGift: () => unawaited(controller.completeOpening()),
          );
        }
        return MainJournalShell(controller: controller);
      },
    );
  }
}

class MainJournalShell extends StatefulWidget {
  const MainJournalShell({required this.controller, super.key});

  final JournalAppController controller;

  @override
  State<MainJournalShell> createState() => _MainJournalShellState();
}

class _MainJournalShellState extends State<MainJournalShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final data = widget.controller.data;
        final now = DateTime.now();

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  HomeScreen(
                    data: data,
                    now: now,
                    openedLetterIds: widget.controller.openedLetterIds,
                    onMemoryTap: _openMemory,
                    onLetterTap: _openLetter,
                    onRecapTap: () => _openRecap(data, now),
                  ),
                  TimelineScreen(
                    memories: data.memories,
                    onMemoryTap: _openMemory,
                  ),
                  MapScreen(data: data, onMemoryTap: _openMemory),
                  LettersScreen(
                    letters: data.letters,
                    now: now,
                    openedLetterIds: widget.controller.openedLetterIds,
                    onLetterTap: _openLetter,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom,
                child: AppBottomTabBar(
                  currentIndex: _currentIndex,
                  onChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMemory(Memory memory) {
    unawaited(widget.controller.markLastViewedMemory(memory.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return MemoryDetailScreen(
                memory: memory,
                isFavorite: widget.controller.isFavoriteMemory(memory.id),
                onToggleFavorite: () => unawaited(
                  widget.controller.toggleFavoriteMemory(memory.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openLetter(Letter letter) {
    unawaited(widget.controller.markLetterOpened(letter.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LetterDetailScreen(letter: letter),
      ),
    );
  }

  void _openRecap(JournalData data, DateTime now) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RecapScreen(data: data, now: now),
      ),
    );
  }
}

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppScaffold(
        child: Center(child: CircularProgressIndicator(color: AppColors.rose)),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: Center(
          child: EmptyStateCard(title: 'Chưa mở được nhật ký', body: '$error'),
        ),
      ),
    );
  }
}
