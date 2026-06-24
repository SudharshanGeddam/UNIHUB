import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unihub/features/community/models/community_post.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CommunityPost>> getPosts({String? category}) {
    Query query = _firestore.collection('community_posts');
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    // Order by createdAt descending
    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CommunityPost.fromFirestore(doc)).toList();
    });
  }

  Future<void> createPost({required CommunityPost post}) async {
    await _firestore.collection('community_posts').doc(post.id).set(post.toMap());
  }

  Future<void> likePost(String postId) async {
    await _firestore.collection('community_posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('community_posts').doc(postId).delete();
  }
}
