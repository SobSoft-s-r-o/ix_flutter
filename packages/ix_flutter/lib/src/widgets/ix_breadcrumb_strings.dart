/// Localizable strings for [IxBreadcrumb]'s accessible names.
///
/// Mirrors the upstream Siemens iX web component's hard-coded English copy:
/// `breadcrumb.tsx:161-165` (`role="navigation" aria-label="Breadcrumbs"`),
/// the overflow trigger's accessible name ("Show previous breadcrumb
/// items", `breadcrumb.ct.ts:141-180`) and the current page's
/// `aria-current="page"` state (`breadcrumb-item.tsx:129`) -- surfaced to
/// Flutter as an accessibility hint on the last, non-interactive crumb
/// since there is no dedicated "current page" semantics flag.
class IxBreadcrumbStrings {
  /// Creates a set of breadcrumb strings, defaulting to the upstream
  /// English copy.
  const IxBreadcrumbStrings({
    this.breadcrumbs = 'Breadcrumbs',
    this.previousItems = 'Show previous breadcrumb items',
    this.currentPage = 'current page',
  });

  /// Accessible name of the root `navigation` landmark.
  ///
  /// Overridden per instance by [IxBreadcrumb.semanticLabel] when set.
  final String breadcrumbs;

  /// Accessible name of the home trigger while it also reveals collapsed
  /// (overflowed) items, replacing the item's own label for that state.
  final String previousItems;

  /// Accessibility hint attached to the last, non-interactive crumb.
  final String currentPage;
}
