import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';

class NewTaskController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat("dd/MM/yyyy");
  final TodosRepository repository;
  DateTime daySelected;
  var nameTaskController = TextEditingController();

  bool saved = false;
  bool loading = false;

  String error;

  String get dayFormated => dateFormat.format(daySelected);

  NewTaskController({@required String day, @required this.repository}) {
    daySelected = dateFormat.parse(day);
  }

  Future<void> save() async {
    try {
      if (formKey.currentState.validate()) {
        loading = true;
        saved = false;
        await repository.SaveTodo(daySelected, nameTaskController.text);
        loading = false;
        saved = true;
      }
    } catch (e) {
      error = "Erro ao salvar ToDo";
      print(e);
    }
    notifyListeners();
  }
}
