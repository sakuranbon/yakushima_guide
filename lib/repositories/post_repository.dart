import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // ← XFileを扱う
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<void> uploadPost({
    required PostModel post,
    required List<XFile> imageFiles,
  }) async {
    final postId = _uuid.v4();
    final imageUrls = <String>[];

    for (var i = 0; i < imageFiles.length; i++) {
      final ref = _storage.ref().child('posts/$postId/img_$i.jpg');

      final bytes = await imageFiles[i].readAsBytes();
      await ref.putData(bytes);

      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    final newPost = post.copyWith(
      id: postId,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').doc(postId).set(newPost.toJson());
  }

  Stream<List<PostModel>> watchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<PostModel>> watchUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList());
  }
}
