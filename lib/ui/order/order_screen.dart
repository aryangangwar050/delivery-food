import 'package:flutter/material.dart';

import '../../utils/color_res.dart';
import '../../utils/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Orders screen with horizontal tabs for statuses and a simple order widget list.
class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  static const String routeName = '/orders';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

enum OrderStatus { all, inProcess, completed, notDelivered }

class Order {
  final String id;
  final OrderStatus status;
  final List<String> items;
  final String customer;
  final String address;
  final String phone;

  Order({required this.id, required this.status, required this.items, required this.customer, required this.address, required this.phone});
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  final List<Order> _orders = [
    Order(id: 'OD001', status: OrderStatus.inProcess, items: ['Maggi', 'Tea'], customer: 'Ravi', address: 'Sector 21', phone: '+919876543210'),
    Order(id: 'OD002', status: OrderStatus.completed, items: ['Biscuits', 'Tea'], customer: 'Sita', address: 'MG Road', phone: '+919812345678'),
    Order(id: 'OD003', status: OrderStatus.notDelivered, items: ['Maggi', 'Biscuit', 'Samosa'], customer: 'Amit', address: 'Lake View', phone: '+919700000001'),
    Order(id: 'OD004', status: OrderStatus.inProcess, items: ['Tea', 'Cookies'], customer: 'Priya', address: 'Park Street', phone: '+919711111111'),
    Order(id: 'OD005', status: OrderStatus.completed, items: ['Maggi'], customer: 'John', address: '5th Avenue', phone: '+919722222222'),
  ];

  late TabController _tabController;
  final List<Map<String, Object>> _tabs = [
    {'label': 'All', 'icon': Icons.list, 'status': OrderStatus.all},
    {'label': 'In-Process', 'icon': Icons.autorenew, 'status': OrderStatus.inProcess},
    {'label': 'Completed', 'icon': Icons.check_circle_outline, 'status': OrderStatus.completed},
    {'label': 'Not Delivered', 'icon': Icons.report_problem, 'status': OrderStatus.notDelivered},
  ];

  bool _tabInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tabInitialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      int initialIndex = 0;
      if (arg is OrderStatus) {
        switch (arg) {
          case OrderStatus.all:
            initialIndex = 0;
            break;
          case OrderStatus.inProcess:
            initialIndex = 1;
            break;
          case OrderStatus.completed:
            initialIndex = 2;
            break;
          case OrderStatus.notDelivered:
            initialIndex = 3;
            break;
        }
      }

      _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
      _tabController.addListener(() {
        if (mounted) setState(() {});
      });
      _tabInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Ensure TabController was initialized in didChangeDependencies
    if (!_tabInitialized) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorRes.primary,
        title: const Text('Orders'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // custom tab row moved out of AppBar
          SizedBox(
            height: SizeConfig.scale(10),
            
          ),
          Container(
            color: ColorRes.primary,
            padding: EdgeInsets.symmetric(vertical: SizeConfig.scale(8), horizontal: SizeConfig.scale(12)),
            margin: EdgeInsets.symmetric(vertical: SizeConfig.scale(8), horizontal: SizeConfig.scale(12)),
            child: Container(
              decoration: BoxDecoration(color: ColorRes.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(SizeConfig.scale(6)),
              child: Stack(
                children: [
                  Row(
                    children: List.generate(_tabs.length, (i) {
                      final tab = _tabs[i];
                      final selected = _tabController.index == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.scale(8)),
                            decoration: BoxDecoration(
                              color: selected ? ColorRes.white.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tab['icon'] as IconData, size: SizeConfig.scale(18), color: selected ? ColorRes.white : ColorRes.white70),
                                SizedBox(height: SizeConfig.scale(6)),
                                Text(tab['label'] as String, style: TextStyle(color: selected ? ColorRes.white : ColorRes.white70, fontSize: SizeConfig.fs(12), fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Animated indicator
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FractionallySizedBox(
                        widthFactor: 1 / _tabs.length,
                        alignment: Alignment((-1.0 + (_tabController.index * 2) / (_tabs.length - 1)), 0.0),
                        child: Container(
                          margin: EdgeInsets.only(top: SizeConfig.scale(48)),
                          height: SizeConfig.scale(4),
                          decoration: BoxDecoration(color: ColorRes.accent, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(OrderStatus.all),
                _buildList(OrderStatus.inProcess),
                _buildList(OrderStatus.completed),
                _buildList(OrderStatus.notDelivered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(OrderStatus status) {
    final filtered = status == OrderStatus.all
        ? _orders
        : _orders.where((o) => o.status == status).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('No orders', style: TextStyle(fontSize: SizeConfig.fs(16))));
    }

    return ListView.separated(
      padding: EdgeInsets.all(SizeConfig.scale(12)),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: SizeConfig.scale(12)),
      itemBuilder: (context, index) {
        final o = filtered[index];
        return _OrderCard(order: o);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({Key? key, required this.order}) : super(key: key);

  IconData _iconForItem(String item) {
    final lower = item.toLowerCase();
    if (lower.contains('tea')) return Icons.local_cafe;
    if (lower.contains('maggi')) return Icons.ramen_dining;
    if (lower.contains('biscuit') || lower.contains('cookies')) return Icons.cookie;
    if (lower.contains('samosa')) return Icons.fastfood;
    return Icons.shopping_bag;
  }

  Future<void> _callNumber(String number, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot place call')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.scale(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.fs(16))),
                _statusChip(order.status),
              ],
            ),
            SizedBox(height: SizeConfig.scale(8)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${order.customer}', style: TextStyle(color: ColorRes.textSecondary)),
                      SizedBox(height: SizeConfig.scale(6)),
                      Text('Address: ${order.address}', style: TextStyle(color: ColorRes.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _callNumber(order.phone, context),
                  icon: const Icon(Icons.call, color: Colors.green),
                )
              ],
            ),
            SizedBox(height: SizeConfig.scale(8)),
            Wrap(
              spacing: SizeConfig.scale(8),
              runSpacing: SizeConfig.scale(6),
              children: order.items.map((it) {
                return Chip(
                  backgroundColor: ColorRes.primaryVariant.withOpacity(0.14),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_iconForItem(it), size: SizeConfig.scale(16), color: ColorRes.primary),
                      SizedBox(width: SizeConfig.scale(6)),
                      Text(it),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(OrderStatus status) {
    String label;
    Color color;
    switch (status) {
      case OrderStatus.inProcess:
        label = 'In-Process';
        color = ColorRes.warning;
        break;
      case OrderStatus.completed:
        label = 'Completed';
        color = ColorRes.success;
        break;
      case OrderStatus.notDelivered:
        label = 'Not Delivered';
        color = ColorRes.blueGrey;
        break;
      default:
        label = 'All';
        color = ColorRes.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.scale(8), vertical: SizeConfig.scale(6)),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: SizeConfig.fs(12))),
    );
  }
}
