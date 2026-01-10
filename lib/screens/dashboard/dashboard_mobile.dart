import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:sizer/sizer.dart';

class MobileDashboardScreen extends StatelessWidget {
  const MobileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing
                    .containerInsideMargin), // 20.0 -> 24.0 (AppSpacing.containerInsideMargin) or just 20 manually
            // Figma likely has specific padding. I used 20 before. AppSpacing.containerInsideMargin is 24. I will use 20 to match design if 24 is too big, but DS says 24. I'll stick to design-like values or DS. Let's use 20 as per my visual check or 24 if standard.
            // visual inspection of screenshot looks like ~20px.
            // I'll stick to symmetric 20 for now or use standard.
            // Let's use 20.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 24),
                _buildCollaboratorList(context),
                const SizedBox(height: 40),
                _buildFooter(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tableau de bord',
          style: GoogleFonts.anton(
            fontSize: 40,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
            height: 1.4,
            color: Colors.black,
          ),
        ),
        Icon(
          Icons.info_outline_rounded,
          size: 24,
          color: Colors.black.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabItem('Collaborateur', isActive: true),
        _buildTabItem('Entreprise'),
        _buildTabItem('Objectifs'),
      ],
    );
  }

  Widget _buildTabItem(String label, {bool isActive = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF5F27CD) : const Color(0xFF636363),
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 80,
            color: const Color(0xFF5F27CD),
          ),
        ]
      ],
    );
  }

  Widget _buildCollaboratorList(BuildContext context) {
    // Mock data based on Figma screenshot
    final collaborators = [
      {
        'name': 'User 1',
        'points': '1 500',
        'gems': '10',
        'progress': '70%',
        'img': AppImages.homeBox1Path
      },
      {
        'name': 'User 2',
        'points': '3 750',
        'gems': '20',
        'progress': '75%',
        'img': AppImages.homeBox2Path
      },
      {
        'name': 'User 3',
        'points': '9 230',
        'gems': '20',
        'progress': '75%',
        'img': AppImages.homeBox3Path
      },
      {
        'name': 'User 4',
        'points': '9 230',
        'gems': '40',
        'progress': '81%',
        'img': AppImages.homeBox4Path
      },
      {
        'name': 'User 5',
        'points': '9 230',
        'gems': '40',
        'progress': '81%',
        'img': AppImages.homeBox5Path
      },
      {
        'name': 'User 6',
        'points': '9 230',
        'gems': '40',
        'progress': '81%',
        'img': AppImages.homeBox6Path
      },
      {
        'name': 'User 7',
        'points': '9 230',
        'gems': '40',
        'progress': '81%',
        'img': AppImages.homeBox7Path
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(
            0xFFEEECE2), // Matching the exact beige from design inspection, AppColors.backgroundCard is slightly different
        borderRadius: AppRadius.large,
      ),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: collaborators.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 32, thickness: 1, color: Color(0xFFD3D1C8)),
        itemBuilder: (context, index) {
          final user = collaborators[index];
          return Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(user['img']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Points + Diamond
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(
                      user['points']!,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF636363)),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(AppIcons.diamondIconPath,
                        width: 14, height: 14),
                  ],
                ),
              ),
              // Gems amount
              Expanded(
                flex: 1,
                child: Text(
                  user['gems']!,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF636363)),
                  textAlign: TextAlign.center,
                ),
              ),
              // Progress
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.pie_chart_outline_rounded,
                        size: 16, color: Color(0xFF636363)),
                    const SizedBox(width: 4),
                    Text(
                      user['progress']!,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF636363)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEEECE2),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppIcons.frLanguageIconPath, width: 16),
                const SizedBox(width: 8),
                Text('Français',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _footerLink('Mentions légales'),
          _footerLink('Confidentialité'),
          _footerLink('Paramètres des cookies'),
          _footerLink('Accessibilité'),
          const SizedBox(height: 24),
          Text(
            '2025 Murya SAS',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style:
            GoogleFonts.inter(fontSize: 12, color: Colors.black, height: 1.5),
      ),
    );
  }
}
