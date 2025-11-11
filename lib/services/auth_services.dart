import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Tạo tài khoản trên Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Lấy UID (ID duy nhất của người dùng)
      String uid = userCredential.user!.uid;

      // 3️⃣ Lưu thêm thông tin vào Realtime Database
      await _dbRef.child('users').child(uid).set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ Đăng ký thành công và lưu dữ liệu vào Realtime Database');
    } on FirebaseAuthException catch (e) {
      print('❌ Lỗi FirebaseAuth: ${e.message}');
    } catch (e) {
      print('❌ Lỗi khác: $e');
    }
  }
}
