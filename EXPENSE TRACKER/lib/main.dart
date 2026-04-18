 import 'dart:io';

class Transaction {
  String type; // income or expense
  String category;
  double amount;
  DateTime date;

  Transaction(this.type, this.category, this.amount, this.date);

  String toFileString() {
    return "$type|$category|$amount|${date.toIso8601String()}";
  }

  static Transaction fromFileString(String line) {
    var parts = line.split("|");
    return Transaction(
      parts[0],
      parts[1],
      double.parse(parts[2]),
      DateTime.parse(parts[3]),
    );
  }

  @override
  String toString() {
    return "$type | $category | ₹$amount | ${date.toLocal().toString().split(' ')[0]}";
  }
}

class ExpenseTracker {
  List<Transaction> transactions = [];
  final String fileName = "expenses.txt";

  void loadFromFile() {
    File file = File(fileName);
    if (file.existsSync()) {
      var lines = file.readAsLinesSync();
      transactions = lines.map((e) => Transaction.fromFileString(e)).toList();
    }
  }

  void saveToFile() {
    File file = File(fileName);
    var lines = transactions.map((e) => e.toFileString()).toList();
    file.writeAsStringSync(lines.join("\n"));
  }

  void addTransaction() {
    stdout.write("Enter type (income/expense): ");
    String type = stdin.readLineSync()!;

    stdout.write("Enter category (Food, Travel, etc.): ");
    String category = stdin.readLineSync()!;

    stdout.write("Enter amount: ");
    double amount = double.parse(stdin.readLineSync()!);

    transactions.add(Transaction(type, category, amount, DateTime.now()));
    saveToFile();

    print("Transaction added!");
  }

  void viewTransactions() {
    if (transactions.isEmpty) {
      print("No transactions found.");
      return;
    }

    print("\n--- All Transactions ---");
    for (var t in transactions) {
      print(t);
    }
  }

  void monthlySummary() {
    double income = 0;
    double expense = 0;

    var now = DateTime.now();

    for (var t in transactions) {
      if (t.date.month == now.month && t.date.year == now.year) {
        if (t.type.toLowerCase() == "income") {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }

    print("\n--- Monthly Summary ---");
    print("Total Income: ₹$income");
    print("Total Expense: ₹$expense");
    print("Balance: ₹${income - expense}");
  }
}

void main() {
  ExpenseTracker app = ExpenseTracker();
  app.loadFromFile();

  while (true) {
    print("\n==== EXPENSE TRACKER ====");
    print("1. Add Transaction");
    print("2. View Transactions");
    print("3. Monthly Summary");
    print("4. Exit");

    stdout.write("Choose option: ");
    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        app.addTransaction();
        break;
      case 2:
        app.viewTransactions();
        break;
      case 3:
        app.monthlySummary();
        break;
      case 4:
        print("Goodbye!");
        return;
      default:
        print("Invalid option.");
    }
  }
}