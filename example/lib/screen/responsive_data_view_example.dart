import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:example/ix_icons.dart';

class ResponsiveDataViewExample extends StatefulWidget {
  static const routePath = '/responsive-data-view';
  static const routeName = 'responsive_data_view';

  const ResponsiveDataViewExample({super.key});

  @override
  State<ResponsiveDataViewExample> createState() =>
      _ResponsiveDataViewExampleState();
}

class _ResponsiveDataViewExampleState extends State<ResponsiveDataViewExample> {
  final List<_ExampleItem> _allItems = List.generate(
    240,
    (index) => _ExampleItem(
      id: 'item-$index',
      name: 'Item $index',
      status: index % 3 == 0 ? 'Active' : 'Inactive',
      amount: (index + 1) * 100.0,
      date: DateTime.now().add(Duration(days: index)),
      category: index % 2 == 0 ? 'Hardware' : 'Software',
    ),
  );

  List<_ExampleItem> _displayedItems = [];
  IxPaginationMode _paginationMode = IxPaginationMode.standard;
  int _page = 1;
  int _pageSize = 20;
  bool _isLoading = true;
  bool _isPageLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  IxSortSpec? _currentSort = const IxSortSpec(key: 'name', ascending: true);
  bool _useCustomStrings = false;

  // Backs the simulated network delay below with a cancelable `Timer`
  // (instead of a bare `Future.delayed`, whose underlying timer cannot be
  // cancelled) so `dispose()` can stop it outright -- otherwise a pending
  // timer outliving the widget trips flutter_test's "Timer is still
  // pending" invariant when a test navigates away before the delay fires.
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    _sortItems(_currentSort!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Whether [item] survives the current search query.
  ///
  /// The one place the query is applied: the rows and the pagination
  /// counters below both go through it, so they can never disagree about
  /// how many results a query has.
  bool _matchesQuery(_ExampleItem item) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query);
  }

  /// The demo data set narrowed to the current search query. Always a fresh
  /// list: the pagination branches below hand it straight to
  /// `_displayedItems` and then mutate that.
  List<_ExampleItem> get _filteredItems =>
      _allItems.where(_matchesQuery).toList();

  /// How many items the current query matches.
  int get _filteredCount => _searchQuery.isEmpty
      ? _allItems.length
      : _allItems.where(_matchesQuery).length;

  /// Starts, or restarts, the simulated network round trip.
  ///
  /// A call while one is still pending cancels it outright, so typing in
  /// the search box debounces into a single load instead of queueing one
  /// per keystroke -- and no superseded load is left behind to publish
  /// stale rows over the newer query's.
  void _loadData() {
    if (_displayedItems.isEmpty && _page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isPageLoading = true);
    }

    _loadTimer?.cancel();
    _loadTimer = Timer(
      const Duration(milliseconds: 1500), // Simulate network
      _publishLoadedItems,
    );
  }

  /// Applies the current query, sort and pagination to the demo data.
  void _publishLoadedItems() {
    if (!mounted) return;
    final filteredItems = _filteredItems;

    if (_paginationMode == IxPaginationMode.none) {
      setState(() {
        _displayedItems = filteredItems;
        _isLoading = false;
        _isPageLoading = false;
      });
    } else if (_paginationMode == IxPaginationMode.standard) {
      final start = (_page - 1) * _pageSize;
      final end = (start + _pageSize).clamp(0, filteredItems.length);
      setState(() {
        _displayedItems = filteredItems.sublist(start, end);
        _isLoading = false;
        _isPageLoading = false;
      });
    } else {
      // Infinite
      final currentCount = _displayedItems.length;
      final nextCount = (currentCount + _pageSize).clamp(
        0,
        filteredItems.length,
      );
      setState(() {
        _displayedItems.addAll(filteredItems.sublist(currentCount, nextCount));
        _hasMore = _displayedItems.length < filteredItems.length;
        _isLoading = false;
        _isPageLoading = false;
      });
    }
  }

  void _sortItems(IxSortSpec sortSpec) {
    _allItems.sort((a, b) {
      int cmp;
      switch (sortSpec.key) {
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'amount':
          cmp = a.amount.compareTo(b.amount);
          break;
        case 'date':
          cmp = a.date.compareTo(b.date);
          break;
        default:
          cmp = 0;
      }
      return sortSpec.ascending ? cmp : -cmp;
    });
  }

  void _handleSort(IxSortSpec sortSpec) {
    setState(() {
      _currentSort = sortSpec;
      _sortItems(sortSpec);
      // Reset pagination on sort
      _page = 1;
      if (_paginationMode == IxPaginationMode.infinite) {
        _displayedItems = [];
        _hasMore = true;
      }
    });
    _loadData();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      // Reset pagination on search
      _page = 1;
      if (_paginationMode == IxPaginationMode.infinite) {
        _displayedItems = [];
        _hasMore = true;
      }
    });
    _loadData();
  }

  void _clearSearch() {
    _searchController.clear();
    _handleSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          // `Wrap` (not `Row`): this toolbar has a lot of controls, and a
          // plain `Row` overflows once density/text scale changes push
          // their combined width past a narrower window -- see A-4
          // (density-data-view plan), which applies the same fix inside
          // IxResponsiveDataView/IxPaginationBar itself.
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pagination Mode: '),
                  const SizedBox(width: 8),
                  IxDropdownButton<IxPaginationMode>(
                    label: _paginationMode.name.toUpperCase(),
                    buttonVariant: IxButtonVariant.subtleSecondary,
                    items: IxPaginationMode.values
                        .map(
                          (mode) => IxDropdownMenuItem<IxPaginationMode>(
                            label: mode.name.toUpperCase(),
                            value: mode,
                            // This menu picks a mode rather than running an
                            // action, so the current one carries the check
                            // and the menu opens on it.
                            checked: mode == _paginationMode,
                          ),
                        )
                        .toList(),
                    onItemSelected: (mode) {
                      setState(() {
                        _paginationMode = mode;
                        _page = 1;
                        _displayedItems = [];
                        _hasMore = true;
                      });
                      _loadData();
                    },
                  ),
                ],
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  // The field filters as it is typed in -- `_loadData`
                  // restarts its delay on every keystroke, so the simulated
                  // round trip debounces itself. `onSubmitted` alone left
                  // the query doing nothing until Enter was pressed.
                  onChanged: _handleSearch,
                  onSubmitted: _handleSearch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () => _handleSearch(_searchController.text),
              ),
              IconButton(
                icon: const Icon(Icons.sort_by_alpha),
                tooltip: 'Toggle Sort (Name)',
                onPressed: () {
                  final newAscending = !(_currentSort?.ascending ?? true);
                  _handleSort(IxSortSpec(key: 'name', ascending: newAscending));
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Strings: '),
                  Switch(
                    value: _useCustomStrings,
                    onChanged: (value) {
                      setState(() {
                        _useCustomStrings = value;
                      });
                    },
                  ),
                  Text(_useCustomStrings ? 'Custom' : 'Default'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IxResponsiveDataView<_ExampleItem>(
              items: _displayedItems,
              strings: _useCustomStrings ? _customStrings : null,
              enableSorting: true,
              onSortChanged: _handleSort,
              initialSortKey: _currentSort?.key,
              initialSortAscending: _currentSort?.ascending ?? true,
              isLoading: _isLoading,
              isPageLoading: _isPageLoading,
              searchQuery: _searchQuery,
              onClearSearch: _clearSearch,
              onSearchChangedRequestResetPagination: () {
                // This callback is triggered if searchAffectsPagination is true
                // and searchQuery changes.
                // In this example, we handle reset in _handleSearch, but this
                // is useful if the query came from a stream or parent prop update.
                setState(() {
                  _page = 1;
                  if (_paginationMode == IxPaginationMode.infinite) {
                    _displayedItems = [];
                    _hasMore = true;
                  }
                });
                _loadData();
              },
              pagination: IxPaginationConfig(
                mode: _paginationMode,
                page: _page,
                pageSize: _pageSize,
                totalItems: _filteredCount,
                totalPages: (_filteredCount / _pageSize).ceil(),
                pageSizeOptions: [10, 20, 50],
                hasMore: _hasMore,
                showPaginationOnMobile: true,
              ),
              onPageChanged: (newPage) {
                setState(() => _page = newPage);
                _loadData();
              },
              onPageSizeChanged: (newSize) {
                setState(() {
                  _pageSize = newSize;
                  _page = 1;
                });
                _loadData();
              },
              onLoadNextPage: () async => _loadData(),
              desktopColumns: [
                IxColumnDef(
                  label: 'Name',
                  flex: 2,
                  sortKey: 'name',
                  cellBuilder: (context, item) => Text(item.name),
                ),
                IxColumnDef(
                  label: 'Status',
                  cellBuilder: (context, item) => _StatusChip(
                    label: item.status,
                    isSuccess: item.status == 'Active',
                  ),
                ),
                IxColumnDef(
                  label: 'Category',
                  cellBuilder: (context, item) => Text(item.category),
                ),
                IxColumnDef(
                  label: 'Amount',
                  alignment: Alignment.centerRight,
                  sortKey: 'amount',
                  cellBuilder: (context, item) =>
                      Text('\$${item.amount.toStringAsFixed(2)}'),
                ),
                IxColumnDef(
                  label: 'Date',
                  sortKey: 'date',
                  cellBuilder: (context, item) => Text(
                    '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
              // mobileItemBuilder: (context, item) {
              //   // Example of custom mobile card builder
              //   // If not provided, it uses mobileFields to build a default card
              //   return Card(
              //     child: ListTile(
              //       title: Text(item.name),
              //       subtitle: Text(item.status),
              //     ),
              //   );
              // },
              mobileFields: [
                IxMobileFieldDef(
                  label: 'Name',
                  valueBuilder: (context, item) => Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IxMobileFieldDef(
                  label: 'Status',
                  valueBuilder: (context, item) => _StatusChip(
                    label: item.status,
                    isSuccess: item.status == 'Active',
                  ),
                ),
                IxMobileFieldDef(
                  label: 'Amount',
                  valueBuilder: (context, item) =>
                      Text('\$${item.amount.toStringAsFixed(2)}'),
                ),
                IxMobileFieldDef(
                  label: 'Category',
                  valueBuilder: (context, item) => Text(item.category),
                ),
                IxMobileFieldDef(
                  label: 'Date',
                  valueBuilder: (context, item) => Text(
                    '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
              rowActions: [
                IxRowAction(
                  id: 'edit',
                  label: 'Edit',
                  icon: IxIcon(IxIconsData.pen, size: IxIconSize.s16),
                  onSelected: (item) {
                    print('Edit ${item.name}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit ${item.name}')),
                    );
                  },
                ),
                IxRowAction(
                  id: 'add_payment',
                  label: 'Add Payment',
                  icon: IxIcon(IxIconsData.plus, size: IxIconSize.s16),
                  onSelected: (item) {
                    print('Add Payment for ${item.name}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Add Payment for ${item.name}')),
                    );
                  },
                ),
                IxRowAction(
                  id: 'delete',
                  label: 'Delete',
                  icon: IxIcon(IxIconsData.trashcan, size: IxIconSize.s16),
                  destructive: true,
                  onSelected: (item) {
                    print('Delete ${item.name}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete ${item.name}')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExampleItem {
  _ExampleItem({
    required this.id,
    required this.name,
    required this.status,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String name;
  final String status;
  final double amount;
  final DateTime date;
  final String category;
}

final _customStrings = IxResponsiveDataViewStrings(
  toolsColumnHeader: 'Options',
  emptyTitle: 'Nothing here',
  emptyBody: 'There is nothing to show yet.',
  noResultsTitleBuilder: (query) => 'Nothing matched "$query"',
  noResultsBody: 'Try a different keyword',
  searchChipLabel: 'Filtered on',
  clearSearchLabel: 'Reset search',
  clearSearchTooltip: 'Reset search',
  paginationPrevTooltip: 'Back',
  paginationNextTooltip: 'Forward',
  pageOfBuilder: (page, total) => '$page / $total',
  pageBuilder: (page) => 'p. $page',
  rowsPerPageLabel: 'Rows shown:',
  totalItemsBuilder: (count) => '$count entries',
  resultsCountBuilder: (count) => 'Found: $count',
  detailsTitle: 'Info',
  actionsTitle: 'Options',
  rowActionsTooltip: 'Options',
);

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isSuccess});

  final String label;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    // Using alarm/success colors from theme if available, otherwise fallback
    final bgColor = isSuccess
        ? (theme?.color(IxThemeColorToken.alarm) ??
              Colors
                  .green) // Using alarm as placeholder if success not found in token list
        : (theme?.color(IxThemeColorToken.alarm) ?? Colors.red);

    // Actually let's check IxThemeColorToken again.
    // It has alarm, but maybe not success?
    // The file content showed: alarm, alarmActive, alarmContrast, alarmHover, alarm10...
    // It didn't show success in the first 50 lines.

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: bgColor.a * 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
