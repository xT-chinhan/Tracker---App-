import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../data/ai_models.dart';

class RerouteMenuCard extends StatelessWidget {
  const RerouteMenuCard({
    required this.skills,
    required this.onSelectSkill,
    required this.onDismiss,
    super.key,
  });

  final List<AiSkillItem> skills;
  final ValueChanged<String> onSelectSkill;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cảm ơn. Ý bạn là...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(999),
                child: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: Color(0xFF787774),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Lựa chọn của bạn giúp trợ lý hiểu đúng hơn lần sau.',
            style: TextStyle(fontSize: 13, color: Color(0xFF787774)),
          ),
          const SizedBox(height: 14),

          // Skills list
          if (skills.isNotEmpty) ...[
            for (final s in skills) ...[
              _buildSkillOption(
                icon: _iconForSkill(s.name),
                label: s.label ?? s.name,
                onTap: () => onSelectSkill(s.name),
              ),
              const Divider(height: 1, indent: 40, color: Color(0xFFF0EFEC)),
            ],
          ] else ...[
            _buildSkillOption(
              icon: LucideIcons.pencil,
              label: 'Ghi một khoản tiền mới',
              onTap: () => onSelectSkill('ghi-nhanh'),
            ),
            const Divider(height: 1, indent: 40, color: Color(0xFFF0EFEC)),
            _buildSkillOption(
              icon: LucideIcons.target,
              label: 'Xem ngân sách',
              onTap: () => onSelectSkill('ngan-sach'),
            ),
            const Divider(height: 1, indent: 40, color: Color(0xFFF0EFEC)),
            _buildSkillOption(
              icon: LucideIcons.clock,
              label: 'Tìm giao dịch trước đó',
              onTap: () => onSelectSkill('tim-kiem'),
            ),
            const Divider(height: 1, indent: 40, color: Color(0xFFF0EFEC)),
          ],
          _buildSkillOption(
            icon: LucideIcons.keyboard,
            label: 'Ý khác, để tôi gõ lại',
            onTap: onDismiss,
          ),
        ],
      ),
    );
  }

  IconData _iconForSkill(String name) {
    if (name.contains('nhap') || name.contains('ghi')) {
      return LucideIcons.pencil;
    }
    if (name.contains('ngan-sach')) {
      return LucideIcons.target;
    }
    if (name.contains('tim') || name.contains('lich-su')) {
      return LucideIcons.clock;
    }
    return LucideIcons.sparkles;
  }

  Widget _buildSkillOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F0EC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 14, color: const Color(0xFF787774)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevron_right,
              size: 16,
              color: Color(0xFFA9A8A3),
            ),
          ],
        ),
      ),
    );
  }
}
