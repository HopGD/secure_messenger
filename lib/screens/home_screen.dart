import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import '../models/rsa_key_model.dart';
import 'key_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _isEncryptMode = true;

  RsaKeyModel? _selectedContactKey;
  RsaKeyModel? _selectedMyKey;

  @override
  Widget build(BuildContext context) {
    final crypto = Provider.of<CryptoProvider>(context);

    if (_selectedContactKey != null &&
        !crypto.contactKeys.contains(_selectedContactKey)) {
      _selectedContactKey = null;
    }
    if (_selectedMyKey != null && !crypto.myKeys.contains(_selectedMyKey)) {
      _selectedMyKey = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crypto Translate"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: "Gestionar Llaves",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KeyManagerScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEncryptMode
                        ? "ENTRADA (Texto Plano)"
                        : "ENTRADA (Texto Cifrado)",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _isEncryptMode
                            ? "Escribe aquí el mensaje secreto..."
                            : "Pega aquí el código cifrado...",
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: () async {
                        final data =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          _inputController.text = data!.text!;
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildKeySelector(crypto),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  icon: const Icon(Icons.swap_vert),
                  tooltip: "Cambiar Modo",
                  onPressed: () {
                    setState(() {
                      _isEncryptMode = !_isEncryptMode;
                      _inputController.clear();
                      _outputController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _processAction(crypto),
                style:
                    FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                icon:
                    Icon(_isEncryptMode ? Icons.lock_outline : Icons.lock_open),
                label: Text(
                  _isEncryptMode ? "ENCRIPTAR MENSAJE" : "DESENCRIPTAR MENSAJE",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEncryptMode ? "SALIDA (Cifrado)" : "SALIDA (Legible)",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _outputController,
                      readOnly: true,
                      maxLines: null,
                      expands: true,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: _isEncryptMode ? 'Courier' : null,
                        color: _isEncryptMode ? Colors.grey[700] : Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _outputController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Resultado copiado")));
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeySelector(CryptoProvider crypto) {
    if (_isEncryptMode) {
      if (crypto.contactKeys.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text("Sin contactos (Importa una llave)",
              style: TextStyle(color: Colors.red)),
        );
      }
      return DropdownButtonHideUnderline(
        child: DropdownButton<RsaKeyModel>(
          isExpanded: true,
          value: _selectedContactKey,
          hint: const Text("Para: Seleccionar Contacto"),
          items: crypto.contactKeys.map((k) {
            return DropdownMenuItem(
                value: k, child: Text(k.name, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: (val) => setState(() => _selectedContactKey = val),
        ),
      );
    } else {
      if (crypto.myKeys.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text("Sin llaves propias (Genera una)",
              style: TextStyle(color: Colors.red)),
        );
      }
      return DropdownButtonHideUnderline(
        child: DropdownButton<RsaKeyModel>(
          isExpanded: true,
          value: _selectedMyKey,
          hint: const Text("Usar mi llave: Seleccionar"),
          items: crypto.myKeys.map((k) {
            return DropdownMenuItem(
                value: k, child: Text(k.name, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: (val) => setState(() => _selectedMyKey = val),
        ),
      );
    }
  }

  Future<void> _processAction(CryptoProvider crypto) async {
    FocusScope.of(context).unfocus();

    if (_isEncryptMode) {
      if (_selectedContactKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selecciona un destinatario")));
        return;
      }
      final result = await crypto.encryptMessage(
          _inputController.text, _selectedContactKey!);
      setState(() => _outputController.text = result);
    } else {
      if (_selectedMyKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selecciona tu llave privada")));
        return;
      }
      final result =
          await crypto.decryptMessage(_inputController.text, _selectedMyKey!);
      setState(() => _outputController.text = result);
    }
  }
}
