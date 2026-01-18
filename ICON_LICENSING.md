# Icon Licensing and EULA

## Overview

This Flutter package provides widgets based on the Siemens iX Design System. The package itself is licensed under the MIT License, but the icons require special licensing consideration.

## Icon Licensing

### Icon Source

Icons are sourced from the official **@siemens/ix-icons** npm package maintained by Siemens AG. These icons are NOT bundled with this package for licensing and distribution compliance reasons.

Package: https://www.npmjs.com/package/@siemens/ix-icons

### Icon Generation Process

Users must generate icons locally using the integrated icon generator:

```bash
dart run ix_flutter:generate_icons
```

This command:
1. Downloads icons from the official Siemens source (`@siemens/ix-icons` npm package)
2. Processes them into Flutter-compatible SVG format
3. Stores them in your application's assets directory

### Siemens iX Design System Terms

The Siemens iX Design System is owned and maintained by Siemens AG. When using icons from this system, you must comply with:

1. **Official Attribution**: Icons are provided by Siemens iX Design System
2. **Usage Rights**: Icons are provided for use in applications implementing Siemens iX Design System
3. **Restrictions**: Icons are subject to the Siemens iX Design System terms and conditions

For complete terms, visit: https://ix.siemens.io

### Visual Language and Guidelines

The design patterns and visual language implemented in this package are based on the Siemens iX Design System. Refer to the official documentation for:

- Component guidelines
- Design principles
- Brand usage rules
- Accessibility standards

## Package Licensing

### Code License

All Flutter widget code is licensed under the **MIT License**.

This includes:
- Widget implementations
- Component styles
- Theme system
- Icon generator tool
- All Dart source code

### Third-Party Components

This package uses:
- **flutter_svg** (MIT License)
- **http** (BSD License)
- **path** (BSD License)
- **args** (BSD License)
- **recase** (MIT License)
- **archive** (Apache 2.0 License)
- **yaml** (BSD License)

## Commercial Use

If you intend to use this package commercially:

1. **Review Licensing**: Ensure your use complies with MIT License terms
2. **Icon Compliance**: Verify your usage of Siemens iX icons complies with their terms
3. **Attribution**: Provide clear attribution to Siemens iX Design System
4. **Legal Review**: Consider legal review before commercial deployment

## Important Disclaimers

### Not an Official Product

This package is an **independent community adaptation** of the Siemens iX Design System for Flutter.

- **Not developed by Siemens**: Created by independent developers
- **Not maintained by Siemens**: Community maintained
- **Not endorsed by Siemens**: Not an official Siemens product
- **Not affiliated with Siemens**: Independent project

### Trademark Notice

- **Siemens**: Registered trademark of Siemens AG
- **Siemens iX**: Trademark/Design System owned by Siemens AG
- This package is not affiliated with or endorsed by Siemens AG

### Warranty Disclaimer

This package is provided "AS-IS" without any warranty or guarantee:

- No warranty of compatibility with official Siemens products
- No warranty of accuracy relative to official design system
- No guarantee of license compliance
- Users are solely responsible for license compliance

## User Responsibilities

When using this package, you are responsible for:

1. **Icon Licensing**: Complying with Siemens iX Design System icon licensing terms
2. **Attribution**: Properly attributing icons to Siemens iX Design System
3. **Legal Compliance**: Ensuring your use complies with all applicable licenses
4. **Design System Compliance**: Following Siemens iX guidelines for proper usage
5. **Commercial Use**: Conducting legal review for commercial applications

## Getting Help

### For Design System Questions

Visit the official Siemens iX Design System:
- Website: https://ix.siemens.io
- Documentation: https://ix.siemens.io/docs
- Icons: https://www.npmjs.com/package/@siemens/ix-icons

### For Package Issues

Report issues on the package repository, but note:
- This is not an official Siemens project
- Community support only
- Not affiliated with Siemens support

## Summary

**TL;DR**:

✅ **DO**:
- Use this package for Flutter applications
- Follow Siemens iX design guidelines
- Attribute icons to Siemens iX
- Generate icons from official source

❌ **DON'T**:
- Claim this is an official Siemens product
- Distribute icons without proper attribution
- Use icons contrary to Siemens iX terms
- Assume Siemens endorsement or support

## Questions?

If you have licensing questions:

1. **Package Code**: Refer to the MIT License
2. **Icons**: Refer to Siemens iX terms at https://ix.siemens.io
3. **Attribution**: Include proper credits to Siemens iX Design System
4. **Doubt**: Consult with legal/compliance team before commercial use

---

**Last Updated**: 2025
**Version**: 1.0

Remember: Proper licensing compliance ensures sustainable use of this package and respect for Siemens iX intellectual property.
