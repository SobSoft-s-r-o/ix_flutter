import 'ix_responsive_data_view_strings.dart';

/// Holds the localizable strings for [IxPaginationBar].
///
/// Upstream: `pagination.tsx:102-118` (`Previous page`, `Next page`,
/// `Page selection input`).
class IxPaginationStrings {
  /// Creates a set of pagination strings, defaulting to English.
  const IxPaginationStrings({
    this.previousPage = 'Previous page',
    this.nextPage = 'Next page',
    this.rowsPerPage = 'Items per page',
    this.pageSelection = 'Page selection',
    this.pageOf = defaultPageOf,
    this.page = defaultPage,
    this.totalItems = defaultTotalItems,
  });

  /// Accessible name and tooltip of the "previous page" chevron.
  final String previousPage;

  /// Accessible name and tooltip of the "next page" chevron.
  final String nextPage;

  /// Label preceding the page-size selector.
  ///
  /// This constructor's own default ("Items per page", no colon) only
  /// applies when an [IxPaginationStrings] is constructed directly. An
  /// [IxPaginationBar] with neither `paginationStrings:` nor `strings:`
  /// set instead bridges from `IxResponsiveDataViewStrings.defaultsEn()`
  /// (see [IxPaginationBar.paginationStrings]), whose matching
  /// `rowsPerPageLabel` has always read "Items per page:" (with a
  /// trailing colon) -- that visual default is unchanged by this class.
  final String rowsPerPage;

  /// Accessible name of the page-size selector trigger.
  final String pageSelection;

  /// Builds the "page X of Y" label shown when the total page count is
  /// known.
  final String Function(int page, int totalPages) pageOf;

  /// Builds the "page X" label shown when the total page count is unknown.
  final String Function(int page) page;

  /// Builds the total-item-count label.
  final String Function(int count) totalItems;

  /// Default English "page X of Y" label.
  static String defaultPageOf(int page, int total) => 'Page $page of $total';

  /// Default English "page X" label.
  static String defaultPage(int page) => 'Page $page';

  /// Default English total-item-count label.
  static String defaultTotalItems(int count) => '$count items';

  /// Bridges the legacy [IxResponsiveDataViewStrings] (still accepted by
  /// [IxPaginationBar.strings] for 1.x callers) into [IxPaginationStrings].
  ///
  /// Every field is taken from the matching [IxResponsiveDataViewStrings]
  /// member, so a caller that only ever customized `strings:` keeps seeing
  /// its own overrides -- including any `xxxBuilder` -- unchanged.
  factory IxPaginationStrings.fromDataView(IxResponsiveDataViewStrings s) {
    return IxPaginationStrings(
      previousPage: s.paginationPrevTooltip,
      nextPage: s.paginationNextTooltip,
      rowsPerPage: s.rowsPerPageLabel,
      pageSelection: s.pageSelectionLabel,
      pageOf: s.pageOf,
      page: s.page,
      totalItems: s.totalItems,
    );
  }
}
