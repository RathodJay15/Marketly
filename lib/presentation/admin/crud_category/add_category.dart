import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/providers/admin/admin_categories_provider.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _addCategoryState();
}

class _addCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController slugCtrl = TextEditingController();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    slugCtrl.dispose();
    super.dispose();
  }

  // ---------------- Add ----------------
  Future<void> _onAdd() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AdminCategoryProvider>().addCategory(
      title: titleCtrl.text.trim(),
      slug: slugCtrl.text.trim(),
      isActive: isActive,
    );
    await context.read<AdminDashboardProvider>().refreshDashboard();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.addCategory,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _detailsForm(),
    );
  }

  Widget _detailsForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _label(AppConstants.title),
          _field(
            titleCtrl,
            AppConstants.title,
            Validators.title,
            icon: Icons.title_rounded,
          ),
          _label(AppConstants.slug),
          _field(
            slugCtrl,
            AppConstants.slug,
            Validators.slug,
            icon: Icons.text_fields_rounded,
          ),
          const SizedBox(height: 20),

          /// Active Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConstants.activeStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              Switch(
                value: isActive,
                activeColor: Theme.of(context).colorScheme.onInverseSurface,
                inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _onAdd,
              child: Text(
                AppConstants.addCategory,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    IconData icon = Icons.text_fields_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
