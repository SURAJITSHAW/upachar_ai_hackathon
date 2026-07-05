/// Lightweight map-based localization for English, Bengali and Hindi.
enum AppLanguage { english, bengali, hindi }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.english => 'en',
    AppLanguage.bengali => 'bn',
    AppLanguage.hindi => 'hi',
  };

  String get displayName => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.bengali => 'বাংলা (Bengali)',
    AppLanguage.hindi => 'हिंदी (Hindi)',
  };

  String get shortLabel => switch (this) {
    AppLanguage.english => 'En',
    AppLanguage.bengali => 'বাং',
    AppLanguage.hindi => 'हिं',
  };

  static AppLanguage fromCode(String? code) => switch (code) {
    'bn' => AppLanguage.bengali,
    'hi' => AppLanguage.hindi,
    _ => AppLanguage.english,
  };
}

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  static const Map<String, Map<String, String>> _values = {
    'appName': {'en': 'Upachar AI', 'bn': 'উপাচার AI', 'hi': 'उपचार AI'},
    'tagline': {
      'en': 'Your trusted companion for daily healthcare needs.',
      'bn': 'আপনার দৈনন্দিন স্বাস্থ্যসেবার বিশ্বস্ত সঙ্গী।',
      'hi': 'आपकी दैनिक स्वास्थ्य ज़रूरतों का भरोसेमंद साथी।',
    },
    'welcome': {'en': 'Welcome', 'bn': 'স্বাগতম', 'hi': 'स्वागत है'},
    'selectLanguage': {
      'en': 'Please select your preferred language to begin.',
      'bn': 'শুরু করতে আপনার পছন্দের ভাষা নির্বাচন করুন।',
      'hi': 'शुरू करने के लिए अपनी पसंदीदा भाषा चुनें।',
    },
    'languageChangeHint': {
      'en':
          'You can change your language preference later in the settings menu at any time.',
      'bn': 'আপনি যেকোনো সময় সেটিংস মেনু থেকে ভাষা পরিবর্তন করতে পারবেন।',
      'hi': 'आप कभी भी सेटिंग्स मेनू से भाषा बदल सकते हैं।',
    },
    'secureLogin': {
      'en': 'Secure Login',
      'bn': 'নিরাপদ লগইন',
      'hi': 'सुरक्षित लॉगिन',
    },
    'dataEncrypted': {
      'en': 'Your health data is encrypted and stored locally.',
      'bn': 'আপনার স্বাস্থ্য তথ্য এনক্রিপ্ট করে স্থানীয়ভাবে সংরক্ষিত।',
      'hi': 'आपका स्वास्थ्य डेटा एन्क्रिप्टेड और स्थानीय रूप से संग्रहीत है।',
    },
    'mobileNumber': {
      'en': 'Mobile Number',
      'bn': 'মোবাইল নম্বর',
      'hi': 'मोबाइल नंबर',
    },
    'invalidMobile': {
      'en': 'Invalid mobile number',
      'bn': 'অবৈধ মোবাইল নম্বর',
      'hi': 'अमान्य मोबाइल नंबर',
    },
    'sendOtp': {'en': 'Send OTP', 'bn': 'OTP পাঠান', 'hi': 'OTP भेजें'},
    'enterOtp': {
      'en': 'Enter the 6-digit OTP',
      'bn': '৬-সংখ্যার OTP লিখুন',
      'hi': '6 अंकों का OTP दर्ज करें',
    },
    'otpSentTo': {
      'en': 'OTP sent to',
      'bn': 'OTP পাঠানো হয়েছে',
      'hi': 'OTP भेजा गया',
    },
    'invalidOtp': {
      'en': 'Invalid OTP. Please try again.',
      'bn': 'ভুল OTP। আবার চেষ্টা করুন।',
      'hi': 'गलत OTP। पुनः प्रयास करें।',
    },
    'verify': {'en': 'Verify', 'bn': 'যাচাই করুন', 'hi': 'सत्यापित करें'},
    'resendOtp': {
      'en': 'Resend OTP',
      'bn': 'আবার OTP পাঠান',
      'hi': 'OTP पुनः भेजें',
    },
    'resendIn': {'en': 'Resend in', 'bn': 'পুনরায় পাঠান', 'hi': 'पुनः भेजें'},
    'networkError': {
      'en': 'Network error. Please try again.',
      'bn': 'নেটওয়ার্ক সমস্যা। আবার চেষ্টা করুন।',
      'hi': 'नेटवर्क त्रुटि। पुनः प्रयास करें।',
    },
    'todaysSchedule': {
      'en': "Today's Schedule",
      'bn': 'আজকের সময়সূচী',
      'hi': 'आज का शेड्यूल',
    },
    'offlineBanner': {
      'en': 'Offline Mode - Showing cached data',
      'bn': 'অফলাইন মোড - সংরক্ষিত তথ্য দেখানো হচ্ছে',
      'hi': 'ऑफ़लाइन मोड - सहेजा गया डेटा दिखाया जा रहा है',
    },
    'dueNow': {'en': 'Due Now', 'bn': 'এখন খেতে হবে', 'hi': 'अभी लेना है'},
    'takeNow': {'en': 'Take Now', 'bn': 'এখন খান', 'hi': 'अभी लें'},
    'emptyStateTitle': {
      'en': 'No prescriptions yet',
      'bn': 'এখনও কোনো প্রেসক্রিপশন নেই',
      'hi': 'अभी कोई प्रिस्क्रिप्शन नहीं',
    },
    'emptyStateSubtitle': {
      'en': 'Tap the scan button below to add your first prescription.',
      'bn': 'প্রথম প্রেসক্রিপশন যোগ করতে নিচের স্ক্যান বাটনে চাপ দিন।',
      'hi': 'पहला प्रिस्क्रिप्शन जोड़ने के लिए नीचे स्कैन बटन दबाएं।',
    },
    'home': {'en': 'Home', 'bn': 'হোম', 'hi': 'होम'},
    'history': {'en': 'History', 'bn': 'ইতিহাস', 'hi': 'इतिहास'},
    'family': {'en': 'Family', 'bn': 'পরিবার', 'hi': 'परिवार'},
    'settings': {'en': 'Settings', 'bn': 'সেটিংস', 'hi': 'सेटिंग्स'},
    'settingsSubtitle': {
      'en': 'Manage your profile, preferences, and data.',
      'bn': 'আপনার প্রোফাইল, পছন্দ এবং তথ্য পরিচালনা করুন।',
      'hi': 'अपनी प्रोफ़ाइल, प्राथमिकताएं और डेटा प्रबंधित करें।',
    },
    'profiles': {'en': 'PROFILES', 'bn': 'প্রোফাইল', 'hi': 'प्रोफ़ाइल'},
    'preferences': {
      'en': 'PREFERENCES',
      'bn': 'পছন্দসমূহ',
      'hi': 'प्राथमिकताएं',
    },
    'dataPrivacy': {
      'en': 'DATA & PRIVACY',
      'bn': 'তথ্য ও গোপনীয়তা',
      'hi': 'डेटा और गोपनीयता',
    },
    'about': {'en': 'ABOUT', 'bn': 'সম্পর্কে', 'hi': 'जानकारी'},
    'myProfile': {
      'en': 'My Profile',
      'bn': 'আমার প্রোফাইল',
      'hi': 'मेरी प्रोफ़ाइल',
    },
    'active': {'en': 'Active', 'bn': 'সক্রিয়', 'hi': 'सक्रिय'},
    'addFamilyMember': {
      'en': 'Add Family Member',
      'bn': 'পরিবারের সদস্য যোগ করুন',
      'hi': 'परिवार का सदस्य जोड़ें',
    },
    'languageSelection': {
      'en': 'Language Selection',
      'bn': 'ভাষা নির্বাচন',
      'hi': 'भाषा चयन',
    },
    'notificationSettings': {
      'en': 'Notification Settings',
      'bn': 'নোটিফিকেশন সেটিংস',
      'hi': 'सूचना सेटिंग्स',
    },
    'exportHealthData': {
      'en': 'Export Health Data',
      'bn': 'স্বাস্থ্য তথ্য এক্সপোর্ট করুন',
      'hi': 'स्वास्थ्य डेटा निर्यात करें',
    },
    'clearCache': {
      'en': 'Clear Cache',
      'bn': 'ক্যাশ পরিষ্কার করুন',
      'hi': 'कैश साफ़ करें',
    },
    'deleteAllData': {
      'en': 'Delete All Data',
      'bn': 'সব তথ্য মুছুন',
      'hi': 'सारा डेटा हटाएं',
    },
    'appVersion': {
      'en': 'App Version',
      'bn': 'অ্যাপ সংস্করণ',
      'hi': 'ऐप संस्करण',
    },
    'support': {
      'en': 'Support & Help Center',
      'bn': 'সহায়তা কেন্দ্র',
      'hi': 'सहायता केंद्र',
    },
    'scanPrescription': {
      'en': 'Scan Prescription',
      'bn': 'প্রেসক্রিপশন স্ক্যান করুন',
      'hi': 'प्रिस्क्रिप्शन स्कैन करें',
    },
    'alignPrescription': {
      'en': 'Align prescription within frame',
      'bn': 'ফ্রেমের মধ্যে প্রেসক্রিপশন রাখুন',
      'hi': 'फ्रेम के भीतर प्रिस्क्रिप्शन रखें',
    },
    'gallery': {'en': 'Gallery', 'bn': 'গ্যালারি', 'hi': 'गैलरी'},
    'help': {'en': 'Help', 'bn': 'সাহায্য', 'hi': 'मदद'},
    'cameraPermissionTitle': {
      'en': 'Camera access needed',
      'bn': 'ক্যামেরার অনুমতি প্রয়োজন',
      'hi': 'कैमरा एक्सेस आवश्यक',
    },
    'cameraPermissionBody': {
      'en':
          'Upachar AI needs the camera to scan your prescriptions. Your photos never leave this device without your consent.',
      'bn':
          'প্রেসক্রিপশন স্ক্যান করতে ক্যামেরা প্রয়োজন। আপনার অনুমতি ছাড়া ছবি ডিভাইস থেকে বাইরে যায় না।',
      'hi':
          'प्रिस्क्रिप्शन स्कैन करने के लिए कैमरा चाहिए। आपकी अनुमति के बिना फोटो डिवाइस से बाहर नहीं जाती।',
    },
    'openSettings': {
      'en': 'Open Settings',
      'bn': 'সেটিংস খুলুন',
      'hi': 'सेटिंग्स खोलें',
    },
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল', 'hi': 'रद्द करें'},
    'processing1': {
      'en': 'Extracting text...',
      'bn': 'লেখা পড়া হচ্ছে...',
      'hi': 'टेक्स्ट निकाला जा रहा है...',
    },
    'processing2': {
      'en': 'Checking safety...',
      'bn': 'নিরাপত্তা যাচাই হচ্ছে...',
      'hi': 'सुरक्षा जांची जा रही है...',
    },
    'processing3': {
      'en': 'Translating...',
      'bn': 'অনুবাদ হচ্ছে...',
      'hi': 'अनुवाद हो रहा है...',
    },
    'processingSlow': {
      'en': 'Heavy server load, processing locally...',
      'bn': 'সার্ভার ব্যস্ত, ডিভাইসে প্রক্রিয়া হচ্ছে...',
      'hi': 'सर्वर व्यस्त, डिवाइस पर प्रोसेस हो रहा है...',
    },
    'modelWaking': {
      'en': 'AI model is waking up, retrying shortly...',
      'bn': 'AI মডেল চালু হচ্ছে, একটু পরে আবার চেষ্টা হবে...',
      'hi': 'AI मॉडल शुरू हो रहा है, थोड़ी देर में पुनः प्रयास होगा...',
    },
    'processedLocally': {
      'en': 'Processed on-device (offline fallback)',
      'bn': 'ডিভাইসে প্রক্রিয়া হয়েছে (অফলাইন)',
      'hi': 'डिवाइस पर प्रोसेस हुआ (ऑफ़लाइन)',
    },
    'tryAgain': {
      'en': 'Try Again',
      'bn': 'আবার চেষ্টা করুন',
      'hi': 'पुनः प्रयास करें',
    },
    'prescriptionDetails': {
      'en': 'Prescription Details',
      'bn': 'প্রেসক্রিপশনের বিবরণ',
      'hi': 'प्रिस्क्रिप्शन विवरण',
    },
    'medicines': {'en': 'Medicines', 'bn': 'ওষুধ', 'hi': 'दवाइयां'},
    'schedule': {'en': 'Schedule', 'bn': 'সময়সূচী', 'hi': 'शेड्यूल'},
    'warnings': {'en': 'Warnings', 'bn': 'সতর্কতা', 'hi': 'चेतावनियां'},
    'listenAloud': {'en': 'Listen Aloud', 'bn': 'শুনুন', 'hi': 'सुनें'},
    'stopAudio': {'en': 'Stop', 'bn': 'থামান', 'hi': 'रोकें'},
    'saveSchedule': {
      'en': 'Save Schedule',
      'bn': 'সময়সূচী সংরক্ষণ করুন',
      'hi': 'शेड्यूल सहेजें',
    },
    'needsReview': {
      'en': 'Needs review — dosage unclear',
      'bn': 'যাচাই প্রয়োজন — মাত্রা অস্পষ্ট',
      'hi': 'जांच आवश्यक — खुराक अस्पष्ट',
    },
    'editMedicine': {
      'en': 'Edit medicine',
      'bn': 'ওষুধ সম্পাদনা',
      'hi': 'दवा संपादित करें',
    },
    'save': {'en': 'Save', 'bn': 'সংরক্ষণ', 'hi': 'सहेजें'},
    'delete': {'en': 'Delete', 'bn': 'মুছুন', 'hi': 'हटाएं'},
    'prescriptionSaved': {
      'en': 'Prescription saved to schedule',
      'bn': 'প্রেসক্রিপশন সময়সূচীতে সংরক্ষিত',
      'hi': 'प्रिस्क्रिप्शन शेड्यूल में सहेजा गया',
    },
    'deleteAllConfirm': {
      'en':
          'This will permanently delete all profiles, prescriptions and schedules. This cannot be undone.',
      'bn':
          'সব প্রোফাইল, প্রেসক্রিপশন এবং সময়সূচী স্থায়ীভাবে মুছে যাবে। এটি ফেরানো যাবে না।',
      'hi':
          'सभी प्रोफ़ाइल, प्रिस्क्रिप्शन और शेड्यूल स्थायी रूप से हट जाएंगे। इसे वापस नहीं किया जा सकता।',
    },
    'cacheCleared': {
      'en': 'Cache cleared',
      'bn': 'ক্যাশ পরিষ্কার হয়েছে',
      'hi': 'कैश साफ़ हो गया',
    },
    'name': {'en': 'Name', 'bn': 'নাম', 'hi': 'नाम'},
    'add': {'en': 'Add', 'bn': 'যোগ করুন', 'hi': 'जोड़ें'},
    'taken': {'en': 'Taken', 'bn': 'খাওয়া হয়েছে', 'hi': 'ले लिया'},
    'logout': {'en': 'Log Out', 'bn': 'লগ আউট', 'hi': 'लॉग आउट'},
    'noHistory': {
      'en': 'No scanned prescriptions yet.',
      'bn': 'এখনও কোনো স্ক্যান করা প্রেসক্রিপশন নেই।',
      'hi': 'अभी तक कोई स्कैन किया गया प्रिस्क्रिप्शन नहीं।',
    },
    'tablets': {'en': 'Tablet(s)', 'bn': 'ট্যাবলেট', 'hi': 'टैबलेट'},
    'orally': {'en': 'Orally', 'bn': 'মুখে', 'hi': 'मुंह से'},
  };

  String get(String key) =>
      _values[key]?[language.code] ?? _values[key]?['en'] ?? key;
}
