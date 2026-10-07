import 'package:flutter_test/flutter_test.dart';
import 'package:bengkelflutter/core/network/page.dart';
import 'package:bengkelflutter/core/error/app_exception.dart';
import 'package:bengkelflutter/domain/entities/roles.dart';
import 'package:bengkelflutter/domain/entities/user_branch.dart';

void main() {
  group('Laravel response', () {
    test('paginator parsed', () {
      final p = ApiPage.fromJson<Map<String, dynamic>>({
        'current_page': 1,
        'data': [
          {'id': 1},
        ],
        'per_page': 20,
        'total': 1,
        'last_page': 1,
      }, (j) => j);
      expect(p.total, 1);
      expect(p.hasMore, isFalse);
    });
    test('unwrap {data}', () {
      expect(
        unwrapData({
          'data': {'a': 1},
        }),
        {'a': 1},
      );
    });
    test('validation summary', () {
      expect(
        validationSummary({
          'email': ['wajib diisi'],
        }),
        contains('email'),
      );
    });
  });

  group('roles', () {
    test('unrestricted', () {
      expect(Roles.unrestricted(['admin']), isTrue);
      expect(Roles.unrestricted(['mekanik']), isFalse);
      expect(Roles.canDriveTask(['mekanik']), isTrue);
      expect(Roles.canPay(['kasir']), isTrue);
      expect(Roles.canConvertEstimate(['service_advisor']), isFalse);
    });
  });

  group('user entity', () {
    test('parses spatie roles', () {
      final u = UserEntity.fromJson({
        'id': 1,
        'name': 'A',
        'email': 'a@x.id',
        'roles': [
          {'name': 'mekanik'},
        ],
        'permissions': [],
      });
      expect(u.roles, ['mekanik']);
    });
  });
}
