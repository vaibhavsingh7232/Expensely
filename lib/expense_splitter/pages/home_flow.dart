import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/step1_setup.dart';
import '../widgets/step2_people_input.dart';
import '../widgets/step2_5_select_people.dart';
import '../widgets/step3_result.dart';
import '../app_colors.dart';

class HomeFlow extends StatefulWidget {
  const HomeFlow({super.key});

  @override
  State<HomeFlow> createState() => _HomeFlowState();
}

class _HomeFlowState extends State<HomeFlow> {
  int currentStep = 0;
  int numPeople = 1;
  double totalAmount = 0.0;
  String groupName = '';

  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> amountControllers = [];

  List<String> get names =>
      nameControllers.map((c) => c.text.trim()).toList();

  List<double> get amounts =>
      amountControllers.map((c) => double.tryParse(c.text.trim()) ?? 0).toList();

  Set<int> selectedPeople = {};
  List<(String, String, double)> results = [];

  void calculateResult() {
    final selectedNames = selectedPeople.map((i) => names[i]).toList();
    final selectedAmounts = selectedPeople.map((i) => amounts[i]).toList();

    final equalShare = selectedAmounts.reduce((a, b) => a + b) / selectedNames.length;
    final balances = selectedAmounts.map((amt) => amt - equalShare).toList();

    final creditors = <(int, double)>[];
    final debtors = <(int, double)>[];

    for (var i = 0; i < balances.length; i++) {
      if (balances[i] > 0) creditors.add((i, balances[i]));
      if (balances[i] < 0) debtors.add((i, -balances[i]));
    }

    final transactions = <(String, String, double)>[];
    int di = 0, ci = 0;
    while (di < debtors.length && ci < creditors.length) {
      final (dIdx, debtAmt) = debtors[di];
      final (cIdx, credAmt) = creditors[ci];
      final payment = debtAmt < credAmt ? debtAmt : credAmt;

      transactions.add((
      selectedNames[dIdx],
      selectedNames[cIdx],
      double.parse(payment.toStringAsFixed(2)),
      ));

      debtors[di] = (dIdx, debtAmt - payment);
      creditors[ci] = (cIdx, credAmt - payment);

      if (debtors[di].$2 == 0) di++;
      if (creditors[ci].$2 == 0) ci++;
    }

    results = transactions;
  }

  Future<void> goToStep3() async {
    setState(() => currentStep = 999); // loading
    await Future.delayed(const Duration(milliseconds: 50));

    calculateResult();
    setState(() => currentStep = 3);

    ApiService.saveSplit({
      'groupName': groupName.trim(), // Ensures no trailing/leading spaces
      'people': names,
      'amounts': amounts,
      'selectedIndices': selectedPeople.toList(),
      'transactions': results.map((t) => {
        'from': t.$1,
        'to': t.$2,
        'amount': t.$3,
      }).toList(),
    }).catchError((e) {
      debugPrint("Failed to save split: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Expense Splitter',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_pattern.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(currentStep),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                child: switch (currentStep) {
                  0 => Step1Setup(
                    numPeople: numPeople,
                    totalAmount: totalAmount,
                    onNumPeopleChanged: (val) => setState(() => numPeople = val),
                    onTotalAmountChanged: (val) => setState(() => totalAmount = val),
                    onGroupNameChanged: (val) => setState(() => groupName = val),
                    onNext: () {
                      nameControllers.clear();
                      amountControllers.clear();
                      for (var i = 0; i < numPeople; i++) {
                        nameControllers.add(TextEditingController());
                        amountControllers.add(TextEditingController());
                      }
                      setState(() => currentStep = 1);
                    },
                  ),
                  1 => Step2PeopleInput(
                    numPeople: numPeople,
                    nameControllers: nameControllers,
                    amountControllers: amountControllers,
                    onBack: () => setState(() => currentStep = 0),
                    onSubmit: () {
                      selectedPeople = {
                        for (var i = 0; i < numPeople; i++) i
                      };
                      setState(() => currentStep = 2);
                    },
                  ),
                  2 => Step2_5SelectPeople(
                    names: names,
                    selectedIndices: selectedPeople,
                    onToggle: (i) {
                      setState(() {
                        if (selectedPeople.contains(i)) {
                          selectedPeople.remove(i);
                        } else {
                          selectedPeople.add(i);
                        }
                      });
                    },
                    onBack: () => setState(() => currentStep = 1),
                    onNext: goToStep3,
                  ),
                  3 => Step3Result(
                    groupName: groupName,
                    transactions: results,
                    onBack: () => setState(() => currentStep = 2),
                    onStartOver: () {
                      nameControllers.clear();
                      amountControllers.clear();
                      selectedPeople.clear();
                      results.clear();
                      groupName = '';
                      setState(() {
                        currentStep = 0;
                        numPeople = 1;
                        totalAmount = 0.0;
                      });
                    },
                  ),
                  999 => const Center(
                    child: CircularProgressIndicator(color: purple100),
                  ),
                  _ => const SizedBox(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
