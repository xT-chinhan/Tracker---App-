import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/application/app_session.dart';
import '../features/auth/application/bootstrap_service.dart';
import 'router.dart';

class ThuChiApp extends ConsumerStatefulWidget {
  const ThuChiApp({super.key});

  @override
  ConsumerState<ThuChiApp> createState() => _ThuChiAppState();
}

class _ThuChiAppState extends ConsumerState<ThuChiApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final session = ref.read(appSessionProvider);
    if (session.status == AppSessionStatus.unknown) return;
    final service = ref.read(bootstrapServiceProvider);
    if (session.status == AppSessionStatus.maintenance ||
        session.status == AppSessionStatus.updateRequired) {
      service.start().ignore();
    } else {
      service.refreshConfig().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Thu Chi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
