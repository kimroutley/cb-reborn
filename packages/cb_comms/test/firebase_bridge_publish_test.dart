// ignore_for_file: subtype_of_sealed_class
import 'package:cb_comms/src/firebase_bridge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class MockBatch extends Fake implements WriteBatch {
  int commitCount = 0;
  int setCount = 0;
  final List<DocumentReference> setDocs = [];
  final List<Map<String, dynamic>> setData = [];

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    setCount++;
    setDocs.add(document as DocumentReference<Map<String, dynamic>>);
    setData.add(data as Map<String, dynamic>);
  }

  @override
  Future<void> commit() async {
    commitCount++;
  }
}

class MockDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  int setCount = 0;
  final String _path;
  final MockFirestore _firestore;

  MockDocumentReference(this._path, this._firestore);

  @override
  String get path => _path;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    setCount++;
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference('$_path/$collectionPath', _firestore);
  }
}

class MockCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  final String _path;
  final MockFirestore _firestore;

  MockCollectionReference(this._path, this._firestore);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _firestore.getDoc('$_path/$path');
  }
}

class MockFirestore extends Fake implements FirebaseFirestore {
  final MockBatch batchInstance = MockBatch();
  int batchCount = 0;
  final Map<String, MockDocumentReference> _docs = {};

  @override
  WriteBatch batch() {
    batchCount++;
    return batchInstance;
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference(collectionPath, this);
  }

  MockDocumentReference getDoc(String path) {
    return _docs.putIfAbsent(path, () => MockDocumentReference(path, this));
  }
}

void main() {
  test('publishState uses a single batch for all writes (optimized)', () async {
    final mockFirestore = MockFirestore();
    final bridge = FirebaseBridge(joinCode: 'TEST_GAME', firestore: mockFirestore);

    final publicState = {'phase': 'day', 'dayCount': 1};
    final playerPrivateData = {
      'p1': {'role': 'medic'},
      'p2': {'role': 'creep'},
    };

    await bridge.publishState(
      publicState: publicState,
      playerPrivateData: playerPrivateData,
    );

    // Optimized expectations:
    // 1. gameDoc.set is NOT called directly anymore
    final gameDoc = mockFirestore.getDoc('games/TEST_GAME');
    expect(gameDoc.setCount, 0, reason: 'Expected 0 direct set calls on gameDoc after optimization');

    // 2. batch.commit is called once
    expect(mockFirestore.batchInstance.commitCount, 1, reason: 'Expected 1 batch commit');

    // 3. batch.set is called for the public state + each player
    expect(mockFirestore.batchInstance.setCount, 3, reason: 'Expected 3 set calls in batch (1 public + 2 players)');

    // Verify public state was added to batch first
    expect(mockFirestore.batchInstance.setDocs[0].path, 'games/TEST_GAME');
    expect(mockFirestore.batchInstance.setData[0], publicState);

    // Verify player data followed in the batch
    expect(mockFirestore.batchInstance.setData[1], playerPrivateData['p1']);
    expect(mockFirestore.batchInstance.setData[2], playerPrivateData['p2']);
  });
}
