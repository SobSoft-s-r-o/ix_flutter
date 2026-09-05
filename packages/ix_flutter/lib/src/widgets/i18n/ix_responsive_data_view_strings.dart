/// Holds all localizable strings for [IxResponsiveDataView] and its sub-components.
class IxResponsiveDataViewStrings {
  const IxResponsiveDataViewStrings({
    this.toolsColumnHeader = 'Tools',
    this.emptyTitle = 'No data available',
    this.emptyBody = 'There are no items to display.',
    this.noResultsTitleBuilder,
    this.noResultsBody = 'Try a different search term',
    this.searchChipLabel = 'Filtered by',
    this.clearSearchLabel = 'Clear search',
    this.clearSearchTooltip = 'Clear search',
    this.paginationPrevTooltip = 'Previous page',
    this.paginationNextTooltip = 'Next page',
    this.pageOfBuilder,
    this.pageBuilder,
    this.rowsPerPageLabel = 'Items per page:',
    this.totalItemsBuilder,
    this.resultsCountBuilder,
    this.detailsTitle = 'Details',
    this.actionsTitle = 'Actions',
    this.rowActionsTooltip = 'Actions',
    this.sortHint = 'Sort',
    this.sortedAscending = 'Sorted ascending',
    this.sortedDescending = 'Sorted descending',
    this.rowHint = 'Open row',
  });

  final String toolsColumnHeader;
  final String emptyTitle;
  final String emptyBody;
  final String Function(String query)? noResultsTitleBuilder;
  final String noResultsBody;
  final String searchChipLabel;
  final String clearSearchLabel;
  final String clearSearchTooltip;
  final String paginationPrevTooltip;
  final String paginationNextTooltip;
  final String Function(int page, int totalPages)? pageOfBuilder;
  final String Function(int page)? pageBuilder;
  final String rowsPerPageLabel;
  final String Function(int count)? totalItemsBuilder;
  final String Function(int count)? resultsCountBuilder;
  final String detailsTitle;
  final String actionsTitle;
  final String rowActionsTooltip;

  /// Semantics hint on a sortable column header that is not currently
  /// sorted (announced by screen readers, e.g. "Sort").
  final String sortHint;

  /// Semantics hint on a column header currently sorted ascending.
  final String sortedAscending;

  /// Semantics hint on a column header currently sorted descending.
  final String sortedDescending;

  /// Semantics hint on a mobile card, announcing what activating it does.
  final String rowHint;

  /// English defaults
  factory IxResponsiveDataViewStrings.defaultsEn() {
    return const IxResponsiveDataViewStrings();
  }

  String noResultsTitle(String query) =>
      noResultsTitleBuilder?.call(query) ?? 'No results for "$query"';

  String pageOf(int page, int totalPages) =>
      pageOfBuilder?.call(page, totalPages) ?? 'Page $page of $totalPages';

  String page(int page) => pageBuilder?.call(page) ?? 'Page $page';

  String totalItems(int count) =>
      totalItemsBuilder?.call(count) ?? '$count items';

  String resultsCount(int count) =>
      resultsCountBuilder?.call(count) ?? 'Results: $count';
}
