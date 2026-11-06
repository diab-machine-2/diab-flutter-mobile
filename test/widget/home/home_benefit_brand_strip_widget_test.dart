@Tags(['ui'])
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/widget/home_benefit.dart';

import '../../helpers/localized_app.dart';

// BE-1: the "Quyền lợi" brand strip shows bundlePartnerLogoUrl /
// bundleDescription from /App/Home, falling back to the AXON logo +
// "Chăm sóc sức khỏe nhân viên" when they're null/blank
// (lib/src/widget/home/widget/home_benefit.dart, _buildBrandStrip).

Future<void> _pump(WidgetTester tester,
    {String? partnerLogoUrl, String? description}) async {
  await tester.binding.setSurfaceSize(const Size(360, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await pumpLocalized(
    tester,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: HomeBenefitSection(
            hasRecord: false,
            shortcutsConfig: '',
            partnerLogoUrl: partnerLogoUrl,
            description: description,
          ),
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
}

Finder _axonLogo() => find.byWidgetPredicate((w) =>
    w is Image &&
    w.image is AssetImage &&
    (w.image as AssetImage).assetName == R.drawable.logo_axon);

void main() {
  setUpAll(initTestLocalization);

  group('HomeBenefitSection brand strip (BE-1)', () {
    testWidgets('null logo + description (current staging) => AXON fallback',
        (tester) async {
      await _pump(tester);
      expect(_axonLogo(), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.text('Chăm sóc sức khỏe nhân viên'), findsOneWidget);
    });

    testWidgets('blank strings are treated as absent', (tester) async {
      await _pump(tester, partnerLogoUrl: '   ', description: '  ');
      expect(_axonLogo(), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.text('Chăm sóc sức khỏe nhân viên'), findsOneWidget);
    });

    testWidgets('custom description replaces the default tagline (trimmed)',
        (tester) async {
      await _pump(tester, description: '  Chương trình sức khỏe ACME ');
      expect(find.text('Chương trình sức khỏe ACME'), findsOneWidget);
      expect(find.text('Chăm sóc sức khỏe nhân viên'), findsNothing);
      // No logo URL → still the AXON asset.
      expect(_axonLogo(), findsOneWidget);
    });

    testWidgets('logo URL => network image instead of the AXON asset',
        (tester) async {
      await _pump(tester, partnerLogoUrl: 'https://cdn.example.com/logo.png');
      final image =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(image.imageUrl, 'https://cdn.example.com/logo.png');
      // The AXON asset is only the errorWidget now, not in the tree.
      expect(_axonLogo(), findsNothing);
    });
  });
}
