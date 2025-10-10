import 'package:image_service_client/image_service_client.dart';
import 'package:test/test.dart';

void main() {
  group('ImageTransformOptions', () {
    test('toPropertiesString with all options', () {
      const options = ImageTransformOptions(
        width: 500,
        height: 300,
        quality: 85,
      );

      expect(options.toPropertiesString(), 'width=500,height=300,quality=85');
    });

    test('toPropertiesString with partial options', () {
      const options = ImageTransformOptions(width: 500);

      expect(options.toPropertiesString(), 'width=500');
    });

    test('hasTransformations returns correct value', () {
      const withTransform = ImageTransformOptions(width: 500);
      const withoutTransform = ImageTransformOptions();

      expect(withTransform.hasTransformations, isTrue);
      expect(withoutTransform.hasTransformations, isFalse);
    });
  });
}
