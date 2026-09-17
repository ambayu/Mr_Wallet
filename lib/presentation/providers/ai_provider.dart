import 'package:flutter/foundation.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/audio_service.dart';
import '../../data/models/ai_parsed_result.dart';

class AIProvider extends ChangeNotifier {
  final AIService _aiService;
  final AudioService _audioService;

  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  AIParsedResult? _lastParsedResult;
  OCRBillResult? _lastOCRResult;
  String _errorMessage = '';

  AIProvider({
    AIService? aiService,
    AudioService? audioService,
  })  : _aiService = aiService ?? AIService.instance,
        _audioService = audioService ?? AudioService.instance;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get recognizedText => _recognizedText;
  AIParsedResult? get lastParsedResult => _lastParsedResult;
  OCRBillResult? get lastOCRResult => _lastOCRResult;
  String get errorMessage => _errorMessage;

  Future<void> startVoiceRecording() async {
    _errorMessage = '';
    _lastParsedResult = null;
    final path = await _audioService.startRecording();
    if (path != null) {
      _isListening = true;
      notifyListeners();
    } else {
      _isListening = false;
      _errorMessage = 'Tidak dapat mengakses mikrofon.';
      notifyListeners();
    }
  }

  Future<void> stopAndProcessVoice({
    required List<String> walletNames,
    required List<String> categoryNames,
    String? manualTextPrompt,
  }) async {
    _isListening = false;
    _isProcessing = true;
    notifyListeners();

    try {
      await _audioService.stopRecording();
      final inputText = manualTextPrompt ?? 'Catat pengeluaran bensin 30 ribu dompet tunai dan ingatkan servis besok';
      _recognizedText = inputText;

      final result = await _aiService.parseNaturalCommand(
        userInput: inputText,
        availableWallets: walletNames,
        availableCategories: categoryNames,
      );

      _lastParsedResult = result;
    } catch (e) {
      _errorMessage = 'Gagal memproses instruksi: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processTextCommand(
    String command, {
    required List<String> walletNames,
    required List<String> categoryNames,
  }) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _recognizedText = command;
      final result = await _aiService.parseNaturalCommand(
        userInput: command,
        availableWallets: walletNames,
        availableCategories: categoryNames,
      );
      _lastParsedResult = result;
    } catch (e) {
      _errorMessage = 'Gagal memproses perintah teks: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processBillImage({
    required String imagePath,
    String? rawOCRText,
  }) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final billResult = await _aiService.parseBillReceipt(
        imagePath: imagePath,
        rawOCRText: rawOCRText,
      );
      _lastOCRResult = billResult;
    } catch (e) {
      _errorMessage = 'Gagal memproses foto struk: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _lastParsedResult = null;
    _lastOCRResult = null;
    _errorMessage = '';
    _recognizedText = '';
    notifyListeners();
  }
}
