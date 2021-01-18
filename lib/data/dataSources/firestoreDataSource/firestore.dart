import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebirth_hero/data/model/boss.dart';

class Firestore {

  Firestore._privateConstructor(){
    firestore ??= FirebaseFirestore.instance;
  }

  FirebaseFirestore firestore;

  static final Firestore _instance = Firestore._privateConstructor();
  static Firestore get instance => _instance;

  CollectionReference getCollection(String collectionName) {
    return firestore.collection(collectionName);
  }

  Future<void> getDocumentById(String collectionName, String id) {
    return getCollection(collectionName).doc(id).get();
  }

  Future<void> deleteDocumentById(String collectionName, String id) {
    return getCollection(collectionName).doc(id).delete();
  }
  
  Future<void> insertScore(Boss boss, int niveau) async{
    final share = FirebaseFirestore.instance.collection('score');
    await share.doc().set({
      'Nom': boss.nom,
      'niveau': niveau
    });
  }

}