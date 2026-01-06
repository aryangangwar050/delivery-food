import 'package:flutter/material.dart';

import '../../widgets/custom_dialog_box.dart';
import '../../utils/color_res.dart';
import '../../utils/size_config.dart';
import '../order/order_screen.dart';

/// Home screen with drawer, notification badge and four animated tiles.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AnimationController _controller;
  late final List<Animation<double>> _tileAnimations;

  int _notificationCount = 3; // example count; replace with real data

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Staggered animations for 4 tiles
    _tileAnimations = List.generate(4, (i) {
      final start = i * 0.12;
      final end = start + 0.6;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutBack),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // _onTileTap was removed in favor of direct navigation from tiles.

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.scale(12.0)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // open notifications screen or panel
                    setState(() {
                      _notificationCount = 0; // mark read for demo
                    });
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: SizeConfig.scale(6),
                    top: SizeConfig.scale(8),
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.scale(4)),
                      decoration: BoxDecoration(
                        color: ColorRes.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorRes.white, width: SizeConfig.scale(1.5)),
                      ),
                      constraints: BoxConstraints(minWidth: SizeConfig.scale(20), minHeight: SizeConfig.scale(20)),
                      child: Center(
                        child: Text(
                          '$_notificationCount',
                          style: TextStyle(color: ColorRes.white, fontSize: SizeConfig.fs(11), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: ColorRes.primary,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: SizeConfig.scale(28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: SizeConfig.scale(36),
                    backgroundColor: ColorRes.white.withOpacity(0.12),
                    child: Icon(Icons.person, size: SizeConfig.scale(40), color: ColorRes.white),
                  ),
                  SizedBox(height: SizeConfig.scale(12)),
                  Text('Driver Name', style: TextStyle(color: ColorRes.white, fontWeight: FontWeight.bold, fontSize: SizeConfig.fs(16))),
                  SizedBox(height: SizeConfig.scale(4)),
                  Text('+91 98765 43210', style: TextStyle(color: ColorRes.white70)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Orders'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/orders');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profile'),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final confirmed = await showCustomDialog(
                        context,
                        title: 'Confirm Logout',
                        description: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                        cancelText: 'Cancel',
                      );
                      if (confirmed == true) {
                        // Perform logout: clear state, navigate to login and remove back stack
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.scale(12.0)),
        child: Column(
          children: [
            // (Removed quick navigation buttons by request.) The grid tiles below
            // now navigate to the Orders screen with the matching initial tab.
            // Grid of four animated containers
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: List.generate(4, (i) {
                  final data = _tileData(i);
                  return ScaleTransition(
                      scale: _tileAnimations[i],
                      child: GestureDetector(
                        onTap: () {
                          // Map the grid tile index to the OrderStatus and navigate to Orders
                          OrderStatus status;
                          switch (i) {
                            case 0:
                              status = OrderStatus.all;
                              break;
                            case 1:
                              status = OrderStatus.inProcess;
                              break;
                            case 2:
                              status = OrderStatus.completed;
                              break;
                            default:
                              status = OrderStatus.notDelivered;
                          }
                          Navigator.of(context).pushNamed(OrderScreen.routeName, arguments: status);
                        },
                      child: Container(
                        decoration: BoxDecoration(
                          color: data['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: EdgeInsets.all(SizeConfig.scale(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(data['icon'] as IconData, size: SizeConfig.scale(36), color: ColorRes.white),
                                Icon(Icons.more_vert, color: ColorRes.white70),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              data['title'] as String,
                              style: TextStyle(color: ColorRes.white, fontSize: SizeConfig.fs(16), fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: SizeConfig.scale(6)),
                            Text(
                              data['subtitle'] as String,
                              style: TextStyle(color: ColorRes.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Object> _tileData(int index) {
    switch (index) {
      case 0:
        return {
          'title': 'All',
          'subtitle': 'View all orders',
          'icon': Icons.list,
          'color': ColorRes.primary,
        };
      case 1:
        return {
          'title': 'In-Process',
          'subtitle': '3 pending',
          'icon': Icons.autorenew,
          'color': ColorRes.warning,
        };
      case 2:
        return {
          'title': 'Completed',
          'subtitle': '24 done',
          'icon': Icons.check_circle_outline,
          'color': ColorRes.success,
        };
      default:
        return {
          'title': 'Not Delivered',
          'subtitle': '2 issues',
          'icon': Icons.report_problem,
          'color': ColorRes.blueGrey,
        };
    }
  }
}
