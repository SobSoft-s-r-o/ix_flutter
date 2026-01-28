import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';

enum IxDropdownButtonVariant {
  primary,
  secondary,
  tertiary,
  subtlePrimary,
  subtleSecondary,
  subtleTertiary,
  danger,
  subtleDanger,
}

enum IxDropdownPlacement {
  bottomStart,
  bottomEnd,
  topStart,
  topEnd,
  leftStart,
  leftEnd,
  rightStart,
  rightEnd,
}

class IxDropdownMenuItem<T> {
  final String label;
  final T value;
  final Widget? icon;
  final bool disabled;

  const IxDropdownMenuItem({
    required this.label,
    required this.value,
    this.icon,
    this.disabled = false,
  });
}

class IxDropdownButton<T> extends StatefulWidget {
  const IxDropdownButton({
    super.key,
    required this.label,
    required this.items,
    this.variant = IxDropdownButtonVariant.primary,
    this.placement = IxDropdownPlacement.bottomStart,
    this.disabled = false,
    this.icon,
    this.onItemSelected,
  });

  final String label;
  final List<IxDropdownMenuItem<T>> items;
  final IxDropdownButtonVariant variant;
  final IxDropdownPlacement placement;
  final bool disabled;
  final Widget? icon;
  final ValueChanged<T>? onItemSelected;

  @override
  State<IxDropdownButton<T>> createState() => _IxDropdownButtonState<T>();
}

class _IxDropdownMenuContent extends StatefulWidget {
  final Widget child;

  const _IxDropdownMenuContent({required this.child});

  @override
  State<_IxDropdownMenuContent> createState() => _IxDropdownMenuContentState();
}

class _IxDropdownMenuContentState extends State<_IxDropdownMenuContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _IxDropdownButtonState<T> extends State<IxDropdownButton<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final FocusNode _buttonFocusNode = FocusNode();
  final Object _tapRegionGroupId = Object();

  @override
  void dispose() {
    _removeOverlay();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (widget.disabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _removeOverlay();
    setState(() {
      _isOpen = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    Alignment followerAnchor = Alignment.topLeft;
    Alignment targetAnchor = Alignment.bottomLeft;
    Offset offset = Offset.zero;

    // Calculate available space and flip if necessary
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final paddingBottom = mediaQuery.padding.bottom;
    final paddingTop = mediaQuery.padding.top;
    final paddingLeft = mediaQuery.padding.left;
    final paddingRight = mediaQuery.padding.right;

    // Estimate dropdown height
    // ~48px per item (12+12 padding + ~24 text/icon) + 2px border
    const double estimatedItemHeight = 48.0;
    final double estimatedDropdownHeight =
        widget.items.length * estimatedItemHeight + 8.0;
    const double estimatedDropdownWidth = 200.0; // Fixed width for now

    IxDropdownPlacement effectivePlacement = widget.placement;

    bool isBottom =
        widget.placement == IxDropdownPlacement.bottomStart ||
        widget.placement == IxDropdownPlacement.bottomEnd;
    bool isTop =
        widget.placement == IxDropdownPlacement.topStart ||
        widget.placement == IxDropdownPlacement.topEnd;
    bool isLeft =
        widget.placement == IxDropdownPlacement.leftStart ||
        widget.placement == IxDropdownPlacement.leftEnd;
    bool isRight =
        widget.placement == IxDropdownPlacement.rightStart ||
        widget.placement == IxDropdownPlacement.rightEnd;

    if (isBottom) {
      final double bottomSpace =
          screenHeight - (buttonPosition.dy + size.height) - paddingBottom;
      if (bottomSpace < estimatedDropdownHeight) {
        final double topSpace = buttonPosition.dy - paddingTop;
        if (topSpace > bottomSpace) {
          if (widget.placement == IxDropdownPlacement.bottomStart) {
            effectivePlacement = IxDropdownPlacement.topStart;
          } else {
            effectivePlacement = IxDropdownPlacement.topEnd;
          }
        }
      }
    } else if (isTop) {
      final double topSpace = buttonPosition.dy - paddingTop;
      if (topSpace < estimatedDropdownHeight) {
        final double bottomSpace =
            screenHeight - (buttonPosition.dy + size.height) - paddingBottom;
        if (bottomSpace > topSpace) {
          if (widget.placement == IxDropdownPlacement.topStart) {
            effectivePlacement = IxDropdownPlacement.bottomStart;
          } else {
            effectivePlacement = IxDropdownPlacement.bottomEnd;
          }
        }
      }
    } else if (isLeft) {
      final double leftSpace = buttonPosition.dx - paddingLeft;
      if (leftSpace < estimatedDropdownWidth) {
        final double rightSpace =
            screenWidth - (buttonPosition.dx + size.width) - paddingRight;
        if (rightSpace > leftSpace) {
          if (widget.placement == IxDropdownPlacement.leftStart) {
            effectivePlacement = IxDropdownPlacement.rightStart;
          } else {
            effectivePlacement = IxDropdownPlacement.rightEnd;
          }
        }
      }
    } else if (isRight) {
      final double rightSpace =
          screenWidth - (buttonPosition.dx + size.width) - paddingRight;
      if (rightSpace < estimatedDropdownWidth) {
        final double leftSpace = buttonPosition.dx - paddingLeft;
        if (leftSpace > rightSpace) {
          if (widget.placement == IxDropdownPlacement.rightStart) {
            effectivePlacement = IxDropdownPlacement.leftStart;
          } else {
            effectivePlacement = IxDropdownPlacement.leftEnd;
          }
        }
      }
    }

    switch (effectivePlacement) {
      case IxDropdownPlacement.bottomStart:
        targetAnchor = Alignment.bottomLeft;
        followerAnchor = Alignment.topLeft;
        offset = const Offset(0, 4);
        break;
      case IxDropdownPlacement.bottomEnd:
        targetAnchor = Alignment.bottomRight;
        followerAnchor = Alignment.topRight;
        offset = const Offset(0, 4);
        break;
      case IxDropdownPlacement.topStart:
        targetAnchor = Alignment.topLeft;
        followerAnchor = Alignment.bottomLeft;
        offset = const Offset(0, -4);
        break;
      case IxDropdownPlacement.topEnd:
        targetAnchor = Alignment.topRight;
        followerAnchor = Alignment.bottomRight;
        offset = const Offset(0, -4);
        break;
      case IxDropdownPlacement.leftStart:
        targetAnchor = Alignment.topLeft;
        followerAnchor = Alignment.topRight;
        offset = const Offset(-4, 0);
        break;
      case IxDropdownPlacement.leftEnd:
        targetAnchor = Alignment.bottomLeft;
        followerAnchor = Alignment.bottomRight;
        offset = const Offset(-4, 0);
        break;
      case IxDropdownPlacement.rightStart:
        targetAnchor = Alignment.topRight;
        followerAnchor = Alignment.topLeft;
        offset = const Offset(4, 0);
        break;
      case IxDropdownPlacement.rightEnd:
        targetAnchor = Alignment.bottomRight;
        followerAnchor = Alignment.bottomLeft;
        offset = const Offset(4, 0);
        break;
    }

    final ixTheme = Theme.of(context).extension<IxTheme>();
    final backgroundColor =
        ixTheme?.color(IxThemeColorToken.color2) ?? Colors.white;
    final borderColor =
        ixTheme?.color(IxThemeColorToken.softBdr) ?? Colors.grey;
    final shadowColor =
        ixTheme?.color(IxThemeColorToken.shadow2) ?? Colors.black12;
    final textColor = ixTheme?.color(IxThemeColorToken.stdText) ?? Colors.black;
    final hoverColor =
        ixTheme?.color(IxThemeColorToken.component1Hover) ?? Colors.grey[200];

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 200, // TODO: Dynamic width or min width
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          offset: offset,
          child: TapRegion(
            groupId: _tapRegionGroupId,
            child: _IxDropdownMenuContent(
              child: Material(
                elevation: 4,
                color: backgroundColor,
                shadowColor: shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // IxCommonGeometry.smallBorderRadius
                  side: BorderSide(color: borderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.items.map((item) {
                    return InkWell(
                      onTap: item.disabled
                          ? null
                          : () {
                              _closeDropdown();
                              widget.onItemSelected?.call(item.value);
                            },
                      hoverColor: hoverColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              item.icon!,
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: item.disabled
                                      ? textColor.withValues(
                                          alpha: textColor.a * 0.5,
                                        )
                                      : textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IxButtonVariant _mapVariant(IxDropdownButtonVariant variant) {
    switch (variant) {
      case IxDropdownButtonVariant.primary:
        return IxButtonVariant.primary;
      case IxDropdownButtonVariant.secondary:
        return IxButtonVariant.secondary;
      case IxDropdownButtonVariant.tertiary:
        return IxButtonVariant.tertiary;
      case IxDropdownButtonVariant.subtlePrimary:
        return IxButtonVariant.subtlePrimary;
      case IxDropdownButtonVariant.subtleSecondary:
        return IxButtonVariant.subtleSecondary;
      case IxDropdownButtonVariant.subtleTertiary:
        return IxButtonVariant.subtleTertiary;
      case IxDropdownButtonVariant.danger:
        return IxButtonVariant.dangerPrimary;
      case IxDropdownButtonVariant.subtleDanger:
        return IxButtonVariant.dangerTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ixButtonTheme = Theme.of(context).extension<IxButtonTheme>();
    final buttonStyle = ixButtonTheme?.style(_mapVariant(widget.variant));

    return TapRegion(
      groupId: _tapRegionGroupId,
      onTapOutside: (event) {
        if (_isOpen) {
          _closeDropdown();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: ElevatedButton(
          onPressed: widget.disabled ? null : _toggleDropdown,
          style: buttonStyle,
          focusNode: _buttonFocusNode,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(widget.label),
              const SizedBox(width: 8),
              _isOpen ? IxIcons.chevronUpSmall : IxIcons.chevronDownSmall,
            ],
          ),
        ),
      ),
    );
  }
}
