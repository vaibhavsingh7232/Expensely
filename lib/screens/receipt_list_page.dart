import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';

import '../components/custom_app_bar.dart';
import '../components/expense_item_card.dart';
import 'add_update_receipt_page.dart';
import 'extract_page.dart';

//implement a search bar that updates dynamically
class ReceiptListPage extends StatefulWidget {
  static const String id = 'receipt_list_page';

  const ReceiptListPage({super.key});

  @override
  ReceiptListPageState createState() => ReceiptListPageState();
}

class ReceiptListPageState extends State<ReceiptListPage> {
  // Added State Variables for Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  // Inside ReceiptListPageState
  List<Map<String, dynamic>> _searchedReceipts =
      []; // Local list for search results

  String _currencySymbolToDisplay = ' ';

  late VoidCallback _receiptProviderListener;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);

      // Fetch receipts and apply filters initially
      receiptProvider.fetchAllReceipts();
      receiptProvider.applyFilters();

      // Set initial search results
      if (mounted) {
        setState(() {
          _currencySymbolToDisplay = receiptProvider.currencySymbolToDisplay!;
          _searchedReceipts = receiptProvider.filteredReceipts;
        });
      }
    });

    // Add listener to update receipts dynamically
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    _receiptProviderListener = () {
      if (mounted) {
        setState(() {
          _searchedReceipts = receiptProvider.filteredReceipts;
        });
      }
    };

    receiptProvider.addListener(_receiptProviderListener);
  }

  @override
  void dispose() {
    // Remove the listener to prevent calls after dispose
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    receiptProvider.removeListener(_receiptProviderListener);

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Builds each receipt section
  Widget _buildReceiptSection(
    BuildContext context, {
    required String sectionTitle,
    required List<Map<String, dynamic>> receipts,
  }) {
    return receipts.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...receipts.map((receipt) => ExpenseItem(
                    categoryIcon: receipt['categoryIcon'] ?? Icons.category,
                    categoryName: receipt['categoryName'] ?? 'Unknown Category',
                    categoryColor:
                        receipt['categoryColor'] ?? Colors.grey.shade200,
                    merchantName: receipt['merchant'] ?? 'Unknown Merchant',
                    receiptDate: receipt['date'] != null
                        ? DateFormat('MMM d, yyyy')
                            .format((receipt['date'] as Timestamp).toDate())
                        : 'Unknown',
                    currencySymbol: _currencySymbolToDisplay,
                    amount: receipt['amountToDisplay'].toStringAsFixed(2),
                    paymentMethod:
                        receipt['paymentMethod'] ?? 'Unknown Payment Method',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddOrUpdateReceiptPage(
                            existingReceipt: receipt,
                            receiptId: receipt['id'],
                          ),
                        ),
                      ).then((_) {
                        Provider.of<ReceiptProvider>(context, listen: false)
                            .fetchAllReceipts();
                      });
                    },
                  )),
              const SizedBox(height: 16),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: purple80,
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Try adjusting your search and filters to find what you are looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Define filter options with icons
  // Ignore other fields:
  // - id: Unique identifier, not relevant for searching.
  // - imageUrl: Typically contains a URL, not text to match user queries.
  // - categoryId: Internal identifier, not meaningful to users.
  // - categoryColor: A Color object, not searchable by text.
  final List<Map<String, dynamic>> _filterOptions = [
    {
      'key': 'date',
      'label': 'Date',
      'icon': Icons.calendar_month_outlined,
      'isSelected': true
    },
    {
      'key': 'merchant',
      'label': 'Merchant',
      'icon': Icons.store,
      'isSelected': true
    },
    {
      'key': 'amountToDisplay',
      'label': 'Converted Amt',
      'icon': Icons.attach_money,
      'isSelected': true
    },
    {
      'key': 'amount',
      'label': 'Original Amt',
      'icon': Icons.attach_money,
      'isSelected': true
    },
    {
      'key': 'itemName',
      'label': 'Items',
      'icon': Icons.label,
      'isSelected': true
    },
    {
      'key': 'paymentMethod',
      'label': 'Payment',
      'icon': Icons.credit_card,
      'isSelected': true
    },
    {
      'key': 'categoryName',
      'label': 'Category',
      'icon': Icons.category,
      'isSelected': true
    },
    {
      'key': 'description',
      'label': 'Description',
      'icon': Icons.description,
      'isSelected': true
    },
    {
      'key': 'currencyCode',
      'label': 'Currency',
      'icon': Icons.attach_money,
      'isSelected': true
    },
  ];

  Widget _buildSearchBarWithChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors
                .white, // Same background color as the financial report bar
            borderRadius: BorderRadius.circular(8.0), // Same rounded corners
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14), // Adjust padding
          child: Row(
            children: [
              Icon(
                Icons.search,
                color:
                    purple80, // Match the icon color with the report bar text
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(color: purple80), // Optional: hint color
                  ),
                  style: const TextStyle(color: purple80),
                  onChanged: (query) {
                    _performSearch(query); // Call search on each text change
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Chips for Filters in a Single Horizontal Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0), // Add space on the left
            child: Row(
              children: _filterOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Row(
                      children: [
                        if (!option[
                            'isSelected']) // Show both Icon and SizedBox if not selected
                          Row(
                            children: [
                              Icon(
                                option['icon'],
                                size: 18,
                                color: purple200,
                              ),
                              const SizedBox(
                                  width: 8), // Add spacing after the icon
                            ],
                          ),
                        Text(
                          option['label'],
                          style: TextStyle(
                            color: option['isSelected']
                                ? dark25
                                : purple200, // Text color for selected/unselected
                          ),
                        ),
                      ],
                    ),
                    selected: option['isSelected'],
                    selectedColor:
                        purple20, // Background color for selected chip
                    backgroundColor:
                        Colors.grey.shade200, // Background for unselected chip
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: option['isSelected']
                            ? purple40
                            : Colors.grey, // Border color
                        width: 1.5, // Border width
                      ),
                    ),
                    onSelected: (isSelected) {
                      setState(() {
                        option['isSelected'] = isSelected;
                      });
                      _performSearch(_searchController
                          .text); // Trigger search with updated filters
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Method to filter receipts and provide suggestions
  void _performSearch(String query) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    final selectedKeys = _filterOptions
        .where((option) => option['isSelected'])
        .map((option) => option['key'])
        .toList();

    setState(() {
      final lowerCaseQuery = query.toLowerCase();

      // Filter receipts based on selected filters and search query
      _searchedReceipts = receiptProvider.filteredReceipts.where((receipt) {
        return receipt.entries.any((entry) {
          final key = entry.key;
          final value = entry.value;

          // Only process keys that are in selectedKeys
          if (!selectedKeys.contains(key)) return false;

          if ((key == 'amount' || key == 'amountToDisplay') && value is num) {
            return value.toStringAsFixed(2).contains(lowerCaseQuery);
          }

          if (key == 'date' && value is Timestamp) {
            final date = value.toDate();
            final formattedDate =
                "${date.day} ${DateFormat.MMMM().format(date)} ${date.year}";
            return formattedDate.toLowerCase().contains(lowerCaseQuery);
          }

          final stringValue = value?.toString().toLowerCase() ?? '';
          return stringValue.contains(lowerCaseQuery);
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: light90,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBarWithChips(context), // The search bar at the top
            const SizedBox(height: 16), // Add space after the search bar
            Expanded(
              child: Consumer<ReceiptProvider>(
                builder: (context, receiptProvider, _) {
                  if (_searchedReceipts.isEmpty) {
                    return buildNoResultsFound(); // Show "No results" message if empty
                  }

                  // Get the sortOption from ReceiptProvider
                  String sectionTitle = receiptProvider.sortOption;

                  // Display the filtered receipts
                  return ListView(
                    children: [
                      _buildReceiptSection(
                        context,
                        sectionTitle: 'Receipts $sectionTitle',
                        receipts:
                            _searchedReceipts, // Use the local searched list
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add, // Main FAB icon
        activeIcon: Icons.close, // Icon when the menu is expanded
        backgroundColor: purple100,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        activeForegroundColor: Colors.white,
        tooltip: 'Add Entry',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt), // Icon for extracting text
            backgroundColor: Colors.blue,
            label: 'Extract from Image',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // Handle extracting text from image
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExtractPage(),
                  ));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.edit), // Icon for manual input
            backgroundColor: Colors.green,
            label: 'Manual Input',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // Handle manual input
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrUpdateReceiptPage(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
