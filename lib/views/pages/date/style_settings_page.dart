import 'package:flutter/material.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/theme/app_colors.dart';
import 'package:remind_me/models/event.dart';
import 'package:collection/collection.dart';
import 'package:remind_me/utils/ui/background_utils.dart';

class StyleSettingsPage extends StatefulWidget {
  final String title;
  final String dateText;  // 新增：日期文本 (yyyy-MM-dd 周x)
  final String prefix;    // 新增：前缀文本 ("还有"/"已经"等)
  final int absDays;     // 新增：天数
  final BackgroundType? backgroundType;
  final int? backgroundColorValue;
  final List<int>? gradientColorValues;
  final String? localImagePath;
  final String? animationType;
  final String? iconName;
  final String? fontFamily;
  final Function(BackgroundType?, int?, List<int>?, String?, String?) onBackgroundChanged;
  final Function(String?) onIconChanged;
  final Function(String?)? onFontFamilyChanged;
  
  const StyleSettingsPage({
    super.key,
    required this.title,
    required this.dateText,  // 新增
    required this.prefix,    // 新增
    required this.absDays,   // 新增
    this.backgroundType,
    this.backgroundColorValue,
    this.gradientColorValues,
    this.localImagePath,
    this.animationType,
    this.iconName,
    this.fontFamily,
    required this.onBackgroundChanged,
    required this.onIconChanged,
    this.onFontFamilyChanged,
  });

  @override
  State<StyleSettingsPage> createState() => _StyleSettingsPageState();
}

class _StyleSettingsPageState extends State<StyleSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BackgroundType? _selectedBackgroundType;
  int? _selectedBackgroundColor;
  List<int>? _selectedGradientColors;
  String? _selectedLocalImagePath;
  String? _selectedAnimationType;
  String? _selectedIcon;
  String? _selectedFontFamily;
  
  // 用于比较列表是否相等
  final _listEquals = const ListEquality().equals;
  
  // 定义背景选项区域的固定高度
  static const double _backgroundOptionsHeight = 120.0;
  
  // 定义字体选项区域的固定高度
  static const double _fontOptionsHeight = 50.0;
  
  // 定义图标选项区域的固定高度
  static const double _iconOptionsHeight = 150.0;
  
  // 预设字体列表
  final List<Map<String, dynamic>> _fontOptions = [
    {'name': '默认', 'fontFamily': null},
    {'name': '思源黑体', 'fontFamily': 'SourceHanSans'},
    {'name': '思源宋体', 'fontFamily': 'SourceHanSerif'},
    {'name': '站酷高端黑', 'fontFamily': 'ZCOOLKuaiLe'},
    {'name': '站酷快乐体', 'fontFamily': 'ZCOOLQingKeHuangYou'},
    {'name': '霞鹜文楷', 'fontFamily': 'LXGWWenKai'},
    {'name': '阿里巴巴普惠体', 'fontFamily': 'AlibabaPuHuiTi'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedBackgroundType = widget.backgroundType;
    _selectedBackgroundColor = widget.backgroundColorValue;
    _selectedGradientColors = widget.gradientColorValues;
    _selectedLocalImagePath = widget.localImagePath;
    _selectedAnimationType = widget.animationType;
    _selectedIcon = widget.iconName;
    _selectedFontFamily = widget.fontFamily;
    
    // 根据初始背景类型设置选中的选项卡
    if (widget.backgroundType != null) {
      switch (widget.backgroundType) {
        case BackgroundType.color:
          _tabController.index = 0;
          break;
        case BackgroundType.gradient:
          _tabController.index = 1;
          break;
        case BackgroundType.image:
          _tabController.index = 2;
          break;
        case BackgroundType.animation:
          _tabController.index = 3;
          break;
        default:
          _tabController.index = 0;
      }
    }
    
    _tabController.addListener(() {
      setState(() {});  // 更新背景选项显示
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 构建颜色选择网格的通用方法
  Widget _buildColorGrid({
    required List<dynamic> colors,
    required BackgroundType type,
    required bool Function(dynamic color) isSelected,
    required void Function(dynamic color) onSelected,
  }) {
    const int crossAxisCount = 6; // 每行6个
    const double spacing = 8.0;   // 间距
    
    return SizedBox(
      height: _backgroundOptionsHeight,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1.0,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final selected = isSelected(color);
          
          // 构建颜色项的装饰
          BoxDecoration decoration;
          if (type == BackgroundType.color) {
            // 纯色背景
            decoration = BoxDecoration(
              color: color as Color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            );
          } else if (type == BackgroundType.gradient) {
            // 渐变背景
            final gradientColors = color as List<Color>;
            decoration = BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            );
          } else {
            // 默认装饰
            decoration = BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            );
          }
          
          return InkWell(
            onTap: () => onSelected(color),
            child: Container(
              decoration: decoration,
              child: selected ? const Icon(Icons.check, color: Colors.white) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundOptions() {
    switch (_tabController.index) {
      case 0:  // 纯色
        return _buildColorGrid(
          colors: AppColors.presetColors,
          type: BackgroundType.color,
          isSelected: (color) {
            return _selectedBackgroundType == BackgroundType.color && 
                   _selectedBackgroundColor == (color as Color).value;
          },
          onSelected: (color) {
            setState(() {
              if (_selectedBackgroundType == BackgroundType.color && 
                  _selectedBackgroundColor == (color as Color).value) {
                // 如果已经选中，则取消选择
                _selectedBackgroundType = null;
                _selectedBackgroundColor = null;
              } else {
                // 否则选中该颜色
                _selectedBackgroundType = BackgroundType.color;
                _selectedBackgroundColor = (color as Color).value;
                // 清除其他背景类型的选择
                _selectedGradientColors = null;
                _selectedLocalImagePath = null;
                _selectedAnimationType = null;
              }
            });
            
            // 通知父组件背景已更改
            widget.onBackgroundChanged(
              _selectedBackgroundType,
              _selectedBackgroundColor,
              _selectedGradientColors,
              _selectedLocalImagePath,
              _selectedAnimationType,
            );
          },
        );
        
      case 1:  // 渐变
        return _buildColorGrid(
          colors: AppColors.presetGradients,
          type: BackgroundType.gradient,
          isSelected: (color) {
            if (_selectedBackgroundType != BackgroundType.gradient || 
                _selectedGradientColors == null) {
              return false;
            }
            
            final gradientColors = (color as List<Color>).map((c) => c.value).toList();
            if (_selectedGradientColors!.length != gradientColors.length) {
              return false;
            }
            
            // 比较两个列表是否包含相同的颜色值
            return _listEquals(_selectedGradientColors!, gradientColors);
          },
          onSelected: (color) {
            final gradientColors = (color as List<Color>).map((c) => c.value).toList();
            
            setState(() {
              if (_selectedBackgroundType == BackgroundType.gradient && 
                  _selectedGradientColors != null && 
                  _listEquals(_selectedGradientColors!, gradientColors)) {
                // 如果已经选中，则取消选择
                _selectedBackgroundType = null;
                _selectedGradientColors = null;
              } else {
                // 否则选中该渐变
                _selectedBackgroundType = BackgroundType.gradient;
                _selectedGradientColors = gradientColors;
                // 清除其他背景类型的选择
                _selectedBackgroundColor = null;
                _selectedLocalImagePath = null;
                _selectedAnimationType = null;
              }
            });
            
            // 通知父组件背景已更改
            widget.onBackgroundChanged(
              _selectedBackgroundType,
              _selectedBackgroundColor,
              _selectedGradientColors,
              _selectedLocalImagePath,
              _selectedAnimationType,
            );
          },
        );
        
      case 2:  // 图案（暂未实现）
        return Container(
          height: _backgroundOptionsHeight,
          alignment: Alignment.center,
          child: const Text('图案背景功能即将推出'),
        );
        
      case 3:  // 自定义（暂未实现）
        return Container(
          height: _backgroundOptionsHeight,
          alignment: Alignment.center,
          child: const Text('自定义背景功能即将推出'),
        );
        
      default:
        return Container();
    }
  }

  Widget _buildFontOptions() {
    return SizedBox(
      height: _fontOptionsHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _fontOptions.length,
        itemBuilder: (context, index) {
          final font = _fontOptions[index];
          final isSelected = _selectedFontFamily == font['fontFamily'];
          
          return InkWell( // 添加 InkWell 包裹
            onTap: () {
              final newFont = isSelected ? null : font['fontFamily'];
              LoggerUtils.i('字体变更: 从 $_selectedFontFamily 变为 $newFont', 'StyleSettingsPage');
              setState(() {
                _selectedFontFamily = newFont;
              });
              // 检查 widget 是否有 onFontFamilyChanged 回调
              if (widget.onFontFamilyChanged != null) {
                widget.onFontFamilyChanged!(_selectedFontFamily);
              }
            },
            child: Container(
              width: 80, // 减小宽度
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              ),
              child: Center(
                child: Text(
                  font['name'],
                  style: TextStyle(
                    fontSize: 12, // 减小字体大小
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconOptions() {
    return SizedBox(
      height: _iconOptionsHeight, // 使用固定高度
      child: GridView.builder(
        physics: const BouncingScrollPhysics(), // 允许滚动
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: EventIconMapping.icons.length,
        itemBuilder: (context, index) {
          final iconName = EventIconMapping.icons.keys.elementAt(index);
          final icon = EventIconMapping.icons[iconName]!;
          final isSelected = _selectedIcon == iconName;
          
          return InkWell(
            onTap: () {
              final newIcon = isSelected ? null : iconName;
              LoggerUtils.i('图标变更: 从 $_selectedIcon 变为 $newIcon', 'StyleSettingsPage');
              setState(() {
                _selectedIcon = newIcon;
              });
              widget.onIconChanged(_selectedIcon);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard() {
    final defaultColor = Theme.of(context).colorScheme.surface;
    
    final decoration = BackgroundUtils.buildBackgroundDecoration(
      backgroundType: _selectedBackgroundType ?? BackgroundType.color,
      backgroundColor: _selectedBackgroundColor != null 
          ? Color(_selectedBackgroundColor!) 
          : null,
      gradientColors: _selectedGradientColors?.map((c) => Color(c)).toList(),
      localImagePath: _selectedLocalImagePath,
      defaultColor: defaultColor,
    );
    
    final defaultDarkColor = Theme.of(context).colorScheme.onSurface;
    const defaultLightColor = Colors.white;
    
    final textColor = BackgroundUtils.getTextColor(
      backgroundType: _selectedBackgroundType ?? BackgroundType.color,
      backgroundColor: _selectedBackgroundColor != null 
          ? Color(_selectedBackgroundColor!) 
          : null,
      gradientColors: _selectedGradientColors?.map((c) => Color(c)).toList(),
      lightTextColor: defaultLightColor,
      darkTextColor: defaultDarkColor,
    );
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(12),
      child: Container(
        decoration: decoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_selectedIcon != null && _selectedIcon!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    EventIconMapping.getIcon(_selectedIcon!),
                    size: 20,
                    color: textColor,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: _selectedFontFamily,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.dateText,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.prefix,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: _selectedFontFamily,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (widget.prefix == '就是')
                    Text(
                      '今天',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: _selectedFontFamily,
                        color: textColor,
                      ),
                    )
                  else
                    Text(
                      '${widget.absDays}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: _selectedFontFamily,
                        color: textColor,
                      ),
                    ),
                  if (widget.prefix != '就是')
                    Text(
                      ' 天',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: _selectedFontFamily,
                        color: textColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('样式设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 预览区域
            _buildPreviewCard(),

            // 背景设置
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('背景', style: TextStyle(fontSize: 14)),
                  TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 13),
                    tabs: const [
                      Tab(text: '纯色'),
                      Tab(text: '渐变'),
                      Tab(text: '图案'),
                      Tab(text: '自定义'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    child: _buildBackgroundOptions(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 字体设置
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('字体', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildFontOptions(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 图标设置
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('图标', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildIconOptions(), // 使用修改后的图标选项
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 