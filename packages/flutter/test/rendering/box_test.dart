// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rendering_tester.dart';

void main() {
  test('should size to render view', () {
    final RenderBox root = new RenderDecoratedBox(
      decoration: new BoxDecoration(
        color: const Color(0xFF00FF00),
        gradient: new RadialGradient(
          center: Alignment.topLeft, radius: 1.8,
          colors: <Color>[Colors.yellow[500], Colors.blue[500]],
        ),
        boxShadow: kElevationToShadow[3],
      ),
    );
    layout(root);
    expect(root.size.width, equals(800.0));
    expect(root.size.height, equals(600.0));
  });

  test('Flex and padding', () {
    final RenderBox size = new RenderConstrainedBox(
      additionalConstraints: const BoxConstraints().tighten(height: 100.0),
    );
    final RenderBox inner = new RenderDecoratedBox(
      decoration: const BoxDecoration(
        color: const Color(0xFF00FF00),
      ),
      child: size,
    );
    final RenderBox padding = new RenderPadding(
      padding: const EdgeInsets.all(50.0),
      child: inner,
    );
    final RenderBox flex = new RenderFlex(
      children: <RenderBox>[padding],
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
    final RenderBox outer = new RenderDecoratedBox(
      decoration: const BoxDecoration(
        color: const Color(0xFF0000FF),
      ),
      child: flex,
    );

    layout(outer);

    expect(size.size.width, equals(700.0));
    expect(size.size.height, equals(100.0));
    expect(inner.size.width, equals(700.0));
    expect(inner.size.height, equals(100.0));
    expect(padding.size.width, equals(800.0));
    expect(padding.size.height, equals(200.0));
    expect(flex.size.width, equals(800.0));
    expect(flex.size.height, equals(600.0));
    expect(outer.size.width, equals(800.0));
    expect(outer.size.height, equals(600.0));
  });

  test('should not have a 0 sized colored Box', () {
    final RenderBox coloredBox = new RenderDecoratedBox(
      decoration: const BoxDecoration(),
    );

    expect(coloredBox, hasAGoodToStringDeep);
    expect(coloredBox.toStringDeep(minLevel: DiagnosticLevel.info), equalsIgnoringHashCodes(
        'RenderDecoratedBox#00000 NEEDS-LAYOUT NEEDS-PAINT DETACHED\n'
        '   parentData: MISSING\n'
        '   constraints: MISSING\n'
        '   size: MISSING\n'
        '   decoration: BoxDecoration:\n'
        '     <no decorations specified>\n'
        '   configuration: ImageConfiguration()\n'));

    final RenderBox paddingBox = new RenderPadding(
      padding: const EdgeInsets.all(10.0),
      child: coloredBox,
    );
    final RenderBox root = new RenderDecoratedBox(
      decoration: const BoxDecoration(),
      child: paddingBox,
    );
    layout(root);
    expect(coloredBox.size.width, equals(780.0));
    expect(coloredBox.size.height, equals(580.0));

    expect(coloredBox, hasAGoodToStringDeep);
    expect(
      coloredBox.toStringDeep(minLevel: DiagnosticLevel.info),
      equalsIgnoringHashCodes(
        'RenderDecoratedBox#00000 NEEDS-PAINT\n'
        '   parentData: offset=Offset(10.0, 10.0) (can use size)\n'
        '   constraints: BoxConstraints(w=780.0, h=580.0)\n'
        '   size: Size(780.0, 580.0)\n'
        '   decoration: BoxDecoration:\n'
        '     <no decorations specified>\n'
        '   configuration: ImageConfiguration()\n',
      ),
    );
  });

  test('reparenting should clear position', () {
    final RenderDecoratedBox coloredBox = new RenderDecoratedBox(
      decoration: const BoxDecoration(),
    );

    final RenderPadding paddedBox = new RenderPadding(
      child: coloredBox,
      padding: const EdgeInsets.all(10.0),
    );
    layout(paddedBox);
    final BoxParentData parentData = coloredBox.parentData;
    expect(parentData.offset.dx, isNot(equals(0.0)));
    paddedBox.child = null;

    final RenderConstrainedBox constraintedBox = new RenderConstrainedBox(
      child: coloredBox,
      additionalConstraints: const BoxConstraints(),
    );
    layout(constraintedBox);
    expect(coloredBox.parentData?.runtimeType, ParentData);
  });

  test('UnconstrainedBox expands to fit children', () {
    final RenderUnconstrainedBox unconstrained = new RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      child: new RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 200.0, height: 200.0),
      ),
      alignment: Alignment.center,
    );
    layout(
      unconstrained,
      constraints: const BoxConstraints(
        minWidth: 200.0,
        maxWidth: 200.0,
        minHeight: 200.0,
        maxHeight: 200.0,
      ),
    );

    expect(unconstrained.size.width, equals(200.0), reason: 'unconstrained width');
    expect(unconstrained.size.height, equals(200.0), reason: 'unconstrained height');
  });

  test('UnconstrainedBox handles vertical overflow', () {
    final RenderUnconstrainedBox unconstrained = new RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      child: new RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(height: 200.0),
      ),
      alignment: Alignment.center,
    );
    final BoxConstraints viewport = const BoxConstraints(maxHeight: 100.0, maxWidth: 100.0);
    layout(unconstrained, constraints: viewport);
    expect(unconstrained.getMinIntrinsicHeight(100.0), equals(200.0));
    expect(unconstrained.getMaxIntrinsicHeight(100.0), equals(200.0));
    expect(unconstrained.getMinIntrinsicWidth(100.0), equals(0.0));
    expect(unconstrained.getMaxIntrinsicWidth(100.0), equals(0.0));
  });

  test('UnconstrainedBox handles horizontal overflow', () {
    final RenderUnconstrainedBox unconstrained = new RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      child: new RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 200.0),
      ),
      alignment: Alignment.center,
    );
    final BoxConstraints viewport = const BoxConstraints(maxHeight: 100.0, maxWidth: 100.0);
    layout(unconstrained, constraints: viewport);
    expect(unconstrained.getMinIntrinsicHeight(100.0), equals(0.0));
    expect(unconstrained.getMaxIntrinsicHeight(100.0), equals(0.0));
    expect(unconstrained.getMinIntrinsicWidth(100.0), equals(200.0));
    expect(unconstrained.getMaxIntrinsicWidth(100.0), equals(200.0));
  });

  test('UnconstrainedBox.toStringDeep returns useful information', () {
    final RenderUnconstrainedBox unconstrained = new RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      alignment: Alignment.center,
    );
    expect(unconstrained.alignment, Alignment.center);
    expect(unconstrained.textDirection, TextDirection.ltr);
    expect(unconstrained, hasAGoodToStringDeep);
    expect(
      unconstrained.toStringDeep(minLevel: DiagnosticLevel.info),
      equalsIgnoringHashCodes(
        'RenderUnconstrainedBox#00000 NEEDS-LAYOUT NEEDS-PAINT DETACHED\n'
          '   parentData: MISSING\n'
          '   constraints: MISSING\n'
          '   size: MISSING\n'
          '   alignment: Alignment.center\n'
          '   textDirection: ltr\n'),
    );
  });
}
