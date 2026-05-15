import 'package:flutter/material.dart';

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final Color avatarColor;
  final String timeAgo;
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
    required this.authorName,
    required this.authorAvatar,
    required this.avatarColor,
    required this.timeAgo,
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
}
