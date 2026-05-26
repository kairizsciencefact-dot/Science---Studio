import 'package:flutter/material.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isDevModeAuthenticated = false;

  // --- HIDDEN ACTIVATION FLOW (STEALTH MODE - Desain Layar 4) ---
  int _stealthStep = 0;
  Timer? _stealthTimer;
  final String _devPin = "0715";

  void _startDevSequence() {
    setState(() {
      _stealthStep = 1; // Langkah 4.1: Long Press terdeteksi
      _stealthTimer?.cancel();
      // Titik indikator siluman hanya aktif selama 4 detik
      _stealthTimer = Timer(const Duration(seconds: 4), () {
        setState(() => _stealthStep = 0);
      });
    });
  }

  void _completeDevSequence() {
    if (_stealthStep == 1) { // Langkah 4.2 & 4.3: Double tap ikon Studio saat titik cyan aktif
      _stealthTimer?.cancel();
      setState(() => _stealthStep = 2);
      _showPinDialog();
    }
  }

  void _showPinDialog() {
    String enteredPin = "";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111116),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5)
        ),
        title: const Column(
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.deepPurpleAccent, size: 44),
            SizedBox(height: 12),
            Text('Otorisasi Sistem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Masukkan PIN Dev untuk melanjutkan', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 28, letterSpacing: 14),
              onChanged: (value) => enteredPin = value,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: const Color(0xFF181822),
                hintText: '••••',
                hintStyle: const TextStyle(color: Colors.white12, letterSpacing: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _stealthStep = 0);
              Navigator.pop(context);
            },
            child: const Text('BATAL', style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (enteredPin == _devPin) {
                setState(() {
                  _isDevModeAuthenticated = true;
                  _stealthStep = 0;
                });
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperDevPanel()));
              } else {
                setState(() => _stealthStep = 0);
                Navigator.pop(context);
              }
            },
            child: const Text('VERIFIKASI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: false,
        title: GestureDetector(
          onLongPress: _startDevSequence, // Trigger Langkah 4.1 (Long Press 3 Detik)
          child: const Text('Science Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5)),
        ),
        actions: [
          if (_isDevModeAuthenticated)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amberAccent, size: 26),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperDevPanel())),
            ),
          IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildEksplorasiTab(),
          _buildKerjaTab(),
          _buildStudioTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF0D0D12),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white30,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 22), activeIcon: Icon(Icons.explore, size: 22), label: 'Eksplorasi'),
          const BottomNavigationBarItem(icon: Icon(Icons.hub_outlined, size: 22), activeIcon: Icon(Icons.hub, size: 22), label: 'Kerja'),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onDoubleTap: _completeDevSequence, // Trigger Langkah 4.3 (Double Tap)
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.bar_chart_outlined, size: 22),
                  if (_stealthStep == 1) // Langkah 4.2: Titik Indikator Cyan muncul di ikon Studio
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle)),
                    ),
                ],
              ),
            ),
            label: 'Studio',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: EKSPLORASI (Media Feed Pipeline) ---
  Widget _buildEksplorasiTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Untukmu', true),
              _buildFilterChip('Trending', false),
              _buildFilterChip('Sains', false),
              _buildFilterChip('Tech', false),
              _buildFilterChip('Gaming', false),
              _buildFilterChip('AI', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('TRENDING NO #1'),
        _buildBigMediaCard('Perjalanan ke Lubang Hitam Supermasif', 'Science Studio • 12 jt ditonton • 7:42'),
        const SizedBox(height: 16),
        _buildSectionHeader('REKOMENDASI UNTUKMU'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildGridMediaCard('Quantum Chip Breakthrough 2026', 'Tech Insider • 850 rb ditonton • 5:21'),
            _buildGridMediaCard('BioHack: Meretas Umur Sel Manusia', 'BioLab • 300 rb ditonton • 11:04'),
          ],
        )
      ],
    );
  }

  // --- TAB 2: KERJA (Unified Workspace & Communication) ---
  Widget _buildKerjaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Unified Contact Sync'),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.deepPurple, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100')),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ardiansyah Dev', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Master Builder', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              _buildAppStatusIndicator('WhatsApp', 'Aktif', Colors.greenAccent),
              const SizedBox(width: 12),
              _buildAppStatusIndicator('Discord', 'Online', Colors.indigoAccent),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Ruang Kolaborasi'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _buildWorkspaceTile('Komunitas Dev', '12 Online', Icons.group_outlined, Colors.purpleAccent),
            _buildWorkspaceTile('Project Hub', '8 Proyek Aktif', Icons.folder_open_outlined, Colors.blueAccent),
            _buildWorkspaceTile('Pesan Tersimpan', '42 Item', Icons.bookmark_border_rounded, Colors.tealAccent),
            _buildWorkspaceTile('Notifikasi', '9 Baru', Icons.notifications_none_rounded, Colors.orangeAccent),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Media Auto-Archiving'),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('☁️ AI Cloud Backup Aktif', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('Penyimpanan Cloud: 76% Terpakai', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildArchivingProgress('Faces', '98%', Colors.cyanAccent),
                  _buildArchivingProgress('Documents', '97%', Colors.deepPurpleAccent),
                  _buildArchivingProgress('Assets', '95%', Colors.amberAccent),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  // --- TAB 3: STUDIO (Live Analytics & Fintech) ---
  Widget _buildStudioTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('📊 Live Analytics'),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: const Row(children: [Icon(Icons.circle, size: 8, color: Colors.redAccent), SizedBox(width: 4), Text('Live', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold))]))
          ],
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Views (All Platforms)', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('12.487.981', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text('▲ +24.578 (0.19%)', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 60, width: double.infinity, color: Colors.white10, child: const Center(child: Text('[ Grafik Garis Neon ]', style: TextStyle(color: Colors.white24, fontSize: 12)))),
              const Divider(height: 30, color: Colors.white10),
              const Text('Estimated Earnings', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rp 25.890.750', style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('▲ +Rp 1.250.000 (5.07%)', style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Integrated System'),
        Row(
          children: [
            Expanded(child: _buildSystemCard('Crypto & Fiat Wallet', 'Terenkripsi • Rp 1.500.000', Icons.account_balance_wallet_outlined, Colors.cyanAccent, 'Buka Wallet')),
            const SizedBox(width: 12),
            Expanded(child: _buildSystemCard('AI Script Copilot v2', 'Bantu buat skrip konten viral berbasis AI.', Icons.psychology_outlined, Colors.deepPurpleAccent, 'Buka Copilot')),
          ],
        )
      ],
    );
  }

  // --- WIDGET KOMPONEN PEMBANTU ---
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)));
  
  Widget _buildFilterChip(String label, bool isSelected) => Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: isSelected ? Colors.deepPurpleAccent : const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? Colors.transparent : Colors.white10)), child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)));

  Widget _buildBigMediaCard(String title, String sub) => Container(height: 180, width: double.infinity, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1F1235), Color(0xFF0F0F14)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)), child: const Stack(children: [Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, size: 54, color: Colors.deepPurpleAccent))), Positioned(bottom: 16, left: 16, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TRENDING NO #1', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Perjalanan ke Lubang Hitam Supermasif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), SizedBox(height: 2), Text('Science Studio • 12 jt ditonton • 7:42', style: TextStyle(color: Colors.white38, fontSize: 11))]))]));

  Widget _buildGridMediaCard(String title, String sub) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 30)))), const SizedBox(height: 10), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 4), Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11))]));

  Widget _buildAppStatusIndicator(String app, String status, Color color) => Column(children: [Text(app, style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)))]);

  Widget _buildWorkspaceTile(String title, String sub, IconData icon, Color color) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Row(children: [Icon(icon, color: color, size: 22), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 2), Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11))])]));

  Widget _buildArchivingProgress(String label, String pct, Color color) => Column(children: [Stack(alignment: Alignment.center, children: [SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: 0.9, strokeWidth: 4, valueColor: AlwaysStoppedAnimation<Color>(color), backgroundColor: Colors.white12)), Text(pct, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11))]);

  Widget _buildSystemCard(String t, String s, IconData i, Color c, String btnText) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0F0F14), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 26), const SizedBox(height: 12), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(s, style: const TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(height: 16), SizedBox(width: double.infinity, height: 32, child: ElevatedButton(style: ElevatedButton.styleFrom(b
