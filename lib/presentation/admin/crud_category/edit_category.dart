import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/category_model.dart';
import 'package:marketly/providers/admin/admin_categories_provider.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

class EditCategory extends StatefulWidget {
  final CategoryModel category;

  const EditCategory({super.key, required this.category});

  @override
  State<StatefulWidget> createState() => _editCategoryState();
}

class _editCategoryState extends State<EditCategory> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController slugCtrl;
  late bool isActive;

  @override
  void initState() {
    super.initState();

    // Pre-fill existing values
    titleCtrl = TextEditingController(text: widget.category.title);
    slugCtrl = TextEditingController(text: widget.category.slug);
    isActive = widget.category.isActive;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    slugCtrl.dispose();
    super.dispose();
  }

  // ---------------- DELETE ----------------
  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        title: Text(
          '${AppConstants.delete} ${AppConstants.category}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        content: Text(
          AppConstants.areYouSureDeleteCate,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppConstants.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppConstants.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<AdminCategoryProvider>().deleteCategory(
        widget.category.slug,
      );
      await context.read<AdminDashboardProvider>().refreshDashboard();
      Navigator.pop(context, true);
    }
  }

  // ---------------- UPDATE ----------------
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AdminCategoryProvider>().updateCategory(
      oldSlug: widget.category.slug,
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
          '${AppConstants.category} : ${widget.category.title}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onDelete,
            icon: const Icon(Icons.delete_rounded),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
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
                  fontSize: 18,
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
              onPressed: _onSave,
              child: Text(
                AppConstants.updtCategory,
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
