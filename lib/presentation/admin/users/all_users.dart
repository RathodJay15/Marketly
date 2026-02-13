import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
// import 'package:marketly/presentation/admin/users/add_user.dart';
import 'package:marketly/presentation/admin/users/user_details.dart';
import 'package:marketly/providers/admin/admin_user_provider.dart';
import 'package:provider/provider.dart';

class AllUsers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _allUsersState();
}

class _allUsersState extends State<AllUsers> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminUserProvider>().fetchAllUsers());
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
          AppConstants.users,
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
        child: Consumer<AdminUserProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                // if (index == 0) {
                //   return GestureDetector(
                //     onTap: () async {
                //       await Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (_) => AddUser()),
                //       );
                //       // if (result == true) {
                //       //   context.read<AdminUserProvider>().fetchAllUsers();
                //       // }
                //     },
                //     child: Container(
                //       margin: const EdgeInsets.only(bottom: 10),
                //       padding: const EdgeInsets.symmetric(vertical: 20),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         color: Theme.of(context).colorScheme.primary,
                //         border: Border.all(
                //           color: Theme.of(context).colorScheme.onPrimary,
                //         ),
                //       ),
                //       child: Center(
                //         child: Text(
                //           AppConstants.addUser,
                //           style: TextStyle(
                //             color: Theme.of(context).colorScheme.onPrimary,
                //             fontSize: 18,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //     ),
                //   );
                // }
                final user = provider.users[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 25,
                      ),
                    ),
                    title: Text(
                      user!.email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      user.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetails(user: user),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.visibility_outlined),
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
