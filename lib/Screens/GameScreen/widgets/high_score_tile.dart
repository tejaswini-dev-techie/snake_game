import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String? docID;
  const HighScoreTile({super.key, required this.docID});

  @override
  Widget build(BuildContext context) {
    /* Get Firebase Collection */
    CollectionReference highScores =
        FirebaseFirestore.instance.collection("highscores");
    return FutureBuilder<DocumentSnapshot>(
      future: highScores.doc(docID).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Row(
            children: [
              Text(
                "${data['score']}",
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "${data['name']}",
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Text("Loading data...");
        }
      },
    );
  }
}
