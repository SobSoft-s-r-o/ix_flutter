import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

/// A pagination bar widget that adheres to Siemens IX design guidelines.
class IxPaginationBar extends StatelessWidget {
  const IxPaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
    this.totalItems,
    this.pageSize,
    this.onPageSizeChanged,
    this.pageSizeOptions,
  });

  final int page;
  final int? totalPages;
  final int? totalItems;
  final int? pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int>? pageSizeOptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final stdText = theme?.color(IxThemeColorToken.stdText) ?? Colors.black;
    final weakText = theme?.color(IxThemeColorToken.weakText) ?? Colors.grey;

    final canGoBack = page > 1;
    final canGoForward = totalPages == null || page < totalPages!;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme?.color(IxThemeColorToken.color4) ?? Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: [
          if (totalItems != null)
            Text(
              '$totalItems items',
              style: theme?.textStyle(
                IxTypographyVariant.label,
                tone: IxThemeTextTone.soft,
              ),
            ),
          const Spacer(),
          if (pageSizeOptions != null &&
              onPageSizeChanged != null &&
              pageSize != null) ...[
            Text(
              'Items per page:',
              style: theme?.textStyle(
                IxTypographyVariant.label,
                tone: IxThemeTextTone.soft,
              ),
            ),
            const SizedBox(width: 8),
            IxDropdownButton<int>(
              label: pageSize.toString(),
              variant: IxDropdownButtonVariant.subtleTertiary,
              items: pageSizeOptions!
                  .map(
                    (size) => IxDropdownMenuItem<int>(
                      label: size.toString(),
                      value: size,
                    ),
                  )
                  .toList(),
              onItemSelected: onPageSizeChanged,
            ),
            const SizedBox(width: 24),
          ],
          Text(
            totalPages != null ? 'Page $page of $totalPages' : 'Page $page',
            style: theme?.textStyle(IxTypographyVariant.label),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: IxIcons.chevronLeft,
            onPressed: canGoBack ? () => onPageChanged(page - 1) : null,
            color: canGoBack ? stdText : weakText,
            tooltip: 'Previous page',
          ),
          IconButton(
            icon: IxIcons.chevronRight,
            onPressed: canGoForward ? () => onPageChanged(page + 1) : null,
            color: canGoForward ? stdText : weakText,
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}
