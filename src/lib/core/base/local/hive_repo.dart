import 'package:hive/hive.dart';
import 'package:src/core/base/base_repo.dart';

abstract class HiveRepository<T> extends BaseRepository<T> {
  String get boxName;

  String getItemKey(T item);

  Future<Box<T>> get _box async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return await Hive.openBox<T>(boxName);
  }

  @override
  Future<void> add(T item) async {
    final box = await _box;
    final key = getItemKey(item);
    await box.put(key, item);
  }

  @override
  Future<void> addAll(List<T> items) async {
    final box = await _box;

    final map = {for (var item in items) getItemKey(item): item};

    await box.putAll(map);
  }

  @override
  Future<void> delete(String key) async {
    final box = await _box;
    await box.delete(key);
  }

  @override
  Future<void> update(String key, T item) async {
    final box = await _box;

    if (box.containsKey(key)) {
      await box.put(key, item);
    }
  }

  @override
  Future<T?> getById(String id) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName).get(id);
    }
    return null;
  }

  @override
  Future<List<T>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
