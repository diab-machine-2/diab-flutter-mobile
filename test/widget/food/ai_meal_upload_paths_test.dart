import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/confirm_gen_food.dart';

void main() {
  group('aiMealUploadPaths', () {
    const analysed = '/cache/bun_rieu.jpg';
    const attached = '/cache/banh.jpg';

    test('server keeps the analysed photo => upload only the attachments', () {
      expect(
        aiMealUploadPaths([analysed, attached],
            analysedPath: analysed,
            primaryPath: analysed,
            serverHasAnalysedImage: true),
        [attached],
      );
    });

    test('no imageUrl from the analysis => upload the analysed photo too', () {
      expect(
        aiMealUploadPaths([analysed, attached],
            analysedPath: analysed,
            primaryPath: analysed,
            serverHasAnalysedImage: false),
        [analysed, attached],
      );
    });

    test('user swapped the main photo => keep every path', () {
      const swapped = '/cache/new.jpg';
      expect(
        aiMealUploadPaths([swapped, attached],
            analysedPath: analysed,
            primaryPath: swapped,
            serverHasAnalysedImage: true),
        [swapped, attached],
      );
    });

    test('analysed photo only => nothing to upload', () {
      expect(
        aiMealUploadPaths([analysed],
            analysedPath: analysed,
            primaryPath: analysed,
            serverHasAnalysedImage: true),
        isEmpty,
      );
    });
  });

  group('FoodClient.aiImageUrlOf', () {
    test('top-level imageUrl wins', () {
      expect(
          FoodClient.aiImageUrlOf({
            'imageUrl': 'https://x/top.jpg',
            'items': [
              {'imageUrl': 'https://x/item.jpg'}
            ],
          }),
          'https://x/top.jpg');
    });

    test('falls back to the first item imageUrl', () {
      expect(
          FoodClient.aiImageUrlOf({
            'imageUrl': '',
            'items': [
              {'imageUrl': null},
              {'imageUrl': 'https://x/item.jpg'}
            ],
          }),
          'https://x/item.jpg');
    });

    test('none => null', () {
      expect(FoodClient.aiImageUrlOf(null), isNull);
      expect(FoodClient.aiImageUrlOf({'items': []}), isNull);
    });
  });
}
