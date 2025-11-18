class MaterialItem {
  final String id;
  final String title;
  final String fileUrl;
  final String? fileName;
  final String? fileStorageId; // ID do arquivo no GridFS
  
  MaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.fileName,
    this.fileStorageId,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> j) {
    // Extrai o fileStorageId do fileUrl se disponível
    // fileUrl tem formato: "/api/materials/{fileStorageId}/download"
    String? fileStorageId;
    final fileUrl = j['fileUrl'] ?? '';
    if (fileUrl.isNotEmpty && fileUrl.contains('/materials/')) {
      final parts = fileUrl.split('/materials/');
      if (parts.length > 1) {
        final downloadPart = parts[1];
        final downloadParts = downloadPart.split('/download');
        if (downloadParts.isNotEmpty) {
          fileStorageId = downloadParts[0];
        }
      }
    }
    
    return MaterialItem(
      id: j['id'] ?? '',
      title: j['title'] ?? '',
      fileUrl: fileUrl,
      fileName: j['fileName']?.toString(),
      fileStorageId: j['fileStorageId']?.toString() ?? fileStorageId,
    );
  }
}
