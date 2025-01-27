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
        backgroundColor: Colors.black12,
        body: Center(
          child: IconSelectionBar(
            items: [
              StyledIcon(icon: Icons.person, color: Colors.blue, backgroundColor: Colors.blue.shade100),
              StyledIcon(icon: Icons.message, color: Colors.green, backgroundColor: Colors.green.shade100),
              StyledIcon(icon: Icons.call, color: Colors.red, backgroundColor: Colors.red.shade100),
              StyledIcon(icon: Icons.camera, color: Colors.purple, backgroundColor: Colors.purple.shade100),
              StyledIcon(icon: Icons.photo, color: Colors.orange, backgroundColor: Colors.orange.shade100),
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
  final String? label;

  const StyledIcon({
    required this.icon,
    this.color = Colors.black,
    this.backgroundColor,
    this.size = 48,
    this.label,
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

class _IconSelectionBarState extends State<IconSelectionBar> with SingleTickerProviderStateMixin {
  late List<StyledIcon> _items;
  double? _mouseX;
  bool _isDragging = false;
  late AnimationController _spreadAnimationController;
  Offset? _dragOffset;
  String? _hoveredLabel;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _spreadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _spreadAnimationController.dispose();
    super.dispose();
  }

  double _calculateScale(double distance, double maxDistance) {
    if (distance >= maxDistance) return 1.0;
    final double normalized = (maxDistance - distance) / maxDistance;
    return 1.0 + (normalized * normalized * 0.5); // Parabolic scaling
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MouseRegion(
          onHover: (event) {
            setState(() {
              _mouseX = event.localPosition.dx;
            });
          },
          onExit: (event) {
            setState(() {
              _mouseX = null;
              _hoveredLabel = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: -5,
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedBuilder(
              animation: _spreadAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildDraggableIcons(),
                );
              },
            ),
          ),
        ),
        if (_hoveredLabel != null)
          Positioned(
            top: -30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _hoveredLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDraggableIcons() {
    final List<Widget> icons = [];
    final itemWidth = 64.0;

    for (int i = 0; i < _items.length; i++) {
      final styledIcon = _items[i];

      double spreadOffset = 0.0;
      if (_dragOffset != null && _isDragging) {
        final iconCenter = i * itemWidth;
        final dragCenter = _dragOffset!.dx;
        final distance = (iconCenter - dragCenter).abs();
        final maxDistance = itemWidth * 3;

        if (distance < maxDistance) {
          final spreadFactor = 1 - (distance / maxDistance);
          spreadOffset = (iconCenter < dragCenter ? -1 : 1) * spreadFactor * 40 * _spreadAnimationController.value;
        }
      }

      icons.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(spreadOffset, 0, 0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredLabel = styledIcon.label ?? ''),
            onExit: (_) => setState(() => _hoveredLabel = null),
            child: Draggable<StyledIcon>(
              data: styledIcon,
              feedback: _buildIconWidget(styledIcon, index: i, isDragging: true),
              childWhenDragging: _buildIconWidget(styledIcon, index: i, isPlaceholder: true),
              onDragStarted: () {
                setState(() {
                  _isDragging = true;
                });
                _spreadAnimationController.forward();
              },
              onDragEnd: (_) {
                setState(() {
                  _isDragging = false;
                  _dragOffset = null;
                });
                _spreadAnimationController.reverse();
              },
              onDragUpdate: (details) {
                setState(() {
                  _dragOffset = details.localPosition;
                });
              },
              child: DragTarget<StyledIcon>(
                builder: (context, candidateData, rejectedData) {
                  return _buildIconWidget(styledIcon, index: i);
                },
                onAccept: (draggedIcon) => _reorderIcons(draggedIcon, styledIcon),
              ),
            ),
          ),
        ),
      );
    }
    return icons;
  }

  Widget _buildIconWidget(StyledIcon styledIcon, {required int index, bool isDragging = false, bool isPlaceholder = false}) {
    double scale = 1.0;
    if (_mouseX != null && !_isDragging) {
      final itemWidth = styledIcon.size + 16;
      final centerPosition = (index * itemWidth) + (itemWidth / 2);
      final distance = (_mouseX! - centerPosition).abs();
      scale = _calculateScale(distance, itemWidth * 2);
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: scale),
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4 * value),
          decoration: BoxDecoration(
            color: isDragging
                ? styledIcon.color.withValues(alpha: 0.3)
                : isPlaceholder
                    ? Colors.grey.shade300
                    : styledIcon.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: value,
            child: IconButton(
              icon: Stack(
                children: [
                  Icon(
                    styledIcon.icon,
                    color: isDragging ? styledIcon.color.withValues(alpha: 0.5) : styledIcon.color,
                    size: styledIcon.size,
                  ),
                  if (!isDragging && !isPlaceholder)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: styledIcon.size / 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {},
            ),
          ),
        );
      },
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
