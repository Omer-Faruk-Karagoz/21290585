import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String> registerUser(String email, String password, String name, String surname, String username, int age, String gender) async {
  try {
    UserCredential user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(user.user!.uid).set({
      'email': email,
      'firstName': name,
      'lastName': surname,
      'username': username,
      'age': age,
      'gender': gender,
    });
    return "success";
  } catch (e) {
    return e.toString();
  }
}
Future<void> addComment(String recipeId, String userId, double rating, String comment) async {
    try {
      final docRef = _firestore.collection('ratings').doc(recipeId);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        await docRef.update({
          'users': FieldValue.arrayUnion([userId]),
          'rate': FieldValue.arrayUnion([rating]),
          'comments': FieldValue.arrayUnion([comment]),
        });
      } else {
        await docRef.set({
          'users': [userId],
          'rate': [rating],
          'comments': [comment],
        });
      }
    } catch (e) {
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> getComments(String recipeId) async {
  try {
    final docRef = _firestore.collection('ratings').doc(recipeId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      List<String> userIds = List<String>.from(data['users']);
      List<dynamic> comments = data['comments'] ?? [];
      List<dynamic> ratings = data['rate'] ?? [];

      List<Map<String, dynamic>> result = [];

      for (int i = 0; i < userIds.length; i++) {
        String userId = userIds[i];
        String? username = await getUsernameById(userId);

        result.add({
          'username': username ?? 'Unknown User',
          'comment': comments.length > i ? comments[i] : null,
          'rating': ratings.length > i ? ratings[i] : null,
        });
      }

      return result;
    } else {
      return [];
    }
  } catch (e) {
    rethrow;
  }
}

Future<String?> getUsernameById(String userId) async {
  try {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()?['username'];
    } else {
      return null;
    }
  } catch (e) {
    rethrow;
  }
}


  Future<String> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}