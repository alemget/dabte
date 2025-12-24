import 'package:flutter/material.dart';
import '../../../../core/data/debt_database.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _footerController = TextEditingController();
  
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DebtDatabase.instance.getProfileInfo();
    if (mounted) {
      setState(() {
        if (data != null) {
          _nameController.text = data['name'] as String? ?? '';
          _phoneController.text = data['phone'] as String? ?? '';
          _addressController.text = data['address'] as String? ?? '';
          _footerController.text = data['footer'] as String? ?? '';
        }
        _loading = false;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await DebtDatabase.instance.saveProfileInfo(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      footer: _footerController.text.trim(),
    );

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم حفظ المعلومات بنجاح'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'المعلومات الشخصية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'هويتك التجارية',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'هذه البيانات ستظهر في جميع التقارير والفواتير التي تشاركها مع العملاء',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Name Field
                      _buildLabel('الاسم التجاري / الشخصي'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('مثال: مؤسسة الأحمد التجارية', Icons.store),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone Field
                      _buildLabel('رقم الهاتف للتواصل'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('مثال: 0555555555', Icons.phone),
                      ),

                      const SizedBox(height: 20),

                      // Address Field
                      _buildLabel('العنوان / الموقع'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration('مثال: الرياض - حي الملز', Icons.location_on),
                      ),

                      const SizedBox(height: 20),

                      // Footer Note Field
                      _buildLabel('رسالة تذييل التقارير'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _footerController,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          'مثال: شكراً لتعاملكم معنا.. نسعد بخدمتكم دائماً',
                          Icons.format_quote_rounded,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                          ),
                          child: const Text(
                            'حفظ التغييرات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }
}
