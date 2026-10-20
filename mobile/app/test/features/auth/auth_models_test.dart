import 'package:app/features/auth/data/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppUser ánh xạ enum viết hoa từ API', () {
    final user = AppUser.fromJson({
      'id': 'u1',
      'email': 'user@example.com',
      'name': 'Người dùng',
      'role': 'USER',
      'status': 'ACTIVE',
      'lastLoginAt': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-02T00:00:00.000Z',
    });

    expect(user.role, UserRole.user);
    expect(user.status, UserStatus.active);
    expect(user.toJson()['role'], 'USER');
  });
}
