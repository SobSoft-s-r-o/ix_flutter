# API Reference

Complete API reference for ix_flutter components and utilities.

## Components

### Application Structure

#### IxApplicationScaffold

Main application container with responsive layout and navigation.

```dart
IxApplicationScaffold(
  title: 'My App',
  onNavigate: (route) => navigator.push(route),
  child: Container(),
)
```

**Properties:**
- `title` (String) - Application title
- `onNavigate` (Function) - Navigation callback
- `child` (Widget) - Main content
- `sidebar` (Widget?) - Optional sidebar widget
- `header` (Widget?) - Optional header widget

**Documentation:** [ix_application_scaffold.md](doc/ix_application_scaffold.md)

---

### Navigation

#### IxBreadcrumb

Navigation breadcrumb component showing current location.

```dart
IxBreadcrumb(
  items: [
    BreadcrumbItem(label: 'Home', onTap: () {}),
    BreadcrumbItem(label: 'Settings', onTap: () {}),
  ],
)
```

**Properties:**
- `items` (List<BreadcrumbItem>) - Breadcrumb items
- `onItemTap` (Function?) - Item tap callback
- `maxDisplayed` (int) - Maximum items to display

**Documentation:** See doc folder

---

### Layout & Containers

#### IxBlind

Sliding drawer/panel component (also called "Blind" or "Slider Panel").

```dart
IxBlind(
  header: Text('Panel Title'),
  body: Column(children: [...]),
  expanded: true,
  onToggle: (expanded) {},
)
```

**Properties:**
- `header` (Widget) - Panel header
- `body` (Widget) - Panel content
- `expanded` (bool) - Initial state
- `onToggle` (Function?) - Toggle callback
- `width` (double?) - Custom width

**Documentation:** [ix_blind.md](doc/ix_blind.md)

---

### Form Components

#### IxDropdownButton

Advanced dropdown selection component.

```dart
IxDropdownButton<String>(
  value: selectedValue,
  items: [
    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
    DropdownMenuItem(value: 'option2', child: Text('Option 2')),
  ],
  onChanged: (value) {},
)
```

**Properties:**
- `value` (T?) - Selected value
- `items` (List<DropdownMenuItem<T>>) - Available options
- `onChanged` (Function?) - Selection callback
- `hint` (Widget?) - Placeholder widget
- `icon` (Widget?) - Custom icon

**Documentation:** [ix_dropdown_button.md](doc/ix_dropdown_button.md)

---

### Data Display

#### IxResponsiveDataView

Responsive data table/list component.

```dart
IxResponsiveDataView(
  columns: [
    DataColumn(label: Text('Name')),
    DataColumn(label: Text('Email')),
  ],
  rows: [
    DataRow(cells: [
      DataCell(Text('John')),
      DataCell(Text('john@example.com')),
    ]),
  ],
)
```

**Properties:**
- `columns` (List<DataColumn>) - Table columns
- `rows` (List<DataRow>) - Table rows
- `onSort` (Function?) - Sort callback
- `sortColumnIndex` (int?) - Current sort column
- `sortAscending` (bool) - Sort direction

**Documentation:** [ix_responsive_data_view.md](doc/ix_responsive_data_view.md)

---

#### IxPaginationBar

Pagination controls for data navigation.

```dart
IxPaginationBar(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (page) {},
)
```

**Properties:**
- `currentPage` (int) - Current page
- `totalPages` (int) - Total pages
- `onPageChanged` (Function) - Page change callback
- `itemsPerPage` (int?) - Items per page

**Documentation:** See doc folder

---

### Feedback

#### IxToast

Toast notification system for user feedback.

```dart
IxToast.show(
  context,
  message: 'Action completed!',
  type: ToastType.success,
  duration: Duration(seconds: 3),
)
```

**Usage:**
```dart
IxToast.success(context, message: 'Success!')
IxToast.error(context, message: 'Error occurred')
IxToast.info(context, message: 'Information')
IxToast.warning(context, message: 'Warning')
```

**Properties:**
- `message` (String) - Toast message
- `type` (ToastType) - Toast type (success, error, info, warning)
- `duration` (Duration) - Display duration
- `action` (String?) - Optional action button

**Documentation:** [ix_toast.md](doc/ix_toast.md)

---

#### IxEmptyState

Empty state placeholder component.

```dart
IxEmptyState(
  icon: Icons.inbox_outlined,
  title: 'No Data',
  message: 'There is no data to display',
  action: ElevatedButton(
    onPressed: () {},
    child: Text('Add Data'),
  ),
)
```

**Properties:**
- `icon` (IconData) - Display icon
- `title` (String) - Empty state title
- `message` (String) - Description message
- `action` (Widget?) - Optional action button

**Documentation:** [ix_empty_state.md](doc/ix_empty_state.md)

---

## Theme System

### IxTheme

Complete theming system with light and dark modes.

```dart
MaterialApp(
  theme: IxTheme.lightTheme,
  darkTheme: IxTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

**Available Themes:**
- `IxTheme.lightTheme` - Light theme
- `IxTheme.darkTheme` - Dark theme
- `IxTheme.customTheme()` - Create custom theme

**Documentation:** [copilot_colors.md](doc/copilot_colors.md)

---

## Icons

### IxIcons

Access to 1400+ Siemens iX icons.

```dart
import 'package:your_app/ix_icons.dart';

// Use icons in widgets
Icon(IxIcons.home)
Text('Home', style: TextStyle(fontFamily: IxIcons.fontFamily))
```

**Icon Categories:**
- Navigation icons
- Action icons
- Status icons
- And 1400+ more...

**Complete Icon List:** [ix_icons.md](doc/ix_icons.md)

---

## Utilities

### Icon Generator Tool

Command-line tool to generate icons from official Siemens source.

```bash
# Basic usage
dart run ix_flutter:generate_icons

# Custom paths
dart run ix_flutter:generate_icons \
  --output lib/generated \
  --assets assets/icons

# For library packages
dart run ix_flutter:generate_icons \
  --package my_library_name

# See all options
dart run ix_flutter:generate_icons --help
```

**Options:**
- `--output` - Output directory for generated Dart file
- `--assets` - Assets directory for icon SVGs
- `--package` - Package name for icon references
- `--verbose` - Verbose output
- `--help` - Show help message

**Documentation:** [ix_icons.md](doc/ix_icons.md)

---

## Quick Links

### Documentation
- [Complete Component Documentation](doc/)
- [Icon Integration Guide](doc/ix_icons.md)
- [Color System](doc/copilot_colors.md)
- [Contributing Guide](CONTRIBUTING.md)

### Official Resources
- [Siemens iX Design System](https://ix.siemens.io)
- [Icon Library](https://www.npmjs.com/package/@siemens/ix-icons)
- [Design Guidelines](https://ix.siemens.io/docs/guidelines/)

### Examples
- [Example Application](example/)
- [Example Screens](example/lib/screen/)

---

## API Stability

This is a community package with ongoing development. While we aim for stability:

- ⚠️ Minor versions may include breaking changes
- 🔄 APIs may evolve based on Flutter/Dart updates
- ✅ We follow semantic versioning when possible

---

**Last Updated**: January 2026
**Package Version**: 1.0.0
**Flutter**: >=3.10.0
**Dart**: >=3.10.0
