import 'dart:async';

import 'package:flutter/material.dart';

import './annual_task_item.dart';

enum AnnualTaskCellShape { SQUARE, CIRCLE, ROUNDED_SQUARE }

class AnnualTaskView extends StatefulWidget {
  final List<AnnualTaskItem> items;
  final Color? activateColor;
  final Color? emptyColor;
  final int year;

  final bool showWeekDayLabel;
  final List<String>? weekDayLabels;
  final bool showMonthLabel;
  final List<String>? monthLabels;
  final AnnualTaskCellShape? cellShape;

  final bool swipeEnabled;
  final TextStyle? labelStyle;

  // New parameter for adjusting the cell width proportionally
  final double cellWidthFactor;
  final double spacing;
  final DateTime firstDate;

  AnnualTaskView(this.items,
      {int? year,
      this.activateColor,
      this.emptyColor,
      this.cellShape,
      this.showWeekDayLabel = true,
      this.showMonthLabel = true,
      List<String>? weekDayLabels,
      List<String>? monthLabels,
      this.labelStyle,
      this.swipeEnabled = false,
      this.cellWidthFactor = 0.85,
      this.spacing = 0,
      required this.firstDate})
      : assert(showWeekDayLabel == false ||
            (weekDayLabels == null || weekDayLabels.length == 7)),
        assert(showMonthLabel == false ||
            (monthLabels == null || monthLabels.length == 12)),
        this.year = year ?? DateTime.now().year,
        this.weekDayLabels =
            (weekDayLabels?.length ?? 0) == 7 ? weekDayLabels : _WEEKDAY_LABELS,
        this.monthLabels =
            (monthLabels?.length ?? 0) == 12 ? monthLabels : _MONTH_LABELS;

  @override
  _AnnualTaskViewState createState() => _AnnualTaskViewState();
}

class _AnnualTaskViewState extends State<AnnualTaskView> {
  double? contentsWidth;
  bool? _refreshing;

  final StreamController<Map<DateTime, AnnualTaskItem>?> _streamController =
      StreamController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      return _buildListToMap();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(AnnualTaskView oldWidget) {
    _buildListToMap();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _layoutManagerView(),
        Builder(builder: (context) {

          return _AnnualTaskGrid(
              widget.year,
              _buildListToMap(),
              widget.activateColor ?? Theme.of(context).primaryColor,
              widget.emptyColor,
              widget.showWeekDayLabel,
              widget.showMonthLabel,
              widget.weekDayLabels,
              widget.monthLabels,
              widget.cellShape,
              widget.labelStyle,
              contentsWidth,
              widget.cellWidthFactor,
              widget.spacing,
              widget.swipeEnabled,
              widget.firstDate);
        }),
        // StreamBuilder<Map<DateTime, AnnualTaskItem>?>(
        //   stream: _streamController.stream,
        //   builder: (context, snapshot) {
        //     double opacity = 1.0;
        //     if (contentsWidth == null) {
        //       opacity = 0.0;
        //     } else if (_refreshing == true) {
        //       opacity = 0.5;
        //     }
        //     return AnimatedOpacity(
        //       opacity: opacity,
        //       duration: Duration(milliseconds: opacity == 1.0 ? 500 : 0),
        //       child: _AnnualTaskGrid(
        //           widget.year,
        //           snapshot.data,
        //           widget.activateColor ?? Theme.of(context).primaryColor,
        //           widget.emptyColor,
        //           widget.showWeekDayLabel,
        //           widget.showMonthLabel,
        //           widget.weekDayLabels,
        //           widget.monthLabels,
        //           widget.cellShape,
        //           widget.labelStyle,
        //           contentsWidth,
        //           widget.cellWidthFactor,
        //           widget.spacing,
        //           widget.swipeEnabled),
        //     );
        //   },
        // ),
      ],
    );
  }

  //
  // Future<Map<DateTime, AnnualTaskItem>> _buildListToMap() {
  //   Map<DateTime, AnnualTaskItem> resultMap = Map();
  //   _refreshing = true;
  //   _streamController.add(null);
  //   widget.items.forEach((item) {
  //     resultMap[item.date] = item;
  //   });
  //   return Future.delayed(Duration.zero, () {
  //     _streamController.add(resultMap);
  //     _refreshing = false;
  //     return resultMap;
  //   });
  // }

  Map<DateTime, AnnualTaskItem> _buildListToMap() {
    Map<DateTime, AnnualTaskItem> resultMap = Map();
    _refreshing = true;
    _streamController.add(null);
    widget.items.forEach((item) {
      resultMap[item.date] = item;
    });
    return resultMap;
  }

  Widget _layoutManagerView() {
    if (contentsWidth != null) return Container();
    return Container(
      height: 0,
      child: Row(
        children: <Widget>[
          (widget.showWeekDayLabel != false)
              ? Column(
                  children: List.generate(7, (idx) {
                  return Text(
                    widget.weekDayLabels?.elementAt(idx) ?? '',
                    style: widget.labelStyle ?? _LABEL_STYLE,
                  );
                }))
              : Container(),
          Expanded(
            child: LayoutBuilder(builder: (_, layout) {
              Future.delayed(
                Duration.zero,
                () => setState(() => contentsWidth = layout.maxWidth),
              );
              return Container();
            }),
          )
        ],
      ),
    );
  }
}

class _AnnualTaskGrid extends StatefulWidget {
  final DateTime firstDate;
  final Map<DateTime, AnnualTaskItem>? resultMap;
  final int firstDay;

  final Color? activateColor;
  final Color? emptyColor;

  final bool showWeekDayLabel;
  final List<String>? weekDayLabels;
  final bool showMonthLabel;
  final List<String>? monthLabels;
  final AnnualTaskCellShape cellShape;
  final TextStyle labelStyle;

  final double? contentsWidth;
  final double cellWidthFactor; // New parameter for cell size adjustment
  final double spacing; // New parameter for cell size adjustment
  final enableSwipe;

  _AnnualTaskGrid(
      int year,
      this.resultMap,
      this.activateColor,
      this.emptyColor,
      this.showWeekDayLabel,
      this.showMonthLabel,
      this.weekDayLabels,
      this.monthLabels,
      AnnualTaskCellShape? cellShape,
      TextStyle? labelStyle,
      this.contentsWidth,
      this.cellWidthFactor,
      this.spacing,
      this.enableSwipe,
      this.firstDate)
      : firstDay = firstDate.weekday % 7,
        this.cellShape = cellShape ?? AnnualTaskCellShape.ROUNDED_SQUARE,
        this.labelStyle = labelStyle ?? _LABEL_STYLE;

  @override
  State<_AnnualTaskGrid> createState() => _AnnualTaskGridState();
}

class _AnnualTaskGridState extends State<_AnnualTaskGrid> {
  late GlobalKey lastCompletedTaskDateWidgetGlobalKey;

  // ScrollController scrollController = ScrollController();
  // final GlobalKey _scrollViewKey = GlobalKey();

  // Offset getWidgetOffset(GlobalKey key) {
  //   final RenderBox? renderBox =
  //       key.currentContext?.findRenderObject() as RenderBox?;
  //   final Offset? offset = renderBox?.localToGlobal(Offset.zero);
  //   return offset ?? Offset(0, 0);
  // }
  // bool isWidgetVisible(GlobalKey childKey,GlobalKey scrollViewKey) {
  //   final RenderBox scrollViewRenderBox =
  //   scrollViewKey.currentContext?.findRenderObject() as RenderBox;
  //   final RenderBox childRenderBox =
  //   childKey.currentContext?.findRenderObject() as RenderBox;
  //
  //   final Offset childOffset = childRenderBox.localToGlobal(Offset.zero);
  //   final Rect visibleRect = Rect.fromPoints(
  //     scrollViewRenderBox.localToGlobal(Offset.zero),
  //     scrollViewRenderBox.localToGlobal(
  //       Offset(scrollViewRenderBox.size.width, scrollViewRenderBox.size.height),
  //     ),
  //   );
  //
  //   return visibleRect.overlaps(Rect.fromLTWH(
  //     childOffset.dx,
  //     childOffset.dy,
  //     childRenderBox.size.width,
  //     childRenderBox.size.height,
  //   ));
  // }
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) {
    //     if (widget.resultMap != null) {
    //       Future.delayed(
    //         Duration(
    //           milliseconds: 200,
    //         ),
    //         () {
    //         //  if(!isWidgetVisible(widget.resultMap!.values.last.key!, _scrollViewKey)){
    //             Offset offset = getWidgetOffset(widget.resultMap!.values.last.key!);
    //
    //             scrollController.jumpTo(offset.dx);
    //         //  }
    //
    //         },
    //       );
    //     }
    //   },
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("mode:" + (widget.firstDate.weekday % 7).toString());
    return LayoutBuilder(
      builder: (context, layout) {
        return widget.enableSwipe
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: _buildTaskGrid(context, layout))
            : _buildTaskGrid(context, layout);
      },
    );
  }

  _buildTaskGrid(BuildContext context, BoxConstraints layout) {
    double maxWidth = widget.contentsWidth ?? layout.maxWidth;
    // Use cellWidthFactor to adjust the cell size
    final double cellSize = (maxWidth / 53) * widget.cellWidthFactor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _rowCnt,
        (days) {
          // if (showMonthLabel == true && days == 0) {
          //   return _buildMonthLabelRow(
          //     cellSize,
          //     paddingLeft: layout.maxWidth - maxWidth,
          //   );
          // }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: (maxWidth / 53) * 0.075),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_colCnt, (weeks) {
                // if (showWeekDayLabel == true && weeks == 0) {
                //   return _buildWeekdayLabel(days,
                //       width: layout.maxWidth - maxWidth);
                // }
                AnnualTaskItem? result = _getResult(weeks, days);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(
                    widget.cellShape == AnnualTaskCellShape.SQUARE
                        ? 0
                        : widget.cellShape == AnnualTaskCellShape.CIRCLE
                            ? 200
                            : cellSize / 4,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(widget.spacing),
                    child: Container(

                      width: cellSize,
                      height: cellSize,
                      color:
                      result?.fillColor(widget.activateColor ??
                              Theme.of(context).primaryColor) ??
                          (widget.emptyColor ??
                              Theme.of(context).disabledColor),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  AnnualTaskItem? _getResult(int weeksIdx, int daysIdx) {
    if (widget.resultMap == null) return null;
    if (widget.showWeekDayLabel) weeksIdx--;
    if (widget.showMonthLabel) daysIdx--;
    int days = weeksIdx * 7 + daysIdx;
    //to start the week from sunday ->  int days = weeksIdx * 7 + daysIdx -widget.firstDay
    DateTime date = widget.firstDate.add(Duration(days: days));
    //DateTime.now().add(Duration(days: days));
    return widget.resultMap![date];
  }

  int get _colCnt => widget.showWeekDayLabel == true ? 54 : 53;

  int get _rowCnt => widget.showMonthLabel == true ? 8 : 7;
}

const List<String> _WEEKDAY_LABELS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const List<String> _MONTH_LABELS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
const TextStyle _LABEL_STYLE = TextStyle(fontSize: 8);
