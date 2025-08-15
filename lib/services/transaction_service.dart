import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';

import '../exceptions/transaction_exceptions.dart';
import '../helpers/helper_taxes.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import 'account_service.dart';
import 'api_key.dart';

class TransactionService {
  final AccountService _accountService = AccountService();
  final String url =
      "https://api.github.com/gists/d8d9257dcbb2d40b6ceb9e9c7fbbc944";

  Future<void> makeTransaction({
    required String idSender,
    required String idReceiver,
    required double amount,
  }) async {
    List<Account> listAccounts = await _accountService.getAll();

    if (listAccounts.where((acc) => acc.id == idSender).isEmpty) {
      throw SenderNotExistsException();
    }
    if (listAccounts.where((acc) => acc.id == idReceiver).isEmpty) {
      throw ReceiverNotExistsException();
    }

    Account senderAccount = listAccounts.firstWhere(
      (acc) => acc.id == idSender,
    );
    Account receiverAccount = listAccounts.firstWhere(
      (acc) => acc.id == idReceiver,
    );

    double taxes = calculateTaxesByAccount(
      sender: senderAccount,
      amount: amount,
    );

    if (senderAccount.balance < amount + taxes) {
      throw InsufficientFundsException(
        cause: senderAccount,
        amount: amount,
        taxes: taxes,
      );
    }

    // Atualiza os saldos
    senderAccount.balance -= (amount + taxes);
    receiverAccount.balance += amount;

    // Atualiza a lista de contas
    listAccounts[listAccounts.indexWhere((acc) => acc.id == senderAccount.id)] =
        senderAccount;
    listAccounts[listAccounts.indexWhere(
          (acc) => acc.id == receiverAccount.id,
        )] =
        receiverAccount;

    // Cria a transação
    Transaction transaction = Transaction(
      id: (Random().nextInt(89999) + 10000).toString(),
      senderAccountId: senderAccount.id,
      receiverAccountId: receiverAccount.id,
      date: DateTime.now(),
      amount: amount,
      taxes: taxes,
    );

    // Salva alterações
    await _accountService.save(listAccounts);
    await addTransaction(transaction);
  }

  Future<List<Transaction>> getAll() async {
    Response response = await get(Uri.parse(url));

    Map<String, dynamic> mapResponse = json.decode(response.body);
    final files = mapResponse["files"];

    if (files == null || files["transactions.json"] == null) {
      return [];
    }

    final content = files["transactions.json"]["content"];
    if (content == null || content.isEmpty) {
      return [];
    }

    List<Transaction> listTransactions = [];

    try {
      List<dynamic> listDynamic = json.decode(content);

      for (dynamic dyn in listDynamic) {
        try {
          Map<String, dynamic> mapTrans = dyn as Map<String, dynamic>;
          Transaction transaction = Transaction.fromMap(mapTrans);
          listTransactions.add(transaction);
        } catch (e) {
          // Transação inválida ignorada
        }
      }
    } catch (e) {
      // Conteúdo malformado
    }

    return listTransactions;
  }

  Future<void> addTransaction(Transaction trans) async {
    List<Transaction> listTransactions = await getAll();
    listTransactions.add(trans);
    await save(listTransactions);
  }

  Future<void> save(List<Transaction> listTransactions) async {
    List<Map<String, dynamic>> listMaps = listTransactions
        .map((t) => t.toMap())
        .toList();

    String content = json.encode(listMaps);

    await patch(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $githubApiKey"},
      body: json.encode({
        "description": "transactions.json",
        "public": true,
        "files": {
          "transactions.json": {"content": content},
        },
      }),
    );
  }
}
