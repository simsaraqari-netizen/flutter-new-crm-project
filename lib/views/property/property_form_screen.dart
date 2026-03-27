import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/property.dart';
import '../../providers/property_provider.dart';
import '../../services/property_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class PropertyFormScreen extends ConsumerStatefulWidget {
  final Property? property;

  const PropertyFormScreen({super.key, this.property});

  @override
  ConsumerState<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends ConsumerState<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _phoneController;
  late TextEditingController _sellerController;
  late TextEditingController _detailsController;
  late TextEditingController _descriptionController;
  late TextEditingController _sectorController;
  late TextEditingController _blockController;
  late TextEditingController _streetController;
  late TextEditingController _avenueController;
  late TextEditingController _plotController;
  late TextEditingController _houseController;

  String? _selectedPurpose;
  String? _selectedType;
  String? _selectedGovernorate;
  String? _selectedArea;

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleController = TextEditingController(text: p?.title ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '0');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _sellerController = TextEditingController(text: p?.seller ?? '');
    _detailsController = TextEditingController(text: p?.details ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _sectorController = TextEditingController(text: p?.sector ?? '');
    _blockController = TextEditingController(text: p?.block ?? '');
    _streetController = TextEditingController(text: p?.street ?? '');
    _avenueController = TextEditingController(text: p?.avenue ?? '');
    _plotController = TextEditingController(text: p?.plotNumber ?? '');
    _houseController = TextEditingController(text: p?.houseNumber ?? '');
    _selectedPurpose = p?.purpose;
    _selectedType = p?.type;
    _selectedGovernorate = p?.gov;
    _selectedArea = p?.loc;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _sellerController.dispose();
    _detailsController.dispose();
    _descriptionController.dispose();
    _sectorController.dispose();
    _blockController.dispose();
    _streetController.dispose();
    _avenueController.dispose();
    _plotController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0,
      'phone': _phoneController.text.trim(),
      'seller': _sellerController.text.trim(),
      'details': _detailsController.text.trim(),
      'description': _descriptionController.text.trim(),
      'purpose': _selectedPurpose,
      'type': _selectedType,
      'gov': _selectedGovernorate,
      'loc': _selectedArea,
      'sector': _sectorController.text.trim(),
      'block': _blockController.text.trim(),
      'street': _streetController.text.trim(),
      'avenue': _avenueController.text.trim(),
      'plot_number': _plotController.text.trim(),
      'house_number': _houseController.text.trim(),
    };

    try {
      if (_isEditing) {
        await PropertyService.updateProperty(widget.property!.id, data);
      } else {
        final property = Property(
          id: '',
          title: data['title'],
          createdAt: DateTime.now(),
          purpose: data['purpose'],
          type: data['type'],
          gov: data['gov'],
          loc: data['loc'],
          price: data['price'],
          phone: data['phone'],
          seller: data['seller'],
          details: data['details'],
          description: data['description'],
          sector: data['sector'],
          block: data['block'],
          street: data['street'],
          avenue: data['avenue'],
          plotNumber: data['plot_number'],
          houseNumber: data['house_number'],
        );
        await PropertyService.createProperty(property);
      }

      if (mounted) {
        ref.read(propertyListProvider.notifier).refresh();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث العقار' : 'تم إضافة العقار'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل العقار' : 'إضافة عقار'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: const Text('حفظ', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Basic Info Section
            _buildSectionHeader('المعلومات الأساسية'),
            const SizedBox(height: 12),
            _buildTextField(_titleController, 'العنوان', required: true, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown('الغرض', AppConstants.purposes, _selectedPurpose, (v) => setState(() => _selectedPurpose = v))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('النوع', AppConstants.propertyTypes, _selectedType, (v) => setState(() => _selectedType = v))),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(_priceController, 'السعر (د.ك)', keyboardType: TextInputType.number),

            const SizedBox(height: 24),
            _buildSectionHeader('الموقع'),
            const SizedBox(height: 12),
            _buildDropdown(
              'المحافظة',
              AppConstants.governorates.keys.toList(),
              _selectedGovernorate,
              (v) => setState(() {
                _selectedGovernorate = v;
                _selectedArea = null;
              }),
            ),
            const SizedBox(height: 12),
            if (_selectedGovernorate != null)
              _buildDropdown(
                'المنطقة',
                AppConstants.governorates[_selectedGovernorate] ?? [],
                _selectedArea,
                (v) => setState(() => _selectedArea = v),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_sectorController, 'القطاع')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_blockController, 'القطعة')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_streetController, 'الشارع')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_avenueController, 'الجادة')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_plotController, 'رقم القسيمة')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_houseController, 'رقم المنزل')),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('التواصل'),
            const SizedBox(height: 12),
            _buildTextField(_phoneController, 'رقم الهاتف', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(_sellerController, 'اسم البائع'),

            const SizedBox(height: 24),
            _buildSectionHeader('تفاصيل إضافية'),
            const SizedBox(height: 12),
            _buildTextField(_detailsController, 'التفاصيل', maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'الوصف', maxLines: 3),

            const SizedBox(height: 32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isEditing ? 'حفظ التعديلات' : 'إضافة العقار',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppTheme.textMuted)),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppTheme.textMuted)),
      dropdownColor: AppTheme.surfaceElevated,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
