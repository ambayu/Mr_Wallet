import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/app_background_scaffold.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_header_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Belum Dibaca'

  final List<Map<String, dynamic>> _todayNotifications = [
    {
      'title': 'Pengeluaran tinggi',
      'desc': 'Pengeluaran makan di luar naik 15% dibanding bulan lalu.',
      'time': '10:30',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.bubblePink,
      'read': false,
    },
    {
      'title': 'Tujuan tercapai',
      'desc': 'Selamat! Kamu telah mencapai 50% dari tujuan "Liburan ke Jepang".',
      'time': '09:00',
      'icon': Icons.star_rounded,
      'color': AppColors.primaryYellow,
      'read': false,
    },
    {
      'title': 'Tabungan bertambah',
      'desc': 'Tabungan "Dana Darurat" bertambah Rp 500.000.',
      'time': '07:20',
      'icon': Icons.savings_rounded,
      'color': AppColors.skyBlue,
      'read': true,
    },
  ];

  final List<Map<String, dynamic>> _yesterdayNotifications = [
    {
      'title': 'Tagihan akan jatuh tempo',
      'desc': 'Tagihan listrik akan jatuh tempo dalam 2 hari.',
      'time': '18:30',
      'icon': Icons.notifications_active_rounded,
      'color': AppColors.coralOrange,
      'read': true,
    },
    {
      'title': 'Transaksi berhasil',
      'desc': 'Transfer dari Budi sebesar Rp 150.000 berhasil masuk.',
      'time': '14:20',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.mintGreen,
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredToday = _selectedFilter == 'Semua'
        ? _todayNotifications
        : _todayNotifications.where((n) => n['read'] == false).toList();

    final filteredYesterday = _selectedFilter == 'Semua'
        ? _yesterdayNotifications
        : _yesterdayNotifications.where((n) => n['read'] == false).toList();

    return AppBackgroundScaffold(
      appBar: NeoHeaderCard(
        title: 'Notifikasi',
        subtitle: 'Pemberitahuan aktivitas & saldo',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter pills matching showcase Screen 11
              Row(
                children: [
                  _buildFilterPill('Semua'),
                  const SizedBox(width: 10),
                  _buildFilterPill('Belum Dibaca'),
                ],
              ),
              const SizedBox(height: 20),

              if (filteredToday.isNotEmpty) ...[
                const Text(
                  'Hari ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 10),
                ...filteredToday.map((n) => _buildNotificationCard(n)),
                const SizedBox(height: 16),
              ],

              if (filteredYesterday.isNotEmpty) ...[
                const Text(
                  'Kemarin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 10),
                ...filteredYesterday.map((n) => _buildNotificationCard(n)),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 10),
              // Mascot footer matching showcase
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderBlack, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBlack,
                      offset: Offset(2.5, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.mascotChecklist,
                      width: 62,
                      height: 62,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tetap update, keuangan tetap aman! 🦀✨',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bubblePink : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderBlack, width: 1.8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowBlack,
                    offset: Offset(1.5, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return NeoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.cardWhite,
      borderRadius: 18,
      borderWidth: 1.8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item['color'] as Color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlack, width: 1.8),
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 20,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Text(
                      item['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['desc'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    height: 1.25,
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
