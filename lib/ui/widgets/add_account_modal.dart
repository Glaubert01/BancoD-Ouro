import 'package:flutter/material.dart';
import 'package:flutter_banco_douro/models/account.dart';
import 'package:flutter_banco_douro/services/account_service.dart';
import 'package:flutter_banco_douro/ui/styles/colors.dart';
import 'package:uuid/uuid.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  String? _accountType = "AMBROSIA";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width * 1,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.center,
                child: Image.asset("assets/icon_add_account.png"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: const Text(
                  'Adicionar nova conta',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: const Text(
                  "Preencha os dados abaixo:",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(label: Text("Nome")),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        label: Text("Sobrenome"),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Text("Tipo de conta"),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _accountType,
                items: [
                  DropdownMenuItem(value: "AMBROSIA", child: Text("Ambrosia")),
                  DropdownMenuItem(value: "CANJICA", child: Text("Canjica")),
                  DropdownMenuItem(value: "PUDIM", child: Text("Pudim")),
                  DropdownMenuItem(
                    value: "BRIGADEIRO",
                    child: Text("Brigadeiro"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _accountType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (isLoading)
                            ? null
                            : () {
                                onButtonCancelClicked();
                              },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onButtonSendClicked();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColor.orange,
                          ),
                        ),
                        child: (isLoading)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Adicionar",
                                style: TextStyle(color: Colors.black),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onButtonCancelClicked() {
    if (!isLoading) {
      Navigator.pop(context, false);
    }
  }

  onButtonSendClicked() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      String name = _nameController.text;
      String lastName = _lastNameController.text;

      Account account = Account(
        id: Uuid().v4(),
        name: name,
        lastName: lastName,
        balance: 0,
        accountType: _accountType,
      );
      await AccountService().addAccount(account);
      closeModal();
    }
  }

  closeModal() {
    if (mounted) Navigator.pop(context, true);
  }
}
