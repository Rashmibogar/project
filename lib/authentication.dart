import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database.dart';


abstract class BaseAuth {
  Future<String> signIn(String email, String password);
 Future<String> signUp(String name,String email, String phone, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
  Future<String> signInWithGoogle();
}
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String name,phone;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }
/* Future<String> signUp(String username,String phone,String email, String password) async { 
     final FirebaseUser user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password) .then((currentUser) 
        => Firestore.instance.collection("users").document(currentUser.user.uid).
        setData({"uid": currentUser.user.uid,"name": username,"phone": phone,"email": email,}))) as FirebaseUser;
    return user.uid;
  }*/
  Future<String> signUp(String name, String email, String phone, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
        await DatabaseService(uid: user.uid).createUserData(name, phone);

    return user.uid;
  }
  /* Future<String> signUp(String email, String password) async {
     try{
   final FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)) as FirebaseUser;
   await DatabaseService(uid: user.uid).updateUserData(name, phone);
    return user.uid;
     }
     catch(e){
       print(e.toString());
       return null;
     }
  }*/
  
  Future<FirebaseUser> getCurrentUser() async {
   final FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

Future<String> signInWithGoogle() async {
  try{
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await  _firebaseAuth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await  _firebaseAuth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
  }
  catch(e){
    print(e.toString());
    return null;
  }
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}
Future<void> sendSignInWithEmailLink(String email) async {
    return _firebaseAuth.sendSignInWithEmailLink(
        email: email,
        url: 'https://travel-a60cf.firebaseapp.com',
        androidInstallIfNotAvailable: true,
        androidMinimumVersion: '21',
        androidPackageName: 'com.example.travel',
        handleCodeInApp: true,
        iOSBundleID: '');
  }
  Future<AuthResult> signInWithEmailLink(String email, String link) async {
    return _firebaseAuth.signInWithEmailAndLink(email: email, link: link);
  }
}