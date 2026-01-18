# Contributing to ix_flutter

Thank you for your interest in contributing to ix_flutter! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inspiring community.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one.

When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem** in as many details as possible
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs if possible**
- **Include your environment details**: Flutter version, Dart version, OS, device/emulator

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **the expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

- Fill in the required template
- Follow the Dart/Flutter style guides (dartfmt, analyzer)
- Include appropriate test cases
- Update relevant documentation
- End all files with a newline

## Development Setup

### Prerequisites

- Flutter SDK: >=3.10.0
- Dart SDK: >=3.10.0
- Git
- A code editor (VS Code, Android Studio, etc.)

### Getting Started

1. **Fork the repository**
   ```bash
   # Go to https://github.com/SobSoft-s-r-o/ix_flutter and click "Fork"
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ix_flutter.git
   cd ix_flutter
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/SobSoft-s-r-o/ix_flutter.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   cd example
   flutter pub get
   cd ..
   ```

5. **Create a new branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```

### Building and Testing

#### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/ix_theme_color_tokens_test.dart
```

#### Static Analysis

```bash
# Analyze the library
flutter analyze lib/

# Analyze the example
flutter analyze example/lib/
```

#### Format Code

```bash
# Format Dart code
dart format lib/ test/ example/lib/

# Check formatting without modifying
dart format --dry-run lib/ test/ example/lib/
```

#### Build Examples

```bash
# Build web example
cd example
flutter build web

# Run example app
flutter run -d chrome
```

#### Icon Generation

```bash
# Generate icons for development/testing
dart run ix_flutter:generate_icons

# Generate with custom output path
dart run ix_flutter:generate_icons --output lib/generated --assets assets/icons
```

## Style Guidelines

### Dart/Flutter Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dartfmt` for automatic formatting
- Run `flutter analyze` before committing
- Use meaningful variable and function names
- Add comments for complex logic
- Write doc comments for public APIs

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Example:
```
Add support for custom icon colors

- Implement IxIcon color parameter
- Update icon documentation
- Add unit tests

Fixes #123
```

### Documentation

- Update relevant documentation in the [doc/](doc/) folder
- Update README.md if adding new features
- Include code examples for new features
- Update CHANGELOG.md with your changes

## Documentation Updates

When you make changes, update the relevant documentation:

1. **Component Documentation**: Update files in [doc/](doc/) folder
2. **Main README**: Update [README.md](README.md) if adding features
3. **Changelog**: Add entry to [CHANGELOG.md](CHANGELOG.md)
4. **Inline Comments**: Add/update code comments and doc strings

### Documentation Structure

- **doc/**: Component-specific documentation
- **README.md**: Main package documentation
- **CHANGELOG.md**: Version history
- **LICENSE**: License terms
- **ICON_LICENSING.md**: Icon licensing specifics

## Testing Requirements

### Test Coverage

- Add unit tests for new features
- Maintain or improve overall test coverage
- Test edge cases and error conditions
- Include integration tests where appropriate

### Test Guidelines

```dart
// Example test structure
void main() {
  group('IxSomething', () {
    testWidgets('should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IxSomething(),
          ),
        ),
      );

      expect(find.byType(IxSomething), findsOneWidget);
    });

    test('should calculate correctly', () {
      final result = someFunction();
      expect(result, expectedValue);
    });
  });
}
```

## Licensing and Copyright

- All contributions are licensed under the MIT License
- You agree that your contributions will be licensed under the MIT License
- Include copyright headers in new files if required
- Update AUTHORS/contributors list if applicable

## Icons and Design System

When working with icons or design patterns:

1. Icons are from the [Siemens iX Design System](https://ix.siemens.io)
2. Regenerate icons using the provided tool if needed
3. Ensure icon licensing compliance
4. Test icon generation on your system
5. Document any new icon integration patterns

## Submitting Changes

### Before Submitting

- [ ] Run `flutter analyze` and fix any issues
- [ ] Run `dart format` to format your code
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Update documentation
- [ ] Update CHANGELOG.md

### Creating a Pull Request

1. Push your branch to your fork:
   ```bash
   git push origin feature/AmazingFeature
   ```

2. Go to the original repository and create a Pull Request

3. Fill in the PR template with:
   - **Description**: What does this PR do?
   - **Type of Change**: Bug fix, feature, documentation, etc.
   - **Related Issues**: Closes #123
   - **Testing**: How have you tested this?
   - **Screenshots**: If applicable

### PR Review Process

- Maintainers will review your PR
- Address any requested changes
- Discussion may occur before merging
- Be patient and respectful during review

## Release Process

Maintainers handle releases. The process typically includes:

1. Bump version in pubspec.yaml
2. Update CHANGELOG.md
3. Tag release in Git
4. Publish to pub.dev

## Recognition

Contributors are recognized in:

- Pull request comments
- Release notes in CHANGELOG.md
- AUTHORS file (if applicable)

## Questions?

- **Documentation**: Check existing docs in [doc/](doc/)
- **Issues**: Search for similar issues
- **Discussions**: Open a GitHub Discussion
- **Email**: Contact maintainers

## Important Reminders

- ⚠️ This is NOT an official Siemens product
- 📋 Ensure compliance with Siemens iX Design System licensing
- 🔒 Respect intellectual property rights
- ✅ Follow the code of conduct
- 🤝 Be respectful and collaborative

Thank you for contributing to ix_flutter! 🎉

---

**Last Updated**: January 2026
**License**: MIT
