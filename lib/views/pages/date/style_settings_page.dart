import 'package:flutter/material.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class StyleSettingsPage extends StatefulWidget {
  final String title;
  final String dateText;  // 新增：日期文本 (yyyy-MM-dd 周x)
  final String prefix;    // 新增：前缀文本 ("还有"/"已经"等)
  final int absDays;     // 新增：天数
  final String? backgroundType;
  final String? iconName;
  final String? fontFamily;
  final Function(String?) onBackgroundChanged;
  final Function(String?) onIconChanged;
  final Function(String?)? onFontFamilyChanged;
  
  const StyleSettingsPage({
    super.key,
    required this.title,
    required this.dateText,  // 新增
    required this.prefix,    // 新增
    required this.absDays,   // 新增
    this.backgroundType,
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
  String? _selectedBackground;
  String? _selectedIcon;
  String? _selectedFontFamily;
  
  // 定义背景选项区域的固定高度
  static const double _backgroundOptionsHeight = 120.0; // 适合显示2行色块
  
  // 定义字体选项区域的固定高度
  static const double _fontOptionsHeight = 50.0; // 减小高度
  
  // 定义图标选项区域的固定高度
  static const double _iconOptionsHeight = 150.0; // 适合显示3行图标
  
  // 预设的背景色列表
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    // 新添加的预设颜色
    const Color(0xFFFF0000), // Material Red 500
    const Color(0xFF4CAF50), // Material Green 500
    const Color(0xFF00FFFF), // Material Cyan 500
    const Color(0xFF3F51B5), // Material Indigo 500
    const Color(0xFF607D8B), // Material Blue Grey 500
    const Color(0xFFFFC107), // Material Amber 500
    const Color(0xFFFF9800), // Material Orange 500
    const Color(0xFFFF5722), // Material Deep Orange 500
    const Color(0xFF795548), // Material Brown 500
    const Color(0xFF9C27B0), // Material Purple 500
    const Color(0xFFFFEB3B), // Material Yellow 500
    const Color(0xFF00BCD4), // Material Cyan 500
  ];
  
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
    _selectedBackground = widget.backgroundType;
    _selectedIcon = widget.iconName;
    _selectedFontFamily = widget.fontFamily;
    _tabController.addListener(() {
      setState(() {});  // 更新背景选项显示
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBackgroundOptions() {
    switch (_tabController.index) {
      case 0:  // 纯色
        const int crossAxisCount = 6; // 每行6个
        const double spacing = 8.0;   // 间距
        
        // 使用固定高度的Container包裹GridView，并允许GridView滚动
        return SizedBox(
          height: _backgroundOptionsHeight,
          child: GridView.builder(
            // 不使用shrinkWrap，允许内容超出并滚动
            physics: const BouncingScrollPhysics(), // 允许滚动
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: _presetColors.length,
            itemBuilder: (context, index) {
              final color = _presetColors[index];
              final isSelected = _selectedBackground == color.value.toRadixString(16);
              
              return InkWell(
                onTap: () {
                  final newBackground = isSelected ? null : color.value.toRadixString(16);
                  LoggerUtils.i('背景色变更: 从 $_selectedBackground 变为 $newBackground', 'StyleSettingsPage');
                  setState(() {
                    _selectedBackground = newBackground;
                  });
                  widget.onBackgroundChanged(_selectedBackground);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                    boxShadow: isSelected 
                      ? [BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )]
                      : null,
                  ),
                ),
              );
            },
          ),
        );
      
      case 1:  // 渐变
        // 使用相同高度的容器
        return const SizedBox(
          height: _backgroundOptionsHeight,
          child: Center(
            child: Text('渐变背景选项'),
          ),
        );
      
      case 2:  // 图案
        // 使用相同高度的容器
        return const SizedBox(
          height: _backgroundOptionsHeight,
          child: Center(
            child: Text('图案背景选项'),
          ),
        );
      
      case 3:  // 自定义
        // 使用相同高度的容器
        return SizedBox(
          height: _backgroundOptionsHeight,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40),
                  SizedBox(height: 8),
                  Text('点击上传图片'),
                ],
              ),
            ),
          ),
        );
      
      default:
        return const SizedBox(height: _backgroundOptionsHeight);
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
    final hasBackground = _selectedBackground != null && _selectedBackground!.isNotEmpty;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: hasBackground
            ? Color(int.parse(_selectedBackground!, radix: 16))
            : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
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
                    color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
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
                        // 不实际应用字体，只是为了演示
                        color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.dateText,
                      style: TextStyle(
                        fontSize: 12,
                        // 不实际应用字体，只是为了演示
                        color: hasBackground
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.prefix,
                style: TextStyle(
                  fontSize: 16,
                  // 不实际应用字体，只是为了演示
                  color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.absDays}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  // 不实际应用字体，只是为了演示
                  color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                ' 天',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  // 不实际应用字体，只是为了演示
                  color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
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