import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/add_ticket_sheet.dart';
import '../widgets/custom_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final currentRange = ref.read(dateRangeProvider);
    final newRange = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: DateRangePickerDialog(
            initialDateRange: currentRange,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          ),
        ),
      ),
    );

    if (newRange != null) {
      ref.read(dateRangeProvider.notifier).state = newRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(ticketsStreamProvider);
    final filteredTickets = ref.watch(filteredTicketsProvider);
    final hasFilter = ref.watch(dateRangeProvider) != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: ticketsAsync.when(
            data: (tickets) => Text('Local Ticket Stash (${tickets.length})'),
            loading: () => const Text('Local Ticket Stash'),
            error: (_, __) => const Text('Local Ticket Stash'),
          ),
          actions: [
            IconButton(
              icon: Icon(
                hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: hasFilter ? const Color(0xFF2196F3) : null,
              ),
              onPressed: _selectDateRange,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3F2FD), Color(0xFFF5F9FF), Colors.white],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 130),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.blue),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasFilter)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        '${DateFormat('MMM d').format(ref.watch(dateRangeProvider)!.start)} - ${DateFormat('MMM d').format(ref.watch(dateRangeProvider)!.end)}',
                        style: const TextStyle(color: Color(0xFF1565C0)),
                      ),
                      onDeleted: () {
                        ref.read(dateRangeProvider.notifier).state = null;
                      },
                      backgroundColor: const Color(0xFFBBDEFB),
                      deleteIconColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              Expanded(
                child: ticketsAsync.when(
                  data: (allTickets) {
                    if (allTickets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_num_outlined,
                              size: 100,
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets found, \nPlease add your ticket',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[300],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredTickets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 100,
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching ticket found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue[300],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 100),
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = filteredTickets[index];
                        return TicketCard(
                          ticket: ticket,
                          onDelete: () async {
                            final confirmed = await showCupertinoDialog<bool>(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: const Text('Delete Ticket'),
                                content: const Text(
                                  'Are you sure you want to delete this ticket?',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true &&
                                ticket.id != null &&
                                context.mounted) {
                              await ref
                                  .read(ticketActionsProvider.notifier)
                                  .deleteTicket(ticket.id!);
                              if (context.mounted) {
                                CustomSnackBar.showSuccess(
                                  context,
                                  'Ticket deleted successfully',
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTicketSheet(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Ticket'),
        ),
      ),
    );
  }
}
