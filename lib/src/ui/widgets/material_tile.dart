import 'package:flutter/material.dart';

class MaterialTile extends StatelessWidget {
  final dynamic item;
  final Color color;
  final VoidCallback? onDownload;

  const MaterialTile({
    required this.item,
    this.color = const Color(0xFF1FB1C2), // cor turquesa padrão
    this.onDownload,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color, // define a cor de fundo
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // bordas arredondadas
      ),
      elevation: 2, // leve sombra para destaque
      child: ListTile(
        leading: const Icon(
          Icons.picture_as_pdf,
          color: Colors.white, // ícone branco sobre fundo colorido
        ),
        title: Text(
          item.title ?? 'Sem título',
          style: const TextStyle(
            color: Colors.white, // texto branco
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: onDownload ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Baixar (simulado)')),
            );
          },
        ),
      ),
    );
  }
}
