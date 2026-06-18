import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/chathub_channel.dart';
import 'package:chat/data_model/tag.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../presentation/utils/formatter.dart';

class FilterChathubScreen extends StatefulWidget {
  final String? status;
  final String? channel;
  final List<String?>? arrLabel;
  final link_status;
  final String? startDay;
  final String? endDay;
  final bool? isGroup;

  const FilterChathubScreen(
      {Key? key,
      this.status,
      this.channel,
      this.arrLabel,
      this.link_status,
      this.startDay,
      this.endDay,
      this.isGroup})
      : super(key: key);

  @override
  _FilterChathubScreenState createState() => _FilterChathubScreenState();
}

class _FilterChathubScreenState extends State<FilterChathubScreen> {
  bool isInitScreen = true;
  ChathubChannel? channels;
  String? status;
  String? channel;
  String? link_status;
  List<String?> arrLabel = [];
  Tag? tag;
  List<String> arrStatus = ['not_seen', 'seen', 'replied'];

  List<String> arr_link_status = [
    'all',
    'not_linked',
    'lead_linked',
    'customer_linked',
  ];
  bool? _isGroup;
  String? _startDay;
  String? _endDay;

  @override
  void initState() {
    super.initState();
    status = widget.status;
    channel = widget.channel;
    if (widget.arrLabel != null) {
      arrLabel = widget.arrLabel!;
    }

    link_status =
        widget.link_status == null ? arr_link_status[0] : widget.link_status;
    _startDay = widget.startDay;
    _endDay = widget.endDay;
    _isGroup = widget.isGroup;

    _getChannel();
  }

  void _submitFilter() {
    Navigator.of(context).pop({
      'status': status,
      'channel': channel,
      'tag_ids': arrLabel.isEmpty ? null : arrLabel,
      'link_status': link_status,
      'startDay': _startDay,
      'endDay': _endDay,
      'isGroup': _isGroup,
    });
  }

  bool _isStartDayAfterEndDay() {
    // Tách chuỗi ngày, giả sử định dạng dd/MM/yyyy
    try {
      List<String>? startParts = _startDay?.split('/');
      List<String> endParts = _endDay!.split('/');

      // Chuyển các phần thành số nguyên
      int startDayNum = int.parse(startParts![0]);
      int startMonth = int.parse(startParts[1]);
      int startYear = int.parse(startParts[2]);

      int endDayNum = int.parse(endParts[0]);
      int endMonth = int.parse(endParts[1]);
      int endYear = int.parse(endParts[2]);

      // So sánh năm, tháng, ngày
      if (startYear > endYear ||
          (startYear == endYear && startMonth > endMonth) ||
          (startYear == endYear &&
              startMonth == endMonth &&
              startDayNum > endDayNum)) {
        return true; // Ngày bắt đầu sau ngày kết thúc
      }
    } catch (_) {
      return false;
    }
    return false; // Ngày bắt đầu không sau ngày kết thúc
  }

  void _handleDateValidation(BuildContext context) {
    if (_startDay == null && _endDay == null ||
        _startDay != null && _endDay != null) {
      if (_startDay != null && _endDay != null) {
        if (_isStartDayAfterEndDay()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.text(LangKey.start_date_after_end_date)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ));
          return;
        }
      }
      _submitFilter();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.text(LangKey.missing_date),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: AutoSizeText(
              AppLocalizations.text(LangKey.filter),
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            leading: InkWell(
              child: Icon(Icons.arrow_back_ios, color: Colors.black),
              onTap: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
              child: isInitScreen
                  ? Center(
                      child: Platform.isAndroid
                          ? const CircularProgressIndicator()
                          : const CupertinoActivityIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.all(10.0),
                            children: [
                              /// Lọc theo ngày
                              SizedBox(
                                  height: 30,
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.95,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      datePickerDropdown(
                                        hintText: AppLocalizations.text(
                                            LangKey.startDay),
                                        context: context,
                                        selectedDate: _startDay,
                                        onDatePicked: (newDate) {
                                          setState(() {
                                            _startDay = newDate;
                                          });
                                        },
                                      ),
                                      Container(
                                        width: 16,
                                        height: 2,
                                        color: AppColors.black,
                                      ),
                                      datePickerDropdown(
                                        hintText: AppLocalizations.text(
                                            LangKey.endDay),
                                        context: context,
                                        selectedDate: _endDay,
                                        onDatePicked: (newDate) {
                                          setState(() {
                                            _endDay = newDate;
                                          });
                                        },
                                      ),
                                    ],
                                  )),

                              ///Lọc theo nhóm
                              SizedBox(
                                height: 41.0,
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      AppLocalizations.text(LangKey.byGroup),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Checkbox(
                                      value: _isGroup,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isGroup = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 15.0,
                              ),

                              ///Lọc theo kênh
                              AutoSizeText(
                                AppLocalizations.text(LangKey.byChannel),
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.15,
                              ),
                              Container(
                                height: 15.0,
                              ),
                              Wrap(
                                children: channels?.channels == null
                                    ? []
                                    : _listChannelWidget(),
                              ),
                              Container(
                                height: 30.0,
                              ),

                              ///Lọc theo trạng thái
                              AutoSizeText(
                                AppLocalizations.text(LangKey.byStatus),
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.15,
                              ),
                              Container(
                                height: 15.0,
                              ),
                              Wrap(
                                children: channels?.channels == null
                                    ? []
                                    : _listStatusWidget(),
                              ),
                              Container(
                                height: 30.0,
                              ),

                              ///Lọc theo nhãn
                              AutoSizeText(
                                AppLocalizations.text(LangKey.byLabel),
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.15,
                              ),
                              Container(
                                height: 15.0,
                              ),
                              Wrap(
                                children:
                                    tag?.data == null ? [] : _listLabelWidget(),
                              ),
                              Container(
                                height: 30.0,
                              ),

                              ///Lọc theo trạng thái liên kết
                              AutoSizeText(
                                AppLocalizations.text(LangKey.byLinkStatus),
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold),
                                textScaleFactor: 1.15,
                              ),
                              Container(
                                height: 15.0,
                              ),
                              Wrap(
                                children: tag?.data == null
                                    ? []
                                    : _list_Link_Status_Widget(),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 41.0,
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: MaterialButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      status = null;
                                      channel = null;
                                      link_status = null;
                                      _startDay = null;
                                      _endDay = null;
                                      _isGroup = false;
                                      arrLabel.clear();
                                    });
                                    _submitFilter();
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Color(0xFF5686E1))),
                                  child: Text(
                                    AppLocalizations.text(LangKey.delete),
                                    style: const TextStyle(
                                        color: Color(0xFF5686E1),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 41.0,
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: MaterialButton(
                                  color: const Color(0xFF5686E1),
                                  onPressed: () {
                                    _handleDateValidation(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    AppLocalizations.text(LangKey.accept),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ))),
    );
  }

  List<Widget> _listLabelWidget() {
    List<Widget> arr = [];
    arr = tag!.data!
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (arrLabel.contains(e.sId)) {
                  arrLabel.remove(e.sId);
                } else {
                  arrLabel.add(e.sId);
                }
                setState(() {});
              },
              child: _chipWidget(e.name ?? '', arrLabel.contains(e.sId)),
            ),
          ),
        )
        .toList();
    arr.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                arrLabel.clear();
              });
            },
            child: _chipWidget(AppLocalizations.text(LangKey.all), arrLabel.isEmpty),
          ),
        ));
    return arr;
  }

  List<Widget> _listStatusWidget() {
    List<Widget> arr = [];
    arr = arrStatus
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  status = e;
                });
              },
              child: _chipWidget(AppLocalizations.text(e), status == e),
            ),
          ),
        )
        .toList();
    arr.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                status = null;
              });
            },
            child: _chipWidget(AppLocalizations.text(LangKey.all), status == null),
          ),
        ));
    return arr;
  }

  List<Widget> _list_Link_Status_Widget() {
    return arr_link_status.map((value) {
      final bool isSelected = link_status == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              link_status = value;
            });
          },
          child: _chipWidget(AppLocalizations.text(value), isSelected),
        ),
      );
    }).toList();
  }

  List<Widget> _listChannelWidget() {
    List<Widget> arr = [];
    arr = channels!.channels!
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  channel = e.sId ?? '';
                });
              },
              child: _chipWidget(e.nameApp ?? '', channel == e.sId),
            ),
          ),
        )
        .toList();
    arr.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                channel = null;
              });
            },
            child: _chipWidget(AppLocalizations.text(LangKey.all), channel == null),
          ),
        ));
    return arr;
  }

  Widget _chipWidget(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  void _getChannel() async {
    channels = await ChatConnection.channelList();
    tag = await ChatConnection.getTagList();
    isInitScreen = false;
    setState(() {});
  }

  Widget datePickerDropdown({
    required BuildContext context,
    required String? selectedDate,
    required Function(String) onDatePicked,
    String hintText = '',
    List<String> arrLabel = const [],
  }) {
    return InkWell(
      onTap: () {
        DateTime tempDate = parseDate(selectedDate) ?? DateTime.now();
        showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: 280,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.text(LangKey.cancel),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.text(LangKey.accept),
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      onPressed: () {
                        final formatted =
                            DateFormat('dd/MM/yyyy').format(tempDate);
                        onDatePicked(formatted);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime(2000),
                    maximumDate: DateTime(2100),
                    onDateTimeChanged: (date) {
                      tempDate = date;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.4,
        height: 30,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white),
        child: Center(
          child: Text(
            formatDate(parseDate(selectedDate), fallback: hintText),
            style: TextStyle(
                color: selectedDate != null ? Colors.blueAccent : Colors.grey,
                fontSize: 14,
                fontWeight:
                    selectedDate != null ? FontWeight.w600 : null),
          ),
        ),
      ),
    );
  }
}
