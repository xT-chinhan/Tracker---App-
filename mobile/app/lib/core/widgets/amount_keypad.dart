import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigit,
    required this.onDelete,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const keys = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '000',
      '0',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 58,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 11) {
          return Semantics(
            button: true,
            label: 'Xóa một số',
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(12),
              child: const Center(child: Icon(LucideIcons.delete, size: 24)),
            ),
          );
        }
        final key = keys[index];
        return Semantics(
          button: true,
          label: key,
          child: InkWell(
            onTap: () => onDigit(key),
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                key,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
