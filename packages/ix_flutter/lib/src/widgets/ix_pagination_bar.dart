import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// A pagination bar widget that adheres to Siemens IX design guidelines.
///
/// Lays its controls out with [Wrap] instead of a plain [Row], so a narrow
/// viewport or a large text scale wraps the page-size selector and the
/// prev/next controls onto their own line instead of overflowing (WCAG
/// 1.4.4 Resize text). The bar never shrinks below a 56px minimum height.
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
    this.strings,
    this.paginationStrings,
  });

  /// The current 1-based page number.
  final int page;

  /// Total number of pages, or `null` when unknown.
  final int? totalPages;

  /// Total number of items across all pages, shown when set.
  final int? totalItems;

  /// The current page size, shown by the page-size selector when set.
  final int? pageSize;

  /// Called with the newly requested page.
  final ValueChanged<int> onPageChanged;

  /// Called with the newly selected page size. The page-size selector is
  /// only shown when this, [pageSizeOptions] and [pageSize] are all set.
  final ValueChanged<int>? onPageSizeChanged;

  /// The page-size choices offered by the selector.
  final List<int>? pageSizeOptions;

  /// Legacy string source, kept for 1.x callers that never migrated to
  /// [paginationStrings].
  ///
  /// Ignored when [paginationStrings] is set; otherwise bridged through
  /// [IxPaginationStrings.fromDataView].
  final IxResponsiveDataViewStrings? strings;

  /// Localizable strings for this bar, taking precedence over [strings].
  final IxPaginationStrings? paginationStrings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final cs = Theme.of(context).colorScheme;
    final s =
        paginationStrings ??
        IxPaginationStrings.fromDataView(
          strings ?? IxResponsiveDataViewStrings.defaultsEn(),
        );
    final label = theme?.textStyle(IxTypographyVariant.label);
    final softLabel = theme?.textStyle(
      IxTypographyVariant.label,
      tone: IxThemeTextTone.soft,
    );

    final canGoBack = page > 1;
    final canGoForward = totalPages == null || page < totalPages!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color:
                  theme?.color(IxThemeColorToken.softBdr) ?? cs.outlineVariant,
            ),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            if (totalItems != null)
              Text(s.totalItems(totalItems!), style: softLabel),
            if (pageSizeOptions != null &&
                onPageSizeChanged != null &&
                pageSize != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      s.rowsPerPage,
                      style: softLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // `IxDropdownButton`'s trigger sits behind an
                  // `OverlayPortal` (for the menu overlay), which always
                  // introduces its own semantics boundary at the trigger's
                  // position -- so a plain ancestor `Semantics` merges its
                  // `value` onto a *shallow* node next to, not into, the
                  // trigger's own button/label node. `MergeSemantics`
                  // forces both back into the one node `ix-pagination-size`
                  // is queried through.
                  MergeSemantics(
                    child: Semantics(
                      value: '$pageSize',
                      child: IxDropdownButton<int>(
                        key: const Key('ix-pagination-size'),
                        label: '$pageSize',
                        semanticLabel: s.pageSelection,
                        buttonVariant: IxButtonVariant.subtleTertiary,
                        items: [
                          for (final o in pageSizeOptions!)
                            IxDropdownMenuItem(
                              label: '$o',
                              value: o,
                              checked: o == pageSize,
                            ),
                        ],
                        onItemSelected: onPageSizeChanged,
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    totalPages != null
                        ? s.pageOf(page, totalPages!)
                        : s.page(page),
                    style: label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                IxIconButton(
                  key: const Key('ix-pagination-prev'),
                  icon: const IxIcon.key(IxIconKey.chevronLeftSmall),
                  tooltip: s.previousPage,
                  onPressed: canGoBack ? () => onPageChanged(page - 1) : null,
                ),
                IxIconButton(
                  key: const Key('ix-pagination-next'),
                  icon: const IxIcon.key(IxIconKey.chevronRightSmall),
                  tooltip: s.nextPage,
                  onPressed: canGoForward
                      ? () => onPageChanged(page + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
