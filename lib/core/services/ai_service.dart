import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/ai_parsed_result.dart';

class AIService {
  static final AIService instance = AIService._internal();

  static const String _defaultApiKey = 'sk-d9a53722e4cfce0d-3eb5kj-a74dc4a8';
  static const String _defaultBaseUrl = 'https://route9.nurset-studio.web.id/v1';
  static const String _defaultModel = 'gemini-3.7-3.8';
  static const String _prefApiKey = 'gemini_api_key';
  static const String _prefBaseUrl = 'ai_base_url';
  static const String _prefModel = 'ai_model_name';
  static const String _prefPromptHistory = 'ai_prompt_history_list';

  GenerativeModel? _visionModel;

  AIService._internal();

  Future<void> initialize() async {
    final apiKey = await getApiKey();
    if (apiKey.isNotEmpty) {
      _initGenerativeModels(apiKey);
    }
  }

  void _initGenerativeModels(String apiKey) {
    try {
      _visionModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
        ),
      );
    } catch (e) {
      debugPrint('Error init Gemini models: $e');
    }
  }

  Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefApiKey) ?? _defaultApiKey;
  }

  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, apiKey);
    _initGenerativeModels(apiKey);
  }

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefBaseUrl) ?? _defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBaseUrl, url);
  }

  Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefModel) ?? _defaultModel;
  }

  Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModel, model);
  }

  Future<void> saveApiKey(String apiKey) => setApiKey(apiKey);

  // --- Riwayat Teks Perintah AI (Prompt History) ---
  Future<List<String>> getPromptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefPromptHistory);
      if (list != null && list.isNotEmpty) {
        return list;
      }
    } catch (e) {
      debugPrint('Error loading prompt history: $e');
    }
    // Default prompt suggestions jika belum ada riwayat
    return [
      'Beli nasi padang 25rb pakai Dompet Tunai',
      'Gaji 5.000.000 masuk ke ATM BCA',
      'Isi bensin motor 30rb pakai Dompet Tunai',
      'Bayar tagihan listrik PLN 150rb dari ATM Mandiri',
      'Transfer 500rb dari ATM BCA ke GoPay',
    ];
  }

  Future<void> addPromptHistory(String prompt) async {
    final clean = prompt.trim();
    if (clean.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_prefPromptHistory) ?? [];
      // Hapus jika sudah ada agar tidak duplikat
      current.removeWhere((p) => p.toLowerCase() == clean.toLowerCase());
      // Sisipkan di posisi pertama (terbaru)
      current.insert(0, clean);
      // Batasi maksimal 20 riwayat
      if (current.length > 20) {
        current.removeRange(20, current.length);
      }
      await prefs.setStringList(_prefPromptHistory, current);
    } catch (e) {
      debugPrint('Error saving prompt history: $e');
    }
  }

  Future<void> clearPromptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefPromptHistory);
    } catch (e) {
      debugPrint('Error clearing prompt history: $e');
    }
  }

  // 1. Process Voice / Text Natural Input via Custom Route9 API / Gemini Proxy
  Future<AIParsedResult> parseNaturalCommand({
    required String userInput,
    List<String> availableWallets = const ['Dompet Tunai', 'ATM BCA', 'ATM Mandiri', 'GoPay / E-Wallet'],
    List<String> availableCategories = const ['Makan', 'Minum', 'Belanja', 'Bensin', 'Listrik', 'Pulsa', 'Gaji', 'Transfer'],
  }) async {
    final trimmed = userInput.trim();
    if (trimmed.isEmpty) {
      return _parseOfflineHeuristic(userInput, availableWallets, availableCategories);
    }

    // Simpan ke riwayat teks
    await addPromptHistory(trimmed);

    final apiKey = await getApiKey();
    final baseUrl = await getBaseUrl();
    final modelName = await getModel();

    if (apiKey.isNotEmpty) {
      try {
        final systemPrompt = '''
Anda adalah AI Asisten Keuangan cerdas untuk aplikasi Mr. Wallet (SmartFlow). Analisis instruksi pengguna dalam Bahasa Indonesia dan ekstrak seluruh tindakan keuangan menjadi format JSON strictly valid tanpa markdown tambahan.

Daftar Akun Dompet Tersedia: ${availableWallets.join(', ')}
Daftar Kategori Tersedia: ${availableCategories.join(', ')}
Waktu Sekarang: ${DateTime.now().toIso8601String()}

Aturan Ekstraksi:
1. Cocokkan dompet ke daftar akun dompet terdekat. Jika tidak disebutkan, default gunakan dompet pertama ("${availableWallets.isNotEmpty ? availableWallets.first : 'Dompet Tunai'}").
2. Cocokkan kategori ke daftar kategori terdekat (misal: "nasi goreng" -> "Makan", "pertamax" -> "Bensin", "gajian" -> "Gaji").
3. Deteksi tipe transaksi:
   - "EXPENSE" untuk pengeluaran / bayar / beli
   - "INCOME" untuk pendapatan / terima uang / gaji / bonus
   - "TRANSFER" untuk transfer antar rekening
   - "ADJUSTMENT" untuk penyesuaian saldo / uang hilang
4. Kembalikan JSON persis sesuai skema di bawah ini.

Skema JSON yang WAJIB dipatuhi:
{
  "intent": "TRANSACTION_ENTRY" | "TASK_ENTRY" | "MULTI_ACTION" | "BALANCE_ADJUSTMENT" | "SUMMARY_QUERY",
  "transactions": [
    {
      "wallet_name": "string (sesuai daftar dompet terdekat)",
      "type": "EXPENSE" | "INCOME" | "TRANSFER" | "ADJUSTMENT",
      "amount": number,
      "category": "string (sesuai kategori terdekat)",
      "notes": "string",
      "target_actual_balance": number or null
    }
  ],
  "tasks": [
    {
      "title": "string",
      "due_date": "YYYY-MM-DDTHH:mm:ss",
      "priority": "LOW" | "MEDIUM" | "HIGH",
      "estimated_amount": number or null,
      "wallet_name": "string or null"
    }
  ],
  "summary_request": {
    "is_requested": boolean,
    "query_target": "FINANCE_TODAY" | "FINANCE_MONTH" | "TASKS_UPCOMING" | null
  },
  "natural_response": "Pesan konfirmasi ringkas dan ramah (contoh: 'Mencatat pengeluaran Makan sebesar Rp 25.000 dari Dompet Tunai.')"
}
''';

        final endpointUri = Uri.parse('$baseUrl/chat/completions');
        final response = await http.post(
          endpointUri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': modelName,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': trimmed},
            ],
            'stream': false,
            'temperature': 0.1,
          }),
        );

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = resJson['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices.first['message'] as Map<String, dynamic>?;
            String? content = message?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              // Bersihkan format markdown ```json ... ``` jika ada
              content = content.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
              content = content.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
              content = content.trim();

              final decoded = jsonDecode(content) as Map<String, dynamic>;
              return AIParsedResult.fromJson(decoded);
            }
          }
        } else {
          debugPrint('Route9 API error status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('Custom AI parse error: $e. Falling back to local heuristic parser.');
      }
    }

    // Fallback: Local Rule-Based Deterministic Heuristic Parser
    return _parseOfflineHeuristic(userInput, availableWallets, availableCategories);
  }

  // 2. Process Receipt Image / OCR Data into Structured Bill Details
  Future<OCRBillResult> parseBillReceipt({
    required String imagePath,
    String? rawOCRText,
  }) async {
    final apiKey = await getApiKey();

    if (apiKey.isNotEmpty && _visionModel != null) {
      try {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();

          final prompt = '''
Ekstrak informasi struk belanja ini menjadi format JSON deterministik:
{
  "merchant_name": "Nama Toko / Resto",
  "date": "YYYY-MM-DDTHH:mm:ss",
  "total_amount": 0,
  "tax": 0,
  "category": "Makanan & Kopi" | "Belanja" | "Transportasi" | "Tagihan & Listrik" | "Lain-lain",
  "items": [
    {
      "name": "Nama Barang",
      "price": 0,
      "quantity": 1
    }
  ]
}
Teks Mentah dari OCR (jika ada): "$rawOCRText"
''';

          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart('image/jpeg', imageBytes),
            ]),
          ];

          final response = await _visionModel!.generateContent(content);
          final resText = response.text;
          if (resText != null && resText.isNotEmpty) {
            final decoded = jsonDecode(resText) as Map<String, dynamic>;
            return OCRBillResult.fromJson(decoded, rawText: rawOCRText ?? '');
          }
        }
      } catch (e) {
        debugPrint('Vision OCR error: $e');
      }
    }

    // Fallback regex parser for offline / no-API key bill snap
    return _parseReceiptOffline(rawOCRText ?? '');
  }

  // Local Offline Heuristic Parser (Deterministik & Anti-Gagal)
  AIParsedResult _parseOfflineHeuristic(
    String input,
    List<String> wallets,
    List<String> categories,
  ) {
    final lower = input.toLowerCase();
    final List<AIParsedTransaction> transactions = [];
    final List<AIParsedTask> tasks = [];

    // Detect Summary Query
    if (lower.contains('berapa') ||
        lower.contains('rekap') ||
        lower.contains('total pengeluaran') ||
        lower.contains('sisa saldo')) {
      final summaryTarget =
          lower.contains('hari ini') ? 'FINANCE_TODAY' : 'FINANCE_MONTH';
      return AIParsedResult(
        intent: 'SUMMARY_QUERY',
        summaryRequest: AIParsedSummaryRequest(
          isRequested: true,
          queryTarget: summaryTarget,
        ),
        naturalResponse: 'Berikut ringkasan catatan keuangan Anda:',
      );
    }

    // Detect Amount
    double amount = 0;
    final numMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:ribu|rb|k|jt|juta)?',
      caseSensitive: false,
    ).firstMatch(lower);

    if (numMatch != null) {
      final rawNumStr = numMatch.group(1)!.replaceAll(',', '.');
      final baseNum = double.tryParse(rawNumStr) ?? 0;
      if (lower.contains('ribu') || lower.contains('rb') || lower.contains('k')) {
        amount = baseNum * 1000;
      } else if (lower.contains('juta') || lower.contains('jt')) {
        amount = baseNum * 1000000;
      } else {
        amount = baseNum;
      }
    }

    // Detect Wallet
    String chosenWallet = wallets.isNotEmpty ? wallets.first : 'Dompet Tunai';
    if (lower.contains('dompet') ||
        lower.contains('tunai') ||
        lower.contains('cash')) {
      chosenWallet = 'Dompet Tunai';
    } else if (lower.contains('bca')) {
      chosenWallet = 'ATM BCA';
    } else if (lower.contains('mandiri')) {
      chosenWallet = 'ATM Mandiri';
    } else if (lower.contains('gopay') ||
        lower.contains('ovo') ||
        lower.contains('wallet')) {
      chosenWallet = 'GoPay / E-Wallet';
    }

    // Detect Adjustment (Uang hilang / sisa saldo)
    if (lower.contains('sisa') ||
        lower.contains('sisa saldo') ||
        lower.contains('uang hilang') ||
        lower.contains('receh')) {
      transactions.add(AIParsedTransaction(
        walletName: chosenWallet,
        type: 'ADJUSTMENT',
        amount: amount,
        category: 'Uang Hilang / Selisih',
        notes: input,
        targetActualBalance: amount,
      ));

      return AIParsedResult(
        intent: 'BALANCE_ADJUSTMENT',
        transactions: transactions,
        naturalResponse:
            'Menyesuaikan saldo $chosenWallet menjadi Rp ${amount.toStringAsFixed(0)}.',
      );
    }

    // Detect Expense/Income
    if (amount > 0) {
      String type = 'EXPENSE';
      String cat = 'Belanja';

      if (lower.contains('kopi') ||
          lower.contains('makan') ||
          lower.contains('sarapan') ||
          lower.contains('jajan')) {
        cat = 'Makanan & Kopi';
      } else if (lower.contains('bensin') ||
          lower.contains('gojek') ||
          lower.contains('grab') ||
          lower.contains('parkir')) {
        cat = 'Transportasi';
      } else if (lower.contains('listrik') ||
          lower.contains('pln') ||
          lower.contains('wifi') ||
          lower.contains('pulsa')) {
        cat = 'Tagihan & Listrik';
      } else if (lower.contains('gaji') ||
          lower.contains('terima uang') ||
          lower.contains('transfer masuk')) {
        type = 'INCOME';
        cat = 'Gaji & Pendapatan';
      }

      transactions.add(AIParsedTransaction(
        walletName: chosenWallet,
        type: type,
        amount: amount,
        category: cat,
        notes: input,
      ));
    }

    // Detect Task / Schedule
    if (lower.contains('ingatkan') ||
        lower.contains('jadwal') ||
        lower.contains('servis') ||
        lower.contains('bayar tagihan') ||
        lower.contains('meeting') ||
        lower.contains('besok')) {
      DateTime dueDate = DateTime.now().add(const Duration(hours: 3));
      if (lower.contains('besok')) {
        dueDate = DateTime.now().add(const Duration(days: 1));
      }

      tasks.add(AIParsedTask(
        title: input.length > 35 ? input.substring(0, 35) : input,
        dueDate: dueDate,
        priority: lower.contains('penting') || lower.contains('urgent')
            ? 'HIGH'
            : 'MEDIUM',
        estimatedAmount: amount > 0 ? amount : null,
        walletName: chosenWallet,
      ));
    }

    String intent = 'TRANSACTION_ENTRY';
    if (transactions.isNotEmpty && tasks.isNotEmpty) {
      intent = 'MULTI_ACTION';
    } else if (tasks.isNotEmpty && transactions.isEmpty) {
      intent = 'TASK_ENTRY';
    }

    return AIParsedResult(
      intent: intent,
      transactions: transactions,
      tasks: tasks,
      naturalResponse: 'Perintah berhasil diekstrak secara deterministik.',
    );
  }

  // Offline Regex Receipt Parser
  OCRBillResult _parseReceiptOffline(String rawText) {
    double total = 0.0;
    final totalRegex = RegExp(
      r'(?:total|amount|subtotal|tagihan|rp)\s*[:=]?\s*([\d.,]+)',
      caseSensitive: false,
    );
    final match = totalRegex.firstMatch(rawText);
    if (match != null) {
      final clean = match.group(1)!.replaceAll('.', '').replaceAll(',', '');
      total = double.tryParse(clean) ?? 0.0;
    }

    String merchant = 'Toko / Resto Kasir';
    final lines =
        rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      merchant = lines.first.trim();
    }

    return OCRBillResult(
      merchantName: merchant,
      date: DateTime.now(),
      totalAmount: total > 0 ? total : 50000.0,
      category: 'Belanja',
      items: [
        OCRBillItem(
          name: 'Item Pembelian',
          price: total > 0 ? total : 50000.0,
          quantity: 1,
        ),
      ],
      rawText: rawText,
    );
  }
}
