# Hive Repository Guidelines

## Overview

Hive repositories are used for **local-only data storage**. Use these for:

- User session data
- App settings/preferences
- Search history
- Offline operation queues
- Cached data that needs to persist locally

## When to Use a Hive Repository

✅ **Use Hive Repository when:**

- Data should persist across app restarts
- Data is specific to the current device/user
- You need offline access to the data
- Data doesn't need to be synced with a server
- You're storing user preferences or session info

❌ **Don't use Hive Repository when:**

- Data needs to be shared across devices
- Data must be backed up on a server
- Multiple users need access to the same data
- You need complex querying/relationships

## Creating a New Hive Repository

### 1. Create the repository file

```dart
// lib/modules/your-module/repositories/your_repository.dart
import '../../../core/base/hive_repo.dart';

class YourRepository extends HiveRepository<Map<String, dynamic>> {
  @override
  String get boxName => 'your_box_name'; // Unique, lowercase with underscores

  @override
  String getItemKey(Map<String, dynamic> item) {
    return item['id'] as String; // Or whatever field you use as key
  }

  // Add your custom methods here
}
```
