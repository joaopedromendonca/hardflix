// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hardflix/auth/film_page.dart';
import 'package:page_transition/page_transition.dart';

class Filme {
  String? nome;
  String? classificacao;
  String? anoLancamento;
  String? genero;
  String? duracao;
  String? idioma;
  String? avaliacao;

  Filme({
    required this.nome,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  List<Filme> tarefas = [];
  final _nomeController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIDs = [];

  Future getDocIDs() async {
    await FirebaseFirestore.instance.collection('usuarios').get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              docIDs.add(document.reference.id);
            },
          ),
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    getDocIDs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MaterialButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: Icon(Icons.logout),
        ),
        elevation: 0,
        flexibleSpace: appBarBackGround(),
        // automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              showDialog(
                barrierColor: Color.fromARGB(255, 140, 192, 255),
                context: context,
                builder: (context) => AlertDialog(
                  insetPadding: EdgeInsets.all(50),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      showCursor: true,
                      autofocus: true,
                      controller: _nomeController,
                      validator: (nome) {
                        if (nome == null || nome.isEmpty) {
                          return "Este campo é obrigatório.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Insira o nome da tarefa",
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (nome) => setState(() {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          _nomeController.clear();
                          return tarefas.add(Filme(nome: nome));
                        }
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: backGround(
          ReorderableListView.builder(
            proxyDecorator: proxyDecorator,
            itemCount: tarefas.length,
            itemBuilder: (BuildContext context, int index) {
              final tarefa = tarefas[index];
              return buildCard(index, tarefa);
            },
            padding: const EdgeInsets.all(8),
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) newIndex--;
              setState(() {
                var tarefa = tarefas[oldIndex];
                tarefas.removeAt(oldIndex);
                tarefas.insert(newIndex, tarefa);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildCard(int index, Filme filme) {
    return Card(
      key: ValueKey(filme),
      margin: const EdgeInsets.all(5),
      child: ListTile(
        key: ValueKey(filme),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            filme.nome!,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          PageTransition(
              type: PageTransitionType.rightToLeftJoined,
              childCurrent: widget,
              duration: Duration(milliseconds: 500),
              reverseDuration: Duration(milliseconds: 500),
              child: TelaFilme(filme: filme)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: (() => editar(index)),
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: (() => deletar(index)),
              icon: Icon(Icons.delete),
            )
          ],
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0.0,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  void editar(int index) => showDialog(
        context: context,
        builder: ((context) {
          final tarefa = tarefas[index];
          return AlertDialog(
            content: Form(
              key: _editFormKey,
              child: TextFormField(
                autofocus: true,
                initialValue: tarefa.nome,
                validator: (nome) {
                  if (nome == null || nome.isEmpty) {
                    return "Este campo é obrigatório.";
                  }
                  return null;
                },
                onFieldSubmitted: (nome) => setState(() {
                  if (_editFormKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    tarefa.nome = nome;
                  }
                }),
              ),
            ),
          );
        }),
      );

  void deletar(int index) => setState(() {
        tarefas.removeAt(index);
      });

  Widget backGround(Widget child) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // ignore: prefer_const_literals_to_create_immutables
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

  Widget appBarBackGround() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // ignore: prefer_const_literals_to_create_immutables
          colors: [
            Color.fromARGB(255, 140, 192, 255),
            Color.fromARGB(255, 127, 174, 233),
          ],
        ),
      ),
    );
  }
}
