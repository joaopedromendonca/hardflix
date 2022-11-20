// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hardflix/auth/film_page.dart';
import 'package:hardflix/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Filme {
  String nome;
  Filme({required this.nome});
  // final String nome;
  // final String classificacao;
  // final String anoLancamento;
  // final String genero;
  // final String duracao;
  // final String idioma;
  // final String avaliacao;

  // const Filme(
  //     {super.key,
  //     required this.nome,
  //     required this.classificacao,
  //     required this.anoLancamento,
  //     required this.avaliacao,
  //     required this.duracao,
  //     required this.genero,
  //     required this.idioma});

  // @override
  // Widget build(BuildContext context) {
  //   CollectionReference filmes =
  //       FirebaseFirestore.instance.collection('filmes');

  //   return FutureBuilder<DocumentSnapshot>(
  //     builder: ((context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         Map<String, dynamic> data =
  //             snapshot.data!.data() as Map<String, dynamic>;
  //         return Filme(
  //           nome: data['nome'],
  //           classificacao: data['classificacao'],
  //           anoLancamento: data['anoLancamento'],
  //           avaliacao: data['avaliacao'],
  //           duracao: data['duracao'],
  //           genero: data['genero'],
  //           idioma: data['idioma'],
  //         );
  //       }
  //       return const Text('Carregando dados...');
  //     }),
  //   );
  // }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  List<Filme> filmes = [];
  final _nomeController = TextEditingController();
  final _classController = TextEditingController();
  final _anoController = TextEditingController();
  final _avController = TextEditingController();
  final _durController = TextEditingController();
  final _genController = TextEditingController();
  final _idiController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIDs = [];

  @override
  void initState() {
    super.initState();
  }

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
                    child: Column(
                      children: [
                        TextFormField(
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
                            hintText: "Insira o nome do filme",
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (nome) => setState(() {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              _nomeController.clear();
                              return filmes.add(Filme(nome: nome));
                            }
                          }),
                        ),
                        TextFormField()
                      ],
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
          FutureBuilder(
            future: getDocIDs(),
            builder: ((context, snapshot) {
              return ReorderableListView.builder(
                proxyDecorator: proxyDecorator,
                itemCount: filmes.length,
                itemBuilder: (BuildContext context, int index) {
                  final filme = filmes[index];
                  return buildCard(index, filme);
                },
                padding: const EdgeInsets.all(8),
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  setState(() {
                    var tarefa = filmes[oldIndex];
                    filmes.removeAt(oldIndex);
                    filmes.insert(newIndex, tarefa);
                  });
                },
              );
            }),
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
            filme.nome,
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
          final tarefa = filmes[index];
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
        filmes.removeAt(index);
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
