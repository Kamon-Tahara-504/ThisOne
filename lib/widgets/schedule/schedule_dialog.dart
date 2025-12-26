import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../models/schedule.dart';
import '../../utils/text_selection_menu_builder.dart';
import '../common/time_picker_bottom_sheet.dart';
import 'notification_settings.dart';
import 'schedule_form_header.dart';
import 'schedule_time_selector.dart';
import 'schedule_basic_settings.dart';
import 'schedule_form_submit_button.dart';

class ScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Map<String, dynamic>)? onAdd;
  final Schedule? schedule;
  final Function(Map<String, dynamic>)? onUpdate;

  const ScheduleDialog({
    super.key,
    required this.selectedDate,
    this.onAdd,
    this.schedule,
    this.onUpdate,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: TimeOfDay.now().minute,
  );
  bool _isAllDay = false;
  String _selectedColorHex = '#9E9E9E';
  bool _isNotificationEnabled = false;
  int _reminderMinutes = 15;

  // 開始時間と終了時間のDateTime（ピッカー用）
  DateTime get _startDateTime {
    final selectedDate = widget.schedule?.scheduleDate ?? widget.selectedDate;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
  }

  DateTime get _endDateTime {
    final selectedDate = widget.schedule?.scheduleDate ?? widget.selectedDate;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
  }

  bool _isCustomReminder = false;
  int _customValue = 15;
  String _customUnit = 'minutes'; // 'minutes', 'hours', 'days'

  // 通知時間オプション
  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': '5分前', 'minutes': 5},
    {'label': '15分前', 'minutes': 15},
    {'label': '30分前', 'minutes': 30},
    {'label': '1時間前', 'minutes': 60},
    {'label': '1日前', 'minutes': 1440},
    {'label': 'カスタム', 'minutes': -1}, // -1はカスタムの識別子
  ];

  @override
  void initState() {
    super.initState();
    // 編集モードの場合、既存スケジュールの値を初期値として設定
    if (widget.schedule != null) {
      final schedule = widget.schedule!;
      _titleController.text = schedule.title;
      _descriptionController.text = schedule.description ?? '';
      _startTime = schedule.startTime;
      _endTime =
          schedule.endTime ??
          TimeOfDay(
            hour: schedule.startTime.hour + 1,
            minute: schedule.startTime.minute,
          );
      _isAllDay = schedule.isAllDay;
      _selectedColorHex = schedule.colorHex;
      _reminderMinutes = schedule.reminderMinutes;
      _isNotificationEnabled = schedule.reminderMinutes > 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // カスタム時間を分単位で計算
  int _getCustomReminderMinutes() {
    switch (_customUnit) {
      case 'minutes':
        return _customValue;
      case 'hours':
        return _customValue * 60;
      case 'days':
        return _customValue * 1440;
      default:
        return _customValue;
    }
  }

  // カスタム設定ダイアログを表示
  void _showCustomReminderDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => _CustomReminderDialog(
            initialValue: _customValue,
            initialUnit: _customUnit,
          ),
    );

    if (result != null) {
      setState(() {
        _customValue = result['value'];
        _customUnit = result['unit'];
        _isCustomReminder = true;
        _reminderMinutes = _getCustomReminderMinutes();
      });
    }
  }

  void _saveSchedule() {
    if (_titleController.text.trim().isNotEmpty) {
      final finalReminderMinutes =
          _isCustomReminder ? _getCustomReminderMinutes() : _reminderMinutes;

      final startForSave =
          _isAllDay ? const TimeOfDay(hour: 0, minute: 0) : _startTime;
      final TimeOfDay? endForSave = _isAllDay ? null : _endTime;

      final scheduleData = {
        'title': _titleController.text.trim(),
        'description':
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        'date': widget.schedule?.scheduleDate ?? widget.selectedDate,
        'startTime': startForSave,
        'endTime': endForSave,
        'isAllDay': _isAllDay,
        'colorHex': _selectedColorHex,
        'reminderMinutes': _isNotificationEnabled ? finalReminderMinutes : 0,
      };

      if (widget.schedule == null) {
        // 作成モード
        widget.onAdd?.call({
          ...scheduleData,
          'id': DateTime.now().millisecondsSinceEpoch,
          'notificationMode': _isNotificationEnabled ? 'reminder' : 'none',
          'isAlarmEnabled': false,
          'createdAt': DateTime.now(),
        });
        // Navigator.popはonAddコールバック内で呼ばれるため、ここでは呼ばない
      } else {
        // 編集モード
        widget.onUpdate?.call(scheduleData);
        // Navigator.popはonUpdateコールバック内で呼ばれるため、ここでは呼ばない
      }
    }
  }

  void _selectStartTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => TimePickerBottomSheet(
            initialDate: _startDateTime,
            onDateChanged: (newDateTime) {
              setState(() {
                _startTime = TimeOfDay.fromDateTime(newDateTime);
              });
            },
          ),
    );
  }

  void _selectEndTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => TimePickerBottomSheet(
            initialDate: _endDateTime,
            onDateChanged: (newDateTime) {
              setState(() {
                _endTime = TimeOfDay.fromDateTime(newDateTime);
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero, // デフォルトの余白を削除
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SizedBox(
          width: maxWidth, // 明示的に幅を指定
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                ScheduleFormHeader(
                  selectedDate:
                      widget.schedule?.scheduleDate ?? widget.selectedDate,
                  onClose: () => Navigator.pop(context),
                  isEditMode: widget.schedule != null,
                ),

                // メインコンテンツ
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      // 入力欄以外をタップした時にキーボードを格納
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 基本設定セクション
                          ScheduleBasicSettings(
                            titleController: _titleController,
                            descriptionController: _descriptionController,
                            selectedColorHex: _selectedColorHex,
                            onColorChanged: (color) {
                              setState(() {
                                _selectedColorHex = color;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // 時間設定セクション
                          ScheduleTimeSelector(
                            isAllDay: _isAllDay,
                            startTime: _startTime,
                            endTime: _endTime,
                            onAllDayChanged: (value) {
                              setState(() {
                                _isAllDay = value;
                                if (_isAllDay) {
                                  _startTime = const TimeOfDay(
                                    hour: 0,
                                    minute: 0,
                                  );
                                  _endTime = const TimeOfDay(
                                    hour: 23,
                                    minute: 59,
                                  );
                                }
                              });
                            },
                            onStartTimeSelected: _selectStartTime,
                            onEndTimeSelected: _selectEndTime,
                          ),
                          const SizedBox(height: 20),

                          // 通知設定セクション（コンポーネント化）
                          NotificationSettings(
                            isEnabled: _isNotificationEnabled,
                            reminderOptions: _reminderOptions,
                            isCustomReminder: _isCustomReminder,
                            reminderMinutes: _reminderMinutes,
                            customValue: _customValue,
                            customUnit: _customUnit,
                            onEnabledChange:
                                (value) => setState(() {
                                  _isNotificationEnabled = value;
                                }),
                            onSelectPresetMinutes:
                                (minutes) => setState(() {
                                  _isCustomReminder = false;
                                  _reminderMinutes = minutes;
                                }),
                            onTapCustom: _showCustomReminderDialog,
                          ),

                          const SizedBox(height: 20),

                          // 作成/更新ボタン
                          ScheduleFormSubmitButton(
                            onPressed: _saveSchedule,
                            label:
                                widget.schedule != null
                                    ? 'スケジュールを更新'
                                    : 'スケジュールを作成',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// カスタム通知設定用の独立ダイアログ
class _CustomReminderDialog extends StatefulWidget {
  final int initialValue;
  final String initialUnit;

  const _CustomReminderDialog({
    required this.initialValue,
    required this.initialUnit,
  });

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  late TextEditingController _controller;
  late int _value;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _unit = widget.initialUnit;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF3A3A3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'カスタム通知設定',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2B2B2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE85A3B)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  contextMenuBuilder: nativeTextSelectionMenuBuilder,
                  onChanged: (value) {
                    final intValue = int.tryParse(value);
                    if (intValue != null && intValue > 0) {
                      var next = intValue;
                      if (_unit == 'days' && next > 3) {
                        next = 3;
                        if (_controller.text != '3') {
                          // 入力を3に戻す
                          _controller.text = '3';
                          _controller.selection = TextSelection.fromPosition(
                            const TextPosition(offset: 1),
                          );
                        }
                      }
                      _value = next;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2B2B2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                  ),
                  dropdownColor: const Color(0xFF3A3A3A),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'minutes', child: Text('分前')),
                    DropdownMenuItem(value: 'hours', child: Text('時間前')),
                    DropdownMenuItem(value: 'days', child: Text('日前')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _unit = value;
                        // days選択時は最大3に制限
                        if (_unit == 'days' && _value > 3) {
                          _value = 3;
                          if (_controller.text != '3') {
                            _controller.text = '3';
                            _controller.selection = TextSelection.fromPosition(
                              const TextPosition(offset: 1),
                            );
                          }
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('キャンセル', style: TextStyle(color: Colors.grey[400])),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: createHorizontalOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context, {'value': _value, 'unit': _unit});
            },
            child: const Text('設定', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
