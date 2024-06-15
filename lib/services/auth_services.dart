import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection("Users").doc(uid).get();
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 确保从 Firestore 中加载用户数据
      DocumentSnapshot userData = await getUserData(userCredential.user!.uid);
      if (userData.exists) {
        print("User data: ${userData.data()}");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
          "name": "",
        },
      );

      return userCredential;
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userData = await getUserData(user.uid);
        if (!userData.exists) {
          await _firestore.collection("Users").doc(user.uid).set(
            {
              "uid": user.uid,
              "email": user.email,
              "name": "", //
            },
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  //登出
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}