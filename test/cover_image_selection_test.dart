import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/services/cover_images.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a cover selection persists, and that every bundled cover is real.
///
/// The Firestore write itself needs a Firebase app, so it is not exercised
/// here; what is covered is the decision the write depends on — which paths
/// count as a bundled asset, where the document lives, and whether the six
/// assets the grid offers actually exist and decode.
void main() {
  final covers = <String>[
    Assigns.image1,
    Assigns.image2,
    Assigns.image3,
    Assigns.image4,
    Assigns.image5,
    Assigns.image6,
  ];

  group('a selection is stored as a bundled asset path', () {
    test('every cover the grid offers is recognised as an asset', () {
      for (final path in covers) {
        expect(CoverImageMethods.isBundledAssetPath(path), isTrue,
            reason: '$path must persist as an asset, not a URL');
      }
    });

    test('a remote URL or an R2 key is not a bundled asset', () {
      expect(
          CoverImageMethods.isBundledAssetPath(
              'https://firebasestorage.googleapis.com/x.jpg'),
          isFalse);
      expect(
          CoverImageMethods.isBundledAssetPath('cover_images/x.jpg'), isFalse);
      expect(CoverImageMethods.isBundledAssetPath(''), isFalse);
      expect(CoverImageMethods.isBundledAssetPath('  '), isFalse);
    });

    test('the document path is per entrepreneur and unchanged', () {
      expect(CoverImageMethods.selectionPath('ent-1'),
          'entrepreneurs/ent-1/coverImages/selectedImage');
      expect(CoverImageMethods.selectionPath('ent-2'),
          isNot(CoverImageMethods.selectionPath('ent-1')),
          reason: 'one entrepreneur must never read another selection');
    });

    test('saving anything that is not a bundled asset is refused', () async {
      await expectLater(
        CoverImageMethods().saveSelection('https://example.com/a.jpg', 'ent-1'),
        throwsA(isA<CoverImageUploadException>()
            .having((e) => e.reason, 'reason', 'not-a-bundled-asset')),
      );
    });
  });

  group('the bundled covers are real, decodable images', () {
    setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

    test('all six load from the asset bundle', () async {
      for (final path in covers) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: '$path is empty');
      }
    });

    test('none is an AVIF, which Flutter cannot decode', () async {
      for (final path in covers) {
        expect(path.toLowerCase().endsWith('.avif'), isFalse,
            reason: '$path cannot be rendered by AssetImage');

        // 'ftyp' at offset 4 marks an ISO-BMFF container such as AVIF.
        final header = (await rootBundle.load(path)).buffer.asUint8List(0, 12);
        final brand = String.fromCharCodes(header.sublist(4, 8));
        expect(brand, isNot('ftyp'), reason: '$path is an ISO/AVIF container');
      }
    });
  });
}
