# Security Policy

## Supported Versions

| Version | Supported          | Notes                                    |
| ------- | ------------------ | ---------------------------------------- |
| 1.0.0   | ✅ Yes             | Current stable release                   |
| < 1.0.0 | ❌ No              | Legacy preview builds                    |

## Reporting a Vulnerability

If you discover a security vulnerability in ix_flutter, please **do not** open a public GitHub issue. Instead, please report it responsibly by:

1. **Email**: Send details to the maintainers (check CONTRIBUTING.md for contact info)
2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce (if applicable)
   - Potential impact
   - Suggested fix (if you have one)

3. **Timeline**:
   - You should receive acknowledgment within 48 hours
   - We will investigate and provide updates
   - Security fixes will be released as soon as possible

## Security Considerations

### Icon Files

- Icons are downloaded from the official [@siemens/ix-icons](https://www.npmjs.com/package/@siemens/ix-icons) npm package
- The icon generator verifies source integrity
- Always use the official generator tool
- Keep the tool updated for security patches

### Dependencies

This package uses the following dependencies:

- **flutter_svg**: SVG rendering for Flutter
- **http**: HTTP client for downloading icons
- **path**: Path manipulation utilities
- **args**: Command-line argument parsing
- **recase**: String case conversion
- **archive**: Archive extraction
- **yaml**: YAML file parsing

All dependencies are regularly updated for security fixes. Please keep your pubspec.yaml updated.

### Best Practices

When using ix_flutter:

1. **Keep Flutter and Dart Updated**
   ```bash
   flutter upgrade
   dart upgrade
   ```

2. **Keep ix_flutter Updated**
   ```bash
   flutter pub upgrade ix_flutter
   ```

3. **Review Dependencies**
   ```bash
   flutter pub outdated
   ```

4. **Run Icon Generation Safely**
   - Only run `dart run ix_flutter:generate_icons` on trusted machines
   - The generator downloads icons from official npm source
   - Verify icon files before use in production

## Known Issues

Currently, there are no known security issues. If you discover one, please report it following the procedure above.

## Security Updates

When a security vulnerability is identified and fixed:

1. A patch version is released (e.g., 0.0.2)
2. Security advisory is published
3. CHANGELOG.md is updated
4. Release notes highlight the security fix

Users are encouraged to update immediately when security updates are available.

## Third-Party Components

### Siemens iX Design System

- **Source**: https://ix.siemens.io
- **Icons**: https://www.npmjs.com/package/@siemens/ix-icons
- **Licensing**: See [ICON_LICENSING.md](ICON_LICENSING.md)

The Siemens iX Design System is maintained by Siemens AG. Security considerations for icons should follow Siemens guidelines.

## Vulnerability Disclosure

We follow responsible disclosure practices:

1. **Private Report**: Security issues reported privately
2. **Investigation**: Thorough analysis of the vulnerability
3. **Patch Development**: Fix is developed and tested
4. **Coordination**: Release timing coordinated with reporters
5. **Public Disclosure**: Advisory and fix released simultaneously

## Compliance

This package aims to comply with:

- OWASP guidelines
- Flutter security best practices
- Dart security recommendations
- Siemens iX Design System requirements

## Questions?

For security-related questions, please contact the maintainers privately rather than opening public issues.

---

**Last Updated**: January 2026
**Version**: 1.0

Remember: Security is a shared responsibility. Please report vulnerabilities responsibly!
