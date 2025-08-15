import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

import '../models/account.dart';
import 'api_key.dart';

class AccountService {
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get streamInfos => _streamController.stream;

  String url = "https://api.github.com/gists/d8d9257dcbb2d40b6ceb9e9c7fbbc944";

  // Obtém todas as contas
  Future<List<Account>> getAll() async {
    Response response = await get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $githubApiKey"},
    );
    _streamController.add("${DateTime.now()} | Requisição de leitura.");

    Map<String, dynamic> mapResponse = json.decode(response.body);

    final files = mapResponse["files"];
    final fileData = files?["accounts.json"];
    final content = fileData?["content"];

    if (content == null) {
      _streamController.add(
        "${DateTime.now()} | Conteúdo do arquivo não encontrado.",
      );
      return [];
    }

    List<dynamic> listDynamic = json.decode(content);
    List<Account> listAccounts = [];

    for (dynamic dyn in listDynamic) {
      try {
        Map<String, dynamic> mapAccount = dyn as Map<String, dynamic>;
        Account account = Account.fromMap(mapAccount);
        listAccounts.add(account);
      } catch (e) {
        _streamController.add("⚠️ Conta inválida ignorada: $dyn");
      }
    }

    return listAccounts;
  }

  // Adiciona nova conta
  Future<void> addAccount(Account account) async {
    List<Account> listAccounts = await getAll();
    listAccounts.add(account);
    await save(listAccounts, accountName: account.name);
  }

  // Salva lista de contas no Gist
  Future<void> save(
    List<Account> listAccounts, {
    String accountName = "",
  }) async {
    List<Map<String, dynamic>> listContent = listAccounts
        .map((account) => account.toMap())
        .toList();

    String content = json.encode(listContent);

    Response response = await patch(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $githubApiKey"},
      body: json.encode({
        "description": "accounts.json",
        "public": true,
        "files": {
          "accounts.json": {"content": content},
        },
      }),
    );

    if (response.statusCode.toString().startsWith("2")) {
      _streamController.add(
        "${DateTime.now()} | Requisição de adição bem-sucedida ($accountName).",
      );
    } else {
      _streamController.add(
        "${DateTime.now()} | Requisição de adição falhou ($accountName).",
      );
    }
  }

  // Fecha o streamController
  void dispose() {
    _streamController.close();
  }
}
