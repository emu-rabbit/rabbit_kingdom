import 'dart:convert';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/controllers/records_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/pages/not_verified_page.dart';
import 'package:rabbit_kingdom/pages/unknown_user_page.dart';
import 'package:rabbit_kingdom/services/notification_service.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  void _setInitialScreen(User? user) async {
    log("User: ${user?.email}, verified: ${user?.emailVerified}", name: "AuthController");
    if (user != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    }
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else if (!user.emailVerified) {
      Get.offAll(() => NotVerifiedPage());
    } else {
      try {
        RLoading.start();
        final userController = Get.find<UserController>();
        await userController.initUser(firebaseUser.value!);
        if (userController.user != null) {
          if (userController.user!.group == KingdomUserGroup.unknown) {
            Get.offAll(() => UnknownUserPage());
          } else {
            await NotificationService.initialize(user.uid);
            final announceController = Get.find<AnnounceController>();
            await announceController.initAnnounce();
            final pricesController = Get.find<PricesController>();
            await pricesController.initPrices();
            final recordsController = Get.find<RecordsController>();
            await recordsController.initRecords(firebaseUser.value!);
            await userController.triggerTaskComplete(KingdomTaskNames.login);
            Get.offAll(() => HomePage());
          }
        } else {
          throw Exception("User not initialized");
        }
      } catch(e) {
        log("Error initUser $e", name: "AuthController");
        RSnackBar.error("Error initUser", "$e");
      } finally {
        RLoading.stop();
      }
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

  /// Apple 登入
  Future<void> loginWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      debugPrint('Generated rawNonce for AppleIDCredential: $rawNonce');
      debugPrint('Generated SHA256 nonce for AppleIDCredential: $nonce');

      // Apple 登入授權
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: nonce,
      );

      debugPrint('Raw appleCredential: ${appleCredential.toString()}'); // 您已有的
      debugPrint('Extracted identityToken from appleCredential: ${appleCredential.identityToken}'); // 新增


      // 檢查是否有拿到 token
      if (appleCredential.identityToken == null) {
        throw Exception("Apple identityToken is null");
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode
      );

      debugPrint('Created oauthCredential: ${oauthCredential.toString()}'); // 您已有的
      debugPrint('oauthCredential token: ${oauthCredential.token}'); // 新增
      debugPrint('oauthCredential accessToken: ${oauthCredential.accessToken}'); 

      // 登入 Firebase
      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      log('Apple SignIn error: $e', name: 'AuthController');
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  // 產生 nonce（避免重播攻擊）
  String _generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // 將 nonce 做 sha256 處理
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> logout() async {
    // 也幫忙 signOut GoogleSignIn，避免殘留
    final uc = Get.find<UserController>();
    uc.onLogout();
    final ac = Get.find<AnnounceController>();
    ac.onLogout();
    final pc = Get.find<PricesController>();
    pc.onLogout();
    final rc = Get.find<RecordsController>();
    rc.onLogout();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> sendVerificationEmail() async {
    if (firebaseUser.value != null && !firebaseUser.value!.emailVerified) {
      await firebaseUser.value!.sendEmailVerification();
    }
  }
}