// import 'package:admineventpro/common/style.dart';
// import 'package:admineventpro/logic/auth_bloc/manage_bloc.dart';
// import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: myColor,
//         actions: [
//           IconButton(
//             onPressed: () {
//               context.read<ManageBloc>().add(Logout());
//               context.read<ManageBloc>().add(SignOutWithGoogle());
//               context.read<ManageBloc>().add(SignOutWithFacebook());
//             },
//             icon: Icon(Icons.logout),
//           )
//         ],
//       ),
//       body: BlocListener<ManageBloc, ManageState>(
//         listener: (context, state) {
//           if (state is UnAthenticated) {
//             Get.off(() => GoogleAuthScreen());
//           } else if (state is AuthenticatedErrors) {
//             Get.snackbar('Logout Error', state.message,
//                 snackPosition: SnackPosition.BOTTOM);
//           }
//         },
//         child: Center(
//           child: Text('Home Page'),
//         ),
//       ),
//     );
//   }
// }

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
  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    ReceiptPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        animationDuration: Duration(milliseconds: 400),
        items: <Widget>[
          Icon(Icons.home, size: 20),
          Icon(Icons.search, size: 20),
          Icon(Icons.receipt, size: 20),
          Icon(Icons.favorite, size: 20),
          Icon(Icons.person, size: 20)
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
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
