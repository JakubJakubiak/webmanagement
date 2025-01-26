import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: IconSelectionBar(
            items: [
              StyledIcon(
                icon: Icons.person, 
                color: Colors.blue, 
                backgroundColor: Colors.blue.shade100
              ),
              StyledIcon(
                icon: Icons.message, 
                color: Colors.green, 
                backgroundColor: Colors.green.shade100
              ),
              StyledIcon(
                icon: Icons.call, 
                color: Colors.red, 
                backgroundColor: Colors.red.shade100
              ),
              StyledIcon(
                icon: Icons.camera, 
                color: Colors.purple, 
                backgroundColor: Colors.purple.shade100
              ),
              StyledIcon(
                icon: Icons.photo, 
                color: Colors.orange, 
                backgroundColor: Colors.orange.shade100
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledIcon {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  
  const StyledIcon({
    required this.icon, 
    this.color = Colors.black, 
    this.backgroundColor,
    this.size = 48
  });
}

class IconSelectionBar extends StatefulWidget {
  const IconSelectionBar({
    super.key,
    required this.items,
  });
  
  final List<StyledIcon> items;
  
  @override
  State<IconSelectionBar> createState() => _IconSelectionBarState();
}

class _IconSelectionBarState extends State<IconSelectionBar> {
  late List<StyledIcon> _items;
  
  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildDraggableIcons(),
      ),
    );
  }
  
  List<Widget> _buildDraggableIcons() {
    return _items.map((styledIcon) {
      return Draggable<StyledIcon>(
        data: styledIcon,
        feedback: _buildIconWidget(styledIcon, isDragging: true),
        childWhenDragging: _buildIconWidget(styledIcon, isPlaceholder: true),
        child: DragTarget<StyledIcon>(
          builder: (context, candidateData, rejectedData) {
            return _buildIconWidget(styledIcon);
          },
          onAccept: (draggedIcon) => _reorderIcons(draggedIcon, styledIcon),
        ),
      );
    }).toList();
  }
  
  Widget _buildIconWidget(StyledIcon styledIcon, {
    bool isDragging = false, 
    bool isPlaceholder = false
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDragging 
          ? styledIcon.color.withOpacity(0.3)
          : isPlaceholder 
            ? Colors.grey.shade300 
            : styledIcon.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          styledIcon.icon, 
          color: isDragging ? styledIcon.color.withOpacity(0.5) : styledIcon.color,
          size: styledIcon.size,
        ),
        onPressed: () {},
      ),
    );
  }
  
  void _reorderIcons(StyledIcon draggedIcon, StyledIcon targetIcon) {
    setState(() {
      final dragIndex = _items.indexOf(draggedIcon);
      final targetIndex = _items.indexOf(targetIcon);
      if (dragIndex != targetIndex) {
        _items.removeAt(dragIndex);
        _items.insert(targetIndex, draggedIcon);
      }
    });
  }
}