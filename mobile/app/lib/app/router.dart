import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/foundation/presentation/foundation_screen.dart';
import '../features/transactions/presentation/transaction_entry_screen.dart';
import 'shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (context, state) => const FoundationScreen(
                title: 'Trang chủ',
                description: 'Tổng quan tài chính sẽ hiển thị tại đây.',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/history',
              builder: (context, state) => const FoundationScreen(
                title: 'Lịch sử',
                description: 'Giao dịch của bạn sẽ hiển thị tại đây.',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/reports',
              builder: (context, state) => const FoundationScreen(
                title: 'Báo cáo',
                description: 'Báo cáo thu chi sẽ hiển thị tại đây.',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              builder: (context, state) => const FoundationScreen(
                title: 'Cài đặt',
                description: 'Các thiết lập tài khoản sẽ hiển thị tại đây.',
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/transactions/new',
      builder: (context, state) => TransactionEntryScreen(
        initialType: state.uri.queryParameters['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
      ),
    ),
  ],
);
