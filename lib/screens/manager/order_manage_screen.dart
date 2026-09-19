import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class OrderManageScreen extends StatefulWidget {
  const OrderManageScreen({super.key});
  @override
  State<OrderManageScreen> createState() => _OrderManageScreenState();
}

class _OrderManageScreenState extends State<OrderManageScreen> {
  List<Order>? _orders;
  String? _error;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _orders = null;
      _error = null;
    });
    try {
      final list = await context
          .read<OrderRepository>()
          .findAll(status: _statusFilter, perPage: 100);
      if (mounted) {
        setState(() => _orders = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Ошибка загрузки');
      }
    }
  }

  Future<void> _changeStatus(Order o, String newStatus) async {
    try {
      await context.read<OrderRepository>().update(Order(
            id: o.id,
            userId: o.userId,
            status: newStatus,
            total: o.total,
            address: o.address,
          ));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_error != null) {
      body = ErrorView(message: _error!, onRetry: _load);
    } else if (_orders == null) {
      body = const LoadingView();
    } else if (_orders!.isEmpty) {
      body = const EmptyView(message: 'Заказов нет');
    } else {
      body = ListView.separated(
        itemCount: _orders!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final o = _orders![i];
          return ListTile(
            title: Text(
              'Заказ №${o.id?.substring(0, 6)} · ${o.total.toStringAsFixed(0)} ₽',
            ),
            subtitle: Text('${o.userName} · ${o.address}'),
            trailing: DropdownButton<String>(
              value: o.status,
              items: Order.statuses
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(Order.statusLabels[s] ?? s),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  _changeStatus(o, v);
                }
              },
            ),
          );
        },
      );
    }

    return AppScaffold(
      currentPath: '/manager/orders',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _statusFilter == null,
                  onSelected: (_) {
                    setState(() => _statusFilter = null);
                    _load();
                  },
                ),
                for (final s in Order.statuses)
                  ChoiceChip(
                    label: Text(Order.statusLabels[s] ?? s),
                    selected: _statusFilter == s,
                    onSelected: (_) {
                      setState(() => _statusFilter = s);
                      _load();
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}