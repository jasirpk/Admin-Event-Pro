import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// TEMPORARY diagnostic logging for the vendor registration path.
///
/// Set to false (or delete every `_debug` call and this flag) once the flow
/// is confirmed working. It never logs an ID token, an Authorization header,
/// or a presigned URL — only whether a token was obtained.
const bool kVendorApiDebug = false;

/// Thrown when a vendor-registration request fails.
///
/// Never carries the Authorization header, an ID token, or a presigned URL —
/// only a message safe to show a user, the HTTP status (if any), and a
/// truncated response body kept for logs.
class VendorApiException implements Exception {
  /// Phrased for a snackbar: this is what the user sees.
  final String message;
  final int? statusCode;
  final String? responseBody;

  VendorApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    final status = statusCode != null ? ' (status $statusCode)' : '';
    final body = responseBody != null ? ' — $responseBody' : '';
    return 'VendorApiException: $message$status$body';
  }
}

/// The result of a successful registration.
class VendorCreation {
  final String vendorId;

  /// ISO-8601 UTC, stamped by the server at the moment of the write.
  final String createdAt;

  const VendorCreation({required this.vendorId, required this.createdAt});
}

/// Client for vendor registration and vendor image storage.
///
/// Vendor artwork lives in the same private Cloudflare R2 bucket as the
/// catalogue. Bytes never pass through the API: the client asks for a
/// presigned PUT and uploads straight to storage, then registers the listing
/// with the resulting object keys.
///
/// The server owns `uid`, `isValid`, `isAccepted`, `isRejected` and
/// `createdAt`, and rejects a request that supplies any of them — so none of
/// them appear as parameters here.
class VendorApiService {
  /// The instance every caller should use. One long-lived client.
  static final VendorApiService instance = VendorApiService();

  final http.Client _client;

  VendorApiService({http.Client? client}) : _client = client ?? http.Client();

  static final String _configuredBaseUrl = dotenv.env['API_BASE_URL'] ?? "";

  static const Duration _timeout = Duration(seconds: 30);

  /// Uploads go straight to storage and can be several megabytes.
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

  /// Matches the convention already used by this app's other API clients.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    // Local development default. 10.0.2.2 is the host machine as seen from the
    // Android emulator; every other target reaches it as localhost.
    if (!kIsWeb && Platform.isIOS) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Reserves the id the listing will be created under.
  ///
  /// Images upload into that id's own namespace, so a registration that is
  /// never completed leaves a prefix that [discardUploads] can clear in one
  /// call — rather than a scattering of anonymous objects.
  Future<String> createDraft() async {
    final body = await _json(
      'POST',
      '/api/vendors/draft',
      // 201, not the 200 default: reserving an id creates something, and the
      // API says so. Omitting this made every successful draft look like a
      // failure, because _json compares the status to expectedStatus before
      // anything else — the request succeeded and the client threw anyway.
      expectedStatus: 201,
      failureMessage: 'Could not start the registration.',
    );

    final vendorId = body['vendorId'] as String?;

    if (vendorId == null) {
      throw VendorApiException('The server did not return a registration id.');
    }

    return vendorId;
  }

  /// Uploads one local image and returns its R2 object key.
  ///
  /// The key is chosen by the server from the verified token's uid — this
  /// client cannot influence where the object lands.
  Future<String> uploadImage({
    required String vendorId,
    required File file,
  }) async {
    final contentType = _contentTypeFor(file.path);

    if (contentType == null) {
      throw VendorApiException(
        'Unsupported image type. Please use a JPG, PNG or WebP file.',
      );
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw VendorApiException('That image file appears to be empty.');
    }

    if (bytes.length > maxUploadBytes) {
      throw VendorApiException(
        'That image is too large. Please choose one under 10 MB.',
      );
    }

    final signed = await _json(
      'POST',
      '/api/vendors/upload-url',
      body: {
        'vendorId': vendorId,
        'fileName': _basename(file.path),
        'contentType': contentType,
        'contentLength': bytes.length,
      },
      failureMessage: 'Could not prepare the image upload.',
    );

    final uploadUrl = signed['uploadUrl'] as String?;
    final objectKey = signed['objectKey'] as String?;

    if (uploadUrl == null || objectKey == null) {
      throw VendorApiException('The server returned an incomplete upload URL.');
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
      throw VendorApiException(
        'Could not upload the image. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw VendorApiException(
        'The image could not be stored. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return objectKey;
  }

  /// Registers the listing.
  ///
  /// [categoryId] and [subCategoryId] are supplied together or not at all: a
  /// listing either comes from a catalogue template or stands alone, and the
  /// server rejects one without the other.
  Future<VendorCreation> createVendor({
    required String vendorId,
    required String categoryName,
    required String description,
    required String location,
    required String imagePathUrl,
    required List<Map<String, dynamic>> images,
    required Map<String, double> budget,
    String? categoryId,
    String? subCategoryId,
  }) async {
    final payload = <String, dynamic>{
      'vendorId': vendorId,
      'categoryName': categoryName,
      'description': description,
      'location': location,
      'imagePathUrl': imagePathUrl,
      'images': images,
      'budget': budget,
    };

    // Omitted entirely rather than sent as null — the server's key allow-list
    // treats a present key as a template registration.
    if (categoryId != null && subCategoryId != null) {
      payload['categoryId'] = categoryId;
      payload['subCategoryId'] = subCategoryId;
    }

    final body = await _json(
      'POST',
      '/api/vendors',
      body: payload,
      expectedStatus: 201,
      failureMessage: 'The registration could not be completed.',
    );

    final id = body['vendorId'] as String?;
    final createdAt = body['createdAt'] as String?;

    if (id == null || createdAt == null) {
      throw VendorApiException(
        'The server accepted the listing but returned an incomplete response.',
      );
    }

    return VendorCreation(vendorId: id, createdAt: createdAt);
  }

  /// Deletes every image uploaded for a registration that was abandoned.
  ///
  /// Best-effort by design: it runs on a path where something has already
  /// gone wrong, and a failure here must not replace the original error the
  /// user needs to see. A prefix that survives is still enumerable
  /// server-side, so nothing is silently lost.
  Future<void> discardUploads(String vendorId) async {
    try {
      await _json(
        'DELETE',
        '/api/vendors/uploads/$vendorId',
        failureMessage: 'Could not clean up the uploaded images.',
      );
    } catch (_) {
      // Swallowed deliberately — see above.
    }
  }

  // ---------------------------------------------------------------- helpers

  /// The part of [path] after the last separator.
  ///
  /// Hand-rolled rather than pulling in package:path, which this app only has
  /// transitively. The server sanitizes and re-derives the stored name
  /// anyway, so this needs to be correct, not clever.
  static String _basename(String path) {
    final separator = path.lastIndexOf(RegExp(r'[/\\]'));
    return separator == -1 ? path : path.substring(separator + 1);
  }

  /// The lower-cased extension of [path], including the dot, or '' if none.
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
    _debug('--- $method $path ---');
    _debug('resolved API_BASE_URL: ${_configuredBaseUrl.isEmpty
        ? "(unset in .env — using fallback)"
        : _configuredBaseUrl}');
    _debug('effective baseUrl: $baseUrl');

    final token = await _currentIdToken();
    final uri = Uri.parse('$baseUrl$path');

    _debug('request URL: $uri');
    _debug('expecting HTTP $expectedStatus');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final http.Response response;

    try {
      final encoded = body == null ? null : jsonEncode(body);

      _debug('sending request now…');

      switch (method) {
        case 'POST':
          response =
              await _client.post(uri, headers: headers, body: encoded).timeout(_timeout);
          break;
        case 'DELETE':
          response =
              await _client.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw VendorApiException('Unsupported request.');
      }
    } catch (error, stackTrace) {
      if (error is VendorApiException) rethrow;

      // Logged in full here so a transport failure is diagnosable; the
      // message shown to the user still says nothing about the request,
      // because the error text can quote it, Authorization header included.
      _debug('TRANSPORT FAILURE before any response: ${error.runtimeType}');
      _debug('$error');
      _debug('$stackTrace');

      throw VendorApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    _debug('HTTP ${response.statusCode}');
    _debug('response body: ${_safeBody(response.body)}');

    if (response.statusCode != expectedStatus) {
      _debug('REJECTED: got ${response.statusCode}, expected $expectedStatus');

      throw VendorApiException(
        _messageForStatus(response.statusCode, failureMessage),
        statusCode: response.statusCode,
        responseBody: _safeBody(response.body),
      );
    }

    if (response.body.isEmpty) return const {};

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Turns a status code into something worth showing a user.
  ///
  /// The server answers every validation failure with one generic message so
  /// the response cannot be used to probe which rule tripped; that is right
  /// for the API and wrong to show here, so the mapping happens on this side
  /// where the context is known.
  String _messageForStatus(int statusCode, String fallback) {
    switch (statusCode) {
      case 400:
        return 'Some of the vendor details are invalid. Please review the form and try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'This account is not set up to register vendors yet.';
      case 409:
        return 'This listing has already been registered.';
      case 413:
        return 'The vendor details are too large. Try shortening the description.';
      case 429:
        return "You've registered too many listings recently. Please try again later.";
      default:
        return statusCode >= 500
            ? 'The server could not process the registration. Please try again later.'
            : fallback;
    }
  }

  /// TEMPORARY — see [kVendorApiDebug].
  void _debug(String message) {
    if (!kVendorApiDebug) return;
    developer.log(message, name: 'VendorApi');
  }

  Future<String> _currentIdToken() async {
    final user = FirebaseAuth.instance.currentUser;

    _debug('currentUser present: ${user != null}');

    if (user == null) {
      throw VendorApiException('Please sign in again to register a vendor.');
    }

    final String? token;

    try {
      token = await user.getIdToken();
    } catch (error, stackTrace) {
      // The error is logged, never the token.
      _debug('getIdToken THREW: $error');
      _debug('$stackTrace');
      rethrow;
    }

    // Never log the token itself — only that one was obtained.
    _debug('ID token obtained: ${token != null}');

    if (token == null) {
      throw VendorApiException('Please sign in again to register a vendor.');
    }

    return token;
  }

  /// Truncates a response body before it goes into an exception message.
  String _safeBody(String body) {
    const maxLength = 500;
    return body.length > maxLength ? '${body.substring(0, maxLength)}…' : body;
  }
}
