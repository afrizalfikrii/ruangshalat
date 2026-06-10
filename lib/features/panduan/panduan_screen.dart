import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  final List<Map<String, String>> _panduanList = const [
    {
      'title': 'Shalat Jamak',
      'desc': 'Syarat dan tata cara menggabungkan dua shalat dalam satu waktu.',
      'content': 'Shalat Jamak adalah mengumpulkan dua shalat wajib dalam satu waktu. Jamak Taqdim dilakukan di waktu shalat pertama (Dzuhur & Ashar, atau Maghrib & Isya). Jamak Takhir dilakukan di waktu shalat kedua. Syarat utamanya adalah safar (perjalanan) atau keadaan darurat tertentu.'
    },
    {
      'title': 'Shalat Qadha',
      'desc': 'Cara mengganti shalat yang terlewat atau tertinggal.',
      'content': 'Shalat Qadha dilakukan untuk mengganti kewajiban shalat yang terlewat. Hukumnya wajib. Tidak ada waktu khusus untuk melakukan Qadha, sebaiknya dilakukan sesegera mungkin saat teringat.'
    },
    {
      'title': 'Adab Beribadah',
      'desc': 'Etika dalam mempersiapkan diri sebelum menghadap Allah.',
      'content': 'Menjaga kesucian, menggunakan pakaian terbaik, dan menghadirkan hati (khusyuk) adalah inti dari adab shalat. Segerakan shalat di awal waktu jika tidak ada uzur syar\'i.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_ruangshalat.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text('Panduan Fikih', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _panduanList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _panduanList[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['desc']!, style: TextStyle(color: Colors.grey.shade600)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.emeraldGreen),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPanduanScreen(item: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPanduanScreen extends StatelessWidget {
  final Map<String, String> item;
  const DetailPanduanScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_ruangshalat.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            Text(item['title']!),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          item['content']!,
          style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
        ),
      ),
    );
  }
}