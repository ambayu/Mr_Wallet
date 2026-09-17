import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  String? _lastRecordedFilePath;

  AudioService._internal();

  bool get isRecording => _isRecording;
  String? get lastRecordedFilePath => _lastRecordedFilePath;

  Future<bool> hasPermission() async {
    try {
      return await _audioRecorder.hasPermission();
    } catch (e) {
      debugPrint('Permission error: $e');
      return true;
    }
  }

  Future<String?> startRecording() async {
    try {
      if (await hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = p.join(
          dir.path,
          'smartflow_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
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

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _lastRecordedFilePath = path;
      return path;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _isRecording = false;
    }
    return null;
  }

  Future<void> dispose() async {
    try {
      await _audioRecorder.dispose();
    } catch (e) {
      debugPrint('Dispose audio recorder error: $e');
    }
  }
}
