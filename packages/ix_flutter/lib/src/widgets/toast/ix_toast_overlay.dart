import 'package:flutter/material.dart';
import 'ix_toast_data.dart';
import 'ix_toast_service.dart';
import 'ix_toast.dart';

/// Overlay widget that renders the stack of active toasts.
class IxToastOverlay extends StatefulWidget {
  const IxToastOverlay({
    super.key,
    required this.service,
    this.position = Alignment.topRight,
  });

  final IxToastService service;
  final Alignment position;

  @override
  State<IxToastOverlay> createState() => _IxToastOverlayState();
}

class _IxToastOverlayState extends State<IxToastOverlay> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<IxToastData> _displayedToasts = [];

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    _displayedToasts.addAll(widget.service.toasts);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    final newToasts = widget.service.toasts;

    // Find items to remove
    for (var i = _displayedToasts.length - 1; i >= 0; i--) {
      final toast = _displayedToasts[i];
      if (!newToasts.contains(toast)) {
        final removedItem = _displayedToasts.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildItem(removedItem, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Find items to add
    for (var i = 0; i < newToasts.length; i++) {
      final toast = newToasts[i];
      if (!_displayedToasts.contains(toast)) {
        _displayedToasts.insert(i, toast);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  Widget _buildItem(IxToastData toast, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0), // Slide from right
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: IxToast(
            data: toast,
            onDismiss: () => widget.service.dismiss(toast.id),
            onEnter: () => widget.service.pauseTimer(toast.id),
            onExit: () => widget.service.resumeTimer(toast.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position.y == -1.0 ? 16 : null,
      bottom: widget.position.y == 1.0 ? 16 : null,
      left: widget.position.x == -1.0 ? 16 : null,
      right: widget.position.x == 1.0 ? 16 : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360, // Slightly wider than toast to allow padding
          maxHeight: MediaQuery.of(
            context,
          ).size.height, // Limit height to screen
        ),
        child: AnimatedList(
          shrinkWrap: true,
          key: _listKey,
          initialItemCount: _displayedToasts.length,
          itemBuilder: (context, index, animation) {
            if (index >= _displayedToasts.length) {
              return const SizedBox.shrink();
            }
            return _buildItem(_displayedToasts[index], animation);
          },
        ),
      ),
    );
  }
}
