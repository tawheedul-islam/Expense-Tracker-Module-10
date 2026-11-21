
import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../models/expense.dart';
import '../widgets/expense_item.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Expense> _expenses = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // Load expenses from database
  Future<void> _loadExpenses() async {

    final expenses =
    await DatabaseHelper.instance.getExpenses();

    if (!mounted) return;

    setState(() {
      _expenses = expenses;
      _isLoading = false;
    });
  }

  // Calculate total expenses
  double get _totalExpenses {
    return _expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  // Navigate to Add Expense Screen
  Future<void> _navigateToAddExpense() async {

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    // Reload list after saving
    if (result == true) {
      await _loadExpenses();
    }
  }

  // Delete expense
  Future<void> _deleteExpense(int id) async {

    await DatabaseHelper.instance.deleteExpense(id);

    await _loadExpenses();
  }

  // Confirm before deleting
  Future<void> _confirmDelete(Expense expense) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && expense.id != null) {
      await _deleteExpense(expense.id!);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Column(
        children: [

          // Total Expenses Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  '৳${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Expense List Heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Expense List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _expenses.isEmpty
                ? const Center(
              child: Text(
                'No expenses yet!\nAdd your first expense.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _expenses.length,

              itemBuilder: (context, index) {

                final expense = _expenses[index];

                return ExpenseItem(
                  expense: expense,

                  onDelete: () {
                    _confirmDelete(expense);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
