import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';
import 'package:siemens_ix_flutter/src/widgets/ix_pagination_bar.dart';

/// Pagination modes supported by [IxResponsiveDataView].
enum IxPaginationMode { none, standard, infinite }

/// Configuration for pagination in [IxResponsiveDataView].
class IxPaginationConfig {
  const IxPaginationConfig({
    this.mode = IxPaginationMode.none,
    this.page,
    this.pageSize,
    this.totalItems,
    this.totalPages,
    this.pageSizeOptions,
    this.hasMore,
    this.loadMoreThresholdPx = 400.0,
    this.showPaginationOnMobile = false,
  });

  final IxPaginationMode mode;

  // Standard pagination
  final int? page;
  final int? pageSize;
  final int? totalItems;
  final int? totalPages;
  final List<int>? pageSizeOptions;

  // Infinite scroll
  final bool? hasMore;
  final double loadMoreThresholdPx;

  // Shared
  final bool showPaginationOnMobile;
}

/// Defines a column for the desktop table view.
class IxColumnDef<T> {
  const IxColumnDef({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.sortKey,
  });

  final String label;
  final int flex;
  final Alignment alignment;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final String? sortKey;
}

/// Defines a field for the mobile card view.
class IxMobileFieldDef<T> {
  const IxMobileFieldDef({required this.label, required this.valueBuilder});

  final String label;
  final Widget Function(BuildContext context, T item) valueBuilder;
}

/// Defines an action that can be performed on a row/item.
class IxRowAction<T> {
  const IxRowAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
    this.isVisible,
    this.isEnabled,
  });

  final String id;
  final String label;
  final Widget icon;
  final bool destructive;
  final void Function(T item) onSelected;
  final bool Function(T item)? isVisible;
  final bool Function(T item)? isEnabled;
}

/// Defines the current sort state.
class IxSortSpec {
  const IxSortSpec({required this.key, required this.ascending});

  final String key;
  final bool ascending;
}

/// A responsive widget that renders a data table on desktop/tablet and a
/// card list on mobile, adhering to Siemens IX design guidelines.
class IxResponsiveDataView<T> extends StatelessWidget {
  const IxResponsiveDataView({
    super.key,
    required this.items,
    required this.desktopColumns,
    required this.mobileFields,
    required this.rowActions,
    this.rowKey,
    this.onRowTapDesktop,
    this.enableSorting = false,
    this.onSortChanged,
    this.initialSortKey,
    this.initialSortAscending = true,
    this.isLoading = false,
    this.pagination,
    this.onLoadNextPage,
    this.onPageChanged,
    this.onPageSizeChanged,
    this.isPageLoading = false,
    this.searchQuery,
    this.onClearSearch,
    this.searchHintText,
    this.showSearchStatusBar = true,
    this.showSearchClearAction = true,
    this.searchAffectsPagination = true,
    this.onSearchChangedRequestResetPagination,
    this.resultsCountOverride,
    this.resultsLabelBuilder,
    this.noResultsTextBuilder,
    this.mobileItemBuilder,
    this.strings,
    this.stringsResolver,
  });

  final List<T> items;
  final List<IxColumnDef<T>> desktopColumns;
  final List<IxMobileFieldDef<T>> mobileFields;
  final List<IxRowAction<T>> rowActions;
  final String Function(T item)? rowKey;
  final void Function(T item)? onRowTapDesktop;
  final bool enableSorting;
  final void Function(IxSortSpec sortSpec)? onSortChanged;
  final String? initialSortKey;
  final bool initialSortAscending;
  final bool isLoading;

  final IxPaginationConfig? pagination;
  final Future<void> Function()? onLoadNextPage;
  final void Function(int newPage)? onPageChanged;
  final void Function(int newPageSize)? onPageSizeChanged;
  final bool isPageLoading;

  // Search / Filtering
  final String? searchQuery;
  final VoidCallback? onClearSearch;
  final String? searchHintText;
  final bool showSearchStatusBar;
  final bool showSearchClearAction;
  final bool searchAffectsPagination;
  final VoidCallback? onSearchChangedRequestResetPagination;
  final int? resultsCountOverride;
  final String Function(int count)? resultsLabelBuilder;
  final String Function(String query)? noResultsTextBuilder;

  /// Optional builder to provide a custom widget for each item in mobile view.
  /// If provided, this overrides the default card layout generated from [mobileFields].
  final Widget Function(BuildContext context, T item)? mobileItemBuilder;

  /// Optional strings override for this widget instance.
  final IxResponsiveDataViewStrings? strings;

  /// Optional resolver to fetch strings from context (e.g. AppLocalizations).
  final IxResponsiveDataViewStrings Function(BuildContext context)?
  stringsResolver;

  @override
  Widget build(BuildContext context) {
    final effectiveStrings =
        strings ??
        stringsResolver?.call(context) ??
        IxResponsiveDataViewStrings.defaultsEn();

    if (isLoading) {
      return const Center(child: IxSpinner());
    }

    if (items.isEmpty) {
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        return Center(
          child: IxEmptyState(
            icon: IxIcons.search,
            title:
                noResultsTextBuilder?.call(searchQuery!) ??
                effectiveStrings.noResultsTitle(searchQuery!),
            subtitle: effectiveStrings.noResultsBody,
            primaryAction: onClearSearch != null
                ? Builder(
                    builder: (context) {
                      final ixButtons = Theme.of(
                        context,
                      ).extension<IxButtonTheme>();
                      return OutlinedButton(
                        style: ixButtons?.style(IxButtonVariant.secondary),
                        onPressed: onClearSearch,
                        child: Text(effectiveStrings.clearSearchLabel),
                      );
                    },
                  )
                : null,
          ),
        );
      }
      return Center(
        child: IxEmptyState(
          icon: IxIcons.info,
          title: effectiveStrings.emptyTitle,
          subtitle: effectiveStrings.emptyBody,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Siemens IX breakpoint for mobile is typically < 600 or similar.
        // Using 600 as requested.
        if (constraints.maxWidth < 600) {
          return _MobileView<T>(
            items: items,
            fields: mobileFields,
            actions: rowActions,
            pagination: pagination,
            onLoadNextPage: onLoadNextPage,
            onPageChanged: onPageChanged,
            isPageLoading: isPageLoading,
            searchQuery: searchQuery,
            onClearSearch: onClearSearch,
            showSearchStatusBar: showSearchStatusBar,
            showSearchClearAction: showSearchClearAction,
            searchAffectsPagination: searchAffectsPagination,
            onSearchChangedRequestResetPagination:
                onSearchChangedRequestResetPagination,
            resultsCountOverride: resultsCountOverride,
            resultsLabelBuilder: resultsLabelBuilder,
            itemBuilder: mobileItemBuilder,
            strings: effectiveStrings,
          );
        } else {
          return _DesktopView<T>(
            items: items,
            columns: desktopColumns,
            actions: rowActions,
            onRowTap: onRowTapDesktop,
            enableSorting: enableSorting,
            onSortChanged: onSortChanged,
            initialSortKey: initialSortKey,
            initialSortAscending: initialSortAscending,
            pagination: pagination,
            onLoadNextPage: onLoadNextPage,
            onPageChanged: onPageChanged,
            onPageSizeChanged: onPageSizeChanged,
            isPageLoading: isPageLoading,
            searchQuery: searchQuery,
            onClearSearch: onClearSearch,
            showSearchStatusBar: showSearchStatusBar,
            showSearchClearAction: showSearchClearAction,
            searchAffectsPagination: searchAffectsPagination,
            onSearchChangedRequestResetPagination:
                onSearchChangedRequestResetPagination,
            resultsCountOverride: resultsCountOverride,
            resultsLabelBuilder: resultsLabelBuilder,
            strings: effectiveStrings,
          );
        }
      },
    );
  }
}

class _DesktopView<T> extends StatefulWidget {
  const _DesktopView({
    required this.items,
    required this.columns,
    required this.actions,
    this.onRowTap,
    required this.enableSorting,
    this.onSortChanged,
    this.initialSortKey,
    this.initialSortAscending = true,
    this.pagination,
    this.onLoadNextPage,
    this.onPageChanged,
    this.onPageSizeChanged,
    required this.isPageLoading,
    this.searchQuery,
    this.onClearSearch,
    required this.showSearchStatusBar,
    required this.showSearchClearAction,
    required this.searchAffectsPagination,
    this.onSearchChangedRequestResetPagination,
    this.resultsCountOverride,
    this.resultsLabelBuilder,
    required this.strings,
  });

  final List<T> items;
  final List<IxColumnDef<T>> columns;
  final List<IxRowAction<T>> actions;
  final void Function(T item)? onRowTap;
  final bool enableSorting;
  final void Function(IxSortSpec sortSpec)? onSortChanged;
  final String? initialSortKey;
  final bool initialSortAscending;
  final IxPaginationConfig? pagination;
  final Future<void> Function()? onLoadNextPage;
  final void Function(int newPage)? onPageChanged;
  final void Function(int newPageSize)? onPageSizeChanged;
  final bool isPageLoading;

  // Search
  final String? searchQuery;
  final VoidCallback? onClearSearch;
  final bool showSearchStatusBar;
  final bool showSearchClearAction;
  final bool searchAffectsPagination;
  final VoidCallback? onSearchChangedRequestResetPagination;
  final int? resultsCountOverride;
  final String Function(int count)? resultsLabelBuilder;
  final IxResponsiveDataViewStrings strings;

  @override
  State<_DesktopView<T>> createState() => _DesktopViewState<T>();
}

class _DesktopViewState<T> extends State<_DesktopView<T>> {
  String? _sortKey;
  bool _sortAscending = true;
  final ScrollController _scrollController = ScrollController();
  bool _loadTriggeredForCurrentExtent = false;
  String? _previousSearchQuery;

  @override
  void initState() {
    super.initState();
    _sortKey = widget.initialSortKey;
    _sortAscending = widget.initialSortAscending;
    _scrollController.addListener(_onScroll);
    _previousSearchQuery = widget.searchQuery;
  }

  @override
  void didUpdateWidget(_DesktopView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length ||
        !widget.isPageLoading) {
      _loadTriggeredForCurrentExtent = false;
    }

    // If the parent reloads data (e.g. due to sort change), we want to keep our sort state.
    // However, if the parent *resets* the view completely (e.g. new instance), state is lost.
    // Since we are in State object, state persists across rebuilds.

    if (widget.searchAffectsPagination &&
        widget.searchQuery != _previousSearchQuery) {
      _previousSearchQuery = widget.searchQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearchChangedRequestResetPagination?.call();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.pagination?.mode != IxPaginationMode.infinite) return;
    if (widget.onLoadNextPage == null) return;
    if (widget.isPageLoading) return;
    if (_loadTriggeredForCurrentExtent) return;
    if (widget.pagination?.hasMore == false) return;

    final threshold = widget.pagination?.loadMoreThresholdPx ?? 400.0;
    if (_scrollController.position.extentAfter < threshold) {
      _loadTriggeredForCurrentExtent = true;
      widget.onLoadNextPage!();
    }
  }

  void _handleSort(String key) {
    if (!widget.enableSorting) return;

    final newAscending = _sortKey == key ? !_sortAscending : true;

    setState(() {
      _sortKey = key;
      _sortAscending = newAscending;
    });

    widget.onSortChanged?.call(IxSortSpec(key: key, ascending: newAscending));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final color1 = theme?.color(IxThemeColorToken.color1) ?? Colors.grey[100]!;
    final stdText = theme?.color(IxThemeColorToken.stdText) ?? Colors.black;

    return Column(
      children: [
        if (widget.showSearchStatusBar &&
            widget.searchQuery != null &&
            widget.searchQuery!.isNotEmpty)
          _SearchStatusHeader(
            query: widget.searchQuery!,
            count:
                widget.resultsCountOverride ??
                widget.pagination?.totalItems ??
                widget.items.length,
            onClear: widget.showSearchClearAction ? widget.onClearSearch : null,
            resultsLabelBuilder: widget.resultsLabelBuilder,
            strings: widget.strings,
          ),
        // Header
        Padding(
          padding: const EdgeInsets.only(
            right: 16.0,
          ), // Reserve space for scrollbar
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: color1,
              border: Border(
                bottom: BorderSide(
                  color: theme?.color(IxThemeColorToken.color4) ?? Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                ...widget.columns.map((col) {
                  return Expanded(
                    flex: col.flex,
                    child: GestureDetector(
                      onTap: (widget.enableSorting && col.sortKey != null)
                          ? () => _handleSort(col.sortKey!)
                          : null,
                      child: MouseRegion(
                        cursor: (widget.enableSorting && col.sortKey != null)
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: col.alignment,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  col.label,
                                  style: theme?.textStyle(
                                    IxTypographyVariant.label,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.enableSorting &&
                                  col.sortKey != null &&
                                  _sortKey == col.sortKey) ...[
                                const SizedBox(width: 4),
                                IconTheme(
                                  data: IconThemeData(size: 16, color: stdText),
                                  child: _sortAscending
                                      ? IxIcons.chevronUp
                                      : IxIcons.chevronDown,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Tools column header
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      widget.strings.toolsColumnHeader,
                      style: theme?.textStyle(IxTypographyVariant.label),
                    ),
                  ),
                ), // Fixed width for tools
              ],
            ),
          ),
        ),
        // Rows
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                right: 16.0,
              ), // Reserve space for scrollbar
              itemCount: widget.items.length + (widget.isPageLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: IxSpinner()),
                  );
                }
                final item = widget.items[index];
                return _DesktopRow<T>(
                  item: item,
                  columns: widget.columns,
                  actions: widget.actions,
                  onTap: widget.onRowTap,
                  theme: theme,
                  strings: widget.strings,
                );
              },
            ),
          ),
        ),
        if (widget.pagination?.mode == IxPaginationMode.standard &&
            widget.pagination?.page != null &&
            widget.onPageChanged != null)
          IxPaginationBar(
            page: widget.pagination!.page!,
            totalPages: widget.pagination!.totalPages,
            totalItems: widget.pagination!.totalItems,
            pageSize: widget.pagination!.pageSize,
            pageSizeOptions: widget.pagination!.pageSizeOptions,
            onPageChanged: widget.onPageChanged!,
            onPageSizeChanged: widget.onPageSizeChanged,
            strings: widget.strings,
          ),
      ],
    );
  }
}

class _DesktopRow<T> extends StatefulWidget {
  const _DesktopRow({
    required this.item,
    required this.columns,
    required this.actions,
    this.onTap,
    required this.theme,
    required this.strings,
  });

  final T item;
  final List<IxColumnDef<T>> columns;
  final List<IxRowAction<T>> actions;
  final void Function(T item)? onTap;
  final IxTheme? theme;
  final IxResponsiveDataViewStrings strings;

  @override
  State<_DesktopRow<T>> createState() => _DesktopRowState<T>();
}

class _DesktopRowState<T> extends State<_DesktopRow<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color0 =
        widget.theme?.color(IxThemeColorToken.color0) ?? Colors.white;
    final color1Hover =
        widget.theme?.color(IxThemeColorToken.color1Hover) ?? Colors.grey[200]!;
    final borderColor =
        widget.theme?.color(IxThemeColorToken.color4) ?? Colors.grey[300]!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.item) : null,
        child: Container(
          height: 56, // Standard row height
          decoration: BoxDecoration(
            color: _isHovered ? color1Hover : color0,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              ...widget.columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: col.alignment,
                    child: col.cellBuilder(context, widget.item),
                  ),
                );
              }),
              // Tools column
              SizedBox(
                width: 48,
                child: Center(
                  child: PopupMenuButton<IxRowAction<T>>(
                    icon: IxIcons.moreMenu,
                    tooltip: widget.strings.rowActionsTooltip,
                    onSelected: (action) => action.onSelected(widget.item),
                    itemBuilder: (context) {
                      return widget.actions
                          .where((a) => a.isVisible?.call(widget.item) ?? true)
                          .map((action) {
                            final enabled =
                                action.isEnabled?.call(widget.item) ?? true;
                            return PopupMenuItem<IxRowAction<T>>(
                              value: action,
                              enabled: enabled,
                              child: Row(
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                      color: action.destructive
                                          ? widget.theme?.color(
                                              IxThemeColorToken.alarm,
                                            )
                                          : widget.theme?.color(
                                              IxThemeColorToken.stdText,
                                            ),
                                      size: 20,
                                    ),
                                    child: action.icon,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    action.label,
                                    style: TextStyle(
                                      color: action.destructive
                                          ? widget.theme?.color(
                                              IxThemeColorToken.alarm,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                          .toList();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileView<T> extends StatefulWidget {
  const _MobileView({
    required this.items,
    required this.fields,
    required this.actions,
    this.pagination,
    this.onLoadNextPage,
    this.onPageChanged,
    required this.isPageLoading,
    this.searchQuery,
    this.onClearSearch,
    required this.showSearchStatusBar,
    required this.showSearchClearAction,
    required this.searchAffectsPagination,
    this.onSearchChangedRequestResetPagination,
    this.resultsCountOverride,
    this.resultsLabelBuilder,
    this.itemBuilder,
    required this.strings,
  });

  final List<T> items;
  final List<IxMobileFieldDef<T>> fields;
  final List<IxRowAction<T>> actions;
  final IxPaginationConfig? pagination;
  final Future<void> Function()? onLoadNextPage;
  final void Function(int newPage)? onPageChanged;
  final bool isPageLoading;

  // Search
  final String? searchQuery;
  final VoidCallback? onClearSearch;
  final bool showSearchStatusBar;
  final bool showSearchClearAction;
  final bool searchAffectsPagination;
  final VoidCallback? onSearchChangedRequestResetPagination;
  final int? resultsCountOverride;
  final String Function(int count)? resultsLabelBuilder;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final IxResponsiveDataViewStrings strings;

  @override
  State<_MobileView<T>> createState() => _MobileViewState<T>();
}

class _MobileViewState<T> extends State<_MobileView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _loadTriggeredForCurrentExtent = false;
  String? _previousSearchQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _previousSearchQuery = widget.searchQuery;
  }

  @override
  void didUpdateWidget(_MobileView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length ||
        !widget.isPageLoading) {
      _loadTriggeredForCurrentExtent = false;
    }

    if (widget.searchAffectsPagination &&
        widget.searchQuery != _previousSearchQuery) {
      _previousSearchQuery = widget.searchQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearchChangedRequestResetPagination?.call();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.pagination?.mode != IxPaginationMode.infinite) return;
    if (widget.onLoadNextPage == null) return;
    if (widget.isPageLoading) return;
    if (_loadTriggeredForCurrentExtent) return;
    if (widget.pagination?.hasMore == false) return;

    final threshold = widget.pagination?.loadMoreThresholdPx ?? 400.0;
    if (_scrollController.position.extentAfter < threshold) {
      _loadTriggeredForCurrentExtent = true;
      widget.onLoadNextPage!();
    }
  }

  void _showDetail(BuildContext context, T item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MobileDetailView<T>(
        item: item,
        fields: widget.fields,
        actions: widget.actions,
        strings: widget.strings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearchStatusBar &&
            widget.searchQuery != null &&
            widget.searchQuery!.isNotEmpty)
          _SearchStatusHeader(
            query: widget.searchQuery!,
            count:
                widget.resultsCountOverride ??
                widget.pagination?.totalItems ??
                widget.items.length,
            onClear: widget.showSearchClearAction ? widget.onClearSearch : null,
            resultsLabelBuilder: widget.resultsLabelBuilder,
            strings: widget.strings,
          ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.items.length + (widget.isPageLoading ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == widget.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: IxSpinner()),
                );
              }
              final item = widget.items[index];

              if (widget.itemBuilder != null) {
                return widget.itemBuilder!(context, item);
              }

              return _MobileCard<T>(
                item: item,
                fields: widget.fields,
                onTap: () => _showDetail(context, item),
              );
            },
          ),
        ),
        if (widget.pagination?.mode == IxPaginationMode.standard &&
            widget.pagination?.showPaginationOnMobile == true &&
            widget.pagination?.page != null &&
            widget.onPageChanged != null)
          IxPaginationBar(
            page: widget.pagination!.page!,
            totalPages: widget.pagination!.totalPages,
            // Minimal mobile pagination usually doesn't show page size options
            onPageChanged: widget.onPageChanged!,
            strings: widget.strings,
          ),
      ],
    );
  }
}

class _MobileCard<T> extends StatelessWidget {
  const _MobileCard({
    required this.item,
    required this.fields,
    required this.onTap,
  });

  final T item;
  final List<IxMobileFieldDef<T>> fields;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final cardTheme = Theme.of(context).extension<IxCardTheme>();
    final cardStyle = cardTheme?.style(IxCardVariant.filled);

    final cardColor =
        cardStyle?.background ??
        theme?.color(IxThemeColorToken.color0) ??
        Colors.white;
    final borderColor =
        cardStyle?.borderColor ??
        theme?.color(IxThemeColorToken.color4) ??
        Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4), // IX Card radius
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      field.label,
                      style: theme?.textStyle(
                        IxTypographyVariant.label,
                        tone: IxThemeTextTone.soft,
                      ),
                    ),
                  ),
                  Expanded(child: field.valueBuilder(context, item)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MobileDetailView<T> extends StatelessWidget {
  const _MobileDetailView({
    required this.item,
    required this.fields,
    required this.actions,
    required this.strings,
  });

  final T item;
  final List<IxMobileFieldDef<T>> fields;
  final List<IxRowAction<T>> actions;
  final IxResponsiveDataViewStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.detailsTitle,
            style: theme?.textStyle(IxTypographyVariant.h4),
          ),
          const SizedBox(height: 24),
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: theme?.textStyle(
                      IxTypographyVariant.label,
                      tone: IxThemeTextTone.soft,
                    ),
                  ),
                  const SizedBox(height: 4),
                  field.valueBuilder(context, item),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            strings.actionsTitle,
            style: theme?.textStyle(IxTypographyVariant.h5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: actions.where((a) => a.isVisible?.call(item) ?? true).map(
              (action) {
                final enabled = action.isEnabled?.call(item) ?? true;
                return ActionChip(
                  avatar: IconTheme(
                    data: IconThemeData(
                      size: 18,
                      color: action.destructive
                          ? theme?.color(IxThemeColorToken.alarm)
                          : theme?.color(IxThemeColorToken.stdText),
                    ),
                    child: action.icon,
                  ),
                  label: Text(action.label),
                  onPressed: enabled
                      ? () {
                          Navigator.pop(context); // Close sheet
                          action.onSelected(item);
                        }
                      : null,
                  backgroundColor: action.destructive
                      ? theme?.color(IxThemeColorToken.alarm10)
                      : null,
                  labelStyle: TextStyle(
                    color: action.destructive
                        ? theme?.color(IxThemeColorToken.alarm)
                        : null,
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SearchStatusHeader extends StatelessWidget {
  const _SearchStatusHeader({
    required this.query,
    required this.count,
    this.onClear,
    this.resultsLabelBuilder,
    required this.strings,
  });

  final String query;
  final int count;
  final VoidCallback? onClear;
  final String Function(int count)? resultsLabelBuilder;
  final IxResponsiveDataViewStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final color1 = theme?.color(IxThemeColorToken.color1) ?? Colors.grey[100]!;
    final stdText = theme?.color(IxThemeColorToken.stdText) ?? Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color1,
        border: Border(
          bottom: BorderSide(
            color: theme?.color(IxThemeColorToken.color4) ?? Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme?.color(IxThemeColorToken.component1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme?.color(IxThemeColorToken.color4) ?? Colors.grey,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${strings.searchChipLabel}: "$query"',
                  style: theme?.textStyle(IxTypographyVariant.label),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClear,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: strings.clearSearchTooltip,
                        child: IconTheme(
                          data: IconThemeData(size: 16, color: stdText),
                          child: IxIcons.closeSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          Text(
            resultsLabelBuilder?.call(count) ?? strings.resultsCount(count),
            style: theme?.textStyle(
              IxTypographyVariant.label,
              tone: IxThemeTextTone.soft,
            ),
          ),
        ],
      ),
    );
  }
}
