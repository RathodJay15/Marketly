import 'package:flutter/material.dart';
import 'package:marketly/data/services/auth/auth_service.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _homeScreenState();
}

class _homeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //  keeps state alive in IndexedStack

  int _currenetIndex = 0;

  @override
  void initState() {
    super.initState();

    // API call goes here (pachi)
    // context.read<HomeController>().fetchHomeData();
  }

  void onNavigation(index) {
    setState(() {
      _currenetIndex = index;
    });
  }

  Future<void> onLogout() async {
    await AuthService().logout(); // Firebase session
    context.read<UserProvider>().clearUser(); // App state
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keepAlive

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _navBar(_currenetIndex),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        // pull to refresh API
        // await context.read<HomeController>().fetchHomeData();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildSearchSection(),
          const SizedBox(height: 16),
          _buildSectionTitle("Featured Products"),
          const SizedBox(height: 12),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, Welcome 👋",
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              "Username",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          width: 40,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Search Products',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.filter_alt_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("₹999", style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navBar(currentIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        height: 65,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 40,
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                onNavigation(index);
              },
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.home, size: 20),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.search, size: 20),
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.shopping_cart_outlined, size: 20),
                  ),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.person, size: 20),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
