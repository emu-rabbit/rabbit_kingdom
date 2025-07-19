import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rabbit_kingdom/pages/not_verified_page.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'dart:developer';

import '../pages/home_page.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    log("User: ${user?.email}, verified: ${user?.emailVerified}", name: "AuthController");
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else if (!user.emailVerified) {
      Get.offAll(() => NotVerifiedPage());
    } else {
      Get.offAll(() => HomePage());
    }
  }

  // 內部註冊，建立帳號（郵件密碼）
  Future<UserCredential> _registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // 嘗試登入，失敗則自動註冊再登入 (email/password)
  Future<void> loginWithEmail(String email, String password) async {
    log("email: $email password: $password");
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // 沒有註冊過，先註冊
        await _registerWithEmail(email, password);
        // 註冊成功後，已自動登入
      } else {
        RSnackBar.error("Login Failed", e.toString());
        rethrow;
      }
    } catch (e) {
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  // Google 登入，沒有帳號時也會自動建立
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 使用者取消登入
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // 嘗試用credential登入Firebase
        await _auth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // 沒有帳號，自動建立並登入
          // Firebase會自動幫你建立帳號，不用額外動作
          await _auth.signInWithCredential(credential);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      log('Google SignIn error: $e', name: 'AuthController');
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    // 也幫忙 signOut GoogleSignIn，避免殘留
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> sendVerificationEmail() async {
    if (firebaseUser.value != null && !firebaseUser.value!.emailVerified) {
      await firebaseUser.value!.sendEmailVerification();
      log("Send");
    }
  }
}