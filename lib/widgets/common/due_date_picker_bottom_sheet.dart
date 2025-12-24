import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../gradients.dart';

/// タスクの期限選択用ボトムシート
/// 月・日・時・分を個別に操作できるドラム式ピッカーを横一列に配置
class DueDatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DueDatePickerBottomSheet({
    super.key,
    this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<DueDatePickerBottomSheet> createState() =>
      _DueDatePickerBottomSheetState();
}

class _DueDatePickerBottomSheetState extends State<DueDatePickerBottomSheet> {
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
    final now = DateTime.now();
    final initial = widget.initialDate ?? now;

    _selectedYear = initial.year;
    _selectedMonth = initial.month;
    _selectedDay = initial.day;
    _selectedHour = initial.hour;
    _selectedMinute = initial.minute;

    // コントローラーの初期化（無限スクロール用の中央位置に設定）
    _monthController = FixedExtentScrollController(
      initialItem:
          _monthBaseCycle * _monthOptionsLength +
          _monthOptions.indexOf(_selectedMonth),
    );
    _dayPickerKey = UniqueKey();
    _dayController = FixedExtentScrollController(
      initialItem:
          _calculateDayBaseCycle() * _getDayOptionsLength() +
          _getDayOptions().indexOf(_selectedDay),
    );
    _hourController = FixedExtentScrollController(
      initialItem:
          _hourBaseCycle * _hourOptionsLength +
          _hourOptions.indexOf(_selectedHour),
    );
    _minuteController = FixedExtentScrollController(
      initialItem:
          _minuteBaseCycle * _minuteOptionsLength +
          _minuteOptions.indexOf(_selectedMinute),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  // 選択された月と年から、その月の日数を取得
  List<int> _getDayOptions() {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  int _getDayOptionsLength() => _getDayOptions().length;
  int _calculateDayBaseCycle() => _loopingMultiplier ~/ 2;
  int get _dayTotalItems => _getDayOptionsLength() * _loopingMultiplier;
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

        // 日数の調整（例：31日→30日に変更された場合）
        final newMaxDays = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
        if (_selectedDay > newMaxDays) {
          _selectedDay = newMaxDays;
        }

        // 日のピッカーを再構築
        _dayPickerKey = UniqueKey();
      });

      // 日のコントローラーを再設定
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _dayController.hasClients) {
          final newDayOptions = _getDayOptions();
          final dayIndex = newDayOptions.indexOf(_selectedDay);
          if (dayIndex >= 0) {
            final targetIndex =
                _calculateDayBaseCycle() * newDayOptions.length + dayIndex;
            _dayController.jumpToItem(targetIndex);
          }
        }
      });
      _notifyDateChanged();
    }
  }

  void _onDayChanged() {
    if (!mounted || !_dayController.hasClients) return;
    final currentIndex = (_dayController.offset / _itemExtent).round();
    final logicalIndex = _toDayLogicalIndex(currentIndex);
    final newDay = _getDayOptions()[logicalIndex];
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
    final newDate = DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay,
      _selectedHour,
      _selectedMinute,
    );
    widget.onDateChanged(newDate);
  }

  Widget _buildDrumPicker({
    required String label,
    required List<int> options,
    required FixedExtentScrollController controller,
    required int selectedValue,
    required VoidCallback onChanged,
    required int Function(int) toLogicalIndex,
    required int totalItems,
    required int baseCycle,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
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
                // スクロール可能なピッカー
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: _itemExtent,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) => onChanged(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: totalItems,
                    builder: (context, index) {
                      final logicalIndex = toLogicalIndex(index);
                      final value = options[logicalIndex];
                      final isSelected = value == selectedValue;

                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          value.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: isSelected ? 20 : 16,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 中央の選択エリアを強調（グラデーションオーバーレイ）
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF2B2B2B).withValues(alpha: 0.8),
                            Colors.transparent,
                            Colors.transparent,
                            const Color(0xFF2B2B2B).withValues(alpha: 0.8),
                          ],
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // 中央の選択ライン
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        height: _itemExtent,
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey[700]!,
                              width: 1,
                            ),
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.33;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー（年の表示と閉じるボタン）
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
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
            ),

            // ピッカーエリア（横一列）
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
                child: Row(
                  children: [
                    // 月のピッカー
                    _buildDrumPicker(
                      label: '月',
                      options: _monthOptions,
                      controller: _monthController,
                      selectedValue: _selectedMonth,
                      onChanged: _onMonthChanged,
                      toLogicalIndex: _toMonthLogicalIndex,
                      totalItems: _monthTotalItems,
                      baseCycle: _monthBaseCycle,
                    ),

                    // 日のピッカー
                    Builder(
                      key: _dayPickerKey,
                      builder:
                          (context) => _buildDrumPicker(
                            label: '日',
                            options: _getDayOptions(),
                            controller: _dayController,
                            selectedValue: _selectedDay,
                            onChanged: _onDayChanged,
                            toLogicalIndex: _toDayLogicalIndex,
                            totalItems: _dayTotalItems,
                            baseCycle: _calculateDayBaseCycle(),
                          ),
                    ),

                    // 時のピッカー
                    _buildDrumPicker(
                      label: '時',
                      options: _hourOptions,
                      controller: _hourController,
                      selectedValue: _selectedHour,
                      onChanged: _onHourChanged,
                      toLogicalIndex: _toHourLogicalIndex,
                      totalItems: _hourTotalItems,
                      baseCycle: _hourBaseCycle,
                    ),

                    // 分のピッカー
                    _buildDrumPicker(
                      label: '分',
                      options: _minuteOptions,
                      controller: _minuteController,
                      selectedValue: _selectedMinute,
                      onChanged: _onMinuteChanged,
                      toLogicalIndex: _toMinuteLogicalIndex,
                      totalItems: _minuteTotalItems,
                      baseCycle: _minuteBaseCycle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
