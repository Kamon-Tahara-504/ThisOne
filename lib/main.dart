import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'services/supabase_service.dart';
import 'widgets/app_bars/collapsible_app_bar.dart';
import 'widgets/overlays/account_info_overlay.dart';
import 'widgets/navigation/bottom_navigation_bar.dart';
import 'widgets/schedule/schedule_dialog.dart';
import 'widgets/task/task_dialog.dart';
import 'models/schedule_template.dart';
import 'models/task_template.dart';
import 'screens/task/task_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/memo/memo_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'utils/error_handler.dart';
import 'controllers/scroll_controller_manager.dart';
import 'controllers/header_controller.dart';
import 'controllers/page_controller.dart';
import 'services/main_data_service.dart';
import 'screens/auth/unified_auth_screen.dart';
import 'screens/auth/password_reset_screen.dart';

// カスタムScrollPhysics for スワイプアニメーション速度調整
class CustomPageScrollPhysics extends ScrollPhysics {
  final double speedMultiplier;

  const CustomPageScrollPhysics({
    super.parent,
    this.speedMultiplier = 0.5, // 1.0が標準速度、大きいほど速い、小さいほど遅い
  });

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(
      parent: buildParent(ancestor),
      speedMultiplier: speedMultiplier,
    );
  }

  @override
  SpringDescription get spring => SpringDescription(
    mass: 80.0 / speedMultiplier, // 質量を調整（小さいほど軽快）
    stiffness: 100.0 * speedMultiplier, // 剛性を調整（大きいほど速い）
    damping: 1.2, // 減衰を調整（大きいほど振動が少ない）
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドリングを設定
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // 本番環境ではエラーログを記録
    if (kReleaseMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  // 非同期エラーのハンドリング
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  try {
    // Supabaseを初期化
    await SupabaseConfig.initialize();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // 初期化エラーが発生した場合、エラー画面を表示
    runApp(ErrorApp(error: e, stackTrace: stackTrace));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThisOne',
      // 日本語ロケール設定
      locale: const Locale('ja', 'JP'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'), // 日本語
        Locale('en', 'US'), // 英語（フォールバック）
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE85A3B), // 赤みの強いオレンジ（画像の色に近い）
          secondary: const Color(0xFFE85A3B), // サブカラーも同じ色
          surface: const Color(0xFF2B2B2B), // 全体のベース色
          onPrimary: Colors.white, // オレンジの上の文字色
          onSurface: Colors.white, // サーフェス上の文字色
        ),
        scaffoldBackgroundColor: const Color(0xFF2B2B2B), // Scaffoldの背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // 透明にしてグラデーションを表示
          foregroundColor: Colors.white, // AppBarの文字色
          elevation: 0, // 影を削除
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE85A3B), // FABを程よいオレンジに
          foregroundColor: Colors.white, // FABのアイコン色
        ),
        textSelectionTheme: TextSelectionThemeData(
          // Androidでは青系、iOSではnull（システム標準）を使用
          selectionHandleColor: Platform.isAndroid ? Colors.blueAccent : null,
          cursorColor: Platform.isAndroid ? Colors.blueAccent : null,
        ),
        // Androidシミュレーター対応：フォントファミリーを明示的に設定
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isPasswordRecoveryMode = false;

  @override
  Widget build(BuildContext context) {
    try {
      final supabaseService = SupabaseService();

      return StreamBuilder<AuthState>(
        stream: supabaseService.authStateChanges,
        builder: (context, snapshot) {
          // エラーが発生した場合
          if (snapshot.hasError) {
            debugPrint('AuthGate StreamBuilder error: ${snapshot.error}');
            // エラーが発生しても認証画面を表示（オフライン対応）
            return const UnifiedAuthScreen();
          }

          // パスワードリカバリーイベントをチェック
          if (snapshot.hasData) {
            final authState = snapshot.data!;
            if (authState.event == AuthChangeEvent.passwordRecovery) {
              // パスワードリカバリーモードに設定
              if (!_isPasswordRecoveryMode) {
                _isPasswordRecoveryMode = true;
                // 次のフレームでパスワードリセット画面に遷移
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PasswordResetScreen(
                          onPasswordResetComplete: () {
                            setState(() {
                              _isPasswordRecoveryMode = false;
                            });
                          },
                        ),
                      ),
                    );
                  }
                });
              }
            }
          }

          try {
            final user = supabaseService.getCurrentUser();

            if (user != null) {
              return const MainScreen();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE85A3B)),
                ),
              );
            }

            return const UnifiedAuthScreen();
          } catch (e) {
            debugPrint('AuthGate error: $e');
            // エラーが発生しても認証画面を表示
            return const UnifiedAuthScreen();
          }
        },
      );
    } catch (e) {
      debugPrint('AuthGate initialization error: $e');
      // 初期化エラーが発生した場合でも認証画面を表示
      return const UnifiedAuthScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 状態変数
  AccountInfoOverlay? _accountInfoOverlay;

  // コントローラー（メモリリーク対策）
  late AppPageController _appPageController;
  final GlobalKey _scheduleScreenKey = GlobalKey();
  late ScrollControllerManager _scrollControllerManager;
  late HeaderController _headerController;
  late MainDataService _dataService;
  bool _isDisposed = false; // 二重dispose防止

  @override
  void initState() {
    super.initState();

    try {
      // コントローラーを初期化
      _appPageController = AppPageController();
      _appPageController.initializePageController(initialPage: 0);

      _scrollControllerManager = ScrollControllerManager();
      _headerController = HeaderController();
      _dataService = MainDataService();

      // ヘッダーコントローラーの変更を監視
      _headerController.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      // ページコントローラーの変更を監視
      _appPageController.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      // データサービスの変更を監視
      _dataService.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      // ScrollControllersを初期化
      _scrollControllerManager.initializeScrollControllers(
        pageCount: 4, // タスク、スケジュール、メモ、設定
        onScroll: _onScroll,
      );

      // データを読み込み（エラーが発生しても続行）
      _loadData().catchError((error) {
        debugPrint('MainScreen初期化時のデータ読み込みエラー: $error');
        // エラーが発生してもアプリは続行可能
      });

      // テンプレートを読み込み
      _dataService.loadTemplates().catchError((error) {
        debugPrint('テンプレート読み込みエラー: $error');
      });

      // タスクテンプレートを読み込み
      _dataService.loadTaskTemplates().catchError((error) {
        debugPrint('タスクテンプレート読み込みエラー: $error');
      });

      // 認証状態の変更を監視
      try {
        _dataService.startAuthStateListener();
      } catch (e) {
        debugPrint('認証状態リスナーの開始エラー: $e');
        // エラーが発生してもアプリは続行可能
      }
    } catch (e, stackTrace) {
      debugPrint('MainScreen初期化エラー: $e');
      debugPrint('Stack trace: $stackTrace');
      // エラーが発生してもアプリは続行可能（空のデータで表示）
    }
  }

  // スクロール制御（メモリリーク対策）
  void _onScroll(int pageIndex) {
    if (_isDisposed || !mounted) return; // dispose後やマウント解除後の処理防止

    final controller = _scrollControllerManager.getScrollController(pageIndex);
    if (controller == null ||
        !controller.hasClients ||
        controller.hasClients == false) {
      return;
    }

    // 現在のページのみ監視
    final currentPageIndex = _appPageController.getCurrentPageIndex();
    if (pageIndex != currentPageIndex) return;

    final currentPosition = controller.offset;

    // ヘッダーコントローラーにスクロール位置を通知
    _headerController.updateScrollPosition(
      currentPosition: currentPosition,
      currentPageIndex: pageIndex,
      targetPageIndex: currentPageIndex,
    );
  }

  /// ページ変更時の処理（ヘッダーリセットを含む）
  void _handlePageChanged(int pageIndex) {
    // 既存のページ管理ロジックを実行
    _appPageController.onPageChanged(pageIndex);

    // ヘッダーをリセット（新しい画面に遷移した際に常に表示状態に戻す）
    _headerController.reset();
  }

  // AccountInfoOverlayの遅延初期化
  AccountInfoOverlay get accountInfoOverlay {
    _accountInfoOverlay ??= AccountInfoOverlay(
      context: context,
      onTasksNeedReload: () => _dataService.loadTasks(),
    );
    return _accountInfoOverlay!;
  }

  @override
  void dispose() {
    if (_isDisposed) return; // 二重dispose防止
    _isDisposed = true;

    try {
      _appPageController.dispose();
    } catch (e) {
      debugPrint('AppPageController dispose error: $e');
    }

    // コントローラーを安全に解放
    _scrollControllerManager.dispose();
    _headerController.dispose();
    _dataService.dispose();

    // AccountInfoOverlayを安全に解放
    try {
      _accountInfoOverlay?.dispose();
      _accountInfoOverlay = null;
    } catch (e) {
      debugPrint('AccountInfoOverlay dispose error: $e');
    }

    super.dispose();
  }

  // データを読み込み
  Future<void> _loadData() async {
    if (_isDisposed || !mounted) return;

    // タスクを読み込み
    try {
      await _dataService.loadTasks();
    } catch (e) {
      if (!_isDisposed && mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'タスクの読み込み',
          onRetry: _loadData,
        );
      }
    }

    // メモを読み込み
    try {
      await _dataService.loadMemos();
    } catch (e) {
      if (!_isDisposed && mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'メモの読み込み',
          onRetry: _loadData,
        );
      }
    }

    // スケジュールを読み込み
    try {
      await _dataService.loadSchedules();
    } catch (e) {
      if (!_isDisposed && mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'スケジュールの読み込み',
          onRetry: _loadData,
        );
      }
    }
  }

  // タスクを追加
  Future<void> _addTask(Map<String, dynamic> taskData) async {
    if (_isDisposed ||
        !mounted ||
        taskData['title'].toString().trim().isEmpty) {
      return;
    }

    try {
      await _dataService.addTaskWithDetails(taskData);
    } catch (e) {
      if (!_isDisposed && mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'タスクの保存',
          onRetry: () => _addTask(taskData),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PageViewで表示する画面のリストを作成
    final List<Widget> pages = [
      // 0: タスク画面
      _dataService.isLoading
          ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFE85A3B)),
          )
          : TaskScreen(
            tasks: _dataService.tasks,
            dataService: _dataService,
            scrollController: _scrollControllerManager.getScrollController(0),
            newlyCreatedTaskId: _dataService.newlyCreatedTaskId,
            onPopAnimationComplete: () {
              _dataService.clearNewlyCreatedTaskId();
            },
          ),
      // 1: カレンダー画面
      ScheduleScreen(
        key: _scheduleScreenKey,
        scrollController: _scrollControllerManager.getScrollController(1),
        dataService: _dataService,
        newlyCreatedScheduleId: _dataService.newlyCreatedScheduleId,
        onPopAnimationComplete: () {
          _dataService.clearNewlyCreatedScheduleId();
        },
      ),
      // 2: メモ画面
      _dataService.isLoadingMemos
          ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFE85A3B)),
          )
          : MemoScreen(
            memos: _dataService.memos,
            dataService: _dataService,
            onMemosChanged: (updatedMemos) {
              _dataService.updateMemos(updatedMemos);
            },
            newlyCreatedMemoId: _dataService.newlyCreatedMemoId,
            onPopAnimationComplete: () {
              _dataService.clearNewlyCreatedMemoId();
            },
            scrollController: _scrollControllerManager.getScrollController(2),
          ),
      // 3: 設定画面
      SettingsScreen(
        scrollController: _scrollControllerManager.getScrollController(3),
        dataService: _dataService,
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // メインコンテンツ（PageView）- 動的パディング調整
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: _headerController.calculateDynamicTopPadding(
                  context,
                ), // ヘッダーの隠れ具合に応じて調整
              ),
              child: PageView(
                controller: _appPageController.pageController,
                physics:
                    const PageScrollPhysics(), // 標準のPageScrollPhysicsでページスナップを確実にする
                onPageChanged: _handlePageChanged,
                children: pages,
              ),
            ),
          ),
          // スクロール連動ヘッダー
          Positioned(
            top: _headerController.calculateHeaderTop(context),
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                CollapsibleAppBar(
                  onAccountButtonPressed:
                      () => accountInfoOverlay.handleAccountButtonPressed(),
                  scrollProgress: _headerController.headerOffset,
                ),
                // ガイドライン
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE85A3B),
                        const Color(0xFFFFA726),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ヘッダー文字マスク
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).padding.top + 15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2B2B2B),
                      const Color(0xFF2B2B2B),
                      const Color(0xFF2B2B2B).withValues(alpha: 0.0),
                      const Color(0xFF2B2B2B).withValues(alpha: 0.0),
                    ],
                    stops: [0.0, 0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _appPageController,
        builder: (context, child) {
          return BottomNavigationBar(
            currentIndex: _appPageController.currentIndex,
            onTabChanged: (index) => _appPageController.navigateToTab(index),
            pageController: _appPageController.pageController,
            supabaseService: SupabaseService(),
            onTaskCreate: (taskData) => _addTask(taskData),
            onMemoCreated:
                (title, mode, colorHex) => _createMemo(title, mode, colorHex),
            onScheduleCreate: _handleScheduleCreate,
            onTemplateCreate: _handleTemplateCreate,
            dataService: _dataService,
            onTaskTemplateEdit: _handleTaskTemplateEdit,
            onTaskTemplateDelete: _handleTaskTemplateDelete,
          );
        },
      ),
    );
  }

  // スケジュール作成処理
  void _handleScheduleCreate() {
    // スケジュール画面がアクティブな場合、スケジュール作成ボトムシートを開く
    if (_appPageController.currentIndex ==
        AppPageController.schedulePageIndex) {
      final scheduleScreenState = _scheduleScreenKey.currentState as dynamic;
      scheduleScreenState?.addScheduleFromExternal(
        onTemplateEdit: _handleTemplateEdit,
        onTemplateDelete: _handleTemplateDelete,
        onTemplateCreate: _handleTemplateCreate,
      );
    }
  }

  // テンプレート作成処理
  void _handleTemplateCreate() {
    if (!mounted) return;

    // スケジュール画面がアクティブな場合、スケジュールテンプレート作成ダイアログを表示
    if (_appPageController.currentIndex ==
        AppPageController.schedulePageIndex) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        builder:
            (context) => ScheduleDialog(
              selectedDate: DateTime.now(),
              dataService: _dataService,
              onTemplateAdd: (template) {
                // テンプレート作成完了（コールバック内でダイアログが閉じられる）
              },
            ),
      );
    }
    // タスク画面がアクティブな場合、タスクテンプレート作成ダイアログを表示
    else if (_appPageController.currentIndex ==
        AppPageController.taskPageIndex) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        builder:
            (context) => TaskDialog(
              dataService: _dataService,
              onTemplateAdd: (template) {
                // テンプレート作成完了（コールバック内でダイアログが閉じられる）
                // TaskDialogの_saveTask内で既にaddTaskTemplateが呼ばれているため、ここでは何もしない
              },
            ),
      );
    }
  }

  // テンプレート編集処理
  void _handleTemplateEdit(ScheduleTemplate template) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => ScheduleDialog(
            selectedDate: DateTime.now(),
            dataService: _dataService,
            editingTemplate: template,
            onTemplateUpdate: (updatedTemplate) {
              // テンプレート更新完了（コールバック内でダイアログが閉じられる）
            },
          ),
    );
  }

  // テンプレート削除処理
  void _handleTemplateDelete(ScheduleTemplate template) async {
    if (!mounted) return;

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text(
              'テンプレートを削除',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '「${template.title}」を削除しますか？',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await _dataService.deleteTemplate(template.id);
      } catch (e) {
        if (mounted) {
          AppErrorHandler.handleError(context, e, operation: 'テンプレートの削除');
        }
      }
    }
  }

  // タスクテンプレート編集処理
  void _handleTaskTemplateEdit(TaskTemplate template) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => TaskDialog(
            dataService: _dataService,
            editingTemplate: template,
            onTemplateUpdate: (updatedTemplate) {
              // テンプレート更新完了（コールバック内でダイアログが閉じられる）
              // TaskDialogの_saveTask内で既にupdateTaskTemplateが呼ばれているため、ここでは何もしない
            },
          ),
    );
  }

  // タスクテンプレート削除処理
  void _handleTaskTemplateDelete(TaskTemplate template) async {
    if (!mounted) return;

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text(
              'テンプレートを削除',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '「${template.title}」を削除しますか？',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await _dataService.deleteTaskTemplate(template.id);
      } catch (e) {
        if (mounted) {
          AppErrorHandler.handleError(context, e, operation: 'テンプレート削除');
        }
      }
    }
  }

  // メモを作成
  Future<void> _createMemo(String title, String mode, String colorHex) async {
    if (!mounted) return;

    try {
      await _dataService.createMemo(title, mode, colorHex);
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'メモの作成',
          onRetry: () => _createMemo(title, mode, colorHex),
        );
      }
    }
  }
}

/// 初期化エラー時に表示するエラー画面
class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const ErrorApp({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThisOne',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE85A3B),
          surface: const Color(0xFF2B2B2B),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF2B2B2B),
        textSelectionTheme: TextSelectionThemeData(
          // Androidでは青系、iOSではnull（システム標準）を使用
          selectionHandleColor: Platform.isAndroid ? Colors.blueAccent : null,
          cursorColor: Platform.isAndroid ? Colors.blueAccent : null,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF2B2B2B),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFE85A3B),
                ),
                const SizedBox(height: 24),
                const Text(
                  'アプリの起動に失敗しました',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getErrorMessage(error),
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'エラー詳細（デバッグモード）:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// エラーメッセージを取得（環境変数エラーの場合、より詳細な情報を表示）
  static String _getErrorMessage(Object error) {
    final errorString = error.toString();
    
    // 環境変数が設定されていない場合のエラー
    if (errorString.contains('環境変数が設定されていません') ||
        errorString.contains('SUPABASE_URL') ||
        errorString.contains('SUPABASE_ANON_KEY')) {
      return 'アプリの設定が正しくありません。\n'
          '開発者にお問い合わせください。\n\n'
          'エラー: 環境変数が設定されていません';
    }
    
    // その他のエラー
    return 'アプリを再起動してください。\n'
        '問題が続く場合は、アプリを再インストールしてください。';
  }
}
