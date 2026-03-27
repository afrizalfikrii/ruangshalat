import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/models/prayer_detail.dart';

class PrayerDetailScreen extends StatefulWidget {
  final PrayerDetail prayer;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const PrayerDetailScreen({
    super.key,
    required this.prayer,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      // ── AppBar: back button + prayer name langsung berdampingan ──────────
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prayer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  prayer.arabic,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              prayer.rakaat,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
        // ── Info waktu di bawah AppBar title ─────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Baris waktu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        prayer.timeInfo,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                tabs: const [
                  Tab(text: 'Niat'),
                  Tab(text: 'Rakaat'),
                  Tab(text: 'Bacaan'),
                  Tab(text: 'Doa & Waktu'),
                ],
              ),
            ],
          ),
        ),
      ),
      // ── Body: TabBarView ─────────────────────────────────────────────────
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNiatTab(prayer),
          _buildRakaatTab(prayer),
          _buildBacaanTab(prayer),
          _buildDoaWaktuTab(prayer),
        ],
      ),
    );
  }

  // ── Tab 1: Niat ─────────────────────────────────────────────────────────────
  Widget _buildNiatTab(PrayerDetail p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _sectionLabel('Lafaz Niat'),
          const SizedBox(height: 12),
          _arabicCard(
            title: 'Arab',
            content: p.niatArabic,
            isArabic: true,
            color: widget.color,
          ),
          const SizedBox(height: 10),
          _arabicCard(
            title: 'Latin',
            content: p.niatLatin,
            isArabic: false,
            color: widget.color,
          ),
          const SizedBox(height: 10),
          _arabicCard(
            title: 'Arti',
            content: p.niatTranslation,
            isArabic: false,
            color: AppColors.emeraldGreen,
            isTranslation: true,
          ),
          const SizedBox(height: 16),
          _infoBox(
            icon: Icons.info_outline,
            text:
                'Niat dilakukan di dalam hati. Mengucapkan niat dengan lisan hukumnya sunnah '
                'menurut sebagian ulama.',
            color: widget.color,
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Rakaat ────────────────────────────────────────────────────────────
  Widget _buildRakaatTab(PrayerDetail p) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: p.rakaatStructure.length,
      itemBuilder: (context, i) {
        final r = p.rakaatStructure[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header rakaat
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.color.withAlpha(20),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${r.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rakaat ke-${r.number}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: widget.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${r.steps.length} gerakan',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Steps
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: r.steps.asMap().entries.map((entry) {
                    final stepIdx = entry.key;
                    final step = entry.value;
                    final bool isLast = stepIdx == r.steps.length - 1;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline line + dot
                          SizedBox(
                            width: 28,
                            child: Column(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: widget.color.withAlpha(25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: widget.color.withAlpha(100),
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${stepIdx + 1}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: widget.color,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 1.5,
                                      color: widget.color.withAlpha(50),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : 10, top: 2),
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Bacaan ────────────────────────────────────────────────────────────
  Widget _buildBacaanTab(PrayerDetail p) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: p.bacaanWajib.length,
      itemBuilder: (context, i) {
        final b = p.bacaanWajib[i];
        return _BacaanCard(item: b, color: widget.color);
      },
    );
  }

  // ── Tab 4: Doa & Waktu ───────────────────────────────────────────────────────
  Widget _buildDoaWaktuTab(PrayerDetail p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Doa Setelah Shalat'),
          const SizedBox(height: 12),
          _arabicCard(
            title: 'Arab',
            content: p.doaArabic,
            isArabic: true,
            color: widget.color,
          ),
          const SizedBox(height: 10),
          _arabicCard(
            title: 'Latin',
            content: p.doaLatin,
            isArabic: false,
            color: widget.color,
          ),
          const SizedBox(height: 10),
          _arabicCard(
            title: 'Arti',
            content: p.doaTranslation,
            isArabic: false,
            color: AppColors.emeraldGreen,
            isTranslation: true,
          ),
          const SizedBox(height: 24),
          _sectionLabel('Info Waktu Shalat'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.schedule,
                          color: widget.color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.timeInfo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: widget.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  p.timeDetail,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Shared Helpers ───────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _arabicCard({
    required String title,
    required String content,
    required bool isArabic,
    required Color color,
    bool isTranslation = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTranslation ? color.withAlpha(12) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
        boxShadow: isTranslation
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title disalin!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: color,
                    ),
                  );
                },
                child: Icon(Icons.copy_outlined,
                    size: 16, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: isArabic ? 18 : 13,
              color:
                  isTranslation ? color.withAlpha(200) : Colors.black87,
              height: 1.7,
              fontStyle:
                  isTranslation ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: color.withAlpha(200),
                  fontSize: 12,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bacaan Card widget ────────────────────────────────────────────────────────
class _BacaanCard extends StatefulWidget {
  final BacaanItem item;
  final Color color;
  const _BacaanCard({required this.item, required this.color});

  @override
  State<_BacaanCard> createState() => _BacaanCardState();
}

class _BacaanCardState extends State<_BacaanCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.menu_book,
                        color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.arabic,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
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
          // Expanded content
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
                    widget.item.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Latin
                  Text(
                    widget.item.latin,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Translation
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.item.translation,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.color.withAlpha(200),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Copy button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final text =
                            '${widget.item.arabic}\n\n${widget.item.latin}\n\nArti: ${widget.item.translation}';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${widget.item.title} disalin!'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: widget.color,
                          ),
                        );
                      },
                      icon: Icon(Icons.copy_outlined,
                          size: 14, color: widget.color),
                      label: Text(
                        'Salin',
                        style:
                            TextStyle(fontSize: 12, color: widget.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
