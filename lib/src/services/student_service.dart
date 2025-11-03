import 'package:uuid/uuid.dart';
import 'api_client.dart';
import '../models/user.dart';

class StudentService {
  final ApiClient client;
  StudentService(this.client);

  Future<List<Map<String, dynamic>>> listAllWithSubjects() async {
    final res = await client.get('/students');
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items;
  }

  Future<User> createStudent({required String name, required String ra}) async {
    final id = const Uuid().v4();
    final payload = {
      'id': id,
      'name': name,
      'ra': ra,
      'role': 'student',
    };
    await client.post('/students', data: payload);
    return User(id: id, name: name, ra: ra, role: 'student');
  }
}


