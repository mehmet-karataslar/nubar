import 'package:nubar/core/constants/app_constants.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (value.length > AppConstants.maxUsernameLength) {
      return 'Username must be at most ${AppConstants.maxUsernameLength} characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePostContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Post content is required';
    }
    if (value.length > AppConstants.maxPostLength) {
      return 'Post must be at most ${AppConstants.maxPostLength} characters';
    }
    return null;
  }

  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment is required';
    }
    if (value.length > AppConstants.maxCommentLength) {
      return 'Comment must be at most ${AppConstants.maxCommentLength} characters';
    }
    return null;
  }
}
