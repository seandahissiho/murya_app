part of '../profile.dart';
//
// /// Résultat du placement :
// /// - positionsByNodeKey : clé stable (id/code/path) -> GridPos
// /// - nodeKeyByPos       : inverse, pratique si tu veux retrouver un node depuis un tap
// class QuestGridPlacement {
//   final Map<String, GridPos> positionsByNodeKey;
//   final Map<GridPos, String> nodeKeyByPos;
//
//   const QuestGridPlacement({
//     required this.positionsByNodeKey,
//     required this.nodeKeyByPos,
//   });
// }
//
// class QuestGridPlacer {
//   /// Espacement logique en "cellules"
//   final int colStep; // ex: 2 -> laisse un espace entre nodes
//   final int branchRowGap; // ex: 2 -> branches haut/bas plus espacées
//
//   const QuestGridPlacer({
//     this.colStep = 2,
//     this.branchRowGap = 2,
//   });
//
//   QuestGridPlacement place({
//     required QuestLineage lineage,
//     required int rows,
//     required int cols,
//     int startCol = 0,
//   }) {
//     final root = lineage.main;
//     if (root == null || rows <= 0 || cols <= 0) {
//       return const QuestGridPlacement(
//         positionsByNodeKey: {},
//         nodeKeyByPos: {},
//       );
//     }
//
//     // ✅ Premier node au centre vertical (dynamique)
//     final startRow = (rows ~/ 2).clamp(0, rows - 10);
//
//     final positions = <String, GridPos>{};
//     final reverse = <GridPos, String>{};
//     final occupied = <GridPos>{};
//
//     void setPos(String key, GridPos pos) {
//       positions[key] = pos;
//       reverse[pos] = key;
//       occupied.add(pos);
//     }
//
//     int findNearestFreeRow({
//       required int desiredRow,
//       required int col,
//     }) {
//       final base = desiredRow.clamp(0, rows - 1);
//       if (!occupied.contains(GridPos(base, col))) return base;
//
//       for (int d = 1; d < rows; d++) {
//         final up = base - d;
//         if (up >= 0 && !occupied.contains(GridPos(up, col))) return up;
//
//         final down = base + d;
//         if (down < rows && !occupied.contains(GridPos(down, col))) return down;
//       }
//       return base;
//     }
//
//     /// clé stable pour node :
//     /// - priorité id
//     /// - sinon code
//     /// - sinon path ("root-0-1-0")
//     String nodeKey(QuestLineageNode node, String path) {
//       return node.definition?.id ?? node.definition?.code ?? path;
//     }
//
//     int nodeUiOrder(QuestLineageNode n) => n.definition?.uiOrder ?? 0;
//
//     /// Décide quel child "continue" la MAIN line :
//     /// 👉 ici : le plus petit uiOrder
//     QuestLineageNode? pickMainChild(List<QuestLineageNode> children) {
//       if (children.isEmpty) return null;
//       final sorted = [...children]..sort((a, b) => nodeUiOrder(a).compareTo(nodeUiOrder(b)));
//       return sorted.first;
//     }
//
//     /// Suite d’offsets verticals pour placer les branches autour de la main row :
//     /// [-1, +1, -2, +2, -3, +3] * branchRowGap
//     List<int> branchOffsets(int count) {
//       final out = <int>[];
//       for (int k = 1; out.length < count; k++) {
//         out.add(-k * branchRowGap);
//         if (out.length < count) out.add(k * branchRowGap);
//       }
//       return out;
//     }
//
//     void walk(
//       QuestLineageNode node, {
//       required int row,
//       required int col,
//       required String path,
//     }) {
//       if (col < 0 || col >= cols) return;
//
//       final key = nodeKey(node, path);
//
//       // collision-safe
//       final fixedRow = findNearestFreeRow(desiredRow: row, col: col);
//       final pos = GridPos(fixedRow, col);
//
//       // si déjà posé, skip
//       if (positions.containsKey(key)) return;
//
//       setPos(key, pos);
//
//       // ---- children ----
//       if (node.children.isEmpty) return;
//
//       final childrenSorted = [...node.children]..sort((a, b) => nodeUiOrder(a).compareTo(nodeUiOrder(b)));
//
//       // main child = continue sur la même row
//       final mainChild = pickMainChild(childrenSorted);
//
//       // other children = branches haut/bas
//       final otherChildren = <QuestLineageNode>[];
//       for (final c in childrenSorted) {
//         if (!identical(c, mainChild)) otherChildren.add(c);
//       }
//
//       final nextCol = col + colStep;
//       if (nextCol >= cols) return;
//
//       // 1) place main child sur la même row
//       if (mainChild != null) {
//         final idx = childrenSorted.indexOf(mainChild);
//         walk(
//           mainChild,
//           row: fixedRow,
//           col: nextCol,
//           path: "$path-$idx",
//         );
//       }
//
//       // 2) place branches au-dessus/en-dessous
//       final offsets = branchOffsets(otherChildren.length);
//       for (int i = 0; i < otherChildren.length; i++) {
//         final child = otherChildren[i];
//         final originalIndex = childrenSorted.indexOf(child);
//
//         final desiredRow = fixedRow + offsets[i];
//         walk(
//           child,
//           row: desiredRow,
//           col: nextCol,
//           path: "$path-$originalIndex",
//         );
//       }
//     }
//
//     // Start placement
//     walk(root, row: startRow, col: startCol, path: "root");
//
//     return QuestGridPlacement(
//       positionsByNodeKey: positions,
//       nodeKeyByPos: reverse,
//     );
//   }
// }

/// Génère les edges (traits) à partir du placement.
/// - horizontalFirst = true : on va d’abord en X (col), puis en Y (row)
// Set<GridEdge> buildActiveEdgesFromLineage({
//   required QuestLineage lineage,
//   required Map<String, GridPos> positionsByNodeKey,
//   required int rows,
//   required int cols,
//   bool horizontalFirst = true,
// }) {
//   final root = lineage.main;
//   if (root == null) return {};
//
//   // --- Helpers identiques à ceux du placer (IMPORTANT) ---
//   String nodeKey(QuestLineageNode node, String path) {
//     return node.definition?.id ?? node.definition?.code ?? path;
//   }
//
//   int nodeUiOrder(QuestLineageNode n) => n.definition?.uiOrder ?? 0;
//
//   int sign(int x) => x == 0 ? 0 : (x > 0 ? 1 : -1);
//
//   bool inBounds(GridPos p) => p.row >= 0 && p.row < rows && p.col >= 0 && p.col < cols;
//
//   /// Route Manhattan : from -> to (liste d'edges)
//   Iterable<GridEdge> routeManhattan(GridPos from, GridPos to) sync* {
//     GridPos cur = from;
//
//     if (horizontalFirst) {
//       // move X
//       while (cur.col != to.col) {
//         final next = GridPos(cur.row, cur.col + sign(to.col - cur.col));
//         if (inBounds(cur) && inBounds(next)) yield GridEdge(cur, next);
//         cur = next;
//       }
//       // move Y
//       while (cur.row != to.row) {
//         final next = GridPos(cur.row + sign(to.row - cur.row), cur.col);
//         if (inBounds(cur) && inBounds(next)) yield GridEdge(cur, next);
//         cur = next;
//       }
//     } else {
//       // move Y
//       while (cur.row != to.row) {
//         final next = GridPos(cur.row + sign(to.row - cur.row), cur.col);
//         if (inBounds(cur) && inBounds(next)) yield GridEdge(cur, next);
//         cur = next;
//       }
//       // move X
//       while (cur.col != to.col) {
//         final next = GridPos(cur.row, cur.col + sign(to.col - cur.col));
//         if (inBounds(cur) && inBounds(next)) yield GridEdge(cur, next);
//         cur = next;
//       }
//     }
//   }
//
//   final edges = <GridEdge>{};
//
//   /// Parcours récursif du lineage avec EXACTEMENT la même logique de path
//   void walk(QuestLineageNode node, {required String path}) {
//     final parentKey = nodeKey(node, path);
//     final parentPos = positionsByNodeKey[parentKey];
//
//     // Tri children (comme dans le placer)
//     final childrenSorted = [...node.children]..sort((a, b) => nodeUiOrder(a).compareTo(nodeUiOrder(b)));
//
//     for (int i = 0; i < childrenSorted.length; i++) {
//       final child = childrenSorted[i];
//       final childPath = "$path-$i";
//
//       final childKey = nodeKey(child, childPath);
//       final childPos = positionsByNodeKey[childKey];
//
//       // Si on a les positions, on route et ajoute les edges
//       if (parentPos != null && childPos != null) {
//         edges.addAll(routeManhattan(parentPos, childPos));
//       }
//
//       // Recursion
//       walk(child, path: childPath);
//     }
//   }
//
//   walk(root, path: "root");
//   return edges;
// }

class TabletJourneyObjectivesTab extends StatefulWidget {
  const TabletJourneyObjectivesTab({super.key});

  @override
  State<TabletJourneyObjectivesTab> createState() => _TabletJourneyObjectivesTabState();
}

class _TabletJourneyObjectivesTabState extends State<TabletJourneyObjectivesTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return BlocConsumer<QuestsBloc, QuestsState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          return QuestLineageTreeView(
            lineage: state.questLineage,
            nodeSize: 64,
            levelSeparation: constraints.maxWidth / 10, // distance entre MAIN
            subtreeSeparation: constraints.maxWidth / 10, // distance entre nodes en BRANCH
            rowGapFactor: 1.25, // distance entre rows
            branchAttachFactor: 0.95, // distance MAIN->départ branche
            siblingSeparation: 44, // espacement vertical entre branches empilées
            cornerRadiusFactor: 0.18, // arrondi des coudes
            connectorStrokeFactor: 0.35, // épaisseur du tuyau
          );
        });
        // return QuestLineageTreeView(lineage: state.questLineage);
      },
    );
  }
}

// class QuestMap extends StatefulWidget {
//   final QuestLineage lineage;
//   const QuestMap({super.key, required this.lineage});
//
//   @override
//   State<QuestMap> createState() => _QuestMapState();
// }
//
// class _QuestMapState extends State<QuestMap> {
//   @override
//   Widget build(BuildContext context) {
//     final isMobile = DeviceHelper.isMobile(context);
//     const double spacing = 20;
//     final activeNodes = _getActiveNodes();
//     final activeEdges = _getActiveEdges();
//
//     const placer = QuestGridPlacer(colStep: 8, branchRowGap: 6);
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final placement = placer.place(
//         lineage: widget.lineage,
//         rows: constraints.maxHeight ~/ spacing,
//         cols: constraints.maxWidth ~/ spacing,
//       );
//
//       // ✅ activeNodes = toutes les positions des "vrais nodes de quête"
//       final activeNodes = placement.positionsByNodeKey.values.toSet();
//       final activeEdges = buildActiveEdgesFromLineage(
//         lineage: widget.lineage,
//         positionsByNodeKey: placement.positionsByNodeKey,
//         rows: constraints.maxHeight ~/ spacing,
//         cols: constraints.maxWidth ~/ spacing,
//         horizontalFirst: true,
//       );
//       return QuestGridMapView(
//         rows: constraints.maxHeight ~/ spacing,
//         cols: constraints.maxWidth ~/ spacing,
//         spacing: spacing,
//         nodeRadius: 18,
//         padding: spacing + (spacing),
//         showInactiveBackgroundGrid: false, // ou false => masque tout le reste
//         activeNodes: activeNodes,
//         activeEdges: activeEdges,
//         selectedNode: const GridPos(4, 4),
//         onNodeTap: (pos) {
//           debugPrint("Clicked node $pos");
//         },
//       );
//     });
//     return LayoutBuilder(builder: (context, constraints) {
//       return GridPaper(
//         interval: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
//         subdivisions: 1,
//         divisions: 1,
//         color: Colors.black38,
//       );
//     });
//   }
//
//   _getActiveNodes() {
//     return <GridPos>{
//       const GridPos(4, 0),
//       const GridPos(4, 2),
//       const GridPos(4, 4),
//       const GridPos(2, 4),
//       const GridPos(6, 4),
//     };
//   }
//
//   _getActiveEdges() {
//     return <GridEdge>{
//       GridEdge(const GridPos(4, 0), const GridPos(4, 1)),
//       GridEdge(const GridPos(4, 1), const GridPos(4, 2)),
//       GridEdge(const GridPos(4, 2), const GridPos(4, 3)),
//       GridEdge(const GridPos(4, 3), const GridPos(4, 4)),
//       GridEdge(const GridPos(4, 4), const GridPos(3, 4)),
//       GridEdge(const GridPos(3, 4), const GridPos(2, 4)),
//       GridEdge(const GridPos(4, 4), const GridPos(5, 4)),
//       GridEdge(const GridPos(5, 4), const GridPos(6, 4)),
//     };
//   }
// }
//
// @immutable
// class GridPos {
//   final int row;
//   final int col;
//
//   const GridPos(this.row, this.col);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is GridPos && runtimeType == other.runtimeType && row == other.row && col == other.col;
//
//   @override
//   int get hashCode => Object.hash(row, col);
//
//   @override
//   String toString() => 'GridPos(r:$row, c:$col)';
// }
//
// @immutable
// class GridEdge {
//   final GridPos a;
//   final GridPos b;
//
//   /// Normalise l'ordre (pour éviter doublons)
//   GridEdge(GridPos p1, GridPos p2)
//       : a = _min(p1, p2),
//         b = _max(p1, p2);
//
//   static GridPos _min(GridPos x, GridPos y) {
//     if (x.row < y.row) return x;
//     if (x.row > y.row) return y;
//     return x.col <= y.col ? x : y;
//   }
//
//   static GridPos _max(GridPos x, GridPos y) {
//     if (x.row > y.row) return x;
//     if (x.row < y.row) return y;
//     return x.col >= y.col ? x : y;
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) || other is GridEdge && runtimeType == other.runtimeType && a == other.a && b == other.b;
//
//   @override
//   int get hashCode => Object.hash(a, b);
//
//   @override
//   String toString() => 'Edge($a -> $b)';
// }
//
// typedef GridNodeTap = void Function(GridPos pos);
//
// class QuestGridMapView extends StatefulWidget {
//   /// Dimensions de la grille
//   final int rows;
//   final int cols;
//
//   /// Spacing entre les centres des ronds
//   final double spacing;
//
//   /// Rayon du rond externe
//   final double nodeRadius;
//
//   /// Marge interne (padding du canvas)
//   final double padding;
//
//   /// Si false => on ne dessine QUE activeNodes/activeEdges
//   final bool showInactiveBackgroundGrid;
//
//   /// Liste des nodes "utiles" (sinon masqués)
//   final Set<GridPos> activeNodes;
//
//   /// Liste des edges "utiles"
//   final Set<GridEdge> activeEdges;
//
//   /// Callback tap node
//   final GridNodeTap? onNodeTap;
//
//   /// Optional : node sélectionné
//   final GridPos? selectedNode;
//
//   const QuestGridMapView({
//     super.key,
//     required this.rows,
//     required this.cols,
//     this.spacing = 90,
//     this.nodeRadius = 32,
//     this.padding = 30,
//     this.showInactiveBackgroundGrid = true,
//     this.activeNodes = const {},
//     this.activeEdges = const {},
//     this.onNodeTap,
//     this.selectedNode,
//   });
//
//   @override
//   State<QuestGridMapView> createState() => _QuestGridMapViewState();
// }
//
// class _QuestGridMapViewState extends State<QuestGridMapView> {
//   late final TransformationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TransformationController();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Size _canvasSize() {
//     final w = widget.padding * 2 + (widget.cols - 1) * widget.spacing;
//     final h = widget.padding * 2 + (widget.rows - 1) * widget.spacing;
//     return Size(w, h);
//   }
//
//   Offset _posToOffset(GridPos p) {
//     return Offset(
//       widget.padding + p.col * widget.spacing,
//       widget.padding + p.row * widget.spacing,
//     );
//   }
//
//   GridPos _nearestGridPos(Offset scenePos) {
//     final x = scenePos.dx - widget.padding;
//     final y = scenePos.dy - widget.padding;
//
//     final col = (x / widget.spacing).round().clamp(0, widget.cols - 1);
//     final row = (y / widget.spacing).round().clamp(0, widget.rows - 1);
//
//     return GridPos(row, col);
//   }
//
//   bool _isWithinNode(Offset scenePos, GridPos gp) {
//     final center = _posToOffset(gp);
//     return (scenePos - center).distance <= widget.nodeRadius;
//   }
//
//   void _handleTapDown(TapDownDetails details) {
//     if (widget.onNodeTap == null) return;
//
//     // Convertit la position écran en "scene coords" (canvas coords)
//     final scenePos = _controller.toScene(details.localPosition);
//     final gp = _nearestGridPos(scenePos);
//
//     // Si tu veux "masquer" les nodes inutiles => on ne clique que sur actifs
//     if (!widget.activeNodes.contains(gp)) return;
//
//     if (_isWithinNode(scenePos, gp)) {
//       widget.onNodeTap?.call(gp);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = _canvasSize();
//
//     return InteractiveViewer(
//       transformationController: _controller,
//       panEnabled: false,
//       constrained: false,
//       alignment: Alignment.centerLeft,
//       boundaryMargin: EdgeInsets.zero,
//       // boundaryMargin: const EdgeInsets.only(bottom: 300),
//       minScale: 1.0,
//       maxScale: 1.0,
//       child: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTapDown: _handleTapDown,
//         child: CustomPaint(
//           size: size,
//           painter: _QuestGridPainter(
//             rows: widget.rows,
//             cols: widget.cols,
//             spacing: widget.spacing,
//             nodeRadius: widget.nodeRadius,
//             padding: widget.padding,
//             showInactiveBackgroundGrid: widget.showInactiveBackgroundGrid,
//             activeNodes: widget.activeNodes,
//             activeEdges: widget.activeEdges,
//             selectedNode: widget.selectedNode,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _QuestGridPainter extends CustomPainter {
//   final int rows;
//   final int cols;
//   final double spacing;
//   final double nodeRadius;
//   final double padding;
//   final bool showInactiveBackgroundGrid;
//
//   final Set<GridPos> activeNodes;
//   final Set<GridEdge> activeEdges;
//   final GridPos? selectedNode;
//
//   _QuestGridPainter({
//     required this.rows,
//     required this.cols,
//     required this.spacing,
//     required this.nodeRadius,
//     required this.padding,
//     required this.showInactiveBackgroundGrid,
//     required this.activeNodes,
//     required this.activeEdges,
//     required this.selectedNode,
//   });
//
//   Offset _posToOffset(GridPos p) {
//     return Offset(
//       padding + p.col * spacing,
//       padding + p.row * spacing,
//     );
//   }
//
//   Iterable<GridPos> _allNodes() sync* {
//     for (int r = 0; r < rows; r++) {
//       for (int c = 0; c < cols; c++) {
//         yield GridPos(r, c);
//       }
//     }
//   }
//
//   Iterable<GridEdge> _allEdges4Dir() sync* {
//     for (int r = 0; r < rows; r++) {
//       for (int c = 0; c < cols; c++) {
//         final p = GridPos(r, c);
//         if (c + 1 < cols) yield GridEdge(p, GridPos(r, c + 1)); // droite
//         if (r + 1 < rows) yield GridEdge(p, GridPos(r + 1, c)); // bas
//       }
//     }
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // --- Paints ---
//     final Paint inactiveEdgePaint = Paint()
//       ..color = const Color(0xFFD9D3CA).withOpacity(0.25)
//       ..strokeWidth = math.max(6, nodeRadius * 0.35)
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final Paint activeEdgePaint = Paint()
//       ..color = const Color(0xFFD9D3CA)
//       ..strokeWidth = math.max(10, nodeRadius * 0.55)
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final Paint outerCirclePaint = Paint()
//       ..color = const Color(0xFFEDE8E0)
//       ..style = PaintingStyle.fill;
//
//     final Paint inactiveOuterCirclePaint = Paint()
//       ..color = const Color(0xFFEDE8E0).withOpacity(0.18)
//       ..style = PaintingStyle.fill;
//
//     final Paint innerCirclePaint = Paint()
//       ..color = const Color(0xFFA29AAE)
//       ..style = PaintingStyle.fill;
//
//     final Paint selectedRingPaint = Paint()
//       ..color = const Color(0xFF6D3CF7)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4;
//
//     // --- 1) Background grid (optionnel) ---
//     if (showInactiveBackgroundGrid) {
//       for (final e in _allEdges4Dir()) {
//         final a = _posToOffset(e.a);
//         final b = _posToOffset(e.b);
//         canvas.drawLine(a, b, inactiveEdgePaint);
//       }
//
//       for (final p in _allNodes()) {
//         final center = _posToOffset(p);
//         canvas.drawCircle(center, nodeRadius, inactiveOuterCirclePaint);
//       }
//     }
//
//     // --- 2) Active edges ---
//     for (final e in activeEdges) {
//       final a = _posToOffset(e.a);
//       final b = _posToOffset(e.b);
//       canvas.drawLine(a, b, activeEdgePaint);
//     }
//
//     // --- 3) Active nodes (non-masqués) ---
//     for (final p in activeNodes) {
//       final center = _posToOffset(p);
//       canvas.drawCircle(center, nodeRadius * 1.5, outerCirclePaint);
//       canvas.drawCircle(center, nodeRadius * 0.78, innerCirclePaint);
//
//       // petit "icone" simple : cercle blanc au centre (placeholder)
//       // (tu peux remplacer par un dessin d'étoile / lock / check)
//       // final Paint iconPaint = Paint()..color = Colors.white.withOpacity(0.95);
//       // canvas.drawCircle(center, nodeRadius * 0.16, iconPaint);
//
//       // selected ring
//       if (selectedNode != null && selectedNode == p) {
//         canvas.drawCircle(center, nodeRadius + 3, selectedRingPaint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _QuestGridPainter oldDelegate) {
//     return oldDelegate.rows != rows ||
//         oldDelegate.cols != cols ||
//         oldDelegate.spacing != spacing ||
//         oldDelegate.nodeRadius != nodeRadius ||
//         oldDelegate.padding != padding ||
//         oldDelegate.showInactiveBackgroundGrid != showInactiveBackgroundGrid ||
//         oldDelegate.activeNodes != activeNodes ||
//         oldDelegate.activeEdges != activeEdges ||
//         oldDelegate.selectedNode != selectedNode;
//   }
// }
//
// typedef QuestNodeTap = void Function(QuestLineageNode node);
//
// class QuestLineageTreeView extends StatefulWidget {
//   final QuestLineage lineage;
//
//   /// Taille des ronds (nœuds)
//   final double nodeSize;
//
//   /// Espacement entre niveaux / branches
//   final double levelSeparation;
//   final double siblingSeparation;
//   final double subtreeSeparation;
//
//   /// Callback au tap sur un nœud
//   final QuestNodeTap? onNodeTap;
//
//   /// Si tu veux surligner le node sélectionné
//   final String? selectedNodeId;
//
//   const QuestLineageTreeView({
//     super.key,
//     required this.lineage,
//     this.nodeSize = 64,
//     this.levelSeparation = 90,
//     this.siblingSeparation = 30,
//     this.subtreeSeparation = 160,
//     this.onNodeTap,
//     this.selectedNodeId,
//   });
//
//   @override
//   State<QuestLineageTreeView> createState() => _QuestLineageTreeViewState();
// }
//
// class _QuestLineageTreeViewState extends State<QuestLineageTreeView> {
//   final Graph _graph = Graph()..isTree = true;
//
//   final Map<String, QuestLineageNode> _nodeDataById = {};
//   final Map<String, Node> _graphNodeById = {};
//
//   final Paint _connectorPaint = Paint();
//   late BuchheimWalkerConfiguration _config;
//
//   @override
//   void initState() {
//     super.initState();
//     _config = BuchheimWalkerConfiguration();
//     _rebuildGraph();
//   }
//
//   @override
//   void didUpdateWidget(covariant QuestLineageTreeView oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.lineage != widget.lineage) {
//       _rebuildGraph();
//     }
//   }
//
//   void _rebuildGraph() {
//     _graph.edges.clear();
//     _graph.nodes.clear();
//     _nodeDataById.clear();
//     _graphNodeById.clear();
//
//     // Config layout
//     _config
//       ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT
//       ..levelSeparation = widget.levelSeparation.round()
//       ..siblingSeparation = widget.siblingSeparation.round()
//       ..subtreeSeparation = widget.subtreeSeparation.round();
//
//     // Style des "routes" entre nodes
//     _connectorPaint
//       ..color = const Color(0xFFD9D3CA) // gris beige comme ton wireframe
//       ..strokeWidth = math.max(10, widget.nodeSize * 0.22)
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final root = widget.lineage.main;
//     if (root == null) return;
//
//     // Construire récursivement
//     final rootId = _buildStableId(root, path: "root");
//     _ensureGraphNode(rootId);
//     _buildRec(root, parentId: null, path: "root");
//   }
//
//   void _buildRec(
//     QuestLineageNode node, {
//     required String? parentId,
//     required String path,
//   }) {
//     final id = _buildStableId(node, path: path);
//
//     _nodeDataById[id] = node;
//     final current = _ensureGraphNode(id);
//
//     if (parentId != null) {
//       final parentNode = _graphNodeById[parentId];
//       if (parentNode != null) {
//         _graph.addEdge(parentNode, current);
//       }
//     }
//
//     // Tri children par uiOrder (si dispo)
//     final children = [...node.children];
//     children.sort((a, b) {
//       final ao = a.definition?.uiOrder ?? 0;
//       final bo = b.definition?.uiOrder ?? 0;
//       return ao.compareTo(bo);
//     });
//
//     for (int i = 0; i < children.length; i++) {
//       final child = children[i];
//       final childPath = "$path-$i";
//       final childId = _buildStableId(child, path: childPath);
//       _buildRec(child, parentId: id, path: childPath);
//     }
//   }
//
//   /// ID stable (très important)
//   /// On prend definition.id en priorité, sinon code, sinon path (stable pour cet arbre)
//   String _buildStableId(QuestLineageNode node, {required String path}) {
//     final def = node.definition;
//     return def?.id ?? def?.code ?? path;
//   }
//
//   Node _ensureGraphNode(String id) {
//     return _graphNodeById.putIfAbsent(id, () {
//       final n = Node.Id(id);
//       _graph.addNode(n);
//       return n;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.lineage.main == null) {
//       return const Center(child: Text("Aucune quête"));
//     }
//
//     final algorithm = BuchheimWalkerAlgorithm(
//       _config,
//       TreeEdgeRenderer(_config),
//     );
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final viewportW = constraints.maxWidth;
//         final viewportH = constraints.maxHeight;
//
//         // Canvas : largeur “large” pour pouvoir panner à droite,
//         // hauteur = écran pour centrer verticalement la ligne MAIN.
//         final canvasW = math.max(viewportW, 2000).toDouble();
//         final canvasH = viewportH;
//
//         return InteractiveViewer(
//           constrained: false,
//           boundaryMargin: const EdgeInsets.all(300),
//           minScale: 0.35,
//           maxScale: 2.8,
//           child: SizedBox(
//             width: canvasW,
//             height: canvasH,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 24),
//                 child: GraphView(
//                   graph: _graph,
//                   algorithm: algorithm,
//                   paint: Paint()
//                     ..color = const Color(0xFF9E9AA6)
//                     ..strokeWidth = math.max(10, widget.nodeSize * 0.22)
//                     ..style = PaintingStyle.stroke,
//                   builder: (Node node) {
//                     final id = (node.key?.value ?? "").toString();
//                     final data = _nodeDataById[id];
//
//                     if (data == null) {
//                       return SizedBox(width: widget.nodeSize, height: widget.nodeSize);
//                     }
//
//                     final selected = widget.selectedNodeId != null && widget.selectedNodeId == id;
//
//                     return _QuestNodeView(
//                       node: data,
//                       size: widget.nodeSize,
//                       selected: selected,
//                       onTap: widget.onNodeTap,
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _QuestNodeView extends StatelessWidget {
//   final QuestLineageNode node;
//   final double size;
//   final bool selected;
//   final QuestNodeTap? onTap;
//
//   const _QuestNodeView({
//     required this.node,
//     required this.size,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final state = _computeState(node);
//
//     Color outerBg = const Color(0xFFEDE8E0);
//     Color innerBg;
//     IconData icon;
//     Color iconColor;
//
//     switch (state) {
//       case _QuestVisualState.locked:
//         innerBg = const Color(0xFFBDB7AE);
//         icon = Icons.lock_rounded;
//         iconColor = const Color(0xFF2E2A25);
//         break;
//
//       case _QuestVisualState.claimable:
//         innerBg = const Color(0xFF6D3CF7);
//         icon = Icons.card_giftcard_rounded;
//         iconColor = Colors.white;
//         break;
//
//       case _QuestVisualState.completed:
//         innerBg = const Color(0xFF6D3CF7);
//         icon = Icons.check_rounded;
//         iconColor = Colors.white;
//         break;
//
//       case _QuestVisualState.inProgress:
//         innerBg = const Color(0xFF8F86A0);
//         icon = Icons.play_arrow_rounded;
//         iconColor = Colors.white;
//         break;
//
//       case _QuestVisualState.available:
//         innerBg = const Color(0xFFA29AAE);
//         icon = Icons.flag_rounded;
//         iconColor = Colors.white;
//         break;
//     }
//
//     // petit effet "glow" si claimable / selected
//     final glow = (state == _QuestVisualState.claimable || selected);
//
//     return GestureDetector(
//       onTap: onTap == null ? null : () => onTap!(node),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: outerBg,
//           boxShadow: glow
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.10),
//                     blurRadius: 16,
//                     spreadRadius: 1,
//                   ),
//                 ]
//               : [],
//           border: Border.all(
//             color: selected ? const Color(0xFF6D3CF7) : Colors.transparent,
//             width: selected ? 3 : 0,
//           ),
//         ),
//         child: Center(
//           child: Container(
//             width: size * 0.58,
//             height: size * 0.58,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: innerBg,
//             ),
//             child: Icon(icon, color: iconColor, size: size * 0.30),
//           ),
//         ),
//       ),
//     );
//   }
//
//   _QuestVisualState _computeState(QuestLineageNode n) {
//     // Priorité 1 : locked
//     if (n.locked) return _QuestVisualState.locked;
//
//     // Claimable fourni par ton API
//     if (n.claimable) return _QuestVisualState.claimable;
//
//     // Si instance existe, on essaie d’inférer completed/progress
//     final inst = n.instance;
//     final def = n.definition;
//
//     final progress = inst?.progressCount ?? 0;
//     final target = def?.targetCount ?? 0;
//
//     // completed si claimedAt existe
//     if (inst?.claimedAt != null) return _QuestVisualState.completed;
//
//     // si target connu et progress >= target => on le considère complété (mais non claim)
//     if (target > 0 && progress >= target) return _QuestVisualState.claimable;
//
//     if (progress > 0) return _QuestVisualState.inProgress;
//
//     return _QuestVisualState.available;
//   }
// }
//
// enum _QuestVisualState {
//   locked,
//   available,
//   inProgress,
//   completed,
//   claimable,
// }
