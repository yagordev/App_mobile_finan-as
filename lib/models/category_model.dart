class CategoryModel {
  final String id;
  final String name;
  final int iconCode; // Para salvar o IconData
  final int colorValue; // Para salvar a cor

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });
}
