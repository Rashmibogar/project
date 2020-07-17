import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String uid;
  DatabaseService({this.uid});


  final CollectionReference users = Firestore.instance.collection('users');
  Future createUserData(String name,String phone) async{
    return await users.document(uid).setData({
      "name": name,"phone": phone
    });
  }
}