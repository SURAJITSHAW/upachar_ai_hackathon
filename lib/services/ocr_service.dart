import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR (ML Kit). Returns the recognized text, or an empty
/// string when nothing legible was found.
class OcrService {
  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}
