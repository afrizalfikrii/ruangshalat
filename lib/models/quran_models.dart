/// Models for myquran.com Al-Quran API

class Surah {
  final int number;
  final String nameAr;
  final String nameId;
  final String nameEn;
  final int numberOfVerses;
  final String revelationId;
  final String translationId;
  final String tafsir;
  final String audioUrl;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.nameId,
    required this.nameEn,
    required this.numberOfVerses,
    required this.revelationId,
    required this.translationId,
    required this.tafsir,
    required this.audioUrl,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return Surah(
      number: int.tryParse(data['number'].toString()) ?? 0,
      nameAr: data['name_short'] ?? '',
      nameId: data['name_id'] ?? '',
      nameEn: data['name_en'] ?? '',
      numberOfVerses: int.tryParse(data['number_of_verses'].toString()) ?? 0,
      revelationId: data['revelation_id'] ?? '',
      translationId: data['translation_id'] ?? '',
      tafsir: data['tafsir'] ?? '',
      audioUrl: data['audio_url'] ?? '',
    );
  }
}

class Ayat {
  final int surahNo;
  final int ayahNo;
  final String arab;
  final String latin;
  final String terjemahan;
  final String audioUrl;
  final int juz;
  final int page;

  const Ayat({
    required this.surahNo,
    required this.ayahNo,
    required this.arab,
    required this.latin,
    required this.terjemahan,
    required this.audioUrl,
    required this.juz,
    required this.page,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
        surahNo: int.tryParse(json['surah'].toString()) ?? 0,
        ayahNo: int.tryParse(json['ayah'].toString()) ?? 0,
        arab: json['arab'] ?? '',
        latin: json['latin'] ?? '',
        terjemahan: json['text'] ?? '',
        audioUrl: json['audio'] ?? '',
        juz: int.tryParse(json['juz'].toString()) ?? 0,
        page: int.tryParse(json['page'].toString()) ?? 0,
      );

  factory Ayat.fromEquranJson(Map<String, dynamic> json, int surahId) {
    String parsedAudio = '';
    if (json['audio'] != null && json['audio'] is Map) {
      parsedAudio = json['audio']['01'] ?? '';
    }
    return Ayat(
      surahNo: surahId,
      ayahNo: int.tryParse(json['nomorAyat'].toString()) ?? 0,
      arab: json['teksArab'] ?? '',
      latin: json['teksLatin'] ?? '',
      terjemahan: json['teksIndonesia'] ?? '',
      audioUrl: parsedAudio,
      juz: 0, // Equran doesn't return juz or page at verse level
      page: 0,
    );
  }
}

/// Static metadata for 114 surahs (to avoid 114 API calls for list screen)
class SurahMeta {
  final int number;
  final String nameAr;
  final String nameId;
  final String nameEn;
  final int ayatCount;
  final String revelasi; // Makkiyyah / Madaniyyah

  const SurahMeta({
    required this.number,
    required this.nameAr,
    required this.nameId,
    required this.nameEn,
    required this.ayatCount,
    required this.revelasi,
  });
}

/// Hardcoded metadata list for all 114 surahs
const List<SurahMeta> surahList = [
  SurahMeta(number: 1, nameAr: 'الفاتحة', nameId: 'Al-Fatihah', nameEn: 'The Opening', ayatCount: 7, revelasi: 'Makkiyyah'),
  SurahMeta(number: 2, nameAr: 'البقرة', nameId: 'Al-Baqarah', nameEn: 'The Cow', ayatCount: 286, revelasi: 'Madaniyyah'),
  SurahMeta(number: 3, nameAr: 'آل عمران', nameId: 'Ali \'Imran', nameEn: 'Family of Imran', ayatCount: 200, revelasi: 'Madaniyyah'),
  SurahMeta(number: 4, nameAr: 'النساء', nameId: 'An-Nisa\'', nameEn: 'The Women', ayatCount: 176, revelasi: 'Madaniyyah'),
  SurahMeta(number: 5, nameAr: 'المائدة', nameId: 'Al-Ma\'idah', nameEn: 'The Table Spread', ayatCount: 120, revelasi: 'Madaniyyah'),
  SurahMeta(number: 6, nameAr: 'الأنعام', nameId: 'Al-An\'am', nameEn: 'The Cattle', ayatCount: 165, revelasi: 'Makkiyyah'),
  SurahMeta(number: 7, nameAr: 'الأعراف', nameId: 'Al-A\'raf', nameEn: 'The Heights', ayatCount: 206, revelasi: 'Makkiyyah'),
  SurahMeta(number: 8, nameAr: 'الأنفال', nameId: 'Al-Anfal', nameEn: 'The Spoils of War', ayatCount: 75, revelasi: 'Madaniyyah'),
  SurahMeta(number: 9, nameAr: 'التوبة', nameId: 'At-Tawbah', nameEn: 'The Repentance', ayatCount: 129, revelasi: 'Madaniyyah'),
  SurahMeta(number: 10, nameAr: 'يونس', nameId: 'Yunus', nameEn: 'Jonah', ayatCount: 109, revelasi: 'Makkiyyah'),
  SurahMeta(number: 11, nameAr: 'هود', nameId: 'Hud', nameEn: 'Hud', ayatCount: 123, revelasi: 'Makkiyyah'),
  SurahMeta(number: 12, nameAr: 'يوسف', nameId: 'Yusuf', nameEn: 'Joseph', ayatCount: 111, revelasi: 'Makkiyyah'),
  SurahMeta(number: 13, nameAr: 'الرعد', nameId: 'Ar-Ra\'d', nameEn: 'The Thunder', ayatCount: 43, revelasi: 'Madaniyyah'),
  SurahMeta(number: 14, nameAr: 'إبراهيم', nameId: 'Ibrahim', nameEn: 'Abraham', ayatCount: 52, revelasi: 'Makkiyyah'),
  SurahMeta(number: 15, nameAr: 'الحجر', nameId: 'Al-Hijr', nameEn: 'The Rocky Tract', ayatCount: 99, revelasi: 'Makkiyyah'),
  SurahMeta(number: 16, nameAr: 'النحل', nameId: 'An-Nahl', nameEn: 'The Bee', ayatCount: 128, revelasi: 'Makkiyyah'),
  SurahMeta(number: 17, nameAr: 'الإسراء', nameId: 'Al-Isra\'', nameEn: 'The Night Journey', ayatCount: 111, revelasi: 'Makkiyyah'),
  SurahMeta(number: 18, nameAr: 'الكهف', nameId: 'Al-Kahf', nameEn: 'The Cave', ayatCount: 110, revelasi: 'Makkiyyah'),
  SurahMeta(number: 19, nameAr: 'مريم', nameId: 'Maryam', nameEn: 'Mary', ayatCount: 98, revelasi: 'Makkiyyah'),
  SurahMeta(number: 20, nameAr: 'طه', nameId: 'Ta Ha', nameEn: 'Ta Ha', ayatCount: 135, revelasi: 'Makkiyyah'),
  SurahMeta(number: 21, nameAr: 'الأنبياء', nameId: 'Al-Anbiya\'', nameEn: 'The Prophets', ayatCount: 112, revelasi: 'Makkiyyah'),
  SurahMeta(number: 22, nameAr: 'الحج', nameId: 'Al-Hajj', nameEn: 'The Pilgrimage', ayatCount: 78, revelasi: 'Madaniyyah'),
  SurahMeta(number: 23, nameAr: 'المؤمنون', nameId: 'Al-Mu\'minun', nameEn: 'The Believers', ayatCount: 118, revelasi: 'Makkiyyah'),
  SurahMeta(number: 24, nameAr: 'النور', nameId: 'An-Nur', nameEn: 'The Light', ayatCount: 64, revelasi: 'Madaniyyah'),
  SurahMeta(number: 25, nameAr: 'الفرقان', nameId: 'Al-Furqan', nameEn: 'The Criterion', ayatCount: 77, revelasi: 'Makkiyyah'),
  SurahMeta(number: 26, nameAr: 'الشعراء', nameId: 'Asy-Syu\'ara\'', nameEn: 'The Poets', ayatCount: 227, revelasi: 'Makkiyyah'),
  SurahMeta(number: 27, nameAr: 'النمل', nameId: 'An-Naml', nameEn: 'The Ant', ayatCount: 93, revelasi: 'Makkiyyah'),
  SurahMeta(number: 28, nameAr: 'القصص', nameId: 'Al-Qasas', nameEn: 'The Stories', ayatCount: 88, revelasi: 'Makkiyyah'),
  SurahMeta(number: 29, nameAr: 'العنكبوت', nameId: 'Al-\'Ankabut', nameEn: 'The Spider', ayatCount: 69, revelasi: 'Makkiyyah'),
  SurahMeta(number: 30, nameAr: 'الروم', nameId: 'Ar-Rum', nameEn: 'The Romans', ayatCount: 60, revelasi: 'Makkiyyah'),
  SurahMeta(number: 31, nameAr: 'لقمان', nameId: 'Luqman', nameEn: 'Luqman', ayatCount: 34, revelasi: 'Makkiyyah'),
  SurahMeta(number: 32, nameAr: 'السجدة', nameId: 'As-Sajdah', nameEn: 'The Prostration', ayatCount: 30, revelasi: 'Makkiyyah'),
  SurahMeta(number: 33, nameAr: 'الأحزاب', nameId: 'Al-Ahzab', nameEn: 'The Clans', ayatCount: 73, revelasi: 'Madaniyyah'),
  SurahMeta(number: 34, nameAr: 'سبأ', nameId: 'Saba\'', nameEn: 'Sheba', ayatCount: 54, revelasi: 'Makkiyyah'),
  SurahMeta(number: 35, nameAr: 'فاطر', nameId: 'Fatir', nameEn: 'Originator', ayatCount: 45, revelasi: 'Makkiyyah'),
  SurahMeta(number: 36, nameAr: 'يس', nameId: 'Ya Sin', nameEn: 'Ya Sin', ayatCount: 83, revelasi: 'Makkiyyah'),
  SurahMeta(number: 37, nameAr: 'الصافات', nameId: 'As-Saffat', nameEn: 'Those who set the Ranks', ayatCount: 182, revelasi: 'Makkiyyah'),
  SurahMeta(number: 38, nameAr: 'ص', nameId: 'Sad', nameEn: 'The Letter Sad', ayatCount: 88, revelasi: 'Makkiyyah'),
  SurahMeta(number: 39, nameAr: 'الزمر', nameId: 'Az-Zumar', nameEn: 'The Troops', ayatCount: 75, revelasi: 'Makkiyyah'),
  SurahMeta(number: 40, nameAr: 'غافر', nameId: 'Ghafir', nameEn: 'The Forgiver', ayatCount: 85, revelasi: 'Makkiyyah'),
  SurahMeta(number: 41, nameAr: 'فصلت', nameId: 'Fussilat', nameEn: 'Explained in Detail', ayatCount: 54, revelasi: 'Makkiyyah'),
  SurahMeta(number: 42, nameAr: 'الشورى', nameId: 'Asy-Syura', nameEn: 'The Consultation', ayatCount: 53, revelasi: 'Makkiyyah'),
  SurahMeta(number: 43, nameAr: 'الزخرف', nameId: 'Az-Zukhruf', nameEn: 'The Ornaments of Gold', ayatCount: 89, revelasi: 'Makkiyyah'),
  SurahMeta(number: 44, nameAr: 'الدخان', nameId: 'Ad-Dukhan', nameEn: 'The Smoke', ayatCount: 59, revelasi: 'Makkiyyah'),
  SurahMeta(number: 45, nameAr: 'الجاثية', nameId: 'Al-Jasiyah', nameEn: 'The Crouching', ayatCount: 37, revelasi: 'Makkiyyah'),
  SurahMeta(number: 46, nameAr: 'الأحقاف', nameId: 'Al-Ahqaf', nameEn: 'The Wind-Curved Sandhills', ayatCount: 35, revelasi: 'Makkiyyah'),
  SurahMeta(number: 47, nameAr: 'محمد', nameId: 'Muhammad', nameEn: 'Muhammad', ayatCount: 38, revelasi: 'Madaniyyah'),
  SurahMeta(number: 48, nameAr: 'الفتح', nameId: 'Al-Fath', nameEn: 'The Victory', ayatCount: 29, revelasi: 'Madaniyyah'),
  SurahMeta(number: 49, nameAr: 'الحجرات', nameId: 'Al-Hujurat', nameEn: 'The Rooms', ayatCount: 18, revelasi: 'Madaniyyah'),
  SurahMeta(number: 50, nameAr: 'ق', nameId: 'Qaf', nameEn: 'The Letter Qaf', ayatCount: 45, revelasi: 'Makkiyyah'),
  SurahMeta(number: 51, nameAr: 'الذاريات', nameId: 'Az-Zariyat', nameEn: 'The Winnowing Winds', ayatCount: 60, revelasi: 'Makkiyyah'),
  SurahMeta(number: 52, nameAr: 'الطور', nameId: 'At-Tur', nameEn: 'The Mount', ayatCount: 49, revelasi: 'Makkiyyah'),
  SurahMeta(number: 53, nameAr: 'النجم', nameId: 'An-Najm', nameEn: 'The Star', ayatCount: 62, revelasi: 'Makkiyyah'),
  SurahMeta(number: 54, nameAr: 'القمر', nameId: 'Al-Qamar', nameEn: 'The Moon', ayatCount: 55, revelasi: 'Makkiyyah'),
  SurahMeta(number: 55, nameAr: 'الرحمن', nameId: 'Ar-Rahman', nameEn: 'The Beneficent', ayatCount: 78, revelasi: 'Madaniyyah'),
  SurahMeta(number: 56, nameAr: 'الواقعة', nameId: 'Al-Waqi\'ah', nameEn: 'The Inevitable', ayatCount: 96, revelasi: 'Makkiyyah'),
  SurahMeta(number: 57, nameAr: 'الحديد', nameId: 'Al-Hadid', nameEn: 'The Iron', ayatCount: 29, revelasi: 'Madaniyyah'),
  SurahMeta(number: 58, nameAr: 'المجادلة', nameId: 'Al-Mujadila', nameEn: 'The Pleading Woman', ayatCount: 22, revelasi: 'Madaniyyah'),
  SurahMeta(number: 59, nameAr: 'الحشر', nameId: 'Al-Hasyr', nameEn: 'The Exile', ayatCount: 24, revelasi: 'Madaniyyah'),
  SurahMeta(number: 60, nameAr: 'الممتحنة', nameId: 'Al-Mumtahanah', nameEn: 'She that is to be Examined', ayatCount: 13, revelasi: 'Madaniyyah'),
  SurahMeta(number: 61, nameAr: 'الصف', nameId: 'As-Saf', nameEn: 'The Ranks', ayatCount: 14, revelasi: 'Madaniyyah'),
  SurahMeta(number: 62, nameAr: 'الجمعة', nameId: 'Al-Jum\'ah', nameEn: 'Friday', ayatCount: 11, revelasi: 'Madaniyyah'),
  SurahMeta(number: 63, nameAr: 'المنافقون', nameId: 'Al-Munafiqun', nameEn: 'The Hypocrites', ayatCount: 11, revelasi: 'Madaniyyah'),
  SurahMeta(number: 64, nameAr: 'التغابن', nameId: 'At-Tagabun', nameEn: 'Mutual Disillusion', ayatCount: 18, revelasi: 'Madaniyyah'),
  SurahMeta(number: 65, nameAr: 'الطلاق', nameId: 'At-Talaq', nameEn: 'Divorce', ayatCount: 12, revelasi: 'Madaniyyah'),
  SurahMeta(number: 66, nameAr: 'التحريم', nameId: 'At-Tahrim', nameEn: 'The Prohibition', ayatCount: 12, revelasi: 'Madaniyyah'),
  SurahMeta(number: 67, nameAr: 'الملك', nameId: 'Al-Mulk', nameEn: 'The Sovereignty', ayatCount: 30, revelasi: 'Makkiyyah'),
  SurahMeta(number: 68, nameAr: 'القلم', nameId: 'Al-Qalam', nameEn: 'The Pen', ayatCount: 52, revelasi: 'Makkiyyah'),
  SurahMeta(number: 69, nameAr: 'الحاقة', nameId: 'Al-Haqqah', nameEn: 'The Reality', ayatCount: 52, revelasi: 'Makkiyyah'),
  SurahMeta(number: 70, nameAr: 'المعارج', nameId: 'Al-Ma\'arij', nameEn: 'The Ascending Stairways', ayatCount: 44, revelasi: 'Makkiyyah'),
  SurahMeta(number: 71, nameAr: 'نوح', nameId: 'Nuh', nameEn: 'Noah', ayatCount: 28, revelasi: 'Makkiyyah'),
  SurahMeta(number: 72, nameAr: 'الجن', nameId: 'Al-Jinn', nameEn: 'The Jinn', ayatCount: 28, revelasi: 'Makkiyyah'),
  SurahMeta(number: 73, nameAr: 'المزمل', nameId: 'Al-Muzzammil', nameEn: 'The Enshrouded One', ayatCount: 20, revelasi: 'Makkiyyah'),
  SurahMeta(number: 74, nameAr: 'المدثر', nameId: 'Al-Muddassir', nameEn: 'The Cloaked One', ayatCount: 56, revelasi: 'Makkiyyah'),
  SurahMeta(number: 75, nameAr: 'القيامة', nameId: 'Al-Qiyamah', nameEn: 'The Resurrection', ayatCount: 40, revelasi: 'Makkiyyah'),
  SurahMeta(number: 76, nameAr: 'الإنسان', nameId: 'Al-Insan', nameEn: 'The Man', ayatCount: 31, revelasi: 'Madaniyyah'),
  SurahMeta(number: 77, nameAr: 'المرسلات', nameId: 'Al-Mursalat', nameEn: 'The Emissaries', ayatCount: 50, revelasi: 'Makkiyyah'),
  SurahMeta(number: 78, nameAr: 'النبأ', nameId: 'An-Naba\'', nameEn: 'The Tidings', ayatCount: 40, revelasi: 'Makkiyyah'),
  SurahMeta(number: 79, nameAr: 'النازعات', nameId: 'An-Nazi\'at', nameEn: 'Those who drag forth', ayatCount: 46, revelasi: 'Makkiyyah'),
  SurahMeta(number: 80, nameAr: 'عبس', nameId: '\'Abasa', nameEn: 'He Frowned', ayatCount: 42, revelasi: 'Makkiyyah'),
  SurahMeta(number: 81, nameAr: 'التكوير', nameId: 'At-Takwir', nameEn: 'The Overthrowing', ayatCount: 29, revelasi: 'Makkiyyah'),
  SurahMeta(number: 82, nameAr: 'الانفطار', nameId: 'Al-Infitar', nameEn: 'The Cleaving', ayatCount: 19, revelasi: 'Makkiyyah'),
  SurahMeta(number: 83, nameAr: 'المطففين', nameId: 'Al-Mutaffifin', nameEn: 'The Defrauding', ayatCount: 36, revelasi: 'Makkiyyah'),
  SurahMeta(number: 84, nameAr: 'الانشقاق', nameId: 'Al-Insyiqaq', nameEn: 'The Splitting Open', ayatCount: 25, revelasi: 'Makkiyyah'),
  SurahMeta(number: 85, nameAr: 'البروج', nameId: 'Al-Buruj', nameEn: 'The Mansions of the Stars', ayatCount: 22, revelasi: 'Makkiyyah'),
  SurahMeta(number: 86, nameAr: 'الطارق', nameId: 'At-Tariq', nameEn: 'The Morning Star', ayatCount: 17, revelasi: 'Makkiyyah'),
  SurahMeta(number: 87, nameAr: 'الأعلى', nameId: 'Al-A\'la', nameEn: 'The Most High', ayatCount: 19, revelasi: 'Makkiyyah'),
  SurahMeta(number: 88, nameAr: 'الغاشية', nameId: 'Al-Ghasyiyah', nameEn: 'The Overwhelming', ayatCount: 26, revelasi: 'Makkiyyah'),
  SurahMeta(number: 89, nameAr: 'الفجر', nameId: 'Al-Fajr', nameEn: 'The Dawn', ayatCount: 30, revelasi: 'Makkiyyah'),
  SurahMeta(number: 90, nameAr: 'البلد', nameId: 'Al-Balad', nameEn: 'The City', ayatCount: 20, revelasi: 'Makkiyyah'),
  SurahMeta(number: 91, nameAr: 'الشمس', nameId: 'Asy-Syams', nameEn: 'The Sun', ayatCount: 15, revelasi: 'Makkiyyah'),
  SurahMeta(number: 92, nameAr: 'الليل', nameId: 'Al-Lail', nameEn: 'The Night', ayatCount: 21, revelasi: 'Makkiyyah'),
  SurahMeta(number: 93, nameAr: 'الضحى', nameId: 'Ad-Duha', nameEn: 'The Morning Hours', ayatCount: 11, revelasi: 'Makkiyyah'),
  SurahMeta(number: 94, nameAr: 'الشرح', nameId: 'Asy-Syarh', nameEn: 'The Relief', ayatCount: 8, revelasi: 'Makkiyyah'),
  SurahMeta(number: 95, nameAr: 'التين', nameId: 'At-Tin', nameEn: 'The Fig', ayatCount: 8, revelasi: 'Makkiyyah'),
  SurahMeta(number: 96, nameAr: 'العلق', nameId: 'Al-\'Alaq', nameEn: 'The Clot', ayatCount: 19, revelasi: 'Makkiyyah'),
  SurahMeta(number: 97, nameAr: 'القدر', nameId: 'Al-Qadr', nameEn: 'The Power', ayatCount: 5, revelasi: 'Makkiyyah'),
  SurahMeta(number: 98, nameAr: 'البينة', nameId: 'Al-Bayyinah', nameEn: 'The Clear Proof', ayatCount: 8, revelasi: 'Madaniyyah'),
  SurahMeta(number: 99, nameAr: 'الزلزلة', nameId: 'Az-Zalzalah', nameEn: 'The Earthquake', ayatCount: 8, revelasi: 'Madaniyyah'),
  SurahMeta(number: 100, nameAr: 'العاديات', nameId: 'Al-\'Adiyat', nameEn: 'The Courser', ayatCount: 11, revelasi: 'Makkiyyah'),
  SurahMeta(number: 101, nameAr: 'القارعة', nameId: 'Al-Qari\'ah', nameEn: 'The Calamity', ayatCount: 11, revelasi: 'Makkiyyah'),
  SurahMeta(number: 102, nameAr: 'التكاثر', nameId: 'At-Takasur', nameEn: 'The Rivalry in World Increase', ayatCount: 8, revelasi: 'Makkiyyah'),
  SurahMeta(number: 103, nameAr: 'العصر', nameId: 'Al-\'Asr', nameEn: 'The Declining Day', ayatCount: 3, revelasi: 'Makkiyyah'),
  SurahMeta(number: 104, nameAr: 'الهمزة', nameId: 'Al-Humazah', nameEn: 'The Traducer', ayatCount: 9, revelasi: 'Makkiyyah'),
  SurahMeta(number: 105, nameAr: 'الفيل', nameId: 'Al-Fil', nameEn: 'The Elephant', ayatCount: 5, revelasi: 'Makkiyyah'),
  SurahMeta(number: 106, nameAr: 'قريش', nameId: 'Quraisy', nameEn: 'Quraysh', ayatCount: 4, revelasi: 'Makkiyyah'),
  SurahMeta(number: 107, nameAr: 'الماعون', nameId: 'Al-Ma\'un', nameEn: 'The Small Kindnesses', ayatCount: 7, revelasi: 'Makkiyyah'),
  SurahMeta(number: 108, nameAr: 'الكوثر', nameId: 'Al-Kausar', nameEn: 'Abundance', ayatCount: 3, revelasi: 'Makkiyyah'),
  SurahMeta(number: 109, nameAr: 'الكافرون', nameId: 'Al-Kafirun', nameEn: 'The Disbelievers', ayatCount: 6, revelasi: 'Makkiyyah'),
  SurahMeta(number: 110, nameAr: 'النصر', nameId: 'An-Nasr', nameEn: 'The Divine Support', ayatCount: 3, revelasi: 'Madaniyyah'),
  SurahMeta(number: 111, nameAr: 'المسد', nameId: 'Al-Masad', nameEn: 'The Palm Fibre', ayatCount: 5, revelasi: 'Makkiyyah'),
  SurahMeta(number: 112, nameAr: 'الإخلاص', nameId: 'Al-Ikhlas', nameEn: 'Sincerity', ayatCount: 4, revelasi: 'Makkiyyah'),
  SurahMeta(number: 113, nameAr: 'الفلق', nameId: 'Al-Falaq', nameEn: 'The Daybreak', ayatCount: 5, revelasi: 'Makkiyyah'),
  SurahMeta(number: 114, nameAr: 'الناس', nameId: 'An-Nas', nameEn: 'Mankind', ayatCount: 6, revelasi: 'Makkiyyah'),
];
