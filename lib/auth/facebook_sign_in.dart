import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential> signInWithFacebook() async {
  // Trigger the sign-in flow
  final result = await FacebookAuth.instance.login();

  // Create a credential from the access token
  final facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken!.token);

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential);
}
