import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/event/event_event.dart';
import 'package:remind_me/blocs/event/event_state.dart';
import 'package:remind_me/utils/common/lunar_utils.dart';
import 'package:remind_me/utils/ui/background_utils.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/date/edit_event_page.dart';
import 'package:remind_me/utils/common/route_utils.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({
    required this.event,
    Key? key,
  }) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event _event;
  
  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    // 使用 BlocBuilder 监听事件变化
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        // 从 state 中获取最新的事件数据
        final updatedEvent = state.events.firstWhere(
          (e) => e.id == _event.id,
          orElse: () => _event,
        );

        // 判断背景类型，决定使用哪种布局
        final isSimpleBackground = updatedEvent.backgroundType == BackgroundType.color || 
                                  updatedEvent.backgroundType == BackgroundType.gradient;
        
        if (isSimpleBackground) {
          return _buildFullscreenLayout(updatedEvent);
        } else {
          return _buildCardLayout(updatedEvent);
        }
      },
    );
  }

  // 纯色/渐变色背景的全屏布局
  Widget _buildFullscreenLayout(Event event) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: BackgroundUtils.getEventTextColor(event, context),
        ),
        actions: _buildAppBarActions(event),
      ),
      body: Container(
        decoration: BackgroundUtils.buildBackgroundDecoration(
          backgroundType: event.backgroundType,
          backgroundColor: event.backgroundColor,
          gradientColors: event.gradientColors,
          localImagePath: event.localImagePath,
          defaultColor: Theme.of(context).colorScheme.surface,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildEventContent(event),
              ),
              _buildBottomActions(event),
            ],
          ),
        ),
      ),
    );
  }

  // 图片/自定义背景的卡片布局
  Widget _buildCardLayout(Event event) {
    return Scaffold(
      appBar: AppBar(
        title: Text('事件详情', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: _buildAppBarActions(event),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BackgroundUtils.getEventCardBackground(event, context),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildEventContent(event),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildBottomActions(event),
        ],
      ),
    );
  }

  // 事件内容（上中下结构）
  Widget _buildEventContent(Event event) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上部分：标题和日期
        _buildHeader(event),
        
        const SizedBox(height: 40),
        
        // 中部分：天数（可点击切换单位）
        _buildDaysCounter(event),
        
        const SizedBox(height: 40),
        
        // 下部分：起始日期
        _buildFooter(event),
      ],
    );
  }

  // 上部分：标题和前缀
  Widget _buildHeader(Event event) {
    return Column(
      children: [
        if (event.iconName != null)
          Icon(
            EventIconMapping.getIcon(event.iconName!),
            size: 32,
            color: BackgroundUtils.getEventTextColor(event, context),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BackgroundUtils.getEventTextColor(event, context),
                fontFamily: event.fontFamily,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              event.getDisplayPrefix(context),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BackgroundUtils.getEventTextColor(event, context),
                fontFamily: event.fontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 中部分：天数（可点击切换单位）
  Widget _buildDaysCounter(Event event) {
    return GestureDetector(
      onTap: () => _toggleDisplayUnit(event),
      child: Container(
        height: 160,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              event.getFormattedNumber(context).replaceAll('\n', ' '),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: BackgroundUtils.getEventTextColor(event, context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // 下部分：起始日期
  Widget _buildFooter(Event event) {
    final l10n = context.l10n;
    final isCountdown = event.targetDate.isAfter(DateTime.now());
    
    return Column(
      children: [
        Text(
          '${isCountdown ? l10n.targetDate : l10n.startDate}: '
          '${LunarUtils.formatDateWithYear(event.targetDate, event.isLunar, context)} '
          '${l10n.weekday(LunarUtils.getWeekDay(event.targetDate, context, useShort: true))}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BackgroundUtils.getEventTextColor(event, context),
          ),
          textAlign: TextAlign.center,
        ),
        // if (event.isLunar)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4),
        //     child: Text(
        //       '${l10n.solarDate}: ${LunarUtils.formatDateWithYear(event.targetDate, false, context)} '
        //       '${l10n.weekday(LunarUtils.getWeekDay(event.targetDate, context, useShort: true))}',
        //       style: TextStyle(
        //         fontSize: 14,
        //         color: BackgroundUtils.getEventTextColor(event, context).withOpacity(0.8),
        //       ),
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
      ],
    );
  }

  // 底部操作按钮
  Widget _buildBottomActions(Event event) {
    final isSimpleBackground = event.backgroundType == BackgroundType.color || 
                              event.backgroundType == BackgroundType.gradient;
    
    return Container(
      color: isSimpleBackground ? Colors.transparent : Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.share,
            label: context.l10n.share,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能正在开发中')),
              );
            },
            isSimpleBackground: isSimpleBackground,
            event: event,
          ),
          _buildActionButton(
            icon: Icons.wallpaper,
            label: '设为壁纸',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('壁纸功能正在开发中')),
              );
            },
            isSimpleBackground: isSimpleBackground,
            event: event,
          ),
          _buildActionButton(
            icon: Icons.edit,
            label: context.l10n.edit,
            onTap: () => _editEvent(event),
            isSimpleBackground: isSimpleBackground,
            event: event,
          ),
          _buildActionButton(
            icon: Icons.delete,
            label: context.l10n.delete,
            onTap: () => _deleteEvent(event),
            isSimpleBackground: isSimpleBackground,
            event: event,
          ),
        ],
      ),
    );
  }

  // 操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSimpleBackground,
    required Event event,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSimpleBackground 
                  ? BackgroundUtils.getEventTextColor(event, context) 
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSimpleBackground 
                    ? BackgroundUtils.getEventTextColor(event, context) 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar操作按钮
  List<Widget> _buildAppBarActions(Event event) {
    return [
      IconButton(
        icon: Icon(
          event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: event.backgroundType == BackgroundType.color || 
                event.backgroundType == BackgroundType.gradient
              ? BackgroundUtils.getEventTextColor(event, context)
              : Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => _togglePin(event),
      ),
    ];
  }

  // 切换显示单位
  void _toggleDisplayUnit(Event event) {
    setState(() {
      _event = event.toggleUnit(context);
    });
    
    // 更新到Bloc
    context.read<EventBloc>().add(UpdateEvent(_event));
  }

  // 切换置顶状态
  void _togglePin(Event event) {
    if (event.isPinned) {
      context.read<EventBloc>().add(UnpinEvent(event.id));
    } else {
      context.read<EventBloc>().add(PinEvent(event.id));
    }
    
    setState(() {
      _event = event.copyWith(isPinned: !event.isPinned);
    });
  }

  // 编辑事件
  void _editEvent(Event event) {
    Navigator.push(
      context,
      RouteUtils.buildPageRoute(
        page: EditEventPage(event: event),
      ),
    ).then((value) {
      // 刷新当前事件数据
      final updatedEvent = context.read<EventBloc>().state.events
          .firstWhere((e) => e.id == event.id, orElse: () => event);
      
      setState(() {
        _event = updatedEvent;
      });
    });
  }

  // 删除事件
  void _deleteEvent(Event event) {
    context.read<EventBloc>().add(InitiateEventDelete(event));
    Navigator.of(context).pop();
  }
} 