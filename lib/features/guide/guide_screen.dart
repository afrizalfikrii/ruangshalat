import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
          // ── Search Bar ────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tata cara shalat...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Tab Bar ───────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.emeraldGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.emeraldGreen,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.mosque, size: 18), text: 'Shalat Wajib'),
                Tab(icon: Icon(Icons.water_drop, size: 18), text: 'Wudhu'),
                Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Doa'),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShalatTab(),
                _buildWudhuTab(),
                _buildDoaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shalat Wajib Tab ─────────────────────────────────────────────────────
  Widget _buildShalatTab() {
    final prayers = [
      _PrayerGuide(
        name: 'Subuh',
        arabic: 'الصبح',
        rakaat: '2 Rakaat',
        icon: Icons.wb_twilight,
        color: const Color(0xFFFF7043),
        bgColor: const Color(0xFFFFF3EF),
      ),
      _PrayerGuide(
        name: 'Dzuhur',
        arabic: 'الظهر',
        rakaat: '4 Rakaat',
        icon: Icons.wb_sunny,
        color: const Color(0xFFF9A825),
        bgColor: const Color(0xFFFFFBEE),
      ),
      _PrayerGuide(
        name: 'Ashar',
        arabic: 'العصر',
        rakaat: '4 Rakaat',
        icon: Icons.wb_cloudy,
        color: const Color(0xFFFF5722),
        bgColor: const Color(0xFFFFF3E0),
      ),
      _PrayerGuide(
        name: 'Maghrib',
        arabic: 'المغرب',
        rakaat: '3 Rakaat',
        icon: Icons.nights_stay,
        color: const Color(0xFF7E57C2),
        bgColor: const Color(0xFFF3E5F5),
      ),
      _PrayerGuide(
        name: 'Isya',
        arabic: 'العشاء',
        rakaat: '4 Rakaat',
        icon: Icons.bedtime,
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
      ),
      _PrayerGuide(
        name: 'Wudhu',
        arabic: 'الوضوء',
        rakaat: 'Tata Cara',
        icon: Icons.water_drop,
        color: AppColors.emeraldGreen,
        bgColor: const Color(0xFFE8F5E9),
      ),
    ];

    return Column(
      children: [
        // Header count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '5 Shalat Wajib & Wudhu',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '6 Panduan',
                  style: TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        // Grid
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
            itemBuilder: (context, index) =>
                _buildPrayerCard(prayers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard(_PrayerGuide p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: p.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(p.icon, color: p.color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              p.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              p.arabic,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              p.rakaat,
              style: TextStyle(
                  color: p.color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            // Buka button
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: () {},
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
                    Text('Buka',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
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

  // ── Wudhu Tab ─────────────────────────────────────────────────────────────
  Widget _buildWudhuTab() {
    final steps = [
      _WudhuStep(
          step: 1,
          title: 'Niat',
          desc: 'Niat wudhu karena Allah Ta\'ala',
          icon: Icons.volunteer_activism),
      _WudhuStep(
          step: 2,
          title: 'Membaca Bismillah',
          desc: 'Membaca bismillah sebelum memulai',
          icon: Icons.menu_book),
      _WudhuStep(
          step: 3,
          title: 'Membasuh Telapak Tangan',
          desc: 'Basuh 3x hingga sela-sela jari',
          icon: Icons.back_hand),
      _WudhuStep(
          step: 4,
          title: 'Berkumur & Istinsyaq',
          desc: 'Berkumur dan membersihkan hidung 3x',
          icon: Icons.water_drop),
      _WudhuStep(
          step: 5,
          title: 'Membasuh Muka',
          desc: 'Basuh seluruh wajah 3x',
          icon: Icons.face),
      _WudhuStep(
          step: 6,
          title: 'Membasuh Tangan',
          desc: 'Basuh hingga siku 3x (kanan dulu)',
          icon: Icons.waving_hand),
      _WudhuStep(
          step: 7,
          title: 'Mengusap Kepala',
          desc: 'Usap dari depan ke belakang 1x',
          icon: Icons.accessibility_new),
      _WudhuStep(
          step: 8,
          title: 'Membasuh Kaki',
          desc: 'Basuh hingga mata kaki 3x (kanan dulu)',
          icon: Icons.directions_walk),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, i) => _buildWudhuStepCard(steps[i]),
    );
  }

  Widget _buildWudhuStepCard(_WudhuStep s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              color: AppColors.emeraldGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(s.icon, color: AppColors.emeraldGreen, size: 22),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${s.step}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(s.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(s.desc,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  // ── Doa Tab ───────────────────────────────────────────────────────────────
  Widget _buildDoaTab() {
    final duas = [
      _DoaItem(title: 'Doa Setelah Wudhu', arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللّٰهُ'),
      _DoaItem(title: 'Doa Masuk Masjid', arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ'),
      _DoaItem(title: 'Doa Keluar Masjid', arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ'),
      _DoaItem(title: 'Doa Iftitah', arabic: 'اللهُ أَكْبَرُ كَبِيراً وَالْحَمْدُ لِلَّهِ كَثِيراً'),
      _DoaItem(title: 'Doa Qunut', arabic: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ'),
    ];

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
                  color: AppColors.gold.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book,
                    color: AppColors.gold, size: 22),
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
}

// ── Data Models ──────────────────────────────────────────────────────────────
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

class _WudhuStep {
  final int step;
  final String title, desc;
  final IconData icon;
  const _WudhuStep(
      {required this.step,
      required this.title,
      required this.desc,
      required this.icon});
}

class _DoaItem {
  final String title, arabic;
  const _DoaItem({required this.title, required this.arabic});
}
