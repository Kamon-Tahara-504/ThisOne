import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/schedule/schedule_dialog.dart';
import '../../widgets/schedule/schedule_card.dart';
import '../../services/main_data_service.dart';
import '../../utils/error_handler.dart';
import '../../models/schedule.dart';
import 'schedule_calendar_header.dart';
import 'schedule_calendar.dart';
import 'empty_schedule_state.dart';
import 'schedule_list_title.dart';
import '../../widgets/common/count_badge.dart';

class ScheduleScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final MainDataService dataService;
  final String? newlyCreatedScheduleId;
  final VoidCallback? onPopAnimationComplete;

  const ScheduleScreen({
    super.key,
    this.scrollController,
    required this.dataService,
    this.newlyCreatedScheduleId,
    this.onPopAnimationComplete,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isFormatChanging = false;
  late AnimationController _popAnimationController;
  late Animation<double> _popAnimation;
  String? _animatingScheduleId;

  @override
  void initState() {
    super.initState();

    // ポップアニメーションコントローラー
    _popAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _popAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // アニメーション完了時のリスナー
    _popAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingScheduleId = null;
        });
        widget.onPopAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _popAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 新しいスケジュールが作成された場合にアニメーションを開始
    if (widget.newlyCreatedScheduleId != null &&
        widget.newlyCreatedScheduleId != oldWidget.newlyCreatedScheduleId) {
      _startPopAnimation(widget.newlyCreatedScheduleId!);
    }
  }

  void _startPopAnimation(String scheduleId) {
    setState(() {
      _animatingScheduleId = scheduleId;
    });
    _popAnimationController.forward(from: 0.0);
  }

  /// スケジュールを削除（データベースからも削除）
  Future<void> _deleteSchedule(Schedule schedule) async {
    try {
      // ローカルデータベースから削除
      await widget.dataService.deleteSchedule(schedule.id);

      // リストを再読み込み（メモ削除処理と一貫性を保つ）
      await widget.dataService.loadSchedules();
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'スケジュールの削除',
          onRetry: () => _deleteSchedule(schedule),
        );
      }
    }
  }

  List<Schedule> _getSchedulesForDate(
    DateTime date,
    List<Schedule> allSchedules,
  ) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return allSchedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.scheduleDate.year,
        schedule.scheduleDate.month,
        schedule.scheduleDate.day,
      );
      return scheduleDate == normalizedDate;
    }).toList();
  }

  /// 指定された月の範囲内のスケジュールを取得
  List<Schedule> _getSchedulesForMonth(
    DateTime focusedDate,
    List<Schedule> allSchedules,
  ) {
    final monthStart = DateTime(focusedDate.year, focusedDate.month, 1);
    final monthEnd = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final normalizedMonthStart = DateTime(
      monthStart.year,
      monthStart.month,
      monthStart.day,
    );
    final normalizedMonthEnd = DateTime(
      monthEnd.year,
      monthEnd.month,
      monthEnd.day,
    );

    return allSchedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.scheduleDate.year,
        schedule.scheduleDate.month,
        schedule.scheduleDate.day,
      );
      return (scheduleDate.isAfter(normalizedMonthStart) ||
              scheduleDate.isAtSameMomentAs(normalizedMonthStart)) &&
          (scheduleDate.isBefore(normalizedMonthEnd) ||
              scheduleDate.isAtSameMomentAs(normalizedMonthEnd));
    }).toList();
  }

  /// 指定された週の範囲内のスケジュールを取得（月曜日始まり）
  List<Schedule> _getSchedulesForWeek(
    DateTime focusedDate,
    List<Schedule> allSchedules,
  ) {
    final weekday = focusedDate.weekday; // 1=月曜日, 7=日曜日
    final weekStart = focusedDate.subtract(Duration(days: weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final normalizedWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final normalizedWeekEnd = DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
    );

    return allSchedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.scheduleDate.year,
        schedule.scheduleDate.month,
        schedule.scheduleDate.day,
      );
      return (scheduleDate.isAfter(normalizedWeekStart) ||
              scheduleDate.isAtSameMomentAs(normalizedWeekStart)) &&
          (scheduleDate.isBefore(normalizedWeekEnd) ||
              scheduleDate.isAtSameMomentAs(normalizedWeekEnd));
    }).toList();
  }

  /// カレンダー表示形式を切り替える
  void _toggleCalendarFormat() {
    setState(() {
      _isFormatChanging = true;
      if (_calendarFormat == CalendarFormat.month) {
        _calendarFormat = CalendarFormat.week;
      } else {
        _calendarFormat = CalendarFormat.month;
      }
    });
    // フォーマット変更が完了したら、フラグをリセット
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _isFormatChanging = false;
        });
      }
    });
  }

  /// スケジュールを追加（データベースにも保存）
  Future<void> _addSchedule(Map<String, dynamic> schedule) async {
    try {
      // ローカルデータベースに保存
      await widget.dataService.addSchedule(
        title: schedule['title'],
        description: schedule['description'],
        scheduleDate: schedule['date'],
        startTime: schedule['startTime'],
        endTime: schedule['endTime'],
        isAllDay: schedule['isAllDay'] ?? false,
        location: schedule['location'],
        reminderMinutes: schedule['reminderMinutes'],
        colorHex: schedule['colorHex'] ?? '#E85A3B',
      );
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'スケジュールの保存',
          onRetry: () => _addSchedule(schedule),
        );
      }
    }
  }

  /// スケジュールを編集
  void _editSchedule(Schedule schedule) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => ScheduleDialog(
            selectedDate: schedule.scheduleDate,
            schedule: schedule,
            onUpdate: (scheduleData) {
              Navigator.pop(context);
              _updateSchedule(schedule, scheduleData);
            },
          ),
    );
  }

  /// スケジュールを更新（データベースにも保存）
  Future<void> _updateSchedule(
    Schedule originalSchedule,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final updatedSchedule = originalSchedule.copyWith(
        title: scheduleData['title'],
        description: scheduleData['description'],
        scheduleDate: scheduleData['date'],
        startTime: scheduleData['startTime'],
        endTime: scheduleData['endTime'],
        isAllDay: scheduleData['isAllDay'] ?? false,
        location: scheduleData['location'],
        reminderMinutes: scheduleData['reminderMinutes'],
        colorHex: scheduleData['colorHex'] ?? '#E85A3B',
        updatedAt: DateTime.now(),
      );
      await widget.dataService.updateSchedule(updatedSchedule);
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'スケジュールの更新',
          onRetry: () => _updateSchedule(originalSchedule, scheduleData),
        );
      }
    }
  }

  // 外部（MainScreenなど）から呼び出すためのpublicメソッド
  void addScheduleFromExternal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => ScheduleDialog(
            selectedDate: _selectedDate,
            onAdd: (schedule) {
              Navigator.pop(context); // ダイアログを閉じる
              _addSchedule(schedule);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.dataService,
      builder: (context, child) {
        final allSchedules = widget.dataService.schedules;
        final todaySchedules = _getSchedulesForDate(
          _selectedDate,
          allSchedules,
        );
        final isLoading = widget.dataService.isLoadingSchedules;

        return Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE85A3B)),
                )
              else
                CustomScrollView(
                  controller: widget.scrollController,
                  slivers: [
                    // カレンダー部分
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Column(
                          children: [
                            ScheduleCalendarHeader(
                              focusedDate: _focusedDate,
                              calendarFormat: _calendarFormat,
                              onPreviousMonth: (date) {
                                setState(() {
                                  _focusedDate = date;
                                });
                              },
                              onNextMonth: (date) {
                                setState(() {
                                  _focusedDate = date;
                                });
                              },
                              onToggleFormat: _toggleCalendarFormat,
                            ),
                            ScheduleCalendar(
                              focusedDate: _focusedDate,
                              selectedDate: _selectedDate,
                              calendarFormat: _calendarFormat,
                              getSchedulesForDate:
                                  (date) =>
                                      _getSchedulesForDate(date, allSchedules),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDate = selectedDay;
                                  _focusedDate = focusedDay;
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _isFormatChanging = true;
                                  // twoWeeksが渡された場合はweekに変換
                                  if (format == CalendarFormat.twoWeeks) {
                                    _calendarFormat = CalendarFormat.week;
                                  } else {
                                    _calendarFormat = format;
                                  }
                                  // focusedDateは変更しない（表示形式変更時も現在の日付を維持）
                                });
                                // フォーマット変更が完了したら、フラグをリセット
                                Future.microtask(() {
                                  if (mounted) {
                                    setState(() {
                                      _isFormatChanging = false;
                                    });
                                  }
                                });
                              },
                              onPageChanged: (focusedDay) {
                                // フォーマット変更中は、focusedDateを変更しない
                                if (!_isFormatChanging) {
                                  setState(() {
                                    _focusedDate = focusedDay;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // スケジュールリストのタイトル
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: ScheduleListTitle(selectedDate: _selectedDate),
                      ),
                    ),

                    // スケジュールリスト部分
                    todaySchedules.isEmpty
                        ? const SliverToBoxAdapter(child: EmptyScheduleState())
                        : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final schedule = todaySchedules[index];
                              final isAnimating =
                                  _animatingScheduleId == schedule.id;

                              return ScheduleCard(
                                schedule: schedule,
                                onEdit: () => _editSchedule(schedule),
                                onDelete: () => _deleteSchedule(schedule),
                                isAnimating: isAnimating,
                                popAnimation:
                                    isAnimating ? _popAnimation : null,
                              );
                            }, childCount: todaySchedules.length),
                          ),
                        ),

                    // 最下部の余白
                    const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                  ],
                ),
              // 件数バッジ（左上、スクリーン基準）
              if (!isLoading)
                CountBadge(
                  count:
                      _calendarFormat == CalendarFormat.month
                          ? _getSchedulesForMonth(
                            _focusedDate,
                            allSchedules,
                          ).length
                          : _getSchedulesForWeek(
                            _focusedDate,
                            allSchedules,
                          ).length,
                  icon: Icons.calendar_today,
                  top: 4,
                  bottom: null,
                ),
            ],
          ),
        );
      },
    );
  }
}
