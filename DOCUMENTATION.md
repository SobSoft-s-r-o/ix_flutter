# ix_flutter Documentation Index

Complete navigation guide to all ix_flutter documentation.

## Quick Navigation

### 🚀 Getting started
- **[README.md](README.md)** - repository and package overview
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - step-by-step setup guide
- **[FAQ.md](FAQ.md)** - frequently asked questions

### 📚 Reference
- **[API_REFERENCE.md](API_REFERENCE.md)** - API index and `dart doc`
- **[doc/](doc/)** - component guides
- **[doc/tokens.md](doc/tokens.md)** - generated color-token table
- **[UPSTREAM.md](UPSTREAM.md)** - the pinned `@siemens/ix` baseline

### 🤝 Contributing & community
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - how to contribute, plus the release checklist
- **[SECURITY.md](SECURITY.md)** - security policy and reporting
- **[packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md)** - version history

### ⚖️ Legal
- **[packages/ix_flutter/LICENSE](packages/ix_flutter/LICENSE)** - MIT License
- **[packages/ix_flutter/ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md)** - icon licensing and compliance
- **[packages/ix_flutter/THIRD_PARTY_NOTICES.md](packages/ix_flutter/THIRD_PARTY_NOTICES.md)** - bundled third-party assets
- **[ICON_MIGRATION.md](ICON_MIGRATION.md)** - migrating off the deprecated `IxIcons` getters

---

## Component documentation

| Page | Covers |
|---|---|
| [doc/ix_application_scaffold.md](doc/ix_application_scaffold.md) | `IxApplicationScaffold`, `IxMenuEntry`, `IxApplicationStrings` |
| [doc/ix_blind.md](doc/ix_blind.md) | `IxBlind`, `IxBlindAccordion` |
| [doc/ix_breadcrumb.md](doc/ix_breadcrumb.md) | `IxBreadcrumb`, stable keys, `IxBreadcrumbStrings` |
| [doc/ix_dropdown_button.md](doc/ix_dropdown_button.md) | `IxDropdownButton`, placements, keyboard model |
| [doc/ix_empty_state.md](doc/ix_empty_state.md) | `IxEmptyState` layouts and types |
| [doc/ix_icons.md](doc/ix_icons.md) | `IxIcon`, `IxIconKey`, `IxIconResolver`, the generator |
| [doc/ix_responsive_data_view.md](doc/ix_responsive_data_view.md) | `IxResponsiveDataView`, `IxPaginationBar` |
| [doc/ix_spinner.md](doc/ix_spinner.md) | `IxSpinner` sizes and variants |
| [doc/ix_toast.md](doc/ix_toast.md) | `IxToastService`, `IxToastOverlay`, `IxToastHandle` |

## Theme documentation

| Page | Covers |
|---|---|
| [doc/theming.md](doc/theming.md) | `IxThemeBuilder`, `IxThemeController`, `IxCustomPalette` |
| [doc/tokens.md](doc/tokens.md) | every `IxThemeColorToken` with its light/dark value |
| [doc/typography.md](doc/typography.md) | `IxTypography`, `IxFonts`, the type scale |
| [doc/density.md](doc/density.md) | `IxDensity`, `IxDensityScope`, `IxIconButton` |

---

## Documentation by topic

### Installation & setup
1. Read the [README.md](README.md) overview
2. Follow the [GETTING_STARTED.md](GETTING_STARTED.md) tutorial
3. Check [FAQ.md](FAQ.md) for common issues

### Using components
1. Find the component in [API_REFERENCE.md](API_REFERENCE.md)
2. Read its page in [doc/](doc/)
3. Check [example/](example/) for working code

### Icons & icon generation
1. Read [GETTING_STARTED.md#icon-setup](GETTING_STARTED.md#icon-setup)
2. Follow the complete guide in [doc/ix_icons.md](doc/ix_icons.md)
3. Check [packages/ix_flutter/ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) for compliance

### Theme & styling
1. Review [doc/theming.md](doc/theming.md)
2. Look up colors in [doc/tokens.md](doc/tokens.md)
3. See the component pages for per-component theme extensions

### Contributing
1. Read the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines
2. Follow the development setup instructions
3. Review the code style, test conventions and release checklist

### Security & compliance
1. Check [SECURITY.md](SECURITY.md) for the security policy
2. Review the [LICENSE](packages/ix_flutter/LICENSE) for legal terms
3. See [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) for icon compliance

---

## Examples

### Complete example app
- [example/](example/) - full working Flutter app
- [example/lib/screen/](example/lib/screen/) - individual screen examples

### Running the example
```bash
cd example
flutter pub get
dart run ix_icons_generator:generate_icons
flutter run
```

### Documentation snippets
Every Dart snippet in the documentation is compiled in
[doc/snippets](doc/snippets):

```bash
cd doc/snippets
flutter pub get
flutter analyze
```

---

## Frequently searched topics

### Installation
- How to install? → [GETTING_STARTED.md](GETTING_STARTED.md#installation)
- What are the requirements? → [README.md](README.md#requirements)

### Icons
- Why no icons? → [FAQ.md](FAQ.md#q-why-arent-icons-included-in-the-package)
- How to generate? → [GETTING_STARTED.md#icon-setup](GETTING_STARTED.md#icon-setup)
- Troubleshooting? → [doc/ix_icons.md](doc/ix_icons.md#troubleshooting)

### Components
- What's available? → [API_REFERENCE.md](API_REFERENCE.md)
- How to use? → [GETTING_STARTED.md](GETTING_STARTED.md#using-components)
- Examples? → [example/lib/screen/](example/lib/screen/)

### Development
- Set up development? → [CONTRIBUTING.md](CONTRIBUTING.md#development-setup)
- Code style? → [CONTRIBUTING.md](CONTRIBUTING.md#style-guidelines)
- Testing? → [CONTRIBUTING.md](CONTRIBUTING.md#testing-requirements)
- Releasing? → [CONTRIBUTING.md](CONTRIBUTING.md#release-checklist)

### Help & support
- Get help → [FAQ.md](FAQ.md#getting-help)
- Report bugs → [CONTRIBUTING.md](CONTRIBUTING.md#reporting-bugs)
- Request features → [CONTRIBUTING.md](CONTRIBUTING.md#suggesting-enhancements)
- Security issues → [SECURITY.md](SECURITY.md)

---

## Documentation files overview

| File | Purpose | Audience |
| ---- | ------- | -------- |
| [README.md](README.md) | Repository overview | Everyone |
| [packages/ix_flutter/README.md](packages/ix_flutter/README.md) | The README published to pub.dev | Package users |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Setup tutorial | New users |
| [FAQ.md](FAQ.md) | Common questions | All users |
| [API_REFERENCE.md](API_REFERENCE.md) | API index | Developers |
| [doc/](doc/) | Component guides | Component users |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guide and release checklist | Contributors |
| [SECURITY.md](SECURITY.md) | Security policy | Security team |
| [UPSTREAM.md](UPSTREAM.md) | Pinned upstream baseline | Maintainers |
| [packages/ix_flutter/ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) | Icon compliance | Legal team |
| [packages/ix_flutter/THIRD_PARTY_NOTICES.md](packages/ix_flutter/THIRD_PARTY_NOTICES.md) | Bundled third-party assets | Legal team |
| [packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md) | Version history | All users |
| [packages/ix_flutter/LICENSE](packages/ix_flutter/LICENSE) | Legal terms | Legal team |

---

## Resources

### Official resources
- **Siemens iX**: https://ix.siemens.io
- **Icon Library**: https://www.npmjs.com/package/@siemens/ix-icons
- **Design Guidelines**: https://ix.siemens.io/docs/guidelines/overview

### This package
- **GitHub**: https://github.com/SobSoft-s-r-o/ix_flutter
- **pub.dev**: https://pub.dev/packages/ix_flutter
- **API docs**: https://pub.dev/documentation/ix_flutter/latest/
- **Issue tracker**: https://github.com/SobSoft-s-r-o/ix_flutter/issues
- **Discussions**: https://github.com/SobSoft-s-r-o/ix_flutter/discussions

---

## Feedback & contributions

### Found an error?
- Report it on [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
- Include the documentation link and a description

### Want to improve the docs?
- See [CONTRIBUTING.md](CONTRIBUTING.md)
- Remember that Dart snippets live in [doc/snippets](doc/snippets) and must
  keep analyzing cleanly

### Have questions?
- Check [FAQ.md](FAQ.md) first
- Open a discussion on [GitHub Discussions](https://github.com/SobSoft-s-r-o/ix_flutter/discussions)

---

📍 **Pro tip**: Use this index as a navigation hub. Click links to dive into specific documentation!
