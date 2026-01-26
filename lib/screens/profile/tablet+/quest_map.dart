// quest_lineage_tree_view.dart
//
// ✅ MAIN quests parfaitement alignées sur une ligne droite
// ✅ Les BRANCH se placent automatiquement au-dessus / en dessous
// ✅ Layout 100% contrôlé (pas GraphView/BuchheimWalker)
// ✅ Pan/Zoom (InteractiveViewer)
// ✅ Connecteurs "roadmap" en courbes épaisses
//
// ⚠️ Modèles supposés:
// QuestLineage { QuestLineageNode? main; }
// QuestLineageNode { definition; instance; bool locked; bool claimable; List<QuestLineageNode> children; }
// definition { String id; String code; dynamic category; int uiOrder; int targetCount; }
// instance { int progressCount; DateTime? claimedAt; }

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:murya/models/quest.dart';

typedef QuestNodeTap = void Function(QuestLineageNode node);

class QuestLineageTreeView extends StatefulWidget {
  final QuestLineage lineage;

  /// Taille des ronds (nœuds)
  final double nodeSize;

  /// Espacement horizontal entre MAIN (distance entre nodes sur la ligne principale)
  final double levelSeparation;

  /// Espacement horizontal entre nodes dans une BRANCH (profondeur)
  final double subtreeSeparation;

  /// Espacement vertical entre branches empilées d’un même MAIN
  final double siblingSeparation;

  /// Distance verticale MAIN ↔ rows TOP/BOTTOM (en multiple de nodeSize)
  /// Ex: 1.5 => gapFromMain = nodeSize * 1.5
  final double rowGapFactor;

  /// Décalage X du point d’attache des branches depuis un MAIN
  /// attachX = mainPos.x + levelSeparation * branchAttachFactor
  final double branchAttachFactor;

  /// Arrondi des coudes
  /// 0.10 = angles secs / 0.60 = très rond
  final double cornerRadiusFactor;

  /// Épaisseur du tuyau = max(minStrokeWidth, nodeSize * connectorStrokeFactor)
  final double connectorStrokeFactor;
  final double minStrokeWidth;

  /// Callback au tap sur un nœud
  final QuestNodeTap? onNodeTap;

  /// Surligner un node sélectionné (id stable = definition.id ou code)
  final String? selectedNodeId;

  const QuestLineageTreeView({
    super.key,
    required this.lineage,
    this.nodeSize = 64,
    this.levelSeparation = 110,
    this.subtreeSeparation = 160,
    this.siblingSeparation = 34,
    this.rowGapFactor = 1.5,
    this.branchAttachFactor = 0.85,
    this.cornerRadiusFactor = 0.12,
    this.connectorStrokeFactor = 0.22,
    this.minStrokeWidth = 10,
    this.onNodeTap,
    this.selectedNodeId,
  });

  @override
  State<QuestLineageTreeView> createState() => _QuestLineageTreeViewState();
}

class _QuestLineageTreeViewState extends State<QuestLineageTreeView> {
  @override
  Widget build(BuildContext context) {
    final root = widget.lineage.main;
    if (root == null) {
      return const Center(child: Text("Aucune quête"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        final viewportH = constraints.maxHeight;

        final layout = _QuestRoadmapLayoutEngine(
          root: root,
          nodeSize: widget.nodeSize,
          mainSeparation: widget.levelSeparation,
          branchSeparation: widget.subtreeSeparation,
          siblingSeparation: widget.siblingSeparation,
          rowGapFactor: widget.rowGapFactor,
          branchAttachFactor: widget.branchAttachFactor,
          viewportW: viewportW,
          viewportH: viewportH,
        ).compute();

        // Canvas assez grand pour pouvoir panner/zoom
        final canvasW = math.max(viewportW, layout.canvasSize.width);
        final canvasH = math.max(viewportH, layout.canvasSize.height);

        // ✅ Paint recalculé à chaque build (évite les bugs de repaint avec la même instance Paint)
        final connectorPaint = Paint()
          ..color = const Color(0xFFD9D3CA)
          ..strokeWidth = math.max(widget.minStrokeWidth, widget.nodeSize * widget.connectorStrokeFactor)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(400),
          minScale: 0.35,
          maxScale: 2.8,
          child: SizedBox(
            width: canvasW,
            height: canvasH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Connecteurs
                CustomPaint(
                  size: Size(canvasW, canvasH),
                  painter: _QuestEdgesPainter(
                    edges: layout.edges,
                    positions: layout.positions,
                    nodeSize: widget.nodeSize,
                    connectorPaint: connectorPaint,
                    cornerRadiusFactor: widget.cornerRadiusFactor,
                    mainIds: layout.mainIds,
                  ),
                ),

                // Nodes
                ...layout.positions.entries.map((entry) {
                  final id = entry.key;
                  final pos = entry.value;
                  final data = layout.nodeById[id];
                  if (data == null) return const SizedBox.shrink();

                  final selected = widget.selectedNodeId != null && widget.selectedNodeId == id;

                  return Positioned(
                    left: pos.dx - widget.nodeSize / 2,
                    top: pos.dy - widget.nodeSize / 2,
                    child: _QuestNodeView(
                      node: data,
                      size: widget.nodeSize,
                      selected: selected,
                      onTap: widget.onNodeTap,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// LAYOUT ENGINE
/// ============================================================================

class _QuestRoadmapLayoutResult {
  final Map<String, QuestLineageNode> nodeById;
  final Map<String, Offset> positions;
  final List<_Edge> edges;
  final Size canvasSize;
  final Set<String> mainIds;

  const _QuestRoadmapLayoutResult({
    required this.nodeById,
    required this.positions,
    required this.edges,
    required this.canvasSize,
    required this.mainIds,
  });
}

class _QuestRoadmapLayoutEngine {
  final QuestLineageNode root;
  final double nodeSize;

  /// distance entre MAIN
  final double mainSeparation;

  /// distance horizontale dans les branches
  final double branchSeparation;

  /// espace vertical entre branches empilées
  final double siblingSeparation;

  /// gap MAIN <-> rows TOP/BOTTOM (multiplié par nodeSize)
  final double rowGapFactor;

  /// décalage X pour attacher les branches depuis MAIN
  final double branchAttachFactor;

  final double viewportW;
  final double viewportH;

  _QuestRoadmapLayoutEngine({
    required this.root,
    required this.nodeSize,
    required this.mainSeparation,
    required this.branchSeparation,
    required this.siblingSeparation,
    required this.rowGapFactor,
    required this.branchAttachFactor,
    required this.viewportW,
    required this.viewportH,
  });

  final Map<String, QuestLineageNode> _nodeById = {};
  final List<_Edge> _edges = [];
  final Map<String, Offset> _pos = {};

  _QuestRoadmapLayoutResult compute() {
    _registerAllNodes();

    final mainChain = _extractMainChain(root);

    final mainIds = <String>{};
    for (int i = 0; i < mainChain.length; i++) {
      mainIds.add(_stableId(mainChain[i], fallbackPath: 'main-$i'));
    }

    // MAIN sur une ligne parfaite
    final paddingLeft = 40.0;
    final paddingV = 60.0;
    final yMain = viewportH / 2;

    for (int i = 0; i < mainChain.length; i++) {
      final node = mainChain[i];
      final id = _stableId(node, fallbackPath: 'main-$i');
      final x = paddingLeft + i * mainSeparation;
      _pos[id] = Offset(x, yMain);
    }

    // Branches TOP/BOTTOM équilibrées
    for (int i = 0; i < mainChain.length; i++) {
      final mainNode = mainChain[i];
      final mainId = _stableId(mainNode, fallbackPath: 'main-$i');
      final mainPos = _pos[mainId];
      if (mainPos == null) continue;

      final branchChildren = _sortedChildren(mainNode).where((c) => !_isMain(c)).toList();
      if (branchChildren.isEmpty) continue;

      final preferTopForThisMain = i.isEven;

      double topUsed = 0;
      double bottomUsed = 0;

      final gapFromMain = nodeSize * rowGapFactor;
      final attachX = mainPos.dx + mainSeparation * branchAttachFactor;

      final topCapacity = (yMain - paddingV);
      final bottomCapacity = ((viewportH - yMain) - paddingV);

      for (int b = 0; b < branchChildren.length; b++) {
        final child = branchChildren[b];
        final childId = _stableId(child, fallbackPath: 'branch-$i-$b');

        final subtreeH = _measureSubtreeHeight(child);

        final desiredTop = b.isEven ? preferTopForThisMain : !preferTopForThisMain;

        final topFits = (gapFromMain + topUsed + subtreeH) <= topCapacity;
        final bottomFits = (gapFromMain + bottomUsed + subtreeH) <= bottomCapacity;

        bool useTop;

        if (topFits && bottomFits) {
          useTop = desiredTop;
        } else if (topFits) {
          useTop = true;
        } else if (bottomFits) {
          useTop = false;
        } else {
          final remTop = topCapacity - (gapFromMain + topUsed + subtreeH);
          final remBottom = bottomCapacity - (gapFromMain + bottomUsed + subtreeH);
          useTop = remTop >= remBottom;
        }

        final y = useTop
            ? (yMain - gapFromMain - (topUsed + subtreeH / 2))
            : (yMain + gapFromMain + (bottomUsed + subtreeH / 2));

        _pos[childId] = Offset(attachX, y);

        _layoutBranchSubtree(node: child, nodeId: childId);

        if (useTop) {
          topUsed += subtreeH + siblingSeparation;
        } else {
          bottomUsed += subtreeH + siblingSeparation;
        }
      }
    }

    // Extents => canvas size + shift positif
    final ext = _computeExtents();
    final minX = ext.$1;
    final minY = ext.$2;
    final maxX = ext.$3;
    final maxY = ext.$4;

    final pad = 120.0;

    final neededW = (maxX - minX) + pad * 2;
    final neededH = (maxY - minY) + pad * 2;

    final canvasW = math.max(neededW, viewportW);
    final canvasH = math.max(neededH, viewportH);

    final shiftX = -minX + pad;
    final shiftY = -minY + pad;

    for (final k in _pos.keys.toList()) {
      final p = _pos[k]!;
      _pos[k] = Offset(p.dx + shiftX, p.dy + shiftY);
    }

    return _QuestRoadmapLayoutResult(
      nodeById: _nodeById,
      positions: _pos,
      edges: _edges,
      canvasSize: Size(canvasW, canvasH),
      mainIds: mainIds,
    );
  }

  void _registerAllNodes() {
    _nodeById.clear();
    _edges.clear();

    void rec(QuestLineageNode node, {required String path, required String? parentId}) {
      final id = _stableId(node, fallbackPath: path);
      _nodeById[id] = node;

      if (parentId != null) {
        _edges.add(_Edge(parentId, id));
      }

      final children = _sortedChildren(node);
      for (int i = 0; i < children.length; i++) {
        rec(children[i], path: '$path-$i', parentId: id);
      }
    }

    rec(root, path: 'root', parentId: null);
  }

  List<QuestLineageNode> _extractMainChain(QuestLineageNode start) {
    final chain = <QuestLineageNode>[];
    QuestLineageNode? cur = start;

    while (cur != null) {
      chain.add(cur);

      final mains = _sortedChildren(cur).where(_isMain).toList();
      if (mains.isEmpty) break;

      cur = mains.first;
    }

    return chain;
  }

  void _layoutBranchSubtree({
    required QuestLineageNode node,
    required String nodeId,
  }) {
    final parentPos = _pos[nodeId];
    if (parentPos == null) return;

    final kids = _sortedChildren(node).where((c) => !_isMain(c)).toList();
    if (kids.isEmpty) return;

    final heights = kids.map(_measureSubtreeHeight).toList();

    final totalH = heights.fold<double>(0, (p, e) => p + e) + siblingSeparation * (kids.length - 1);

    double cursorY = parentPos.dy - totalH / 2;

    for (int i = 0; i < kids.length; i++) {
      final child = kids[i];
      final h = heights[i];
      final childId = _stableId(child, fallbackPath: '$nodeId-$i');

      final x = parentPos.dx + branchSeparation; // ✅ configurable
      final y = cursorY + h / 2;

      _pos[childId] = Offset(x, y);

      _layoutBranchSubtree(node: child, nodeId: childId);

      cursorY += h + siblingSeparation;
    }
  }

  double _measureSubtreeHeight(QuestLineageNode node) {
    final kids = _sortedChildren(node).where((c) => !_isMain(c)).toList();
    if (kids.isEmpty) return nodeSize;

    double sum = 0;
    for (final k in kids) {
      sum += _measureSubtreeHeight(k);
    }
    sum += siblingSeparation * (kids.length - 1);

    return math.max(nodeSize, sum);
  }

  (double, double, double, double) _computeExtents() {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    final r = nodeSize / 2;

    for (final p in _pos.values) {
      minX = math.min(minX, p.dx - r);
      minY = math.min(minY, p.dy - r);
      maxX = math.max(maxX, p.dx + r);
      maxY = math.max(maxY, p.dy + r);
    }

    if (_pos.isEmpty) {
      minX = 0;
      minY = 0;
      maxX = viewportW;
      maxY = viewportH;
    }

    return (minX, minY, maxX, maxY);
  }

  List<QuestLineageNode> _sortedChildren(QuestLineageNode node) {
    final children = [...node.children];
    children.sort((a, b) {
      final ao = a.definition?.uiOrder ?? 0;
      final bo = b.definition?.uiOrder ?? 0;
      return ao.compareTo(bo);
    });
    return children;
  }

  bool _isMain(QuestLineageNode n) {
    final cat = n.definition?.category;
    if (cat == null) return false;

    if (cat is String) return cat.toUpperCase() == 'MAIN';

    try {
      final dynamic d = cat;
      final name = d.name;
      if (name is String) return name.toUpperCase() == 'MAIN';
    } catch (_) {}

    final s = cat.toString().toUpperCase();
    return s.contains('MAIN');
  }

  String _stableId(QuestLineageNode node, {required String fallbackPath}) {
    final def = node.definition;
    final id = def?.id;
    if (id != null && id.toString().trim().isNotEmpty) return id.toString();

    final code = def?.code;
    if (code != null && code.toString().trim().isNotEmpty) return code.toString();

    return fallbackPath;
  }
}

/// ============================================================================
/// EDGES PAINTER
/// ============================================================================

class _Edge {
  final String fromId;
  final String toId;
  const _Edge(this.fromId, this.toId);
}

class _QuestEdgesPainter extends CustomPainter {
  final List<_Edge> edges;
  final Map<String, Offset> positions;
  final double nodeSize;
  final Paint connectorPaint;

  /// ✅ Réglage arrondi (0.10 = angles secs, 0.60 = très rond)
  final double cornerRadiusFactor;

  final Set<String> mainIds;

  const _QuestEdgesPainter({
    required this.edges,
    required this.positions,
    required this.nodeSize,
    required this.connectorPaint,
    required this.mainIds,
    this.cornerRadiusFactor = 0.42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circleR = nodeSize / 2;

    for (final e in edges) {
      final fromCenter = positions[e.fromId];
      final toCenter = positions[e.toId];
      if (fromCenter == null || toCenter == null) continue;

      final centerDx = (toCenter.dx - fromCenter.dx).abs();
      final centerDy = (toCenter.dy - fromCenter.dy).abs();

      final isMainToBranch = mainIds.contains(e.fromId) && !mainIds.contains(e.toId);
      final verticalFirst = isMainToBranch ? true : (centerDy > centerDx);

      final anchors = _smartAnchors(fromCenter, toCenter, circleR, verticalFirst);
      final start = anchors.start;
      final end = anchors.end;

      if (anchors.straight) {
        canvas.drawLine(start, end, connectorPaint);
        continue;
      }

      final dx = (end.dx - start.dx).abs();
      final dy = (end.dy - start.dy).abs();

      if (dx < 0.5 || dy < 0.5) {
        canvas.drawLine(start, end, connectorPaint);
        continue;
      }

      final cornerR = (nodeSize * cornerRadiusFactor).clamp(6.0, math.min(dx, dy) / 2);

      final path = _roundedElbowPath(
        start: start,
        end: end,
        radius: cornerR,
        verticalFirst: verticalFirst,
      );

      canvas.drawPath(path, connectorPaint);
    }
  }

  Path _roundedElbowPath({
    required Offset start,
    required Offset end,
    required double radius,
    required bool verticalFirst,
  }) {
    final pivot = verticalFirst ? Offset(start.dx, end.dy) : Offset(end.dx, start.dy);

    if ((pivot - start).distance < radius * 1.2 || (end - pivot).distance < radius * 1.2) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
    }

    final dir1 = _axisDir(start, pivot);
    final dir2 = _axisDir(pivot, end);

    final before = pivot - dir1 * radius;
    final after = pivot + dir2 * radius;

    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(before.dx, before.dy)
      ..quadraticBezierTo(pivot.dx, pivot.dy, after.dx, after.dy)
      ..lineTo(end.dx, end.dy);
  }

  Offset _axisDir(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;

    if (dx.abs() >= dy.abs()) {
      return Offset(dx >= 0 ? 1 : -1, 0);
    } else {
      return Offset(0, dy >= 0 ? 1 : -1);
    }
  }

  @override
  bool shouldRepaint(covariant _QuestEdgesPainter oldDelegate) {
    return oldDelegate.edges != edges ||
        oldDelegate.positions != positions ||
        oldDelegate.nodeSize != nodeSize ||
        oldDelegate.cornerRadiusFactor != cornerRadiusFactor ||
        oldDelegate.connectorPaint.color != connectorPaint.color ||
        oldDelegate.connectorPaint.strokeWidth != connectorPaint.strokeWidth;
  }
}

class _Anchors {
  final Offset start;
  final Offset end;
  final bool straight;
  const _Anchors(this.start, this.end, {this.straight = false});
}

_Anchors _smartAnchors(Offset from, Offset to, double r, bool verticalFirst) {
  final dx = to.dx - from.dx;
  final dy = to.dy - from.dy;

  const eps = 1.0;

  if (dy.abs() < eps) {
    final sx = dx >= 0 ? r : -r;
    final ex = dx >= 0 ? -r : r;
    return _Anchors(from + Offset(sx, 0), to + Offset(ex, 0), straight: true);
  }

  if (dx.abs() < eps) {
    final sy = dy >= 0 ? r : -r;
    final ey = dy >= 0 ? -r : r;
    return _Anchors(from + Offset(0, sy), to + Offset(0, ey), straight: true);
  }

  if (verticalFirst) {
    final start = from + Offset(0, dy >= 0 ? r : -r);
    final end = to + Offset(dx >= 0 ? -r : r, 0);
    return _Anchors(start, end);
  }

  final start = from + Offset(dx >= 0 ? r : -r, 0);
  final end = to + Offset(0, dy >= 0 ? -r : r);
  return _Anchors(start, end);
}

/// ============================================================================
/// NODE VIEW
/// ============================================================================

class _QuestNodeView extends StatelessWidget {
  final QuestLineageNode node;
  final double size;
  final bool selected;
  final QuestNodeTap? onTap;

  const _QuestNodeView({
    required this.node,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = _computeState(node);
    final shape = _shapeForCategory(node);

    const outerBg = Color(0xFFEDE8E0);
    late final Color innerBg;
    late final IconData icon;
    late final Color iconColor;

    switch (state) {
      case _QuestVisualState.locked:
        innerBg = const Color(0xFFBDB7AE);
        icon = Icons.lock_rounded;
        iconColor = const Color(0xFF2E2A25);
        break;

      case _QuestVisualState.claimable:
        innerBg = const Color(0xFF6D3CF7);
        icon = Icons.card_giftcard_rounded;
        iconColor = Colors.white;
        break;

      case _QuestVisualState.completed:
        innerBg = const Color(0xFF6D3CF7);
        icon = Icons.check_rounded;
        iconColor = Colors.white;
        break;

      case _QuestVisualState.inProgress:
        innerBg = const Color(0xFF8F86A0);
        icon = Icons.play_arrow_rounded;
        iconColor = Colors.white;
        break;

      case _QuestVisualState.available:
        innerBg = const Color(0xFFA29AAE);
        icon = Icons.flag_rounded;
        iconColor = Colors.white;
        break;
    }

    final glow = (state == _QuestVisualState.claimable || selected);
    final borderSide = BorderSide(
      color: selected ? const Color(0xFF6D3CF7) : Colors.transparent,
      width: selected ? 3 : 0,
    );

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(node),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: ShapeDecoration(
          shape: _shapeBorder(shape, size: size, side: borderSide),
          color: outerBg,
          shadows: glow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.58,
            height: size * 0.58,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: _shapeBorder(shape, size: size * 0.58),
                color: innerBg,
              ),
              child: Icon(icon, color: iconColor, size: size * 0.30),
            ),
          ),
        ),
      ),
    );
  }

  _QuestVisualState _computeState(QuestLineageNode n) {
    if (n.locked) return _QuestVisualState.locked;
    if (n.claimable) return _QuestVisualState.claimable;

    final inst = n.instance;
    final def = n.definition;

    final progress = inst?.progressCount ?? 0;
    final target = def?.targetCount ?? 0;

    if (inst?.claimedAt != null) return _QuestVisualState.completed;
    if (target > 0 && progress >= target) return _QuestVisualState.claimable;
    if (progress > 0) return _QuestVisualState.inProgress;

    return _QuestVisualState.available;
  }
}

enum _QuestNodeShape {
  circle,
  roundedSquare,
  diamond,
  hexagon,
}

_QuestNodeShape _shapeForCategory(QuestLineageNode node) {
  final raw = node.definition?.category;
  final s = raw?.toString().toUpperCase().trim();

  switch (s) {
    case 'MAIN':
      return _QuestNodeShape.circle;
    case 'BRANCH':
      return _QuestNodeShape.roundedSquare;
    case 'COLLECTION':
      return _QuestNodeShape.hexagon;
    case 'SHARE':
      return _QuestNodeShape.diamond;
    default:
      return _QuestNodeShape.circle;
  }
}

ShapeBorder _shapeBorder(
  _QuestNodeShape shape, {
  required double size,
  BorderSide side = BorderSide.none,
}) {
  switch (shape) {
    case _QuestNodeShape.circle:
      return CircleBorder(side: side);
    case _QuestNodeShape.roundedSquare:
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size * 0.18),
        side: side,
      );
    case _QuestNodeShape.diamond:
      return _PolygonBorder(sides: 4, rotation: math.pi / 4, side: side);
    case _QuestNodeShape.hexagon:
      return _PolygonBorder(sides: 6, rotation: math.pi / 6, side: side);
  }
}

class _PolygonBorder extends ShapeBorder {
  final int sides;
  final double rotation;
  final BorderSide side;

  const _PolygonBorder({
    required this.sides,
    this.rotation = 0,
    this.side = BorderSide.none,
  }) : assert(sides >= 3);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _polygonPath(rect);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    if (side.width <= 0) return _polygonPath(rect);
    return _polygonPath(rect.deflate(side.width));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width <= 0) return;
    final paint = side.toPaint();
    canvas.drawPath(_polygonPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return _PolygonBorder(
      sides: sides,
      rotation: rotation,
      side: side.scale(t),
    );
  }

  Path _polygonPath(Rect rect) {
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = rotation + (math.pi * 2 * i / sides);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}

enum _QuestVisualState {
  locked,
  available,
  inProgress,
  completed,
  claimable,
}
