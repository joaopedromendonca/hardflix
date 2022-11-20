import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class getMovieData extends StatelessWidget {
  final String documentID;

  const getMovieData({super.key, required this.documentID});

  @override
  Widget build(BuildContext context) {
    CollectionReference filmes =
        FirebaseFirestore.instance.collection('filmes');

    return FutureBuilder<DocumentSnapshot>(
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text('Nome: ${data['nome']}');
        }
        return const Text('Carregando dados...');
      }),
    );
  }
}
