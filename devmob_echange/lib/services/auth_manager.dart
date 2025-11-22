import 'package:firebase_auth/firebase_auth.dart';
import 'package:devmob_echange/services/firebase_service.dart';

class AuthManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode d'inscription qui contourne le bug
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🚀 Début de l\'inscription pour: $email');

      // Étape 1: Créer l'utilisateur Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Utilisateur Auth créé: ${userCredential.user?.uid}');

      // Étape 2: Attendre un peu pour éviter les conflits
      await Future.delayed(Duration(milliseconds: 1000));

      // Étape 3: Créer le document utilisateur dans Firestore
      if (userCredential.user != null) {
        final userData = {
          'id': userCredential.user!.uid,
          'email': email,
          'name': name,
          'phone': '',
          'address': '',
          'rating': 0.0,
          'totalReviews': 0,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        await FirebaseService.firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        print('✅ Document utilisateur créé dans Firestore');

        return {
          'success': true,
          'user': userCredential.user,
          'userData': userData,
        };
      }

      return {'success': false, 'error': 'User creation failed'};
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');

      // Nettoyage en cas d'erreur
      try {
        if (_auth.currentUser != null) {
          await _auth.currentUser!.delete();
        }
      } catch (deleteError) {
        print('Erreur lors du nettoyage: $deleteError');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  // Connexion
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'user': userCredential.user,
      };
    } catch (e) {
      print('Erreur de connexion: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Vérifier si l'utilisateur est connecté
  static User? get currentUser => _auth.currentUser;

  // Stream des changements d'authentification
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}