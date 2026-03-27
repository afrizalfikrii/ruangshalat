import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/features/guide/prayer_detail_screen.dart';
import 'package:ruang_shalat/models/prayer_detail.dart';

// ── Dzikir data model ─────────────────────────────────────────────────────────
class _DzikirItem {
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final int count;
  const _DzikirItem({
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.count,
  });
}

const List<_DzikirItem> _dzikirPagi = [
  _DzikirItem(
    title: 'Ayat Kursi',
    arabic: 'اللّٰهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    latin: 'Allāhu lā ilāha illā huwal-ḥayyul-qayyūm...',
    translation:
        'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, yang terus menerus mengurus makhluk-Nya.',
    count: 1,
  ),
  _DzikirItem(
    title: 'Tasbih Pagi',
    arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
    latin: 'Subhānallāhi wa bihamdih.',
    translation: 'Maha Suci Allah dan aku memuji-Nya.',
    count: 100,
  ),
  _DzikirItem(
    title: 'Istighfar',
    arabic:
        'أَسْتَغْفِرُ اللّٰهَ الْعَظِيمَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    latin:
        "Astaghfirullāhal-'aẓīm alladzī lā ilāha illā huwal-ḥayyul-qayyūmu wa atūbu ilaih.",
    translation:
        'Aku memohon ampun kepada Allah Yang Maha Agung, yang tiada tuhan selain Dia, Yang Maha Hidup dan Berdiri sendiri, dan aku bertaubat kepada-Nya.',
    count: 3,
  ),
  _DzikirItem(
    title: 'Doa Perlindungan Pagi',
    arabic:
        'اللّٰهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    latin:
        'Allāhumma bika aṣbaḥnā wa bika amsaynā wa bika naḥyā wa bika namūtu wa ilaykan-nusyūr.',
    translation:
        'Ya Allah, dengan-Mu kami memasuki pagi, dengan-Mu kami memasuki petang, dengan-Mu kami hidup, dengan-Mu kami mati, dan kepada-Mu kebangkitan.',
    count: 1,
  ),
];

const List<_DzikirItem> _dzikirPetang = [
  _DzikirItem(
    title: 'Dzikir Petang',
    arabic:
        'اللّٰهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    latin:
        'Allāhumma bika amsaynā wa bika aṣbaḥnā wa bika naḥyā wa bika namūtu wa ilaykal-maṣīr.',
    translation:
        'Ya Allah, dengan-Mu kami memasuki petang, dengan-Mu kami memasuki pagi, dengan-Mu kami hidup, dengan-Mu kami mati, dan kepada-Mu tempat kembali.',
    count: 1,
  ),
  _DzikirItem(
    title: 'Tasbih Petang',
    arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
    latin: 'Subhānallāhi wa bihamdih.',
    translation: 'Maha Suci Allah dan aku memuji-Nya.',
    count: 100,
  ),
  _DzikirItem(
    title: 'Hamdalah',
    arabic:
        'الْحَمْدُ لِلّٰهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    latin:
        "Alḥamdu lillāhil-ladzī aḥyānā ba'da mā amātanā wa ilayhīn-nusyūr.",
    translation:
        'Segala puji bagi Allah yang menghidupkan kami setelah mematikan kami, dan kepada-Nya kami akan kembali.',
    count: 1,
  ),
  _DzikirItem(
    title: 'Doa Perlindungan',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللّٰهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    latin: "A'ūdzu bikalimātillāhit-tāmmāti min syarri mā khalaq.",
    translation:
        'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang Dia ciptakan.',
    count: 3,
  ),
];

const List<_DzikirItem> _dzikirSetelahShalat = [
  _DzikirItem(
    title: 'Istighfar',
    arabic: 'أَسْتَغْفِرُ اللّٰهَ',
    latin: 'Astaghfirullāh.',
    translation: 'Aku memohon ampun kepada Allah.',
    count: 3,
  ),
  _DzikirItem(
    title: 'Allahumma Antas Salam',
    arabic:
        'اللّٰهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    latin:
        'Allāhumma antas-salāmu wa minkas-salāmu tabārakta yā dzal-jalāli wal-ikrām.',
    translation:
        'Ya Allah, Engkau adalah As-Salam. Dari-Mu lah keselamatan. Maha Berkah Engkau wahai Dzat yang memiliki keagungan dan kemuliaan.',
    count: 1,
  ),
  _DzikirItem(
    title: 'Subhanallah',
    arabic: 'سُبْحَانَ اللّٰهِ',
    latin: 'Subhānallāh.',
    translation: 'Maha Suci Allah.',
    count: 33,
  ),
  _DzikirItem(
    title: 'Alhamdulillah',
    arabic: 'الْحَمْدُ لِلّٰهِ',
    latin: 'Alḥamdulillāh.',
    translation: 'Segala puji bagi Allah.',
    count: 33,
  ),
  _DzikirItem(
    title: 'Allahu Akbar',
    arabic: 'اللّٰهُ أَكْبَرُ',
    latin: 'Allāhu akbar.',
    translation: 'Allah Maha Besar.',
    count: 33,
  ),
  _DzikirItem(
    title: 'Laa ilaha illallah',
    arabic:
        'لَا إِلَٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        "Lā ilāha illallāhu waḥdahū lā syarīka lahu, lahul-mulku wa lahul-ḥamdu wa huwa 'alā kulli syay'in qadīr.",
    translation:
        'Tidak ada tuhan selain Allah, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dan Dia berkuasa atas segala sesuatu.',
    count: 1,
  ),
];

// ── GuideScreen ───────────────────────────────────────────────────────────────
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_PrayerGuide> _allPrayers = [
    _PrayerGuide(
      name: 'Subuh',
      arabic: 'الصبح',
      rakaat: '2 Rakaat',
      icon: Icons.wb_twilight,
      color: AppColors.emeraldGreen,
      bgColor: Color(0xFFEAF4F0),
    ),
    _PrayerGuide(
      name: 'Dzuhur',
      arabic: 'الظهر',
      rakaat: '4 Rakaat',
      icon: Icons.wb_sunny,
      color: AppColors.emeraldGreen,
      bgColor: Color(0xFFEAF4F0),
    ),
    _PrayerGuide(
      name: 'Ashar',
      arabic: 'العصر',
      rakaat: '4 Rakaat',
      icon: Icons.wb_cloudy,
      color: AppColors.emeraldGreen,
      bgColor: Color(0xFFEAF4F0),
    ),
    _PrayerGuide(
      name: 'Maghrib',
      arabic: 'المغرب',
      rakaat: '3 Rakaat',
      icon: Icons.nights_stay,
      color: AppColors.emeraldGreen,
      bgColor: Color(0xFFEAF4F0),
    ),
    _PrayerGuide(
      name: 'Isya',
      arabic: 'العشاء',
      rakaat: '4 Rakaat',
      icon: Icons.bedtime,
      color: AppColors.emeraldGreen,
      bgColor: Color(0xFFEAF4F0),
    ),
  ];



  static const List<_DoaItem> _allDoas = [
    _DoaItem(title: 'Doa Setelah Wudhu', arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ'),
    _DoaItem(title: 'Doa Masuk Masjid', arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ'),
    _DoaItem(title: 'Doa Keluar Masjid', arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ'),
    _DoaItem(title: 'Doa Iftitah', arabic: 'اللهُ أَكْبَرُ كَبِيراً وَالْحَمْدُ لِلَّهِ كَثِيراً'),
    _DoaItem(title: 'Doa Qunut', arabic: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtered lists ────────────────────────────────────────────────────────
  List<_PrayerGuide> get _filteredPrayers => _searchQuery.isEmpty
      ? _allPrayers
      : _allPrayers
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery) ||
              p.arabic.contains(_searchQuery) ||
              p.rakaat.toLowerCase().contains(_searchQuery))
          .toList();



  List<_DoaItem> get _filteredDoas => _searchQuery.isEmpty
      ? _allDoas
      : _allDoas
          .where((d) =>
              d.title.toLowerCase().contains(_searchQuery) ||
              d.arabic.contains(_searchQuery))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: const Text(
          'Panduan Ibadah',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari panduan shalat, wudhu, doa, atau dzikir...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Tab Bar ─────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.emeraldGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.emeraldGreen,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.mosque, size: 18), text: 'Shalat'),

                Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Doa'),
                Tab(icon: Icon(Icons.favorite, size: 18), text: 'Dzikir'),
              ],
            ),
          ),

          // ── Tab Views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShalatTab(),

                _buildDoaTab(),
                _buildDzikirTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shalat Wajib Tab ──────────────────────────────────────────────────────
  Widget _buildShalatTab() {
    final prayers = _filteredPrayers;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '5 Shalat Wajib',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${prayers.length} Panduan',
                  style: const TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (prayers.isEmpty)
          Expanded(child: _emptyState('Shalat tidak ditemukan'))
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: prayers.length,
              itemBuilder: (context, index) => _buildPrayerCard(prayers[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildPrayerCard(_PrayerGuide p) {
    final detail = prayerDetails.firstWhere(
      (d) => d.name == p.name,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: p.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(p.icon, color: p.color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              p.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              p.arabic,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: p.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.rakaat,
                    style: TextStyle(
                        color: p.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrayerDetailScreen(
                        prayer: detail,
                        color: p.color,
                        bgColor: p.bgColor,
                        icon: p.icon,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Buka', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Doa Tab ───────────────────────────────────────────────────────────────
  Widget _buildDoaTab() {
    final duas = _filteredDoas;
    if (duas.isEmpty) return _emptyState('Doa tidak ditemukan');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, i) {
        final d = duas[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.emeraldGreen, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(d.arabic,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontFamily: 'serif'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade300),
            ],
          ),
        );
      },
    );
  }

  // ── Dzikir Tab ────────────────────────────────────────────────────────────
  Widget _buildDzikirTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppColors.emeraldGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.emeraldGreen,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Pagi'),
                Tab(text: 'Petang'),
                Tab(text: 'Setelah Shalat'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _dzikirList(_dzikirPagi),
                _dzikirList(_dzikirPetang),
                _dzikirList(_dzikirSetelahShalat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dzikirList(List<_DzikirItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => _DzikirCard(item: items[i]),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _searchController.clear(),
            child: const Text('Hapus pencarian'),
          ),
        ],
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────
class _PrayerGuide {
  final String name, arabic, rakaat;
  final IconData icon;
  final Color color, bgColor;
  const _PrayerGuide({
    required this.name,
    required this.arabic,
    required this.rakaat,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}



class _DoaItem {
  final String title, arabic;
  const _DoaItem({required this.title, required this.arabic});
}

// ── Dzikir Card Widget ────────────────────────────────────────────────────────
class _DzikirCard extends StatefulWidget {
  final _DzikirItem item;
  const _DzikirCard({required this.item});

  @override
  State<_DzikirCard> createState() => _DzikirCardState();
}

class _DzikirCardState extends State<_DzikirCard> {
  bool _expanded = false;
  int _counter = 0;
  static const Color _green = AppColors.emeraldGreen;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _green.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite, color: _green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.count}x ulang',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Counter badge
                  if (_counter > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_counter',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded detail ──────────────────────────────────────────────
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 12),
                  // Arabic
                  Text(
                    item.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontSize: 20, color: Colors.black87, height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  // Latin
                  Text(
                    item.latin,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Terjemahan
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _green.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.translation,
                      style: TextStyle(
                          fontSize: 13,
                          color: _green.withAlpha(200),
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Counter row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _counter == 0
                              ? 'Ketuk untuk menghitung'
                              : '$_counter / ${item.count} kali',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ),
                      if (_counter > 0)
                        TextButton(
                          onPressed: () => setState(() => _counter = 0),
                          child: Text('Reset',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 12)),
                        ),
                      GestureDetector(
                        onTap: () => setState(() => _counter++),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _counter >= item.count
                                ? Colors.green
                                : _green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
