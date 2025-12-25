import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../gradients.dart';

/// 日時選択用ボトムシート
/// 月・日・時・分を個別に操作できるドラム式ピッカーを横一列に配置
class TimePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const TimePickerBottomSheet({
    super.key,
    this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedHour;
  late int _selectedMinute;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late Key _dayPickerKey; // 月が変わったときに日のピッカーを再構築するためのKey
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  // 無限スクロール風のループ制御
  static const int _loopingMultiplier = 1000;
  static const double _itemHeight = 40.0;
  static const double _itemExtent = _itemHeight;

  // 月のオプション（1-12）
  final List<int> _monthOptions = List.generate(12, (index) => index + 1);
  int get _monthOptionsLength => _monthOptions.length;
  int get _monthTotalItems => _monthOptionsLength * _loopingMultiplier;
  int get _monthBaseCycle => _loopingMultiplier ~/ 2;
  int _toMonthLogicalIndex(int index) => index % _monthOptionsLength;

  // 時のオプション（0-23）
  final List<int> _hourOptions = List.generate(24, (index) => index);
  int get _hourOptionsLength => _hourOptions.length;
  int get _hourTotalItems => _hourOptionsLength * _loopingMultiplier;
  int get _hourBaseCycle => _loopingMultiplier ~/ 2;
  int _toHourLogicalIndex(int index) => index % _hourOptionsLength;

  // 分のオプション（0-59）
  final List<int> _minuteOptions = List.generate(60, (index) => index);
  int get _minuteOptionsLength => _minuteOptions.length;
  int get _minuteTotalItems => _minuteOptionsLength * _loopingMultiplier;
  int get _minuteBaseCycle => _loopingMultiplier ~/ 2;
  int _toMinuteLogicalIndex(int index) => index % _minuteOptionsLength;

  @override
  void initState() {
    super.initState();

    // 初期値の設定
    final now = DateTime.now();
    if (widget.initialDate != null) {
      _selectedYear = widget.initialDate!.year;
      _selectedMonth = widget.initialDate!.month;
      _selectedDay = widget.initialDate!.day;
      _selectedHour = widget.initialDate!.hour;
      _selectedMinute = widget.initialDate!.minute;
    } else {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
      _selectedHour = now.hour;
      _selectedMinute = now.minute;
    }

    // コントローラーの初期化
    _monthController = FixedExtentScrollController(
      initialItem:
          _monthBaseCycle * _monthOptionsLength +
          _monthOptions.indexOf(_selectedMonth),
    );
    _dayPickerKey = UniqueKey();
    _dayController = FixedExtentScrollController(
      initialItem:
          _dayBaseCycle * _getMaxDaysInMonth() +
          (_selectedDay - 1).clamp(0, _getMaxDaysInMonth() - 1),
    );
    _hourController = FixedExtentScrollController(
      initialItem: _hourBaseCycle * _hourOptionsLength + _selectedHour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minuteBaseCycle * _minuteOptionsLength + _selectedMinute,
    );

    _monthController.addListener(_onMonthChanged);
    _dayController.addListener(_onDayChanged);
    _hourController.addListener(_onHourChanged);
    _minuteController.addListener(_onMinuteChanged);
  }

  @override
  void dispose() {
    _monthController.removeListener(_onMonthChanged);
    _dayController.removeListener(_onDayChanged);
    _hourController.removeListener(_onHourChanged);
    _minuteController.removeListener(_onMinuteChanged);
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int _getMaxDaysInMonth() {
    return DateTime(_selectedYear, _selectedMonth + 1, 0).day;
  }

  int get _dayBaseCycle => _loopingMultiplier ~/ 2;
  int _getDayOptionsLength() => _getMaxDaysInMonth();
  int _getDayTotalItems() => _getDayOptionsLength() * _loopingMultiplier;
  int _toDayLogicalIndex(int index) => index % _getDayOptionsLength();

  void _onMonthChanged() {
    if (!mounted || !_monthController.hasClients) return;
    final currentIndex = (_monthController.offset / _itemExtent).round();
    final logicalIndex = _toMonthLogicalIndex(currentIndex);
    final newMonth = _monthOptions[logicalIndex];
    if (newMonth != _selectedMonth) {
      final oldMonth = _selectedMonth; // 変更前の月を保存
      final oldMaxDays = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

      setState(() {
        _selectedMonth = newMonth;

        // 年度の更新ロジック
        if (oldMonth == 12 && newMonth == 1) {
          // 12月から1月：年度を+1
          _selectedYear++;
        } else if (oldMonth == 1 && newMonth == 12) {
          // 1月から12月：年度を-1
          _selectedYear--;
        }

        final newMaxDays = _getMaxDaysInMonth();

        // 日の範囲を調整
        if (_selectedDay > newMaxDays) {
          _selectedDay = newMaxDays;
        }

        // 日数が変わった場合はコントローラーを再作成
        if (oldMaxDays != newMaxDays) {
          _dayController.removeListener(_onDayChanged);
          _dayController.dispose();
          _dayController = FixedExtentScrollController(
            initialItem:
                _dayBaseCycle * _getDayOptionsLength() +
                (_selectedDay - 1).clamp(0, _getDayOptionsLength() - 1),
          );
          _dayController.addListener(_onDayChanged);
          _dayPickerKey = UniqueKey();
        }
      });
      _notifyDateChanged();
    }
  }

  void _onDayChanged() {
    if (!mounted || !_dayController.hasClients) return;
    final currentIndex = (_dayController.offset / _itemExtent).round();
    final logicalIndex = _toDayLogicalIndex(currentIndex);
    final newDay = logicalIndex + 1; // 1ベース
    if (newDay != _selectedDay) {
      setState(() {
        _selectedDay = newDay;
      });
      _notifyDateChanged();
    }
  }

  void _onHourChanged() {
    if (!mounted || !_hourController.hasClients) return;
    final currentIndex = (_hourController.offset / _itemExtent).round();
    final logicalIndex = _toHourLogicalIndex(currentIndex);
    final newHour = _hourOptions[logicalIndex];
    if (newHour != _selectedHour) {
      setState(() {
        _selectedHour = newHour;
      });
      _notifyDateChanged();
    }
  }

  void _onMinuteChanged() {
    if (!mounted || !_minuteController.hasClients) return;
    final currentIndex = (_minuteController.offset / _itemExtent).round();
    final logicalIndex = _toMinuteLogicalIndex(currentIndex);
    final newMinute = _minuteOptions[logicalIndex];
    if (newMinute != _selectedMinute) {
      setState(() {
        _selectedMinute = newMinute;
      });
      _notifyDateChanged();
    }
  }

  void _notifyDateChanged() {
    final selectedDateTime = DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay,
      _selectedHour,
      _selectedMinute,
    );
    widget.onDateChanged(selectedDateTime);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.42,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ヘッダー（年の表示と閉じるボタン）
            Row(
              children: [
                Text(
                  '$_selectedYear年',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 月・日・時・分ピッカー
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      _DrumPicker(
                        controller: _monthController,
                        options: _monthOptions,
                        totalItems: _monthTotalItems,
                        baseCycle: _monthBaseCycle,
                        toLogicalIndex: _toMonthLogicalIndex,
                        formatLabel: (value) => '$value月',
                        label: '月',
                      ),
                      const SizedBox(width: 8),
                      _DrumPicker(
                        key: _dayPickerKey,
                        controller: _dayController,
                        options: List.generate(
                          _getMaxDaysInMonth(),
                          (index) => index + 1,
                        ),
                        totalItems: _getDayTotalItems(),
                        baseCycle: _dayBaseCycle,
                        toLogicalIndex: _toDayLogicalIndex,
                        formatLabel: (value) => '$value日',
                        label: '日',
                      ),
                      const SizedBox(width: 8),
                      _DrumPicker(
                        controller: _hourController,
                        options: _hourOptions,
                        totalItems: _hourTotalItems,
                        baseCycle: _hourBaseCycle,
                        toLogicalIndex: _toHourLogicalIndex,
                        formatLabel:
                            (value) => value.toString().padLeft(2, '0'),
                        label: '時',
                      ),
                      const SizedBox(width: 8),
                      _DrumPicker(
                        controller: _minuteController,
                        options: _minuteOptions,
                        totalItems: _minuteTotalItems,
                        baseCycle: _minuteBaseCycle,
                        toLogicalIndex: _toMinuteLogicalIndex,
                        formatLabel:
                            (value) => value.toString().padLeft(2, '0'),
                        label: '分',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ドラム式ピッカーのウィジェット
class _DrumPicker extends StatefulWidget {
  final FixedExtentScrollController controller;
  final List<int> options;
  final int totalItems;
  final int baseCycle;
  final int Function(int) toLogicalIndex;
  final String Function(int) formatLabel;
  final String label;

  const _DrumPicker({
    super.key,
    required this.controller,
    required this.options,
    required this.totalItems,
    required this.baseCycle,
    required this.toLogicalIndex,
    required this.formatLabel,
    required this.label,
  });

  @override
  State<_DrumPicker> createState() => _DrumPickerState();
}

class _DrumPickerState extends State<_DrumPicker> {
  static const double _itemExtent = 40.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      final currentOffset = widget.controller.offset;
                      final finalIndex = (currentOffset / _itemExtent).round();

                      // ループ安定化
                      final optionsLength = widget.options.length;
                      if (finalIndex < optionsLength ||
                          finalIndex > widget.totalItems - optionsLength) {
                        final logicalIndex = widget.toLogicalIndex(finalIndex);
                        final centered =
                            widget.baseCycle * optionsLength + logicalIndex;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && widget.controller.hasClients) {
                            widget.controller.jumpToItem(centered);
                          }
                        });
                      }
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    controller: widget.controller,
                    itemExtent: _itemExtent,
                    perspective: 0.003,
                    diameterRatio: 2.5,
                    physics: const SmoothListWheelScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.totalItems,
                      builder: (context, index) {
                        final logicalIndex = widget.toLogicalIndex(index);
                        final currentCenter =
                            widget.controller.hasClients
                                ? (widget.controller.offset / _itemExtent)
                                    .round()
                                : 0;
                        final distance = (index - currentCenter).abs();

                        double opacity;
                        double scale = 1.0;

                        if (distance < 0.1) {
                          opacity = 0.0;
                          scale = 1.0;
                        } else if (distance <= 1.0) {
                          opacity = 0.8 - (distance - 0.1) * 0.2;
                          scale = 1.0 - distance * 0.1;
                        } else if (distance <= 2.0) {
                          opacity = 0.4 - (distance - 1.0) * 0.2;
                          scale = 0.9 - (distance - 1.0) * 0.1;
                        } else {
                          opacity = 0.1;
                          scale = 0.8;
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            height: _itemExtent,
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: opacity),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              child: Text(
                                widget.formatLabel(
                                  widget.options[logicalIndex],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 中央の選択行のグラデーションボックス
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: _itemExtent,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: createHorizontalOrangeYellowGradient(),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 選択中の値ラベル
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.center,
                      child: Builder(
                        builder: (context) {
                          if (!widget.controller.hasClients) {
                            return Text(
                              widget.formatLabel(widget.options[0]),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          final currentIndex =
                              (widget.controller.offset / _itemExtent).round();
                          final logicalIndex = widget.toLogicalIndex(
                            currentIndex,
                          );
                          return Text(
                            widget.formatLabel(widget.options[logicalIndex]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
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

// SmoothListWheelScrollPhysics の再利用
class SmoothListWheelScrollPhysics extends FixedExtentScrollPhysics {
  const SmoothListWheelScrollPhysics({super.parent});

  @override
  SmoothListWheelScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothListWheelScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 50.0, damping: 8.0);

  @override
  double get minFlingVelocity => 30.0;

  @override
  double get maxFlingVelocity => 1600.0;

  @override
  Tolerance get tolerance => const Tolerance(velocity: 0.3, distance: 0.15);
}
