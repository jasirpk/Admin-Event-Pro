import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown when a profile request fails.
///
/// Never carries the Authorization header, an ID token, or a presigned URL —
/// only a message safe to show a user and the HTTP status.
class ProfileApiException implements Exception {
  final String message;
  final int? statusCode;

  ProfileApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ProfileApiException: $message${statusCode == null ? '' : ' ($statusCode)'}';
}

/// What a profile upload is for. The server maps this to a folder; the client
/// cannot name one.
enum ProfileUploadKind { avatar, portfolio }

/// Client for the entrepreneur's own profile and its media.
///
/// Profile pictures live in the same private R2 bucket as everything else.
/// Bytes never pass through the API: the client asks for a presigned PUT and
/// uploads straight to storage, then saves the resulting object keys.
///
/// The server owns `uid` and `createdAt` and rejects a body naming either, so
/// neither appears here.
class ProfileApiService {
  static final ProfileApiService instance = ProfileApiService();

  final http.Client _client;

  ProfileApiService({http.Client? client}) : _client = client ?? http.Client();

  static final String _configuredBaseUrl = dotenv.env['API_BASE_URL'] ?? "";

  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 120);

  /// Must match the API's ALLOWED_CONTENT_TYPES.
  static const Map<String, String> _contentTypes = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.webp': 'image/webp',
  };

  /// Must match the API's MAX_UPLOAD_BYTES.
  static const int maxUploadBytes = 10 * 1024 * 1024;

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && Platform.isIOS) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Uploads one local image and returns its R2 object key.
  ///
  /// The key is chosen by the server from the verified token's uid and the
  /// [kind], so this client cannot influence where the object lands.
  Future<String> uploadImage({
    required ProfileUploadKind kind,
    required File file,
  }) async {
    final contentType = _contentTypeFor(file.path);

    if (contentType == null) {
      throw ProfileApiException(
        'Unsupported image type. Please use a JPG, PNG or WebP file.',
      );
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw ProfileApiException('That image file appears to be empty.');
    }

    if (bytes.length > maxUploadBytes) {
      throw ProfileApiException(
        'That image is too large. Please choose one under 10 MB.',
      );
    }

    final signed = await _json(
      'POST',
      '/api/profile/upload-url',
      body: {
        'kind': kind == ProfileUploadKind.avatar ? 'avatar' : 'portfolio',
        'fileName': _basename(file.path),
        'contentType': contentType,
        'contentLength': bytes.length,
      },
      failureMessage: 'Could not prepare the image upload.',
    );

    final uploadUrl = signed['uploadUrl'] as String?;
    final objectKey = signed['objectKey'] as String?;

    if (uploadUrl == null || objectKey == null) {
      throw ProfileApiException('The server returned an incomplete upload URL.');
    }

    final http.Response response;

    try {
      response = await _client
          .put(
            Uri.parse(uploadUrl),
            // Both headers are bound into the signature, so storage rejects
            // the PUT if either differs from what was declared.
            headers: {
              'Content-Type': contentType,
              'Content-Length': '${bytes.length}',
            },
            body: bytes,
          )
          .timeout(_uploadTimeout);
    } catch (_) {
      // The presigned URL is never interpolated into the message: it grants
      // write access for its lifetime.
      throw ProfileApiException(
        'Could not upload the image. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ProfileApiException(
        'The image could not be stored. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return objectKey;
  }

  /// Saves the profile.
  ///
  /// A partial update: only the arguments given are sent, so anything left
  /// out keeps its stored value. Passing [images] replaces the portfolio
  /// array wholesale, which is how a removal is expressed.
  Future<String> updateProfile({
    String? companyName,
    String? description,
    String? website,
    String? phoneNumber,
    String? emailAddress,
    String? profileImage,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? links,
  }) async {
    final payload = <String, dynamic>{};

    if (companyName != null) payload['companyName'] = companyName;
    if (description != null) payload['description'] = description;
    if (website != null) payload['website'] = website;
    if (phoneNumber != null) payload['phoneNumber'] = phoneNumber;
    if (emailAddress != null) payload['emailAddress'] = emailAddress;
    if (profileImage != null) payload['profileImage'] = profileImage;
    if (images != null) payload['images'] = images;
    if (links != null) payload['links'] = links;

    if (payload.isEmpty) {
      throw ProfileApiException('There is nothing to save.');
    }

    final body = await _json(
      'PATCH',
      '/api/profile',
      body: payload,
      failureMessage: 'The profile could not be saved.',
    );

    final updatedAt = body['updatedAt'] as String?;

    if (updatedAt == null) {
      throw ProfileApiException(
        'The server saved the profile but returned an incomplete response.',
      );
    }

    return updatedAt;
  }

  // ---------------------------------------------------------------- helpers

  /// The part of [path] after the last separator. Hand-rolled rather than
  /// pulling in package:path, which this app only has transitively.
  static String _basename(String path) {
    final separator = path.lastIndexOf(RegExp(r'[/\\]'));
    return separator == -1 ? path : path.substring(separator + 1);
  }

  static String _extension(String path) {
    final name = _basename(path);
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? '' : name.substring(dot).toLowerCase();
  }

  String? _contentTypeFor(String path) => _contentTypes[_extension(path)];

  Future<Map<String, dynamic>> _json(
    String method,
    String path, {
    Object? body,
    int expectedStatus = 200,
    required String failureMessage,
  }) async {
    final token = await _currentIdToken();
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final http.Response response;

    try {
      final encoded = body == null ? null : jsonEncode(body);

      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encoded)
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encoded)
              .timeout(_timeout);
          break;
        default:
          throw ProfileApiException('Unsupported request.');
      }
    } catch (error) {
      if (error is ProfileApiException) rethrow;

      // The underlying error is not interpolated: it can quote the full
      // request, Authorization header included.
      throw ProfileApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode != expectedStatus) {
      throw ProfileApiException(
        _messageForStatus(response.statusCode, failureMessage),
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) return const {};

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// The server answers every validation failure with one generic message so
  /// the response is not an oracle; that is right for the API and wrong to
  /// show here, so the mapping happens on this side.
  String _messageForStatus(int statusCode, String fallback) {
    switch (statusCode) {
      case 400:
        return 'Some of the profile details are invalid. Please review and try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'This account is not allowed to edit this profile.';
      case 404:
        return 'Your profile could not be found.';
      case 413:
        return 'The profile details are too large. Try shortening the description.';
      case 429:
        return "You've saved too many times recently. Please try again later.";
      default:
        return statusCode >= 500
            ? 'The server could not save the profile. Please try again later.'
            : fallback;
    }
  }

  Future<String> _currentIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ProfileApiException('Please sign in again to edit your profile.');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw ProfileApiException('Please sign in again to edit your profile.');
    }
    return token;
  }
}
