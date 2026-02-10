import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'base_conditional.dart';

/// Create a [IOConditional].
///
/// Used from conditional imports, matches the definition in `conditional_stub.dart`.
BaseConditional createConditional() => IOConditional();

/// A conditional for anything but browser
class IOConditional extends BaseConditional {
  /// Returns [CachedNetworkImageProvider] if URI starts with http for better caching
  /// otherwise uses IO to create File
  @override
  ImageProvider getProvider(String uri) {
    if (uri.startsWith('http')) {
      // Use CachedNetworkImageProvider for faster loading with caching
      return CachedNetworkImageProvider(uri);
    } else {
      return FileImage(File(uri));
    }
  }
}
