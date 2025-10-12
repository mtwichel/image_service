import 'dart:convert';
import 'dart:math';

/// A token entry with expiration information
class _TokenEntry {
  _TokenEntry({required this.createdAt, required this.expiresAt});

  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// In-memory store for temporary upload tokens
///
/// Tokens are:
/// - Cryptographically secure (32 random bytes, base64url encoded)
/// - Single-use (deleted after first successful validation)
/// - Time-limited (15 minute expiration by default)
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

  /// In-memory token storage
  final Map<String, _TokenEntry> _tokens = {};

  /// Generates a new cryptographically secure token
  ///
  /// Returns a tuple of (token, expiresAt)
  (String, DateTime) generateToken() {
    // Generate 32 random bytes for security
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final token = base64Url.encode(bytes).replaceAll('=', '');

    final now = DateTime.now();
    final expiresAt = now.add(tokenDuration);

    _tokens[token] = _TokenEntry(createdAt: now, expiresAt: expiresAt);

    return (token, expiresAt);
  }

  /// Validates and consumes a token (single-use)
  ///
  /// Returns true if the token is valid and not expired.
  /// The token is removed from the store after this call.
  bool validateAndConsumeToken(String token) {
    final entry = _tokens.remove(token);

    if (entry == null) {
      return false;
    }

    // Clean up expired tokens opportunistically
    _cleanupExpiredTokens();

    return !entry.isExpired;
  }

  /// Removes all expired tokens from the store
  void _cleanupExpiredTokens() {
    _tokens.removeWhere((_, entry) => entry.isExpired);
  }

  /// Gets the current number of active tokens (for testing/monitoring)
  int get activeTokenCount => _tokens.length;

  /// Clears all tokens (for testing)
  void clear() {
    _tokens.clear();
  }
}
