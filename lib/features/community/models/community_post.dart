import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final DateTime createdAt;
  final String authorName;
  final String authorAvatar;
  final Color avatarColor;
  final String category;
  final String title;
  final String description;
  final String? scheduledTime;
  final String? scheduledLocation;
  final String? imageUrl;
  final int likes;
  final int comments;
  final String actionText;
  final Color actionColor;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.authorName,
    required this.authorAvatar,
    required this.avatarColor,
    required this.category,
    required this.title,
    required this.description,
    this.scheduledTime,
    this.scheduledLocation,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.actionText,
    required this.actionColor,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final avatarColorValue = data['avatarColor'] as int?;
    final actionColorValue = data['actionColor'] as int?;
    
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorName: data['authorName'] ?? 'Unknown',
      authorAvatar: data['authorAvatar'] ?? 'U',
      avatarColor: avatarColorValue != null ? Color(avatarColorValue) : Colors.grey,
      category: data['category'] ?? 'General',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledTime: data['scheduledTime'],
      scheduledLocation: data['scheduledLocation'],
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      actionText: data['actionText'] ?? 'View',
      actionColor: actionColorValue != null ? Color(actionColorValue) : Colors.blue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'avatarColor': avatarColor.toARGB32(),
      'category': category,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime,
      'scheduledLocation': scheduledLocation,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'actionText': actionText,
      'actionColor': actionColor.toARGB32(),
    };
  }
}
