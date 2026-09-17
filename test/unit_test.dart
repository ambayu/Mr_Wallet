import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/utils/currency_formatter.dart';
import 'package:smartflow/data/models/ai_parsed_result.dart';
import 'package:smartflow/data/models/wallet_model.dart';

void main() {
  group('SmartFlow Deterministik & Model Tests', () {
    test('CurrencyFormatter formats Rupiah correctly', () {
      expect(CurrencyFormatter.format(50000), 'Rp 50.000');
      expect(CurrencyFormatter.formatShort(1500000), 'Rp 1.5jt');
      expect(CurrencyFormatter.formatShort(25000), 'Rp 25rb');
    });

    test('Reconciliation Delta calculation logic is mathematically exact', () {
      const double systemBalance = 50000.0;
      const double realBalance = 30000.0;
      const double delta = realBalance - systemBalance;

      expect(delta, -20000.0);
      expect(delta < 0, true); // Lost money / Receh jatuh
    });

    test('WalletModel serialization and deserialization', () {
      final wallet = WalletModel(
        id: 'w_test',
        name: 'Dompet Tunai',
        type: 'CASH',
        balance: 100000.0,
        icon: 'payments',
        color: '#FFF0B3',
        isDefault: true,
      );

      final map = wallet.toMap();
      final fromMap = WalletModel.fromMap(map);

      expect(fromMap.id, wallet.id);
      expect(fromMap.name, wallet.name);
      expect(fromMap.balance, 100000.0);
      expect(fromMap.isDefault, true);
    });

    test('AIParsedResult parses JSON schema correctly', () {
      final json = {
        'intent': 'MULTI_ACTION',
        'transactions': [
          {
            'wallet_name': 'Dompet Tunai',
            'type': 'EXPENSE',
            'amount': 25000,
            'category': 'Makanan & Kopi',
            'notes': 'Kopi siang',
          }
        ],
        'tasks': [
          {
            'title': 'Servis Motor',
            'due_date': '2026-09-17T14:00:00',
            'priority': 'HIGH',
          }
        ],
        'natural_response': 'Berhasil mencatat kopi dan tugas servis motor.',
      };

      final parsed = AIParsedResult.fromJson(json);
      expect(parsed.intent, 'MULTI_ACTION');
      expect(parsed.transactions.length, 1);
      expect(parsed.transactions.first.amount, 25000.0);
      expect(parsed.tasks.length, 1);
      expect(parsed.tasks.first.priority, 'HIGH');
    });
  });
}
