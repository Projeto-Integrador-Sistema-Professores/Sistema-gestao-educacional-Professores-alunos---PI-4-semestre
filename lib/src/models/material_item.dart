class MaterialItem {
  final String id;
  final String title;
  final String fileUrl;
  final String? fileName;
  
  MaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.fileName,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> j) => MaterialItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        fileUrl: j['fileUrl'] ?? '',
        fileName: j['fileName']?.toString(),
      );
}
