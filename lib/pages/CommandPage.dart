// import 'package:flutter/material.dart';

// class MyHomePage extends StatelessWidget {
//   final GlobalKey<_MyDraggableWidgetState> _draggedWidgetKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Drag and Drop Example'),
//       ),
//       body: Center(
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.7,
//           child: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: () => showModalBottomSheet(
//                   context: context,
//                   builder: (context) => DraggableWidgetContainer(
//                     key: _draggedWidgetKey,
//                     child: Container(
//                       // alignment: Alignment.center,
//                       child: const Text('Drag me'),
//                     ),
//                   ),
//                   isScrollControlled: true,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(10.0),
//                     ),
//                   ),
//                 ),
//                 child: const Text("open"),
//               ),
//               Listener(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     print(_draggedWidgetKey.currentState);
//                     if (_draggedWidgetKey.currentState != null) {
//                       return _draggedWidgetKey.currentWidget;
//                     }

//                     return Text("No children");
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DraggableWidgetContainer extends StatefulWidget {
//   final Widget child;

//   DraggableWidgetContainer({Key? key, required this.child}) : super(key: key);

//   @override
//   _MyDraggableWidgetState createState() => _MyDraggableWidgetState();
// }

// class _MyDraggableWidgetState extends State<DraggableWidgetContainer> {
//   Offset _offset = Offset.zero;

//   void resetPosition() {
//     setState(() {
//       _offset = Offset.zero;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           child: Draggable(
//             feedback: Container(
//               width: 100,
//               height: 100,
//               color: Colors.blue,
//               child: Opacity(
//                 opacity: 0.5,
//                 child: widget.child,
//               ),
//             ),
//             onDraggableCanceled: (_, __) {
//               // Reset the position of the dragged widget when it is dropped outside of the modal
//               resetPosition();
//             },
//             onDragEnd: (details) {
//               setState(() {
//                 _offset = _offset + details.offset;
//               });
//               print(widget.key!);
//             },
//             child: widget.child,
//           ),
//         ),
//       ],
//     );
//   }
// }
