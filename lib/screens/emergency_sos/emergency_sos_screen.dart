import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';
import '../../widgets/glass_card.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final _settingsBox = Hive.box(AppConstants.settingsBox);

  List<Map<String, String>> _contacts = [];
  String _medicalInfo = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadContacts();
  }

  void _loadContacts() {
    final raw = _settingsBox.get('экстренные контакты', defaultValue: <dynamic>[]);
    _contacts = (raw as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return {
        'name': (map['name'] ?? map['имя'] ?? 'Без имени').toString(),
        'phone': (map['phone'] ?? map['телефон'] ?? '').toString()
      };
    }).toList();
    _medicalInfo = _settingsBox.get('медицинская информация', defaultValue: '');
    setState(() {});
  }

  Future<void> _saveContacts() async {
    await _settingsBox.put(
      'экстренные контакты',
      _contacts.map((c) => {'name': c['name'], 'phone': c['phone']}).toList(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_information),
            onPressed: _showMedicalInfoDialog,
            tooltip: 'Медицинская информация',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SOS button
            _buildSosButton()
                .animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 12),
            Text(
              'Нажмите, чтобы вызвать службу спасения (112)',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // Quick call buttons
            _buildQuickCallRow()
                .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Emergency contacts
            _buildContactsSection()
                .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Medical info card
            if (_medicalInfo.isNotEmpty)
              _buildMedicalInfoCard()
                  .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            if (_medicalInfo.isNotEmpty) const SizedBox(height: 20),

            // Safety tips
            _buildSafetyTips()
                .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _makeCall('112'),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF1744), Color(0xFFD50000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sos_rounded, color: Colors.white, size: 50),
              SizedBox(height: 4),
              Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCallRow() {
    return Row(
      children: [
        Expanded(
          child: _QuickCallCard(
            icon: Icons.local_police_rounded,
            label: 'Полиция',
            number: '102',
            color: const Color(0xFF1565C0),
            onTap: () => _makeCall('102'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCallCard(
            icon: Icons.local_hospital_rounded,
            label: 'Скорая',
            number: '103',
            color: AppColors.error,
            onTap: () => _makeCall('103'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCallCard(
            icon: Icons.fire_truck_rounded,
            label: 'МЧС',
            number: '101',
            color: Colors.orange.shade800,
            onTap: () => _makeCall('101'),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Экстренные контакты',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _showAddContactDialog,
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_contacts.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.contacts_outlined, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'Добавьте контактные данные для быстрого доступа.',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._contacts.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final name = c['name'] ?? 'Без имени';
            final phone = c['phone'] ?? '';
            
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(phone, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  if (phone.isNotEmpty)
                    IconButton(
                      onPressed: () => _makeCall(phone),
                      icon: const Icon(Icons.call, color: AppColors.success),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() => _contacts.removeAt(i));
                      _saveContacts();
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMedicalInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medical_information, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text('Медицинская информация', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(_medicalInfo, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSafetyTips() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Text('Советы по безопасности', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Делитесь своим текущим местоположением с доверенными контактами.',
            'Держите телефон заряженным и сохраните номера экстренных служб.',
            'Узнайте, где находится ближайшая больница.',
            'Доверяйте своей интуиции — если что-то кажется неправильным, уходите.',
            'Держите экстренные контакты на быстром наборе.',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(tip, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _makeCall(String number) async {
    HapticUtils.heavyTap();
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch $uri: $e');
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый контакт'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Номер телефона', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty ? 'Введите номер' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setState(() {
                _contacts.add({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
              });
              _saveContacts();
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showMedicalInfoDialog() {
    final controller = TextEditingController(text: _medicalInfo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Медицинская информация'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Группа крови, аллергии, заболевания, лекарства...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              _medicalInfo = controller.text.trim();
              _settingsBox.put('медицинская информация', _medicalInfo);
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _QuickCallCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color color;
  final VoidCallback onTap;

  const _QuickCallCard({
    required this.icon,
    required this.label,
    required this.number,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            Text(number, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
