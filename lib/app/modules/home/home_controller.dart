import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/models/todo_model.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';
import 'package:collection/collection.dart';

class HomeController extends ChangeNotifier {
  final TodosRepository repository;
  DateTime startFilter;
  DateTime endFilter;
  Map<String, List<TodoModel>> listTodos;
  var dateFormat = DateFormat('dd/MM/yyyy');
  var daySelected;

  TodoModel deletedTodo;

  int selectedTab = 1;

  HomeController({@required this.repository}) {
    findAllForWeek();
  }

  Future<void> changeSeletedTab(BuildContext context, int index) async {
    selectedTab = index;
    switch (index) {
      case 0:
        filterFinalized();
        break;
      case 1:
        findAllForWeek();
        break;
      case 2:
        var day = await showDatePicker(
          context: context,
          initialDate: daySelected,
          firstDate: DateTime.now().subtract(Duration(days: (365 * 3))),
          lastDate: DateTime.now().add(Duration(days: (365 * 10))),
        );

        if (day != null) {
          daySelected = day;
          findTodoBySelectedDay();
        }
        break;
    }
    notifyListeners();
  }

  Future<void> findAllForWeek() async {
    daySelected = DateTime.now();
    startFilter = DateTime.now();

    if (startFilter.weekday != DateTime.monday) {
      startFilter = startFilter.subtract(Duration(days: startFilter.weekday - 1));
    }

    endFilter = startFilter.add(Duration(days: 6));

    var todos = await repository.findByPeriod(startFilter, endFilter);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(DateTime.now()): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }
    notifyListeners();
  }

  void checkOrUncheck(TodoModel todo) {
    todo.finalizado = !todo.finalizado;
    repository.checkOrUncheck(todo);
    this.notifyListeners();
  }

  void filterFinalized() {
    listTodos = listTodos.map((key, value) {
      var todosFinalizeds = value.where((e) => e.finalizado).toList();
      return MapEntry(key, todosFinalizeds);
    });
    notifyListeners();
  }

  Future<void> findTodoBySelectedDay() async {
    var todos = await repository.findByPeriod(daySelected, daySelected);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(daySelected): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    notifyListeners();
  }

  Future<void> update() async {
    if (selectedTab == 1) {
      await this.findAllForWeek();
    } else if (selectedTab == 2) {
      await this.findTodoBySelectedDay();
    }
  }

  Future<void> delete(TodoModel todo) async {
    deletedTodo = todo;
    await repository.deleteTodo(todo);
  }

  Future<void> restore() async {
    await repository.SaveTodo(deletedTodo.dataHora, deletedTodo.descricao);
    this.update();
  }
}
