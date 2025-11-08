// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//
// class GridTileItem {
//   final String? id;
//   int spanX;
//   int spanY;
//   int orderIndex;
//   GridTileItem({required this.id, this.spanX = 1, this.spanY = 1, required this.orderIndex});
// }
//
// class ResizableReorderableStaggeredGrid extends StatefulWidget {
//   const ResizableReorderableStaggeredGrid({super.key});
//
//   @override
//   _ResizableReorderableStaggeredGridState createState() => _ResizableReorderableStaggeredGridState();
// }
//
// class _ResizableReorderableStaggeredGridState extends State<ResizableReorderableStaggeredGrid> {
//   List<GridTileItem> items = List.generate(8, (i) => GridTileItem(id: 'Tile $i', orderIndex: i));
//
//   @override
//   Widget build(BuildContext context) {
//     int crossAxis = MediaQuery.of(context).size.width > 1200
//         ? 6
//         : MediaQuery.of(context).size.width > 800
//             ? 4
//             : 2;
//     double spacing = 8;
//     double totalWidth = MediaQuery.of(context).size.width - (crossAxis - 1) * spacing;
//     double cellWidth = totalWidth / crossAxis;
//     double cellHeight = cellWidth; // or you define differently
//
//     items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Resizable & Reorderable Grid')),
//       body: StaggeredGridView.countBuilder(
//         crossAxisCount: crossAxis,
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           final tile = items[index];
//           return _buildTileWidget(tile, cellWidth, cellHeight);
//         },
//         staggeredTileBuilder: (index) {
//           final tile = items[index];
//           return StaggeredTile.count(tile.spanX, tile.spanY);
//         },
//         mainAxisSpacing: spacing,
//         crossAxisSpacing: spacing,
//       ),
//     );
//   }
//
//   Widget _buildTileWidget(GridTileItem tile, double cellW, double cellH) {
//     return GestureDetector(
//       onLongPress: () {
//         // start drag logic here → update tile.orderIndex on drop
//       },
//       child: Container(
//         key: ValueKey(tile.id),
//         color: Colors.blueAccent,
//         child: Stack(
//           children: [
//             Center(child: Text('${tile.id}\n${tile.spanX}×${tile.spanY}', textAlign: TextAlign.center)),
//             Positioned(
//               right: 4,
//               bottom: 4,
//               child: GestureDetector(
//                 onPanUpdate: (details) {
//                   setState(() {
//                     // simple resizing logic
//                     double w = tile.spanX * cellW + details.delta.dx;
//                     double h = tile.spanY * cellH + details.delta.dy;
//                     tile.spanX = (w / cellW).ceil().clamp(1, crossAxis);
//                     tile.spanY = (h / cellH).ceil().clamp(1, crossAxis);
//                   });
//                 },
//                 child: Icon(Icons.drag_handle, size: 20, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
