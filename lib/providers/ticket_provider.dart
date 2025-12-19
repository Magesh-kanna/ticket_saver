import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/ticket.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

final ticketsStreamProvider = StreamProvider<List<Ticket>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  // Initial fetch to populate the stream
  dbHelper.refreshTickets();
  return dbHelper.ticketsStream;
});

class TicketNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addTicket(Ticket ticket) async {
    final dbHelper = ref.read(databaseHelperProvider);
    await dbHelper.insertTicket(ticket);
  }

  Future<void> deleteTicket(int id) async {
    final dbHelper = ref.read(databaseHelperProvider);
    await dbHelper.deleteTicket(id);
  }
}

final ticketActionsProvider = NotifierProvider<TicketNotifier, void>(
  TicketNotifier.new,
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final filteredTicketsProvider = Provider<List<Ticket>>((ref) {
  final ticketsAsync = ref.watch(ticketsStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final range = ref.watch(dateRangeProvider);

  return ticketsAsync.maybeWhen(
    data: (tickets) {
      return tickets.where((ticket) {
        final matchesQuery =
            ticket.trainName.toLowerCase().contains(query) ||
            ticket.fromStation.toLowerCase().contains(query) ||
            ticket.toStation.toLowerCase().contains(query);

        final matchesDate =
            range == null ||
            (ticket.travelDate.isAfter(
                  range.start.subtract(const Duration(days: 1)),
                ) &&
                ticket.travelDate.isBefore(
                  range.end.add(const Duration(days: 1)),
                ));

        return matchesQuery && matchesDate;
      }).toList();
    },
    orElse: () => [],
  );
});
