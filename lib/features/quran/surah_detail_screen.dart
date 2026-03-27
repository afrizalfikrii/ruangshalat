import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/models/quran_models.dart';
import 'package:ruang_shalat/services/myquran_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahMeta surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<Ayat> _ayat = [];
  bool _loading = true;
  String? _error;
  bool _showTranslation = true;
  bool _showLatin = true;

  @override
  void initState() {
    super.initState();
    _loadAyat();
  }

  Future<void> _loadAyat() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await MyQuranService.getAyatBySurah(
          widget.surah.number, widget.surah.ayatCount);
      if (!mounted) return;
      setState(() {
        _ayat = result;
        _loading = false;
        if (result.isEmpty) _error = 'Gagal memuat ayat. Coba lagi.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Gagal memuat. Periksa koneksi.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    final isMakki = s.revelasi == 'Makkiyyah';
    final accentColor =
        isMakki ? AppColors.emeraldGreen : const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.nameId,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: Colors.white)),
                Text('${s.ayatCount} Ayat · ${s.revelasi}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(180),
                        height: 1.1)),
              ],
            ),
          ],
        ),
        actions: [
          // Toggle latin
          IconButton(
            tooltip: 'Latin',
            icon: Icon(
              Icons.translate,
              color: _showLatin ? Colors.white : Colors.white38,
              size: 22,
            ),
            onPressed: () => setState(() => _showLatin = !_showLatin),
          ),
          // Toggle terjemahan
          IconButton(
            tooltip: 'Terjemahan',
            icon: Icon(
              Icons.subtitles_outlined,
              color: _showTranslation ? Colors.white : Colors.white38,
              size: 22,
            ),
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Arab name badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.nameAr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '· ${s.nameEn}',
                  style: TextStyle(
                      color: Colors.white.withAlpha(180), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? _buildLoading(accentColor)
          : _error != null
              ? _buildError(accentColor)
              : _buildAyatList(accentColor),
    );
  }

  Widget _buildLoading(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Memuat ${widget.surah.ayatCount} ayat...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '(ini mungkin membutuhkan beberapa detik)',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAyat,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatList(Color accentColor) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _ayat.length,
      itemBuilder: (context, i) {
        final ayat = _ayat[i];
        return _AyatCard(
          ayat: ayat,
          accentColor: accentColor,
          showLatin: _showLatin,
          showTranslation: _showTranslation,
        );
      },
    );
  }
}

// ── Ayat Card ─────────────────────────────────────────────────────────────────
class _AyatCard extends StatelessWidget {
  final Ayat ayat;
  final Color accentColor;
  final bool showLatin;
  final bool showTranslation;

  const _AyatCard({
    required this.ayat,
    required this.accentColor,
    required this.showLatin,
    required this.showTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayat number + copy
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ayat.ayahNo}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final text =
                      '${ayat.arab}\n\n${ayat.latin}\n\n${ayat.terjemahan}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ayat ${ayat.ayahNo} disalin!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: accentColor,
                    ),
                  );
                },
                child: Icon(Icons.copy_outlined,
                    size: 16, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Arabic text
          Text(
            ayat.arab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black87,
              height: 2.0,
            ),
          ),

          // Latin
          if (showLatin && ayat.latin.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ayat.latin,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Terjemahan
          if (showTranslation && ayat.terjemahan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${ayat.terjemahan}"',
                style: TextStyle(
                  fontSize: 13,
                  color: accentColor.withAlpha(200),
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Juz & page info
          if (ayat.juz > 0 || ayat.page > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (ayat.juz > 0) _tag('Juz ${ayat.juz}', accentColor),
                if (ayat.juz > 0 && ayat.page > 0) const SizedBox(width: 6),
                if (ayat.page > 0) _tag('Hal. ${ayat.page}', accentColor),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color.withAlpha(200),
            fontSize: 10,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
