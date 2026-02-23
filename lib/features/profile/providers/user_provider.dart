import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/isar_provider.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

// User Profile Providers
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return UserRepository(isar);
});

final currentUserProvider = StreamProvider<User?>((ref) async* {
  final repo = await ref.watch(userRepositoryProvider.future);
  yield await repo.getUser();
  yield* repo.watchUser();
});
