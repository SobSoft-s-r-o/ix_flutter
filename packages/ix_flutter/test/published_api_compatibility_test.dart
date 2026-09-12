// These deprecated APIs intentionally compile as a published 1.0.2 consumer.
// ignore_for_file: deprecated_member_use

import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

int _publishedIxSpinnerVariantIndex(IxSpinnerVariant value) => switch (value) {
  IxSpinnerVariant.standard => 0,
  IxSpinnerVariant.primary => 1,
};

int _publishedIxToastTypeIndex(IxToastType value) => switch (value) {
  IxToastType.info => 0,
  IxToastType.success => 1,
  IxToastType.warning => 2,
  IxToastType.critical => 3,
  IxToastType.alarm => 4,
  IxToastType.neutral => 5,
};

int _publishedIxTypographyVariantIndex(IxTypographyVariant value) =>
    switch (value) {
      IxTypographyVariant.label => 0,
      IxTypographyVariant.labelXs => 1,
      IxTypographyVariant.labelSm => 2,
      IxTypographyVariant.labelLg => 3,
      IxTypographyVariant.body => 4,
      IxTypographyVariant.bodyXs => 5,
      IxTypographyVariant.bodySm => 6,
      IxTypographyVariant.bodyLg => 7,
      IxTypographyVariant.display => 8,
      IxTypographyVariant.displayXs => 9,
      IxTypographyVariant.displaySm => 10,
      IxTypographyVariant.displayLg => 11,
      IxTypographyVariant.displayXl => 12,
      IxTypographyVariant.displayXxl => 13,
      IxTypographyVariant.h1 => 14,
      IxTypographyVariant.h2 => 15,
      IxTypographyVariant.h3 => 16,
      IxTypographyVariant.h4 => 17,
      IxTypographyVariant.h5 => 18,
      IxTypographyVariant.h6 => 19,
      IxTypographyVariant.code => 20,
      IxTypographyVariant.codeSm => 21,
      IxTypographyVariant.codeLg => 22,
    };

class _PublishedBlindSubclass extends IxBlind {
  const _PublishedBlindSubclass()
    : super(
        title: 'Published subclass',
        expanded: true,
        child: const Text('Content'),
      );

  // Delegation itself is the published subclass contract under test.
  @override
  // ignore: unnecessary_overrides
  Widget build(BuildContext context) => super.build(context);
}

class _GetterControlledBlind extends IxBlind {
  const _GetterControlledBlind({
    required this.isOpen,
    bool? constructorExpanded,
    super.onExpandedChanged,
  }) : super(
         title: 'Getter-controlled subclass',
         expanded: constructorExpanded,
         child: const Text('Getter-controlled content'),
       );

  final bool isOpen;

  @override
  bool get expanded => isOpen;

  @override
  // ignore: unnecessary_overrides -- Exercise published subclass delegation.
  Widget build(BuildContext context) => super.build(context);
}

void main() {
  test(
    'IxSpinnerVariant preserves published values and serialized indices',
    () {
      expect(IxSpinnerVariant.values.map((value) => value.name), [
        'standard',
        'primary',
      ]);
      for (final value in IxSpinnerVariant.values) {
        expect(value.index, _publishedIxSpinnerVariantIndex(value));
      }
    },
  );
  test('IxToastType preserves published values and serialized indices', () {
    expect(IxToastType.values.map((value) => value.name), [
      'info',
      'success',
      'warning',
      'critical',
      'alarm',
      'neutral',
    ]);
    for (final value in IxToastType.values) {
      expect(value.index, _publishedIxToastTypeIndex(value));
    }
  });
  test(
    'IxTypographyVariant preserves published values and serialized indices',
    () {
      expect(IxTypographyVariant.values.map((value) => value.name), [
        'label',
        'labelXs',
        'labelSm',
        'labelLg',
        'body',
        'bodyXs',
        'bodySm',
        'bodyLg',
        'display',
        'displayXs',
        'displaySm',
        'displayLg',
        'displayXl',
        'displayXxl',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'code',
        'codeSm',
        'codeLg',
      ]);
      for (final value in IxTypographyVariant.values) {
        expect(value.index, _publishedIxTypographyVariantIndex(value));
      }
    },
  );
  test('new enum spellings retain published identity', () {
    expect(IxSpinnerVariant.secondary, same(IxSpinnerVariant.standard));
    expect(IxSpinnerVariant.secondary.name, 'standard');
    expect(IxToastType.error, same(IxToastType.critical));
    expect(IxToastType.error.name, 'critical');
  });

  testWidgets('published Blind types and subclass build remain usable', (
    tester,
  ) async {
    const blind = _PublishedBlindSubclass();
    final bool expanded = blind.expanded;
    final StatelessWidget stateless = blind;
    expect(expanded, isTrue);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: stateless)));
    expect(find.text('Content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final constructorExpanded in <bool?>[null, false, true]) {
    testWidgets(
      'subclass expanded getter controls visibility and requests with '
      'constructor expanded=$constructorExpanded',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final requests = <bool>[];
        Future<void> pumpWith(bool isOpen) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: _GetterControlledBlind(
                  isOpen: isOpen,
                  constructorExpanded: constructorExpanded,
                  onExpandedChanged: requests.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        await pumpWith(true);
        expect(
          tester
              .getSemantics(find.text('Getter-controlled subclass'))
              .flagsCollection
              .isExpanded,
          Tristate.isTrue,
        );
        expect(find.text('Getter-controlled content'), findsOneWidget);
        await tester.tap(find.text('Getter-controlled subclass'));
        await tester.pumpAndSettle();
        expect(requests, [false]);
        expect(find.text('Getter-controlled content'), findsOneWidget);

        await pumpWith(false);
        expect(
          tester
              .getSemantics(find.text('Getter-controlled subclass'))
              .flagsCollection
              .isExpanded,
          Tristate.isFalse,
        );
        expect(find.text('Getter-controlled content'), findsNothing);
        await tester.tap(find.text('Getter-controlled subclass'));
        await tester.pumpAndSettle();
        expect(requests, [false, true]);
        expect(find.text('Getter-controlled content'), findsNothing);
        semantics.dispose();
      },
    );
  }

  testWidgets('delegated build preserves the getter on uncontrolled handover', (
    tester,
  ) async {
    Future<void> pumpDelegated(IxBlind blind) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Builder(builder: blind.build)),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpDelegated(
      const _GetterControlledBlind(isOpen: true, constructorExpanded: false),
    );
    expect(find.text('Getter-controlled content'), findsOneWidget);
    await pumpDelegated(
      const IxBlind(
        title: 'Uncontrolled successor',
        child: Text('Successor content'),
      ),
    );
    expect(find.text('Successor content'), findsOneWidget);
    await tester.tap(find.text('Uncontrolled successor'));
    await tester.pumpAndSettle();
    expect(find.text('Successor content'), findsNothing);
  });

  test('uncontrolled Blind exposes a non-null initial expanded value', () {
    const collapsed = IxBlind(title: 'Details', child: SizedBox());
    const open = IxBlind(
      title: 'Details',
      initiallyExpanded: true,
      child: SizedBox(),
    );
    final bool collapsedValue = collapsed.expanded;
    final bool openValue = open.expanded;
    expect(collapsedValue, isFalse);
    expect(openValue, isTrue);
  });
}
