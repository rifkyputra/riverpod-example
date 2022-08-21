import 'dart:io';

import 'package:hive/hive.dart';

class AppSetupService {
  Stream<AppSetupModel> initialize() async* {
    Hive.init(Directory.current.path);

    final rent = await BoxCollection.open(
      DBCollections.rentTrx,
      {
        DBBoxes.lendList,
        DBBoxes.borrowList,
      },
      path: './',
    );

    final counter = await BoxCollection.open(
      DBCollections.counterColl,
      {
        DBBoxes.intCounter,
      },
      path: './',
    );

    yield (AppSetupModel(
      collection: {
        DBCollections.rentTrx: rent,
        DBCollections.counterColl: counter,
      },
    ));
  }
}

class AppSetupModel {
  final Map<String, BoxCollection> collection;
  final String? firebaseToken;

  AppSetupModel({
    required this.collection,
    this.firebaseToken,
  });
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
