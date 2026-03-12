import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/admin/crud_coupons/add_coupon.dart';
import 'package:marketly/presentation/admin/crud_coupons/edit_coupon.dart';
import 'package:marketly/providers/admin/admin_coupon_provider.dart';
import 'package:provider/provider.dart';

class AllCoupons extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _allCouponsState();
}

class _allCouponsState extends State<AllCoupons> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCouponProvider>().fetchAllCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.coupons,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<AdminCouponProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            if (provider.coupons.isEmpty) {
              return Center(
                child: Text(
                  AppConstants.noCouponsAvailable,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.coupons.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddCoupon()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.addCoupon,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final coupon = provider.coupons[index - 1];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: ListTile(
                    leading: Text(
                      index.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 25,
                      ),
                    ),
                    title: Text(
                      coupon.code,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      coupon.isActive
                          ? AppConstants.active
                          : AppConstants.inActive,
                      style: TextStyle(
                        color: coupon.isActive
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCoupon(coupon: coupon),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.edit),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
