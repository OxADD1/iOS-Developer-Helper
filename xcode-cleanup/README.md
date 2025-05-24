# 🧹 Xcode Cleanup Tool

Removes Xcode cache files and build artifacts to free up disk space.

## What It Does

Cleans the following directories:
- **DerivedData** - Build artifacts and intermediate files
- **iOS DeviceSupport** - Old iOS version support files
- **CoreSimulator Caches** - iOS Simulator cache files
- **Archives** - App archives (optional)
- **Swift Package Manager Cache** - Downloaded dependencies
- **iOS Device Logs** - Device debugging logs
- **System Caches** - Various Xcode-related caches

**Typical space savings: 10-100GB**

## Usage

```bash
chmod +x xcode_cleanup.sh
./xcode_cleanup.sh
