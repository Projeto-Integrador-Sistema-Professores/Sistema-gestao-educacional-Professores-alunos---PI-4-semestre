class MaterialItem {
  final String id;
  final String title;
  final String fileUrl;
  MaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> j) => MaterialItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        fileUrl: j['fileUrl'] ?? '',
      );
}
