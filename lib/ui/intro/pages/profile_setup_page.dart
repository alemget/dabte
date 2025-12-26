import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../intro_provider.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;

  // Track focus to animate "conversational" response
  final FocusNode _nameFocus = FocusNode();
  bool _showNameResponse = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _companyController = TextEditingController();

    _nameController.addListener(() {
      if (_nameController.text.isNotEmpty && !_showNameResponse) {
        setState(() => _showNameResponse = true);
      } else if (_nameController.text.isEmpty && _showNameResponse) {
        setState(() => _showNameResponse = false);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IntroProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            onChanged: () {
              provider.updateProfile(
                name: _nameController.text,
                company: _companyController.text,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Welcome
                const Text(
                  'أهلاً بك في ديوني ماكس 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().moveY(begin: 20, end: 0, duration: 600.ms),
                const SizedBox(height: 8),
                const Text(
                  'دعنا نتعرف عليك لنخصص التجربة لك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 40),

                // Question 1
                _buildQuestionLabel(
                  'بماذا نتشرف بمناداتك في التقارير والفواتير؟',
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: _modernInputDecoration(
                        'الاسم الكريم',
                        Icons.person_outline_rounded,
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'مطلوب للمتابعة'
                          : null,
                      textInputAction: TextInputAction.next,
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .shimmer(duration: 1.seconds, delay: 1.seconds),

                // Conversational Feedback
                if (_showNameResponse)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'تشرفنا يا ${_nameController.text} ✨',
                      style: const TextStyle(
                        color: Color(0xFF5C6EF8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn().moveX(begin: -10, end: 0),

                const SizedBox(height: 32),

                // Question 2
                _buildQuestionLabel(
                  'هل تدير نشاطاً تجارياً؟ (اختياري)',
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyController,
                  decoration: _modernInputDecoration(
                    'اسم المتجر / الشركة',
                    Icons.store_mall_directory_outlined,
                  ),
                  textInputAction: TextInputAction.done,
                ).animate().fadeIn(delay: 600.ms),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'كتابة الاسم هنا يجعله يظهر في ترويسة التقارير الرسمية',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 48),

                // Question 3 (Backup)
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: provider.isBackupEnabled
                              ? const Color(0xFF5C6EF8)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Color(0xFF5C6EF8),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'حماية البيانات',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'هل نفعل النسخ الاحتياطي التلقائي؟ (يوصى به)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: provider.isBackupEnabled,
                            onChanged: (value) =>
                                provider.setBackupEnabled(value),
                            activeColor: const Color(0xFF5C6EF8),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 48),

                // Final Button
                ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          provider.completeIntro(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B), // Dark Button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: const Color(0xFF1E293B).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'انطلق في رحلة مالية منظمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1.seconds)
                    .shimmer(delay: 2.seconds, duration: 1.5.seconds),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _modernInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5C6EF8), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }
}
