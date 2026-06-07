import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class MlKitModelService {
  MlKitModelService._();
  static final MlKitModelService instance = MlKitModelService._();

  bool _isReady = false;
  bool get isReady => _isReady;

  // Downloading future is cached so concurrent callers wait for the same future
  Future<void>? _downloadFuture;

  Future<void> ensureReady(String languageCode) {
    _downloadFuture ??= _doDownload(languageCode);
    return _downloadFuture!;
  }

  Future<void> _doDownload(String languageCode) async {
    if (_isReady) return;

    final modelManager = DigitalInkRecognizerModelManager();
    final isDownloaded = await modelManager.isModelDownloaded(languageCode);
    if (!isDownloaded) await modelManager.downloadModel(languageCode);

    // Warm-up call so the first real recognition isn't slow
    // Use a more realistic stroke to trigger full model initialization
    try {
      final recognizer = DigitalInkRecognizer(languageCode: languageCode);
      final dummyInk = Ink();
      // Create a stroke with multiple points to better mimic real writing
      final points = <StrokePoint>[];
      for (int i = 0; i < 20; i++) {
        points.add(StrokePoint(
          x: 50 + (i * 5).toDouble(),
          y: 100 + ((i % 3) * 10 - 10).toDouble(),
          t: i * 50,
        ));
      }
      dummyInk.strokes.add(Stroke()..points.addAll(points));
      await recognizer.recognize(dummyInk);
      recognizer.close();
    } catch (_) {}

    _isReady = true;
  }
}