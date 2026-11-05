import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays [top] out, then [bottom] climbing [overlap] pixels onto it (cards over a header band).
/// Unlike a translated child, the part of [bottom] lying on [top] still receives the taps.
class SoeOverlap extends MultiChildRenderObjectWidget {
  SoeOverlap({
    super.key,
    required Widget top,
    required Widget bottom,
    required this.overlap,
  }) : super(children: [top, bottom]);

  final double overlap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOverlap(overlap: overlap);

  @override
  void updateRenderObject(BuildContext context, _RenderOverlap renderObject) {
    renderObject.overlap = overlap;
  }
}

class _OverlapParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderOverlap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapParentData> {
  _RenderOverlap({required double overlap}) : _overlap = overlap;

  double _overlap;
  set overlap(double value) {
    if (value == _overlap) return;
    _overlap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapParentData) {
      child.parentData = _OverlapParentData();
    }
  }

  @override
  void performLayout() {
    final top = firstChild!;
    final bottom = childAfter(top)!;
    final width = constraints.maxWidth;
    final childConstraints = BoxConstraints.tightFor(width: width);
    top.layout(childConstraints, parentUsesSize: true);
    bottom.layout(childConstraints, parentUsesSize: true);
    final bottomTop = (top.size.height - _overlap).clamp(0.0, double.infinity);
    (top.parentData! as _OverlapParentData).offset = Offset.zero;
    (bottom.parentData! as _OverlapParentData).offset = Offset(0, bottomTop);
    size = constraints.constrain(Size(
        width,
        (bottomTop + bottom.size.height)
            .clamp(top.size.height, double.infinity)));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
