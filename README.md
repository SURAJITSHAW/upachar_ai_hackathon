# 🩺 Upachar AI

**Upachar AI** is an offline-first AI healthcare assistant powered by **Gemma 2B** running locally through **Ollama**. It helps users understand handwritten prescriptions, explain medicines in simple language, interact with an AI voice assistant, and receive multilingual healthcare guidance while keeping personal medical data private.

---

## ✨ Features

- 📷 Scan handwritten prescriptions using **Google ML Kit OCR**
- 🤖 AI-powered prescription interpretation using **Gemma 2B**
- 💊 Explain medicine dosage, timing, duration, and precautions
- 🔊 Read prescriptions aloud with **Text-to-Speech**
- 🌐 Multilingual support (English & Bengali)
- 🎤 AI Voice Assistant with Speech-to-Text and Text-to-Speech
- 🩺 AI-powered symptom checker with responsible healthcare guidance
- 📍 Nearby doctor and hospital recommendations
- 🔒 Privacy-first local AI inference using Ollama
- ⚡ Works offline without cloud AI

---

## 🏗️ Tech Stack

- Flutter
- Dart
- Provider
- Ollama
- Gemma 2B
- Google ML Kit OCR
- Speech-to-Text
- Flutter TTS
- Google Maps API
- HTTP
- Shared Preferences

---

## 🚀 How It Works

1. User scans a handwritten prescription.
2. Google ML Kit extracts the prescription text.
3. Gemma analyzes the extracted information locally through Ollama.
4. The AI explains:
   - Medicine purpose
   - Dosage
   - Timing
   - Duration
   - Precautions
5. Users can ask follow-up questions using text or voice.
6. If symptoms indicate a potentially serious condition, the AI recommends visiting a doctor and suggests nearby healthcare providers.

---

## 🔐 Privacy First

Unlike cloud-based AI assistants, Upachar AI performs AI inference locally using **Gemma** and **Ollama**, ensuring that sensitive healthcare information remains private and minimizing dependence on an internet connection.

---

## ⚠️ Medical Disclaimer

Upachar AI is intended to assist users in understanding prescriptions and providing general health information. It is **not** a substitute for professional medical advice, diagnosis, or treatment.

Always consult a qualified healthcare professional before making medical decisions or taking any medication.

---

## 🏆 Build with Gemma Kolkata Hackathon

Upachar AI was developed for the **Build with Gemma Kolkata Hackathon**, showcasing how lightweight, on-device AI can improve healthcare accessibility through:

- 🤖 On-device AI
- 🌐 Multilingual assistance
- 🔒 Privacy-preserving inference
- 🎤 Voice interaction
- 📷 Intelligent prescription understanding
- ❤️ Accessible healthcare for everyone

---

## 📸 Demo

> 🎥 Demo Video: *Coming Soon*

---

## 📂 Repository Structure

```text
lib/
├── models/
├── providers/
├── screens/
├── services/
├── utils/
├── widgets/
└── main.dart
```

---

## 🚀 Future Improvements

- 📄 Medicine database integration
- 🧠 RAG-powered medical knowledge retrieval
- 📅 Smart medicine reminder system
- 🏥 Hospital and pharmacy finder
- 🌍 Support for additional Indian languages
- 📊 Patient health history and analytics
- 👨‍⚕️ Telemedicine integration
- 💊 Drug interaction detection

---

## 🤝 Contributors

Built with ❤️ using **Flutter**, **Gemma**, and **Ollama** during the **Build with Gemma Kolkata Hackathon**.
