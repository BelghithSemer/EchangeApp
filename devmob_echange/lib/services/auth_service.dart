import 'package:firebase_auth/firebase_auth.dart';
import 'package:devmob_echange/models/user.dart';
import 'package:devmob_echange/services/auth_manager.dart';

class AuthService {
  // Connexion
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await AuthManager.loginUser(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        return result['user'] as User?;
      }
      return null;
    } catch (e) {
      print('Erreur connexion dans AuthService: $e');
      return null;
    }
  }

  // Inscription - Utilise la nouvelle méthode
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final result = await AuthManager.registerUser(
        email: email,
        password: password,
        name: name,
      );

      if (result['success'] == true) {
        print('🎉 Inscription réussie dans AuthService');
        return result['user'] as User?;
      } else {
        print('❌ Échec de l\'inscription: ${result['error']}');
        return null;
      }
    } catch (e) {
      print('💥 Erreur critique dans signUp: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await AuthManager.logout();
  }

  // Écouter les changements d'authentification
  Stream<User?> get userStream => AuthManager.authStateChanges;
}