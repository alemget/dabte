// SQLite database helper for "Debt Max - ديوني ماكس" app

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/client.dart';
import '../models/transaction.dart';

class DebtDatabase {
  static final DebtDatabase instance = DebtDatabase._internal();
  static Database? _db;

  DebtDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  /// Reset database connection (useful after restore)
  Future<void> resetDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'debts.db');

    return openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            createdAt TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            clientId INTEGER NOT NULL,
            amount REAL NOT NULL,
            details TEXT,
            date TEXT NOT NULL,
            currency TEXT NOT NULL,
            isLocal INTEGER NOT NULL,
            isForMe INTEGER NOT NULL,
            reminderDate TEXT,
            FOREIGN KEY (clientId) REFERENCES clients(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE profile_info (
            id INTEGER PRIMARY KEY DEFAULT 1,
            name TEXT,
            phone TEXT,
            address TEXT,
            footer TEXT
          );
        ''');

        // Create indexes for performance
        await db.execute('CREATE INDEX idx_transactions_clientId ON transactions(clientId)');
        await db.execute('CREATE INDEX idx_transactions_currency ON transactions(currency)');
        await db.execute('CREATE INDEX idx_transactions_date ON transactions(date DESC)');
        await db.execute('CREATE INDEX idx_clients_name ON clients(name COLLATE NOCASE)');
        await db.execute('CREATE INDEX idx_transactions_composite ON transactions(clientId, isForMe, currency)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE clients ADD COLUMN phone TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE profile_info (
              id INTEGER PRIMARY KEY DEFAULT 1,
              name TEXT,
              phone TEXT,
              address TEXT,
              footer TEXT
            );
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE clients ADD COLUMN createdAt TEXT');
          // Set createdAt for existing clients to current time
          final now = DateTime.now().toIso8601String();
          await db.execute('UPDATE clients SET createdAt = ? WHERE createdAt IS NULL', [now]);
        }
        if (oldVersion < 5) {
          // Add indexes for performance optimization
          await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_clientId ON transactions(clientId)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_currency ON transactions(currency)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_clients_name ON clients(name COLLATE NOCASE)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_composite ON transactions(clientId, isForMe, currency)');
        }
        if (oldVersion < 6) {
          // إضافة عمود تذكير السداد
          await db.execute('ALTER TABLE transactions ADD COLUMN reminderDate TEXT');
        }
      },
    );
  }

  Future<int> insertClient(String name, {String? phone}) async {
    final db = await database;
    return db.insert('clients', {
      'name': name, 
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final rows = await db.query('clients', orderBy: 'name');
    return rows.map(Client.fromMap).toList();
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'clientId = ?', whereArgs: [id]);
    return db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateClient(int id, String name, {String? phone}) async {
    final db = await database;
    return db.update('clients', {'name': name, 'phone': phone}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(DebtTransaction tx) async {
    final db = await database;
    return db.insert('transactions', tx.toMap());
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(DebtTransaction tx) async {
    final db = await database;
    return db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<bool> hasTransactionsWithCurrency({required String name}) async {
    final db = await database;
    final trimmedName = name.trim();
    final rows = await db.query(
      'transactions',
      where: 'TRIM(currency) = ?',
      whereArgs: [trimmedName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<DebtTransaction>> getClientTransactions(int clientId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
    return rows.map(DebtTransaction.fromMap).toList();
  }

  Future<Map<String, double>> getSummary() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT isForMe, SUM(amount) AS total
      FROM transactions
      GROUP BY isForMe
    ''');

    double forMe = 0;
    double onMe = 0;

    for (final row in rows) {
      final isForMe = row['isForMe'] == 1;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (isForMe) {
        forMe = total;
      } else {
        onMe = total;
      }
    }

    return {'forMe': forMe, 'onMe': onMe};
  }
  
  
  // Profile Info Methods
  Future<Map<String, dynamic>?> getProfileInfo() async {
    final db = await database;
    final rows = await db.query('profile_info', where: 'id = 1');
    if (rows.isNotEmpty) {
      return rows.first;
    }
    return null;
  }

  Future<void> saveProfileInfo({
    required String name,
    required String phone,
    required String address,
    required String footer,
  }) async {
    final db = await database;
    final data = {
      'id': 1,
      'name': name,
      'phone': phone,
      'address': address,
      'footer': footer,
    };
    
    // Using conflict algorithm to insert or update
    await db.insert(
      'profile_info', 
      data, 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all clients with their summaries in a single optimized query
  /// This replaces the N+1 query problem where we had to query each client separately
  Future<Map<int, Map<String, dynamic>>> getAllClientsSummaries() async {
    final db = await database;
    
    // Single optimized query with JOIN and GROUP BY
    final result = await db.rawQuery('''
      SELECT 
        c.id as clientId,
        c.name as clientName,
        c.phone as clientPhone,
        c.createdAt as clientCreatedAt,
        t.currency,
        t.isForMe,
        SUM(t.amount) as total,
        MAX(t.date) as lastTransactionDate,
        COUNT(t.id) as transactionCount
      FROM clients c
      LEFT JOIN transactions t ON c.id = t.clientId
      GROUP BY c.id, t.currency, t.isForMe
      ORDER BY c.name
    ''');
    
    // Process results into structured format
    final Map<int, Map<String, dynamic>> summaries = {};
    
    for (final row in result) {
      final clientId = row['clientId'] as int;
      final currency = row['currency'] as String?;
      final isForMe = (row['isForMe'] as int?) == 1;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      final lastDate = row['lastTransactionDate'] as String?;
      
      // Initialize client entry if not exists
      if (!summaries.containsKey(clientId)) {
        summaries[clientId] = {
          'id': clientId,
          'name': row['clientName'] as String,
          'phone': row['clientPhone'] as String?,
          'createdAt': row['clientCreatedAt'] as String?,
          'netByCurrency': <String, double>{},
          'lastTransactionDate': null,
        };
      }
      
      // Update last transaction date
      if (lastDate != null) {
        final currentLast = summaries[clientId]!['lastTransactionDate'] as String?;
        if (currentLast == null || lastDate.compareTo(currentLast) > 0) {
          summaries[clientId]!['lastTransactionDate'] = lastDate;
        }
      }
      
      // Calculate net balance per currency
      if (currency != null && total > 0) {
        final netByCurrency = summaries[clientId]!['netByCurrency'] as Map<String, double>;
        final currentNet = netByCurrency[currency] ?? 0;
        netByCurrency[currency] = currentNet + (isForMe ? total : -total);
      }
    }
    
    return summaries;
  }
}
