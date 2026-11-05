import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/content_repository.dart';
import '../data/progress_store.dart';
import '../models/models.dart';
import 'progress_notifier.dart';

// Overridden in main() after assets and storage are loaded.
final contentProvider = Provider<Content>((ref) => throw UnimplementedError('contentProvider not overridden'));
final storeProvider = Provider<ProgressStore>((ref) => throw UnimplementedError('storeProvider not overridden'));

final progressProvider = StateNotifierProvider<ProgressNotifier, UserProgress>(
  (ref) => ProgressNotifier(ref.watch(contentProvider), ref.watch(storeProvider)),
);

final isBanglaProvider = Provider<bool>((ref) => ref.watch(progressProvider).language == 'bn');

/// Selected bottom-navigation tab (0 Home, 1 Learn, 2 Practice, 3 Ranks, 4 Profile).
final tabProvider = StateProvider<int>((ref) => 0);
