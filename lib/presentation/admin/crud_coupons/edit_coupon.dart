import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/coupon_model.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/admin/admin_coupon_provider.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

class EditCoupon extends StatefulWidget {
  final CouponModel coupon;

  const EditCoupon({super.key, required this.coupon});

  @override
  State<StatefulWidget> createState() => _editCouponState();
}

class _editCouponState extends State<EditCoupon> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController codeCtrl;
  late TextEditingController discountPercentageCtrl;
  late TextEditingController minOrderAmountCtrl;
  late TextEditingController expiriesInDaysCtrl;
  late bool isActive;
  late bool firstOrderOnly;

  @override
  void initState() {
    super.initState();

    //fixed
    DateTime now = DateTime.now();
    DateTime expiry = widget.coupon.expiryDate.toDate();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    int days = expiryDate.difference(today).inDays;
    debugPrint('---------------------------------$expiry');

    // Pre-fill existing values
    codeCtrl = TextEditingController(text: widget.coupon.code);
    discountPercentageCtrl = TextEditingController(
      text: widget.coupon.discountPercentage.toString(),
    );
    minOrderAmountCtrl = TextEditingController(
      text: widget.coupon.minOrderAmount.toString(),
    );
    expiriesInDaysCtrl = TextEditingController(text: days.toString());
    isActive = widget.coupon.isActive;
    firstOrderOnly = widget.coupon.firstOrderOnly;
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    discountPercentageCtrl.dispose();
    minOrderAmountCtrl.dispose();
    expiriesInDaysCtrl.dispose();
    super.dispose();
  }

  // ---------------- DELETE ----------------
  Future<void> _onDelete() async {
    final confirm = await MarketlyDialog.showMyDialog(
      context: context,
      actionN: AppConstants.cancel,
      actionY: AppConstants.delete,
      content: AppConstants.areYouSureDeleteCate,
      title: '${AppConstants.delete} ${AppConstants.category}',
    );

    if (confirm == true) {
      await context.read<AdminCouponProvider>().deleteCategory(
        widget.coupon.code,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.couponDeleted,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await context.read<AdminDashboardProvider>().refreshDashboard();
      Navigator.pop(context, true);
    }
  }

  // ---------------- UPDATE ----------------
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AdminCouponProvider>().updateCoupon(
      oldCode: widget.coupon.code,
      code: codeCtrl.text.toUpperCase().trim(),
      discountPercentage: int.parse(discountPercentageCtrl.text.trim()),
      minOrderAmount: int.parse(minOrderAmountCtrl.text.trim()),
      expiriesInDays: int.parse(expiriesInDaysCtrl.text.trim()),
      isActive: isActive,
      firstOrderOnly: firstOrderOnly,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppConstants.couponUpdated,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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
          icon: const Iconoir(IconoirIcons.navArrowLeft, size: 30),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${AppConstants.couponCode} : ${widget.coupon.code}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onDelete,
            icon: const Iconoir(IconoirIcons.trash),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
      body: _detailsForm(),
    );
  }

  Widget _detailsForm() {
    final couponProvider = context.read<AdminCouponProvider>();
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _label(AppConstants.couponCode),
          _field(
            codeCtrl,
            AppConstants.couponCode,
            Validators.couponCode,
            icon: IconoirIcons.closedCaptions,
            isNum: false,
          ),
          _label(AppConstants.couponDiscount),
          _field(
            discountPercentageCtrl,
            AppConstants.couponDiscount,
            Validators.discount,
            icon: IconoirIcons.percentageRound,
          ),
          _label(AppConstants.minOrderAmount),
          _field(
            minOrderAmountCtrl,
            AppConstants.minOrderAmount,
            Validators.minOrderAmount,
            icon: IconoirIcons.dollar,
          ),
          _label(AppConstants.erpiriesInDay),
          _field(
            expiriesInDaysCtrl,
            AppConstants.enterNoOfDays,
            Validators.discount,
            icon: IconoirIcons.calendar,
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
                activeThumbColor: Theme.of(
                  context,
                ).colorScheme.onInverseSurface,
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

          const SizedBox(height: 20),

          /// First Order Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConstants.firstOrderOnly,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              Switch(
                value: firstOrderOnly,
                activeThumbColor: Theme.of(
                  context,
                ).colorScheme.onInverseSurface,
                inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                onChanged: (value) {
                  setState(() {
                    firstOrderOnly = value;
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
              child: couponProvider.isLoading
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      AppConstants.updtCoupon,
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
    IconoirIcons icon = IconoirIcons.closedCaptions,
    bool isNum = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        textInputAction: TextInputAction.next,
        keyboardType: isNum == true ? TextInputType.number : TextInputType.text,
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
          errorStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
              width: 1,
            ),
          ),
          prefixIcon: SizedBox(
            height: 40,
            width: 40,
            child: Center(
              child: Iconoir(
                icon,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
