import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import '../models/rsa_key_model.dart';

class KeyManagerScreen extends StatelessWidget {
  const KeyManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crypto = Provider.of<CryptoProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión de Llaves"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Mis Llaves (Privadas)"),
              Tab(text: "Contactos (Públicas)"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyKeysTab(context, crypto),
            _buildContactsTab(context, crypto),
          ],
        ),
      ),
    );
  }

  Widget _buildMyKeysTab(BuildContext context, CryptoProvider crypto) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: crypto.isLoading
                  ? null
                  : () => _showGenerateDialog(context, crypto),
              icon: crypto.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add),
              label: Text(crypto.isLoading
                  ? "Generando..."
                  : "Generar Nuevo Par de Llaves"),
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ),
        Expanded(
          child: crypto.myKeys.isEmpty
              ? const Center(
                  child: Text("No tienes llaves. Genera una para empezar."))
              : ListView.separated(
                  itemCount: crypto.myKeys.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final key = crypto.myKeys[i];
                    final shortId =
                        CryptoProvider.generateFriendlyKeyId(key.publicKey);
                    return ExpansionTile(
                      leading: const Icon(Icons.vpn_key, color: Colors.blue),
                      title: Text(key.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("ID: $shortId"),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            crypto.deleteKey(key.id, true);
                          } else if (value == 'regenerate') {
                            _showRegenerateDialog(context, crypto, key);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'regenerate',
                            child: Row(
                              children: const [
                                Icon(Icons.refresh, size: 20),
                                SizedBox(width: 8),
                                Text("Regenerar Llaves"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Eliminar",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final formatted =
                                            CryptoProvider.formatPublicKey(
                                                key.publicKey);
                                        Clipboard.setData(
                                            ClipboardData(text: formatted));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Llave pública copiada")),
                                        );
                                      },
                                      icon: const Icon(Icons.share),
                                      label: const Text("Copiar Pública"),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showExportDialog(context, key),
                                      icon: const Icon(Icons.qr_code),
                                      label: const Text("Ver Completa"),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "⚠️ Tu llave PRIVADA nunca debe compartirse. Solo comparte la pública.",
                                style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactsTab(BuildContext context, CryptoProvider crypto) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showImportDialog(context, crypto),
              icon: const Icon(Icons.person_add),
              label: const Text("Importar Llave Pública de Contacto"),
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ),
        Expanded(
          child: crypto.contactKeys.isEmpty
              ? const Center(
                  child:
                      Text("No tienes contactos. Importa una llave pública."))
              : ListView.separated(
                  itemCount: crypto.contactKeys.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final key = crypto.contactKeys[i];
                    return ListTile(
                      leading: const Icon(Icons.public, color: Colors.green),
                      title: Text(key.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text("Clave: ${key.publicKey.substring(0, 20)}..."),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditDialog(context, crypto, key);
                          } else if (value == 'delete') {
                            crypto.deleteKey(key.id, false);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text("Editar"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Eliminar",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context, RsaKeyModel key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Llave Pública: ${key.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "ID: ${CryptoProvider.generateFriendlyKeyId(key.publicKey)}"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  CryptoProvider.formatPublicKey(key.publicKey),
                  style: const TextStyle(fontFamily: 'Monospace', fontSize: 10),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final formatted =
                        CryptoProvider.formatPublicKey(key.publicKey);
                    Clipboard.setData(ClipboardData(text: formatted));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Llave pública copiada")),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Copiar Llave"),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog(BuildContext context, CryptoProvider crypto) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Generar Llaves"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Esto generará una llave Privada (para ti) y una Pública (para compartir)."),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Nombre del perfil",
                hintText: "Ej: Personal, Trabajo",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx);
                crypto.generateNewKeyPair(controller.text);
              }
            },
            child: const Text("Generar"),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, CryptoProvider crypto) {
    final nameCtrl = TextEditingController();
    final keyCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Importar Contacto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: "Nombre del Contacto",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keyCtrl,
                  onChanged: (value) {
                    setState(() {
                      if (value.trim().isEmpty) {
                        errorText = null;
                      } else if (!CryptoProvider.isValidPublicKeyFormat(
                          value)) {
                        errorText =
                            "Formato de llave pública inválido.\nDebe comenzar con -----BEGIN PUBLIC KEY-----";
                      } else {
                        errorText = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Pegar Llave Pública",
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                    errorMaxLines: 3,
                  ),
                  maxLines: 4,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      keyCtrl.text = data!.text!;
                      if (!CryptoProvider.isValidPublicKeyFormat(data.text!)) {
                        setState(() {
                          errorText =
                              "El portapapeles no contiene una llave pública válida.";
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.paste),
                  label: const Text("Pegar del Portapapeles"),
                ),
                if (errorText == null && keyCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "✓ Formato válido detectado",
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar")),
            FilledButton(
              onPressed: errorText == null &&
                      nameCtrl.text.isNotEmpty &&
                      keyCtrl.text.isNotEmpty
                  ? () {
                      crypto.importContactKey(nameCtrl.text, keyCtrl.text);
                      Navigator.pop(ctx);
                    }
                  : null,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, CryptoProvider crypto, RsaKeyModel key) {
    final nameCtrl = TextEditingController(text: key.name);
    final keyCtrl = TextEditingController(text: key.publicKey);
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Editar Contacto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre del Contacto",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keyCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Llave Pública",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                Text(
                  "Nota: Para cambiar la llave pública, elimina este contacto y crea uno nuevo.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: nameCtrl.text.isNotEmpty
                  ? () {
                      final index =
                          crypto.contactKeys.indexWhere((k) => k.id == key.id);
                      if (index != -1) {
                        crypto.contactKeys[index] = RsaKeyModel(
                          id: key.id,
                          name: nameCtrl.text,
                          publicKey: key.publicKey,
                        );
                        crypto.notifyListeners();
                      }
                      Navigator.pop(ctx);
                    }
                  : null,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegenerateDialog(
      BuildContext context, CryptoProvider crypto, RsaKeyModel oldKey) {
    final controller = TextEditingController(text: oldKey.name);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Regenerar Llaves"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Esto eliminará la llave anterior y generará un nuevo par de llaves (privada y pública).\n\n"
              "⚠️ Los mensajes cifrados con la llave anterior NO podrán descifrarse.",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Nuevo nombre (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              crypto.deleteKey(oldKey.id, true);
              crypto.generateNewKeyPair(
                  controller.text.isNotEmpty ? controller.text : oldKey.name);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Regenerar"),
          ),
        ],
      ),
    );
  }
}
