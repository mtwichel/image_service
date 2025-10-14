import 'package:hive_ce/hive.dart';

part 'metadata.g.dart';

/// Image metadata entry stored in Hive
@HiveType(typeId: 1)
class ImageMetadata {
  /// Creates an [ImageMetadata] entry
  ImageMetadata({
    required this.originalName,
    required this.secureFileName,
    required this.uploadedAt,
    required this.fileSize,
    this.bucket,
  });

  /// The original filename provided by the user
  @HiveField(0)
  final String originalName;

  /// The generated secure filename on disk
  @HiveField(1)
  final String secureFileName;

  /// When the file was uploaded
  @HiveField(2)
  final DateTime uploadedAt;

  /// Size of the file in bytes
  @HiveField(3)
  final int fileSize;

  /// Optional bucket name for organization
  @HiveField(4)
  final String? bucket;
}

/// Hive-backed store for image metadata
///
/// Provides deduplication by tracking original filenames.
/// If an image with the same original filename already exists,
/// it updates the existing entry and returns the existing secure filename.
///
/// Uses a single box with O(1) lookups keyed by originalName.
class ImageMetadataStore {
  /// Creates an [ImageMetadataStore]
  ///
  /// [boxName] - Name of the Hive box (default: 'image_metadata')
  ImageMetadataStore({String boxName = 'image_metadata'}) : _boxName = boxName;

  /// Name of the Hive box
  final String _boxName;

  /// Box for metadata storage (keyed by originalName)
  Box<ImageMetadata>? _box;

  /// Initializes the store by opening the Hive box
  ///
  /// Must be called before using any other methods.
  /// Should be called after [Hive.init()] has been called.
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ImageMetadataAdapter());
    }
    _box = await Hive.openBox<ImageMetadata>(_boxName);
  }

  /// Ensures the box is initialized
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError(
        'ImageMetadataStore not initialized. '
        'Call initialize() before using.',
      );
    }
  }

  /// Finds metadata by original filename
  ///
  /// Returns null if no metadata exists for this filename.
  /// O(1) lookup.
  ImageMetadata? findByOriginalName(String originalName) {
    _ensureInitialized();
    return _box!.get(originalName);
  }

  /// Saves or updates metadata for an image
  ///
  /// Uses originalName as the key. If metadata with the same originalName
  /// already exists, it will be replaced.
  Future<void> saveOrUpdateMetadata(ImageMetadata metadata) async {
    _ensureInitialized();
    await _box!.put(metadata.originalName, metadata);
  }

  /// Finds metadata by original filename and optional bucket
  ///
  /// Returns null if no metadata exists for this filename in the
  /// specified bucket.
  /// O(n) lookup when bucket is specified (needs to scan all entries).
  ImageMetadata? findByOriginalNameAndBucket(
    String originalName, {
    String? bucket,
  }) {
    _ensureInitialized();

    // If no bucket specified, use the original key-based lookup
    if (bucket == null) {
      final metadata = _box!.get(originalName);
      // Only return if it also has no bucket
      if (metadata?.bucket == null) {
        return metadata;
      }
      return null;
    }

    // Search for matching originalName + bucket combination
    for (final metadata in _box!.values) {
      if (metadata.originalName == originalName && metadata.bucket == bucket) {
        return metadata;
      }
    }

    return null;
  }

  /// Lists all images in a specific bucket
  ///
  /// Returns empty list if no images exist in the bucket.
  /// O(n) operation.
  List<ImageMetadata> listByBucket(String? bucket) {
    _ensureInitialized();

    return _box!.values.where((metadata) => metadata.bucket == bucket).toList();
  }

  /// Lists all unique bucket names
  ///
  /// Returns a set of all bucket names currently in use.
  /// O(n) operation.
  Set<String?> listBuckets() {
    _ensureInitialized();

    return _box!.values.map((metadata) => metadata.bucket).toSet();
  }

  /// Closes the Hive box
  ///
  /// Should be called when the store is no longer needed.
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
