import 'dart:async';
import 'dart:io';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tryriverpod/firebase_options.dart';
import 'package:tryriverpod/providers/app_setup/app_setup_provider.dart';

class AppSetupService {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  Stream<AppSetupModel> initialize() async* {
    // final directory = await getTemporaryDirectory();
    // Hive.init(directory.path);
    String path = './';
    if (!kIsWeb) {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();

      await Permission.storage.request();
      await Permission.manageExternalStorage.request();

      await Directory(appDocDirectory.path + '/' + 'hive')
          .create(recursive: true);

      await Hive.initFlutter('hive');

      path = appDocDirectory.path + '/hive';

      try {
        final platformVersion = await ArFlutterPlugin.platformVersion;
      } on PlatformException {
        print('------------->platfor exception');
      }
    }

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    final rent = await BoxCollection.open(
      DBCollections.rentTrx,
      {
        DBBoxes.lendList,
        DBBoxes.borrowList,
      },
      path: path,
    );

    final counter = await BoxCollection.open(
      DBCollections.counterColl,
      {
        DBBoxes.intCounter,
      },
      path: path,
    );

    final setupModel = AppSetupModel(
      collection: {
        DBCollections.rentTrx: rent,
        DBCollections.counterColl: counter,
      },
    );

    yield (setupModel);

    await for (var user in FirebaseAuth.instance.authStateChanges()) {
      yield (setupModel.copyWith(user: user));
    }

    await for (var user in FirebaseAuth.instance.idTokenChanges()) {
      yield (setupModel.copyWith(user: user));
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class AppSetupModel {
  final Map<String, BoxCollection> collection;
  final String? firebaseToken;
  final User? user;

  AppSetupModel({
    required this.collection,
    this.firebaseToken,
    this.user,
  });

  AppSetupModel copyWith({
    Map<String, BoxCollection>? collection,
    String? firebaseToken,
    User? user,
  }) {
    return AppSetupModel(
      collection: collection ?? this.collection,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      user: user ?? this.user,
    );
  }
}

class DBCollections {
  static const String rentTrx = 'rentCollection';
  static const String counterColl = 'counterCollection';
}

class DBBoxes {
  static const String lendList = 'lend_list';
  static const String borrowList = 'borrow_list';

  static const String intCounter = 'int_counter';
}
