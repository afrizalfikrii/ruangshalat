/// Data model for a single prayer's full detail
class PrayerDetail {
  final String name;
  final String arabic;
  final String rakaat;
  final String timeInfo;
  final String timeDetail;

  // Niat
  final String niatArabic;
  final String niatLatin;
  final String niatTranslation;

  // Rakaat structure
  final List<RakaatInfo> rakaatStructure;

  // Bacaan wajib
  final List<BacaanItem> bacaanWajib;

  // Doa setelah shalat
  final String doaArabic;
  final String doaLatin;
  final String doaTranslation;

  const PrayerDetail({
    required this.name,
    required this.arabic,
    required this.rakaat,
    required this.timeInfo,
    required this.timeDetail,
    required this.niatArabic,
    required this.niatLatin,
    required this.niatTranslation,
    required this.rakaatStructure,
    required this.bacaanWajib,
    required this.doaArabic,
    required this.doaLatin,
    required this.doaTranslation,
  });
}

class RakaatInfo {
  final int number;
  final List<String> steps;
  const RakaatInfo({required this.number, required this.steps});
}

class BacaanItem {
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  const BacaanItem({
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Seed Data for all 5 prayers
// ────────────────────────────────────────────────────────────────────────────

const List<PrayerDetail> prayerDetails = [
  // ── SUBUH ──────────────────────────────────────────────────────────────────
  PrayerDetail(
    name: 'Subuh',
    arabic: 'الصبح',
    rakaat: '2 Rakaat',
    timeInfo: 'Fajar hingga Matahari Terbit',
    timeDetail:
        'Dimulai saat fajar shadiq (cahaya di ufuk timur) dan berakhir saat matahari terbit. '
        'Disunnahkan untuk dikerjakan di awal waktu.',

    niatArabic:
        'أُصَلِّي فَرْضَ الصُّبْحِ رَكْعَتَيْنِ مُسْتَقْبِلَ الْقِبْلَةِ أَدَاءً لِلَّهِ تَعَالَى',
    niatLatin:
        'Ushalli fardash-shubhi rak\'ataini mustaqbilal-qiblati adā\'an lillāhi ta\'ālā.',
    niatTranslation:
        'Saya niat shalat fardhu Subuh dua rakaat, menghadap kiblat, '
        'tunai karena Allah Ta\'ala.',

    rakaatStructure: [
      RakaatInfo(
        number: 1,
        steps: [
          'Takbiratul ihram',
          'Doa iftitah',
          'Al-Fatihah',
          'Surah pendek',
          'Ruku\' + tuma\'ninah',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 2,
        steps: [
          'Berdiri, Al-Fatihah',
          'Surah pendek',
          'Ruku\' + tuma\'ninah',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud akhir',
          'Salam ke kanan & kiri',
        ],
      ),
    ],

    bacaanWajib: _bacaanUmum,

    doaArabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    doaLatin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    doaTranslation:
        'Ya Allah, Engkau adalah As-Salam (Maha Pemberi keselamatan). '
        'Dari-Mu lah keselamatan. Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
  ),

  // ── DZUHUR ─────────────────────────────────────────────────────────────────
  PrayerDetail(
    name: 'Dzuhur',
    arabic: 'الظهر',
    rakaat: '4 Rakaat',
    timeInfo: 'Matahari Tergelincir hingga Asar',
    timeDetail:
        'Dimulai saat matahari tergelincir dari puncaknya (istiwa\') hingga bayangan benda '
        'sama panjang dengan bendanya. Disunnahkan dikerjakan setelah azan.',

    niatArabic:
        'أُصَلِّي فَرْضَ الظُّهْرِ أَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ أَدَاءً لِلَّهِ تَعَالَى',
    niatLatin:
        'Ushalli fardladh-dhuhri arba\'a raka\'ātin mustaqbilal-qiblati adā\'an lillāhi ta\'ālā.',
    niatTranslation:
        'Saya niat shalat fardhu Dzuhur empat rakaat, menghadap kiblat, '
        'tunai karena Allah Ta\'ala.',

    rakaatStructure: [
      RakaatInfo(
        number: 1,
        steps: [
          'Takbiratul ihram',
          'Doa iftitah',
          'Al-Fatihah',
          'Surah pendek',
          'Ruku\' + tuma\'ninah',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 2,
        steps: [
          'Berdiri, Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud awal (duduk)',
        ],
      ),
      RakaatInfo(
        number: 3,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 4,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud akhir',
          'Salam ke kanan & kiri',
        ],
      ),
    ],

    bacaanWajib: _bacaanUmum,

    doaArabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    doaLatin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    doaTranslation:
        'Ya Allah, Engkau adalah As-Salam. Dari-Mu lah keselamatan. '
        'Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
  ),

  // ── ASHAR ──────────────────────────────────────────────────────────────────
  PrayerDetail(
    name: 'Ashar',
    arabic: 'العصر',
    rakaat: '4 Rakaat',
    timeInfo: 'Setelah Dzuhur hingga Matahari Terbenam',
    timeDetail:
        'Dimulai saat bayangan benda dua kali lebih panjang dari bendanya hingga matahari '
        'terbenam. Jangan lewatkan karena termasuk shalat wushtha (pertengahan).',

    niatArabic:
        'أُصَلِّي فَرْضَ الْعَصْرِ أَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ أَدَاءً لِلَّهِ تَعَالَى',
    niatLatin:
        'Ushalli fardhal-\'ashri arba\'a raka\'ātin mustaqbilal-qiblati adā\'an lillāhi ta\'ālā.',
    niatTranslation:
        'Saya niat shalat fardhu Ashar empat rakaat, menghadap kiblat, '
        'tunai karena Allah Ta\'ala.',

    rakaatStructure: [
      RakaatInfo(
        number: 1,
        steps: [
          'Takbiratul ihram',
          'Doa iftitah',
          'Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 2,
        steps: [
          'Berdiri, Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud awal (duduk)',
        ],
      ),
      RakaatInfo(
        number: 3,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 4,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud akhir',
          'Salam ke kanan & kiri',
        ],
      ),
    ],

    bacaanWajib: _bacaanUmum,

    doaArabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    doaLatin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    doaTranslation:
        'Ya Allah, Engkau adalah As-Salam. Dari-Mu lah keselamatan. '
        'Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
  ),

  // ── MAGHRIB ────────────────────────────────────────────────────────────────
  PrayerDetail(
    name: 'Maghrib',
    arabic: 'المغرب',
    rakaat: '3 Rakaat',
    timeInfo: 'Matahari Terbenam hingga Hilangnya Mega Merah',
    timeDetail:
        'Dimulai saat matahari terbenam dan berakhir saat hilangnya awan merah di ufuk barat. '
        'Waktunya singkat, segera shalat setelah matahari terbenam.',

    niatArabic:
        'أُصَلِّي فَرْضَ الْمَغْرِبِ ثَلَاثَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ أَدَاءً لِلَّهِ تَعَالَى',
    niatLatin:
        'Ushalli fardhal-maghribi tsalātsa raka\'ātin mustaqbilal-qiblati adā\'an lillāhi ta\'ālā.',
    niatTranslation:
        'Saya niat shalat fardhu Maghrib tiga rakaat, menghadap kiblat, '
        'tunai karena Allah Ta\'ala.',

    rakaatStructure: [
      RakaatInfo(
        number: 1,
        steps: [
          'Takbiratul ihram',
          'Doa iftitah',
          'Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 2,
        steps: [
          'Berdiri, Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud awal (duduk)',
        ],
      ),
      RakaatInfo(
        number: 3,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud akhir',
          'Salam ke kanan & kiri',
        ],
      ),
    ],

    bacaanWajib: _bacaanUmum,

    doaArabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    doaLatin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    doaTranslation:
        'Ya Allah, Engkau adalah As-Salam. Dari-Mu lah keselamatan. '
        'Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
  ),

  // ── ISYA ───────────────────────────────────────────────────────────────────
  PrayerDetail(
    name: 'Isya',
    arabic: 'العشاء',
    rakaat: '4 Rakaat',
    timeInfo: 'Hilangnya Mega Merah hingga Tengah Malam',
    timeDetail:
        'Dimulai saat hilangnya awan merah di ufuk barat (setelah Maghrib) hingga sepertiga '
        'atau pertengahan malam. Disunnahkan tidak terlalu lama menundanya.',

    niatArabic:
        'أُصَلِّي فَرْضَ الْعِشَاءِ أَرْبَعَ رَكَعَاتٍ مُسْتَقْبِلَ الْقِبْلَةِ أَدَاءً لِلَّهِ تَعَالَى',
    niatLatin:
        'Ushalli fardhal-\'isyā\'i arba\'a raka\'ātin mustaqbilal-qiblati adā\'an lillāhi ta\'ālā.',
    niatTranslation:
        'Saya niat shalat fardhu Isya empat rakaat, menghadap kiblat, '
        'tunai karena Allah Ta\'ala.',

    rakaatStructure: [
      RakaatInfo(
        number: 1,
        steps: [
          'Takbiratul ihram',
          'Doa iftitah',
          'Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 2,
        steps: [
          'Berdiri, Al-Fatihah',
          'Surah pendek',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud awal (duduk)',
        ],
      ),
      RakaatInfo(
        number: 3,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
        ],
      ),
      RakaatInfo(
        number: 4,
        steps: [
          'Berdiri, Al-Fatihah',
          'Ruku\'',
          'I\'tidal',
          'Sujud pertama',
          'Duduk di antara dua sujud',
          'Sujud kedua',
          'Tasyahud akhir',
          'Salam ke kanan & kiri',
        ],
      ),
    ],

    bacaanWajib: _bacaanUmum,

    doaArabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    doaLatin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    doaTranslation:
        'Ya Allah, Engkau adalah As-Salam. Dari-Mu lah keselamatan. '
        'Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
  ),
];

// ── Shared bacaan wajib (sama untuk semua shalat) ──────────────────────────
const List<BacaanItem> _bacaanUmum = [
  BacaanItem(
    title: 'Doa Iftitah',
    arabic:
        'اللهُ أَكْبَرُ كَبِيرًا وَالْحَمْدُ لِلّٰهِ كَثِيرًا وَسُبْحَانَ اللهِ بُكْرَةً وَأَصِيلًا',
    latin:
        'Allāhu akbaru kabīran, walhamdu lillāhi katsīran, wa subhānallāhi bukratan wa ashīlā.',
    translation:
        'Allah Maha Besar dengan segala kebesaran, segala puji bagi Allah dengan pujian yang banyak, '
        'Maha Suci Allah di waktu pagi dan petang.',
  ),
  BacaanItem(
    title: 'Al-Fatihah',
    arabic:
        'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيدَ ۝ الرَّحْمٰنِ الرَّحِيمِ ۝ مٰلِكِ يَوْمِ الدِّيدِ ۝ اِيَّاكَ نَعْبُدُ وَاِيَّاكَ نَسْتَعِيدُ ۝ اِهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِيدَ اَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّاۤلِّيدَ',
    latin:
        'Bismillāhir-rahmānir-rahīm. Alhamdu lillāhi rabbil-\'ālamīn. Ar-rahmānir-rahīm. '
        'Māliki yawmid-dīn. Iyyāka na\'budu wa iyyāka nasta\'īn. Ihdinash-shirāthal-mustaqīm. '
        'Shirāthal-ladzīna an\'amta \'alayhim, ghayril-maghdūbi \'alayhim wa ladh-dhāllīn.',
    translation:
        'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang. Segala puji bagi Allah, '
        'Tuhan semesta alam. Yang Maha Pengasih, Maha Penyayang. Pemilik hari pembalasan. '
        'Hanya kepada-Mu kami menyembah dan hanya kepada-Mu kami mohon pertolongan. '
        'Tunjukilah kami jalan yang lurus, yaitu jalan orang-orang yang telah Engkau beri nikmat, '
        'bukan jalan mereka yang dimurkai dan bukan pula jalan mereka yang sesat.',
  ),
  BacaanItem(
    title: 'Doa Ruku\'',
    arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ وَبِحَمْدِهِ',
    latin: 'Subhāna rabbiyal-\'azhīmi wa bihamdih.',
    translation: 'Maha Suci Tuhanku Yang Maha Agung dan aku memuji-Nya.',
  ),
  BacaanItem(
    title: 'I\'tidal',
    arabic:
        'سَمِعَ اللهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
    latin:
        'Sami\'allāhu liman hamidah. Rabbanā wa lakal-hamdu hamdan katsīran thayyiban mubārakan fīh.',
    translation:
        'Allah mendengar orang yang memuji-Nya. Ya Tuhan kami, bagi-Mu segala puji yang banyak, '
        'baik, dan penuh berkah.',
  ),
  BacaanItem(
    title: 'Doa Sujud',
    arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى وَبِحَمْدِهِ',
    latin: 'Subhāna rabbiyal-a\'lā wa bihamdih.',
    translation: 'Maha Suci Tuhanku Yang Maha Tinggi dan aku memuji-Nya.',
  ),
  BacaanItem(
    title: 'Doa di antara Dua Sujud',
    arabic:
        'رَبِّ اغْفِرْ لِي وَارْحَمْنِي وَاجْبُرْنِي وَارْفَعْنِي وَارْزُقْنِي وَاهْدِنِي وَعَافِنِي وَاعْفُ عَنِّي',
    latin:
        'Rabbighfirlī warhamnī wajburnī warfa\'nī warzuqnī wahdinī wa\'āfinī wa\'fu \'annī.',
    translation:
        'Ya Allah, ampunilah aku, rahmatilah aku, cukupkanlah aku, angkatlah derajatku, '
        'berilah aku rezeki, tunjukilah aku, sehatkanlah aku, dan maafkanlah aku.',
  ),
  BacaanItem(
    title: 'Tasyahud Awal',
    arabic:
        'التَّحِيَّاتُ الْمُبَارَكَاتُ الصَّلَوَاتُ الطَّيِّبَاتُ لِلّٰهِ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللّٰهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللّٰهِ الصَّالِحِيدَ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللّٰهِ',
    latin:
        'At-tahiyyātul mubārakātush-shalawātuth-thayyibātu lillāh. As-salāmu \'alayka ayyuhan-nabiyyu '
        'wa rahmatullāhi wa barakātuh. As-salāmu \'alaynā wa \'alā \'ibādillāhish-shālihīn. '
        'Asyhadu allā ilāha illallāh wa asyhadu anna Muhammadan rasūlullāh.',
    translation:
        'Segala penghormatan, keberkahan, shalawat, dan kebaikan hanya bagi Allah. '
        'Semoga keselamatan terlimpah atasmu wahai Nabi, beserta rahmat Allah dan berkah-Nya. '
        'Semoga keselamatan terlimpah atas kami dan hamba-hamba Allah yang shalih. '
        'Aku bersaksi tiada tuhan selain Allah dan aku bersaksi bahwa Muhammad adalah utusan Allah.',
  ),
  BacaanItem(
    title: 'Tasyahud Akhir',
    arabic:
        'اللّٰهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ وَبَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ فِي الْعَالَمِيدَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    latin:
        'Allāhumma shalli \'alā Muhammad wa \'alā āli Muhammad kamā shallayta \'alā Ibrāhīm '
        'wa \'alā āli Ibrāhīm. Wa bārik \'alā Muhammad wa \'alā āli Muhammad kamā bārakta '
        '\'alā Ibrāhīm wa \'alā āli Ibrāhīm fil-\'ālamīn innaka hamīdun majīd.',
    translation:
        'Ya Allah, berikanlah shalawat kepada Muhammad dan keluarga Muhammad seperti Engkau '
        'memberi shalawat kepada Ibrahim dan keluarga Ibrahim. Dan berikanlah berkah kepada '
        'Muhammad dan keluarga Muhammad seperti Engkau memberi berkah kepada Ibrahim dan '
        'keluarga Ibrahim di seluruh alam. Sungguh Engkau Maha Terpuji lagi Maha Mulia.',
  ),
];
