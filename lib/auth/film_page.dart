import 'package:flutter/material.dart';
import 'package:hardflix/auth/home_page.dart';

class TelaFilme extends StatefulWidget {
  final Filme filme;
  const TelaFilme({super.key, required this.filme});

  @override
  State<TelaFilme> createState() => _TelaFilmeState();
}

class _TelaFilmeState extends State<TelaFilme> {
  Future<bool?> showWarning(BuildContext context) async => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
              "Deseja voltar à lista de filmes? Suas alterações não salvas serão perdidas."),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sim"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não"),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final filmeController = TextEditingController(text: widget.filme.nome);

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                widget.filme.nome = filmeController.text;
              },
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: backGround(
          Container(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Insira a descrição do item',
              ),
              keyboardType: TextInputType.text,
              maxLines: 8,
              minLines: 4,
              controller: filmeController,
            ),
          ),
        ),
      ),
    );
  }
}

Widget backGround(Widget child) {
  return Container(
    height: double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 127, 174, 233),
          Color.fromARGB(255, 78, 143, 218),
          Color.fromARGB(255, 45, 120, 212),
          Color.fromARGB(255, 5, 72, 148),
        ],
      ),
    ),
    child: child,
  );
}
