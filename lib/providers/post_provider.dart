import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';

final postRepositoryProvider =
    Provider<PostRepository>((ref) => PostRepository());

final postListProvider = StreamProvider<List<PostModel>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.watchPosts();
});

final userPostListProvider =
    StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.watchUserPosts(userId);
});
