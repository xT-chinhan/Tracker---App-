import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai/presentation/ai_chat_screen.dart';
import '../features/ai/presentation/ai_conversations_screen.dart';
import '../features/ai/presentation/ai_settings_screen.dart';
import '../features/ai/presentation/archived_conversations_screen.dart';
import '../features/auth/application/app_session.dart';
import '../features/auth/presentation/bootstrap_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/maintenance_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/update_required_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/recurring/presentation/recurring_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/savings/presentation/saving_detail_screen.dart';
import '../features/savings/presentation/savings_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transfers/presentation/transfer_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transaction_entry_screen.dart';
import '../features/wallets/presentation/wallets_screen.dart';
import 'shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.read(appSessionProvider);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/bootstrap',
    refreshListenable: session,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = <String>{
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
      }.contains(location);

      return switch (session.status) {
        AppSessionStatus.unknown =>
          location == '/bootstrap' ? null : '/bootstrap',
        AppSessionStatus.maintenance =>
          location == '/maintenance' ? null : '/maintenance',
        AppSessionStatus.updateRequired =>
          location == '/update-required' ? null : '/update-required',
        AppSessionStatus.unauthenticated => isAuthRoute ? null : '/login',
        AppSessionStatus.authenticated =>
          isAuthRoute ||
                  location == '/bootstrap' ||
                  location == '/maintenance' ||
                  location == '/update-required'
              ? '/home'
              : null,
      };
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/update-required',
        builder: (context, state) => const UpdateRequiredScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
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
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transactions/:id',
        builder: (context, state) =>
            TransactionDetailScreen(transactionId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wallets',
        builder: (context, state) => const WalletsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transfers/new',
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transfer',
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transaction-entry',
        builder: (context, state) => TransactionEntryScreen(
          initialType: state.uri.queryParameters['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/savings',
        builder: (context, state) => const SavingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/savings/:id',
        builder: (context, state) =>
            SavingDetailScreen(goalId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai',
        builder: (context, state) => const AiConversationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai/new',
        builder: (context, state) =>
            AiChatScreen(initialPrompt: state.extra as String?),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai/conversations/:id',
        builder: (context, state) =>
            AiChatScreen(conversationId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai/settings',
        builder: (context, state) => const AiSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai/archived',
        builder: (context, state) => const ArchivedConversationsScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
