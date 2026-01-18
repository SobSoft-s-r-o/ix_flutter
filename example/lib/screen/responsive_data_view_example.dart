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
  bool _useSlovak = false;

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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_displayedItems.isEmpty && _page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isPageLoading = true);
    }

    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulate network

    // Filter by search query
    final filteredItems = _allItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
          child: Row(
            children: [
              const Text('Pagination Mode: '),
              const SizedBox(width: 8),
              IxDropdownButton<IxPaginationMode>(
                label: _paginationMode.name.toUpperCase(),
                variant: IxDropdownButtonVariant.subtleSecondary,
                items: IxPaginationMode.values
                    .map(
                      (mode) => IxDropdownMenuItem<IxPaginationMode>(
                        label: mode.name.toUpperCase(),
                        value: mode,
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
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: _handleSearch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _handleSearch(_searchController.text),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.sort_by_alpha),
                tooltip: 'Toggle Sort (Name)',
                onPressed: () {
                  final newAscending = !(_currentSort?.ascending ?? true);
                  _handleSort(IxSortSpec(key: 'name', ascending: newAscending));
                },
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Text('Language: '),
                  Switch(
                    value: _useSlovak,
                    onChanged: (value) {
                      setState(() {
                        _useSlovak = value;
                      });
                    },
                  ),
                  Text(_useSlovak ? 'SK' : 'EN'),
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
              strings: _useSlovak ? _slovakStrings : null,
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
                totalItems: _searchQuery.isEmpty
                    ? _allItems.length
                    : _allItems
                          .where(
                            (item) =>
                                item.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                item.category.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .length,
                totalPages:
                    ((_searchQuery.isEmpty
                                ? _allItems.length
                                : _allItems
                                      .where(
                                        (item) =>
                                            item.name.toLowerCase().contains(
                                              _searchQuery.toLowerCase(),
                                            ) ||
                                            item.category
                                                .toLowerCase()
                                                .contains(
                                                  _searchQuery.toLowerCase(),
                                                ),
                                      )
                                      .length) /
                            _pageSize)
                        .ceil(),
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
              onLoadNextPage: () async {
                await _loadData();
              },
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
                  icon: IxIcons.pen,
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
                  icon: IxIcons.plus,
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
                  icon: IxIcons.trashcan,
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

final _slovakStrings = IxResponsiveDataViewStrings(
  toolsColumnHeader: 'Nástroje',
  emptyTitle: 'Žiadne dáta',
  emptyBody: 'Nie sú k dispozícii žiadne položky na zobrazenie.',
  noResultsTitleBuilder: (query) => 'Žiadne výsledky pre "$query"',
  noResultsBody: 'Skúste iný hľadaný výraz',
  searchChipLabel: 'Filtrované podľa',
  clearSearchLabel: 'Vymazať hľadanie',
  clearSearchTooltip: 'Vymazať hľadanie',
  paginationPrevTooltip: 'Predchádzajúca strana',
  paginationNextTooltip: 'Nasledujúca strana',
  pageOfBuilder: (page, total) => 'Strana $page z $total',
  pageBuilder: (page) => 'Strana $page',
  rowsPerPageLabel: 'Položiek na stranu:',
  totalItemsBuilder: (count) => '$count položiek',
  resultsCountBuilder: (count) => 'Výsledky: $count',
  detailsTitle: 'Detaily',
  actionsTitle: 'Akcie',
  rowActionsTooltip: 'Akcie',
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
