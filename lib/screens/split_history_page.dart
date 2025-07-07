import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_colors.dart';
import '../expense_splitter/pages/home_flow.dart';

class SplitHistoryPage extends StatefulWidget {
  const SplitHistoryPage({super.key});

  @override
  State<SplitHistoryPage> createState() => _SplitHistoryPageState();
}

class _SplitHistoryPageState extends State<SplitHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allSplits = [];
  List<Map<String, dynamic>> _filteredSplits = [];

  @override
  void initState() {
    super.initState();
    fetchSplits();
  }

  Future<void> fetchSplits() async {
    try {
      final res = await http.get(Uri.parse('https://bill-splitting-backend-0lof.onrender.com/api/splits/all')); // Use real IP for devices
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        setState(() {
          _allSplits = List<Map<String, dynamic>>.from(data);
          _filteredSplits = _allSplits;
        });
      } else {
        print("Failed to fetch splits: ${res.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _performSearch(String query) {
    query = query.toLowerCase();
    setState(() {
      _filteredSplits = _allSplits.where((split) {
        final groupName = (split['groupName'] ?? '').toLowerCase();
        final dateStr = (split['createdAt'] ?? '').toString().toLowerCase();
        return groupName.contains(query) || dateStr.contains(query);
      }).toList();
    });
  }

  Widget _buildSplitCard(Map<String, dynamic> split) {
    final date = DateTime.tryParse(split['createdAt'] ?? '') ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy – hh:mm a').format(date);
    final groupName = split['groupName'] ?? 'Unnamed Group';
    final people = (split['people'] as List?)?.length ?? 0;
    final amount = (split['amounts'] as List?)?.fold<double>(
        0, (sum, a) => sum + (a as num).toDouble()) ??
        0.0;
    final transactions = (split['transactions'] as List?) ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      color: purple20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(groupName),
              content: transactions.isEmpty
                  ? const Text("No transactions.")
                  : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: transactions.map((t) {
                  final from = t['from'] ?? '';
                  final to = t['to'] ?? '';
                  final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
                  return Text('• $from owes $to ₹${amt.toStringAsFixed(2)}');
                }).toList(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                groupName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: purple100,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('People: $people'),
                  Text('Total: ₹${amount.toStringAsFixed(2)}'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by group or date...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: _performSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Split History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _filteredSplits.isEmpty
                  ? const Center(child: Text("No splits found."))
                  : ListView.builder(
                itemCount: _filteredSplits.length,
                itemBuilder: (context, index) =>
                    _buildSplitCard(_filteredSplits[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: purple100,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_chart),
            label: "New Split",
            backgroundColor: Colors.green,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeFlow()),
              );
              fetchSplits(); // Refresh after coming back
            },

          ),
        ],
      ),
    );
  }
}
