import 'package:hive_ce/hive.dart';

part 'metadata.g.dart';

/// Image metadata entry stored in Hive
@HiveType(typeId: 1)
class ImageMetadata {
  /// Creates an [ImageMetadata] entry
  ImageMetadata({
    required this.fileName,
    required this.uploadedAt,
    required this.fileSize,
  });

  /// The generated filename on disk
  @HiveField(0)
  final String fileName;

  /// When the file was uploaded
  @HiveField(1)
  final DateTime uploadedAt;

  /// Size of the file in bytes
  @HiveField(2)
  final int fileSize;
}

/// Hive-backed store for image metadata
///
/// Provides deduplication by tracking filenames.
/// If an image with the same filename already exists,
/// it updates the existing entry and returns the existing filename.
///
/// Uses a single box with O(1) lookups keyed by filename.
class ImageMetadataStore {
  /// Creates an [ImageMetadataStore]
  ///
  /// [boxName] - Name of the Hive box (default: 'image_metadata')
  ImageMetadataStore({String boxName = 'image_metadata'}) : _boxName = boxName;

  /// Name of the Hive box
  final String _boxName;

  /// Box for metadata storage (keyed by filename)
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

  /// Finds metadata by filename
  ///
  /// Returns null if no metadata exists for this filename.
  /// O(1) lookup.
  ImageMetadata? findByName(String fileName) {
    _ensureInitialized();
    return _box!.get(fileName);
  }

  /// Saves or updates metadata for an image
  ///
  /// Uses fileName as the key. If metadata with the same fileName
  /// already exists, it will be replaced.
  Future<void> saveOrUpdateMetadata(ImageMetadata metadata) async {
    _ensureInitialized();
    await _box!.put(metadata.fileName, metadata);
  }

  /// Closes the Hive box
  ///
  /// Should be called when the store is no longer needed.
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
