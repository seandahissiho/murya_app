part of '../profile.dart';

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
        return QuestLineageTreeView(lineage: state.questLineage);
      },
    );
  }
}

typedef QuestNodeTap = void Function(QuestLineageNode node);

class QuestLineageTreeView extends StatefulWidget {
  final QuestLineage lineage;

  /// Taille des ronds (nœuds)
  final double nodeSize;

  /// Espacement entre niveaux / branches
  final double levelSeparation;
  final double siblingSeparation;
  final double subtreeSeparation;

  /// Callback au tap sur un nœud
  final QuestNodeTap? onNodeTap;

  /// Si tu veux surligner le node sélectionné
  final String? selectedNodeId;

  const QuestLineageTreeView({
    super.key,
    required this.lineage,
    this.nodeSize = 64,
    this.levelSeparation = 90,
    this.siblingSeparation = 30,
    this.subtreeSeparation = 60,
    this.onNodeTap,
    this.selectedNodeId,
  });

  @override
  State<QuestLineageTreeView> createState() => _QuestLineageTreeViewState();
}

class _QuestLineageTreeViewState extends State<QuestLineageTreeView> {
  final Graph _graph = Graph()..isTree = true;

  final Map<String, QuestLineageNode> _nodeDataById = {};
  final Map<String, Node> _graphNodeById = {};

  final Paint _connectorPaint = Paint();
  late BuchheimWalkerConfiguration _config;

  @override
  void initState() {
    super.initState();
    _config = BuchheimWalkerConfiguration();
    _rebuildGraph();
  }

  @override
  void didUpdateWidget(covariant QuestLineageTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lineage != widget.lineage) {
      _rebuildGraph();
    }
  }

  void _rebuildGraph() {
    _graph.edges.clear();
    _graph.nodes.clear();
    _nodeDataById.clear();
    _graphNodeById.clear();

    // Config layout
    _config
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT
      ..levelSeparation = widget.levelSeparation.round()
      ..siblingSeparation = widget.siblingSeparation.round()
      ..subtreeSeparation = widget.subtreeSeparation.round();

    // Style des "routes" entre nodes
    _connectorPaint
      ..color = const Color(0xFFD9D3CA) // gris beige comme ton wireframe
      ..strokeWidth = math.max(10, widget.nodeSize * 0.22)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final root = widget.lineage.main;
    if (root == null) return;

    // Construire récursivement
    final rootId = _buildStableId(root, path: "root");
    _ensureGraphNode(rootId);
    _buildRec(root, parentId: null, path: "root");
  }

  void _buildRec(
    QuestLineageNode node, {
    required String? parentId,
    required String path,
  }) {
    final id = _buildStableId(node, path: path);

    _nodeDataById[id] = node;
    final current = _ensureGraphNode(id);

    if (parentId != null) {
      final parentNode = _graphNodeById[parentId];
      if (parentNode != null) {
        _graph.addEdge(parentNode, current);
      }
    }

    // Tri children par uiOrder (si dispo)
    final children = [...node.children];
    children.sort((a, b) {
      final ao = a.definition?.uiOrder ?? 0;
      final bo = b.definition?.uiOrder ?? 0;
      return ao.compareTo(bo);
    });

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final childPath = "$path-$i";
      final childId = _buildStableId(child, path: childPath);
      _buildRec(child, parentId: id, path: childPath);
    }
  }

  /// ID stable (très important)
  /// On prend definition.id en priorité, sinon code, sinon path (stable pour cet arbre)
  String _buildStableId(QuestLineageNode node, {required String path}) {
    final def = node.definition;
    return def?.id ?? def?.code ?? path;
  }

  Node _ensureGraphNode(String id) {
    return _graphNodeById.putIfAbsent(id, () {
      final n = Node.Id(id);
      _graph.addNode(n);
      return n;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lineage.main == null) {
      return const Center(child: Text("Aucune quête"));
    }

    final algorithm = BuchheimWalkerAlgorithm(
      _config,
      TreeEdgeRenderer(_config),
    );

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(300),
      minScale: 0.35,
      maxScale: 2.8,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GraphView(
          graph: _graph,
          algorithm: algorithm,
          paint: _connectorPaint,
          builder: (Node node) {
            final id = (node.key?.value ?? "").toString();
            final data = _nodeDataById[id];

            if (data == null) {
              return SizedBox(width: widget.nodeSize, height: widget.nodeSize);
            }

            final selected = widget.selectedNodeId != null && widget.selectedNodeId == id;

            return _QuestNodeView(
              node: data,
              size: widget.nodeSize,
              selected: selected,
              onTap: widget.onNodeTap,
            );
          },
        ),
      ),
    );
  }
}

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

    Color outerBg = const Color(0xFFEDE8E0);
    Color innerBg;
    IconData icon;
    Color iconColor;

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

    // petit effet "glow" si claimable / selected
    final glow = (state == _QuestVisualState.claimable || selected);

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(node),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: outerBg,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
          border: Border.all(
            color: selected ? const Color(0xFF6D3CF7) : Colors.transparent,
            width: selected ? 3 : 0,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.58,
            height: size * 0.58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerBg,
            ),
            child: Icon(icon, color: iconColor, size: size * 0.30),
          ),
        ),
      ),
    );
  }

  _QuestVisualState _computeState(QuestLineageNode n) {
    // Priorité 1 : locked
    if (n.locked) return _QuestVisualState.locked;

    // Claimable fourni par ton API
    if (n.claimable) return _QuestVisualState.claimable;

    // Si instance existe, on essaie d’inférer completed/progress
    final inst = n.instance;
    final def = n.definition;

    final progress = inst?.progressCount ?? 0;
    final target = def?.targetCount ?? 0;

    // completed si claimedAt existe
    if (inst?.claimedAt != null) return _QuestVisualState.completed;

    // si target connu et progress >= target => on le considère complété (mais non claim)
    if (target > 0 && progress >= target) return _QuestVisualState.claimable;

    if (progress > 0) return _QuestVisualState.inProgress;

    return _QuestVisualState.available;
  }
}

enum _QuestVisualState {
  locked,
  available,
  inProgress,
  completed,
  claimable,
}
