import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeechToText _stt = SpeechToText();

  bool _isRecording = false;
  bool _sttInitialized = false;
  String? _lastRecordedFilePath;
  String _lastTranscript = '';

  AudioService._internal();

  bool get isRecording => _isRecording;
  String? get lastRecordedFilePath => _lastRecordedFilePath;
  String get lastTranscript => _lastTranscript;

  Future<bool> hasPermission() async {
    try {
      return await _audioRecorder.hasPermission();
    } catch (e) {
      debugPrint('Permission error: $e');
      return true;
    }
  }

  Future<bool> _ensureSttReady() async {
    if (_sttInitialized) return true;
    try {
      _sttInitialized = await _stt.initialize(
        onError: (err) => debugPrint('STT error: $err'),
        onStatus: (status) => debugPrint('STT status: $status'),
      );
    } catch (e) {
      debugPrint('STT init error: $e');
      _sttInitialized = false;
    }
    return _sttInitialized;
  }

  /// Mulai rekaman: STT native untuk transkripsi + record file sebagai backup
  Future<String?> startRecording() async {
    _lastTranscript = '';
    try {
      final sttReady = await _ensureSttReady();

      if (sttReady) {
        // Pakai STT native device — jauh lebih akurat & real-time
        await _stt.listen(
          onResult: (result) {
            if (result.finalResult) {
              _lastTranscript = result.recognizedWords;
            } else if (result.recognizedWords.isNotEmpty) {
              _lastTranscript = result.recognizedWords;
            }
          },
          listenOptions: SpeechListenOptions(
            localeId: 'id_ID',
            listenMode: ListenMode.dictation,
            cancelOnError: false,
            partialResults: true,
          ),
        );
        _isRecording = true;
        return 'stt_native';
      }

      // Fallback: rekam file audio jika STT tidak tersedia
      if (await hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = p.join(
          dir.path,
          'mr_wallet_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        _isRecording = true;
        _lastRecordedFilePath = path;
        return path;
      }
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
    return null;
  }

  /// Stop rekaman dan kembalikan teks transkripsi (bukan path file)
  Future<String> stopRecordingAndGetText() async {
    try {
      if (_stt.isListening) {
        await _stt.stop();
        // Tunggu sebentar agar hasil final masuk
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      _isRecording = false;
      return _lastTranscript;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _isRecording = false;
    }
    return _lastTranscript;
  }

  /// Kompatibilitas lama — kembalikan path (hanya untuk fallback file)
  Future<String?> stopRecording() async {
    final text = await stopRecordingAndGetText();
    return text.isNotEmpty ? text : _lastRecordedFilePath;
  }

  Future<void> dispose() async {
    try {
      await _stt.cancel();
      await _audioRecorder.dispose();
    } catch (e) {
      debugPrint('Dispose audio recorder error: $e');
    }
  }
}
