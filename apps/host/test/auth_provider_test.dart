import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cb_host/auth/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Mocks
class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  Future<void> sendSignInLinkToEmail({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) async {
    // No-op
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    return emailLink.contains('signIn');
  }

  @override
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return MockUserCredential(MockUser(email: email));
  }
}

class MockUser extends Fake implements User {
  @override
  final String email;
  @override
  final String uid = 'test_uid';

  MockUser({required this.email});
}

class MockUserCredential extends Fake implements UserCredential {
  @override
  final User? user;
  MockUserCredential(this.user);
}

class MockFirebaseFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference();
  }
}

class MockCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference();
  }
}

class MockDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return MockDocumentSnapshot();
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}
}

class MockDocumentSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => false; // Assume profile doesn't exist initially

  @override
  Map<String, dynamic>? data() => null;
}

class MockAppLinks extends Fake implements AppLinks {
  final _controller = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  void simulateLink(Uri uri) => _controller.add(uri);
}

class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockAppLinks mockAppLinks;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockAppLinks = MockAppLinks();
    mockStorage = MockFlutterSecureStorage();
  });

  test('sendSignInLink stores email in secure storage', () async {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(mockFirestore),
        appLinksProvider.overrideWithValue(mockAppLinks),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );

    final notifier = container.read(authProvider.notifier);

    // Set email text
    notifier.emailController.text = 'test@example.com';

    // Call method
    await notifier.sendSignInLink();

    // Verify storage
    final storedEmail = await mockStorage.read(key: 'host_email_link_pending');
    expect(storedEmail, 'test@example.com');
  });

  test('Processing link retrieves and clears email from secure storage', () async {
    // Pre-populate storage
    await mockStorage.write(key: 'host_email_link_pending', value: 'saved@example.com');

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(mockFirestore),
        appLinksProvider.overrideWithValue(mockAppLinks),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );

    // Initialize notifier (starts listening to links)
    container.read(authProvider);

    // Simulate link
    final link = Uri.parse('https://example.com/signIn?code=123');
    mockAppLinks.simulateLink(link);

    // Wait for async processing
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if storage was cleared (meaning sign in succeeded and cleared the key)
    final storedEmail = await mockStorage.read(key: 'host_email_link_pending');
    expect(storedEmail, isNull);
  });
}
