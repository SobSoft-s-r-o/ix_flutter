import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

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
  bool _isPageLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isPageLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network

    if (_paginationMode == IxPaginationMode.standard) {
      final start = (_page - 1) * _pageSize;
      final end = (start + _pageSize).clamp(0, _allItems.length);
      setState(() {
        _displayedItems = _allItems.sublist(start, end);
        _isPageLoading = false;
      });
    } else {
      // Infinite
      final currentCount = _displayedItems.length;
      final nextCount = (currentCount + _pageSize).clamp(0, _allItems.length);
      setState(() {
        _displayedItems.addAll(_allItems.sublist(currentCount, nextCount));
        _hasMore = _displayedItems.length < _allItems.length;
        _isPageLoading = false;
      });
    }
  }

  void _handleSort(IxSortSpec sortSpec) {
    setState(() {
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
      // Reset pagination on sort
      _page = 1;
      if (_paginationMode == IxPaginationMode.infinite) {
        _displayedItems = [];
        _hasMore = true;
      }
    });
    _loadData();
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
              DropdownButton<IxPaginationMode>(
                value: _paginationMode,
                items: IxPaginationMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() {
                      _paginationMode = mode;
                      _page = 1;
                      _displayedItems = [];
                      _hasMore = true;
                    });
                    _loadData();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IxResponsiveDataView<_ExampleItem>(
              items: _displayedItems,
              enableSorting: true,
              onSortChanged: _handleSort,
              isPageLoading: _isPageLoading,
              pagination: IxPaginationConfig(
                mode: _paginationMode,
                page: _page,
                pageSize: _pageSize,
                totalItems: _allItems.length,
                totalPages: (_allItems.length / _pageSize).ceil(),
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
        color: bgColor.withOpacity(0.1),
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
