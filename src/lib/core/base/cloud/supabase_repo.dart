import 'package:src/core/base/base_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRepository<T> extends BaseRepository<T> {
  final SupabaseClient client = Supabase.instance.client;

  String get tableName;

  Map<String, dynamic> toJson(T item);

  T fromJson(Map<String, dynamic> json);

  String getItemKey(T item);

  @override
  Future<void> add(T item) async {
    await client.from(tableName).insert(toJson(item));
  }

  @override
  Future<void> addAll(List<T> items) async {
    final data = items.map((e) => toJson(e)).toList();

    await client.from(tableName).insert(data);
  }

  @override
  Future<void> delete(String key) async {
    await client.from(tableName).delete().eq('id', key);
  }

  @override
  Future<void> update(String key, T item) async {
    await client.from(tableName).update(toJson(item)).eq('id', key);
  }

  @override
  Future<T?> get(String key) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('id', key)
        .maybeSingle();

    if (response == null) return null;

    return fromJson(response);
  }

  @override
  Future<List<T>> getAll() async {
    final response = await client.from(tableName).select();

    return (response as List).map((e) => fromJson(e)).toList();
  }

  @override
  Future<void> clear() async {
    await client.from(tableName).delete().neq('id', '');
  }
}
