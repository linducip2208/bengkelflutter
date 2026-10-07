import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/network/page.dart';
import '../../../shared/widgets/components.dart';

/// List + search (debounce) + pagination + pull-refresh + infinite scroll.
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});
  @override
  ConsumerState<CustomersPage> createState() => _S();
}

class _S extends ConsumerState<CustomersPage> {
  final search = TextEditingController();
  Timer? deb;
  ApiPage<Map<String, dynamic>>? page;
  int cur = 1;
  bool busy = false;
  String? err;

  @override
  void initState() {
    super.initState();
    load(reset: true);
    search.addListener(() {
      deb?.cancel();
      deb = Timer(const Duration(milliseconds: 400), () => load(reset: true));
    });
  }

  Future<void> load({bool reset = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      err = null;
      if (reset) cur = 1;
    });
    try {
      final r = await ref
          .read(genericRemoteProvider)
          .list(
            R.customers,
            query: pagedQuery(page: cur, search: search.text),
          );
      setState(() {
        page = reset
            ? r
            : ApiPage(
                items: [...?page?.items, ...r.items],
                currentPage: r.currentPage,
                lastPage: r.lastPage,
                total: r.total,
                perPage: r.perPage,
              );
        if (!reset) {}
      });
    } catch (e) {
      setState(() => err = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Customers')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: search,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: err != null
              ? AppErrorState(message: err!, onRetry: () => load(reset: true))
              : RefreshIndicator(
                  onRefresh: () => load(reset: true),
                  child: ListView.builder(
                    itemCount: (page?.items.length ?? 0) + 1,
                    itemBuilder: (_, i) {
                      if (i >= (page?.items.length ?? 0)) {
                        if (page != null && page!.hasMore && !busy) {
                          return TextButton(
                            onPressed: () {
                              cur++;
                              load();
                            },
                            child: const Text('Muat lagi'),
                          );
                        }
                        return busy
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      final c = page!.items[i];
                      return AppCard(
                        child: ListTile(
                          title: Text('${c['name'] ?? '-'}'),
                          subtitle: Text(
                            '${c['phone'] ?? ''} • vehicles/invoices di detail',
                          ),
                          onTap: () => appBottomSheet(
                            context,
                            CustomerDetail(id: (c['id'] as num).toInt()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => appBottomSheet(context, const CustomerForm()),
      child: const Icon(Icons.add),
    ),
  );
}

class CustomerDetail extends ConsumerWidget {
  const CustomerDetail({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.watch(genericRemoteProvider).detail(R.customer(id)),
    builder: (_, s) {
      if (s.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      if (s.hasError) return Text('${s.error}');
      return SingleChildScrollView(child: Text('${s.data}'));
    },
  );
}

class CustomerForm extends ConsumerStatefulWidget {
  const CustomerForm({super.key});
  @override
  ConsumerState<CustomerForm> createState() => _F();
}

class _F extends ConsumerState<CustomerForm> {
  final name = TextEditingController();
  final phone = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppInput(controller: name, label: 'Nama'),
      const SizedBox(height: 8),
      AppInput(
        controller: phone,
        label: 'Telepon',
        keyboard: TextInputType.phone,
      ),
      if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 12),
      AppButton(
        label: 'Simpan',
        onPressed: () async {
          try {
            await ref
                .read(apiProvider)
                .dio
                .post(
                  R.customers,
                  data: {'name': name.text, 'phone': phone.text},
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            setState(() => err = '$e');
          }
        },
      ),
    ],
  );
}
