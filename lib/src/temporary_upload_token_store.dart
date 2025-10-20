import 'dart:convert';
import 'dart:math';

import 'package:hive_ce/hive.dart';

part 'temporary_upload_token_store.g.dart';

/// A token entry with expiration information
@HiveType(typeId: 0)
class _TokenEntry {
  _TokenEntry({
    required this.createdAt,
    required this.expiresAt,
    required this.fileName,
  });

  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final DateTime expiresAt;

  @HiveField(2)
  final String fileName;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Hive-backed store for temporary upload tokens
///
/// Tokens are:
/// - Cryptographically secure (32 random bytes, base64url encoded)
/// - Single-use (deleted after first successful validation)
/// - Time-limited (15 minute expiration by default)
/// - Persistent across server restarts
class TemporaryUploadTokenStore {
  /// Creates a [TemporaryUploadTokenStore]
  ///
  /// [tokenDuration] - How long tokens remain valid (default: 15 minutes)
  /// [random] - Random number generator (defaults to Random.secure())
  TemporaryUploadTokenStore({
    this.tokenDuration = const Duration(minutes: 15),
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Duration for which tokens are valid
  final Duration tokenDuration;

  /// Secure random number generator for token creation
  final Random _random;

  /// Hive box for token storage
  Box<_TokenEntry>? _box;

  /// Initializes the store by opening the Hive box
  ///
  /// Must be called before using any other methods.
  /// Should be called after [Hive.init()] has been called.
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TokenEntryAdapter());
    }
    _box = await Hive.openBox<_TokenEntry>('upload_tokens');

    // Clean up expired tokens on initialization
    await _cleanupExpiredTokens();
  }

  /// Ensures the box is initialized
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError(
        'TemporaryUploadTokenStore not initialized. '
        'Call initialize() before using.',
      );
    }
  }

  /// Generates a new cryptographically secure token
  ///
  /// Returns a tuple of (token, expiresAt)
  Future<(String, DateTime)> generateToken({required String fileName}) async {
    _ensureInitialized();

    // Generate 32 random bytes for security
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final token = base64Url.encode(bytes).replaceAll('=', '');

    final now = DateTime.now();
    final expiresAt = now.add(tokenDuration);

    await _box!.put(
      token,
      _TokenEntry(createdAt: now, expiresAt: expiresAt, fileName: fileName),
    );

    return (token, expiresAt);
  }

  /// Validates and consumes a token (single-use)
  ///
  /// Returns a tuple of (isValid, fileName).
  /// The token is removed from the store after this call.
  Future<(bool, String?)> validateAndConsumeToken(String token) async {
    _ensureInitialized();

    final entry = _box!.get(token);

    if (entry == null) {
      return (false, null);
    }

    // Remove the token (single-use)
    await _box!.delete(token);

    // Clean up expired tokens opportunistically
    await _cleanupExpiredTokens();

    return (!entry.isExpired, entry.fileName);
  }

  /// Removes all expired tokens from the store
  Future<void> _cleanupExpiredTokens() async {
    _ensureInitialized();

    final keysToDelete = <String>[];
    for (final key in _box!.keys) {
      final entry = _box!.get(key);
      if (entry != null && entry.isExpired) {
        keysToDelete.add(key as String);
      }
    }

    await _box!.deleteAll(keysToDelete);
  }

  /// Gets the current number of active tokens (for testing/monitoring)
  int get activeTokenCount {
    _ensureInitialized();
    return _box!.length;
  }

  /// Clears all tokens (for testing)
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Closes the Hive box
  ///
  /// Should be called when the store is no longer needed.
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
