import 'dart:async';
import 'dart:convert';
import 'dart:math' hide log;
import 'dart:developer';

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
import 'package:rabbit_kingdom/pages/home_page.dart';
import 'package:rabbit_kingdom/pages/login_page.dart';
import 'package:rabbit_kingdom/pages/not_verified_page.dart';
import 'package:rabbit_kingdom/pages/unknown_user_page.dart';
import 'package:rabbit_kingdom/services/notification_service.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Rxn<User> firebaseUser = Rxn<User>();
  StreamSubscription<User?>? _userChangesSub;

  @override
  void onInit() {
    super.onInit();
    _userChangesSub = _auth.userChanges().listen((user) {
      log("User changed: $user", name: "AuthController");
      log("Firebase user: ${firebaseUser.value}", name: "AuthController");

      final originalUser = firebaseUser.value;
      firebaseUser.value = user;
      if (
        (originalUser == null && user != null) ||
        (originalUser != null && user != null && originalUser.emailVerified != user.emailVerified)
      ) {
        initialize();
      } else if (originalUser != null && user == null) {
        logout();
      }
    });
  }

  @override
  void onClose() {
    _userChangesSub?.cancel();
    super.onClose();
  }

  Future<void> initialize() async {
    final user = firebaseUser.value;
    log("Initializing user: ${user?.email}, verified: ${user?.emailVerified}", name: "AuthController");

    if (user != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    }

    if (user == null) {
      Get.offAll(() => LoginPage());
      return;
    }

    if (!user.emailVerified) {
      Get.offAll(() => NotVerifiedPage());
      return;
    }

    try {
      RLoading.start();
      final userController = Get.find<UserController>();
      await userController.initUser(user);

      if (userController.user == null) throw Exception("User not initialized");

      if (userController.user!.group == KingdomUserGroup.unknown) {
        Get.offAll(() => UnknownUserPage());
      } else {
        await NotificationService.initialize(user.uid);
        await Get.find<AnnounceController>().initAnnounce();
        await Get.find<PricesController>().initPrices();
        await Get.find<RecordsController>().initRecords(user);
        await userController.triggerTaskComplete(KingdomTaskNames.login);
        Get.offAll(() => HomePage());
      }
    } catch (e) {
      log("Error during initUser: \$e", name: "AuthController");
      RSnackBar.error("Error", e.toString());
    } finally {
      RLoading.stop();
    }
  }

  Future<void> logout() async {
    Get.find<UserController>().onLogout();
    Get.find<AnnounceController>().onLogout();
    Get.find<PricesController>().onLogout();
    Get.find<RecordsController>().onLogout();
    await _auth.signOut();
    await _googleSignIn.signOut();
    firebaseUser.value = null;
    Get.offAll(() => LoginPage());
  }

  Future<void> sendVerificationEmail() async {
    final user = firebaseUser.value;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        RSnackBar.error("Login Failed", e.message ?? e.toString());
        rethrow;
      }
    } catch (e) {
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      log("Google SignIn error: \$e", name: "AuthController");
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  Future<void> loginWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        throw Exception("Apple identityToken is null");
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      log("Apple SignIn error: \$e", name: "AuthController");
      RSnackBar.error("Login Failed", e.toString());
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}