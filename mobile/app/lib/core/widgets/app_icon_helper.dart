import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

abstract final class AppIconHelper {
  static IconData fromName(String? name) {
    if (name == null || name.isEmpty) return LucideIcons.receipt;
    final normalized = name.toLowerCase().trim().replaceAll('_', '-');
    return switch (normalized) {
      'utensils' || 'restaurant' || 'food' || 'an-uong' => LucideIcons.utensils,
      'coffee' || 'cafe' || 'ca-phe' => LucideIcons.coffee,
      'shopping-cart' || 'shopping' || 'mua-sam' => LucideIcons.shopping_cart,
      'car' ||
      'car-taxi-front' ||
      'taxi' ||
      'di-chuyen' ||
      'transport' => LucideIcons.car,
      'square-parking' || 'parking' || 'gui-xe' => LucideIcons.square_parking,
      'wallet' || 'vi' => LucideIcons.wallet,
      'heart' || 'suc-khoe' || 'health' => LucideIcons.heart,
      'film' || 'giai-tri' || 'movie' => LucideIcons.film,
      'graduation-cap' ||
      'giao-duc' ||
      'education' => LucideIcons.graduation_cap,
      'plane' || 'du-lich' || 'travel' => LucideIcons.plane,
      'gift' || 'qua-tang' => LucideIcons.gift,
      'flame' || 'hoa-don' || 'bill' => LucideIcons.flame,
      'house' || 'home' || 'nha-cua' => LucideIcons.house,
      'briefcase' || 'salary' || 'luong' => LucideIcons.briefcase,
      'circle-alert' || 'alert' || 'error' => LucideIcons.circle_alert,
      'triangle-alert' || 'warn' || 'warning' => LucideIcons.triangle_alert,
      'megaphone' || 'broadcast' => LucideIcons.megaphone,
      'repeat' || 'recurring' => LucideIcons.repeat,
      'circle-pause' || 'pause' => LucideIcons.circle_pause,
      'target' || 'budget' => LucideIcons.target,
      'piggy-bank' || 'saving' => LucideIcons.piggy_bank,
      _ => LucideIcons.receipt,
    };
  }

  static Color parseColor(
    String? hexString, {
    Color fallback = const Color(0xFF6B6964),
  }) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
