## 2. Supabase Repository Guidelines (`SUPABASE_REPO_GUIDELINES.md`)

````markdown
# Supabase Repository Guidelines

## Overview

Supabase repositories are used for **cloud data storage**. Use these for:

- User profiles
- Parking spaces
- Reservations
- Reviews
- Payments
- Any data that needs to be shared across devices/users

## When to Use a Supabase Repository

✅ **Use Supabase Repository when:**

- Data needs to be accessible across multiple devices
- Multiple users need to access the same data
- Data requires real-time updates
- You need complex queries and relationships
- Data must be backed up and persistent

❌ **Don't use Supabase Repository when:**

- Data is device-specific (use Hive instead)
- User doesn't need to access data elsewhere
- You need offline-only functionality

## Creating a New Supabase Repository

### 1. Create your model class first

```dart
// lib/modules/your-module/models/your_model.dart
class YourModel {
  final String id;
  final String name;
  final DateTime createdAt;

  YourModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory YourModel.fromJson(Map<String, dynamic> json) {
    return YourModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For Hive keys if needed
  String get key => id;
}
```
````
