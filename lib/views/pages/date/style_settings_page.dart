import 'package:flutter/material.dart';
import 'package:remind_me/utils/common/icon_mapping.dart';

class StyleSettingsPage extends StatefulWidget {
  final String title;
  final String dateText;  // 新增：日期文本 (yyyy-MM-dd 周x)
  final String prefix;    // 新增：前缀文本 ("还有"/"已经"等)
  final int absDays;     // 新增：天数
  final String? backgroundType;
  final String? iconName;
  final Function(String?) onBackgroundChanged;
  final Function(String?) onIconChanged;
  
  const StyleSettingsPage({
    super.key,
    required this.title,
    required this.dateText,  // 新增
    required this.prefix,    // 新增
    required this.absDays,   // 新增
    this.backgroundType,
    this.iconName,
    required this.onBackgroundChanged,
    required this.onIconChanged,
  });

  @override
  State<StyleSettingsPage> createState() => _StyleSettingsPageState();
}

class _StyleSettingsPageState extends State<StyleSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedBackground;
  String? _selectedIcon;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedBackground = widget.backgroundType;
    _selectedIcon = widget.iconName;
    _tabController.addListener(() {
      setState(() {});  // 更新背景选项显示
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
  ];

  Widget _buildBackgroundOptions() {
    switch (_tabController.index) {
      case 0:  // 纯色
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _presetColors.length,
          itemBuilder: (context, index) {
            final color = _presetColors[index];
            final isSelected = _selectedBackground == color.value.toRadixString(16);
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedBackground = isSelected ? null : color.value.toRadixString(16);
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
        );
      
      case 1:  // 渐变
        // TODO: 实现渐变背景选项
        return const Center(child: Text('渐变背景选项'));
      
      case 2:  // 图案
        // TODO: 实现图案背景选项
        return const Center(child: Text('图案背景选项'));
      
      case 3:  // 自定义
        return Container(
          height: 120,
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
        );
      
      default:
        return const SizedBox();
    }
  }

  Widget _buildIconOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            setState(() {
              _selectedIcon = isSelected ? null : iconName;
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
                        color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.dateText,
                      style: TextStyle(
                        fontSize: 12,
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
                  color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.absDays}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: hasBackground ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                ' 天',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                    height: 110,  // 减小整体高度
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
                  SizedBox(
                    height: 45,  // 减小高度
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 90,  // 减小宽度
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('字体 ${index + 1}', 
                              style: const TextStyle(fontSize: 13)),
                          ),
                        );
                      },
                    ),
                  ),
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
                  _buildIconOptions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 