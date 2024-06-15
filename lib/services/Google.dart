import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Google {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    try {
      // 觸發Google的認證流程
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        print("Google sign-in was canceled by the user.");
        throw Exception("Google sign-in canceled");
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Get the signed-in user
      final User? user = userCredential.user;

      // Debug: Print user information
      print("Google sign-in successful. User UID: ${user?.uid}, Email: ${user?.email}");

      // Save user data to Firestore
      if (user != null) {
        await _firestore.collection("Users").doc(user.uid).set(
          {
            "uid": user.uid,
            "email": user.email,
          },
          SetOptions(merge: true), // Ensure we don't overwrite existing data
        );
        print("User data saved to Firestore.");
      } else {
        print("No user data available to save to Firestore.");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Error signing in with Google: ${e.message}");
      throw Exception(e.code);
    }
  }
}