import 'package:flutter/material.dart';

class MaterialTile extends StatelessWidget {
  final dynamic item;
  const MaterialTile({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf),
      title: Text(item.title ?? 'Sem título'),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Baixar (simulado)')));
        },
      ),
    );
  }
}
