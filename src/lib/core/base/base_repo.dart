abstract class BaseRepository<T> {
  Future<void> add(T item);

  Future<void> addAll(List<T> items);

  Future<void> update(String id, T item);

  Future<void> delete(String id);

  Future<T?> getById(String id);

  Future<List<T>> getAll();

  Future<void> clear();
}
