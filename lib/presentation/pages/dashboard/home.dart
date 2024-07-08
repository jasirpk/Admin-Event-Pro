import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/favorites.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/home_page.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/profile.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/search.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/vendor.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(),
      SearchPage(),
      ReceiptPage(),
      FavoritePage(),
      ProfilePage(),
    ];
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: myColor,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 400),
        items: <Widget>[
          Icon(
            Icons.home,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.search,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.receipt,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.favorite,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 20,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          context.read<DashboardBloc>().add(TabChanged(index));
        },
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial) {
            return pages[0];
          } else if (state is TabState) {
            return IndexedStack(
              index: state.index,
              children: pages,
            );
          }
          return pages[0];
        },
      ),
    );
  }
}
