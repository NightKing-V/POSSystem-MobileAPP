/// Category domain model and in-memory repository.

// ─── Model ────────────────────────────────────────────────────────────────────

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.colorIndex,
  });

  final String id;
  final String name;

  /// Index into [CategoryRepository.swatchColors].
  final int colorIndex;
}

// ─── Repository ───────────────────────────────────────────────────────────────

/// In-memory category store. Swap internals for a real data source later
/// without changing the public async API.
class CategoryRepository {
  CategoryRepository._internal();
  static final CategoryRepository instance = CategoryRepository._internal();

  final List<Category> _categories = [
    const Category(id: 'c1', name: 'Dairy',      colorIndex: 0),
    const Category(id: 'c2', name: 'Bakery',     colorIndex: 1),
    const Category(id: 'c3', name: 'Beverages',  colorIndex: 2),
    const Category(id: 'c4', name: 'Snacks',     colorIndex: 3),
  ];

  int _nextId = 5;

  Future<List<Category>> getAll() async => List.unmodifiable(_categories);

  Future<Category> add({required String name, required int colorIndex}) async {
    final cat = Category(
      id: 'c${_nextId++}',
      name: name.trim(),
      colorIndex: colorIndex,
    );
    _categories.add(cat);
    return cat;
  }

  Future<void> delete(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  bool nameExists(String name) =>
      _categories.any((c) => c.name.toLowerCase() == name.trim().toLowerCase());
}
