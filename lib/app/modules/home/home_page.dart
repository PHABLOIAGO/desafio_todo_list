import 'dart:ui';

import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/modules/home/home_controller.dart';
import 'package:todo_list/app/modules/new_task/new_task_page.dart';

class HomePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Atividades",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            backgroundColor: Colors.white,
          ),
          bottomNavigationBar: FFNavigationBar(
            theme: FFNavigationBarTheme(
                itemWidth: 60,
                barHeight: 70,
                barBackgroundColor: Theme.of(context).primaryColor,
                unselectedItemIconColor: Colors.white,
                unselectedItemLabelColor: Colors.white,
                selectedItemBorderColor: Colors.white,
                selectedItemIconColor: Colors.white,
                selectedItemBackgroundColor: Theme.of(context).primaryColor,
                selectedItemLabelColor: Colors.black),
            selectedIndex: controller.selectedTab,
            onSelectTab: (index) => controller.changeSeletedTab(context, index),
            items: [
              FFNavigationBarItem(
                iconData: Icons.check_circle,
                label: "Finalizados",
              ),
              FFNavigationBarItem(
                iconData: Icons.view_week,
                label: "Semanal",
              ),
              FFNavigationBarItem(
                iconData: Icons.calendar_today,
                label: "Selecionar data",
              )
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: controller.listTodos?.keys?.length ?? 0,
              itemBuilder: (_, index) {
                var dateformat = DateFormat('dd/MM/yyyy');
                var dayKey = controller.listTodos.keys.elementAt(index);
                var day = dayKey;
                var listTodos = controller.listTodos[day];
                var today = DateTime.now();

                if (listTodos.isEmpty && controller.selectedTab == 0) {
                  return SizedBox.shrink();
                }

                if (dayKey == dateformat.format(today)) {
                  day = "Hoje";
                } else if (dayKey == dateformat.format(today.add(Duration(days: 1)))) {
                  day = "Amanhã";
                } else if (dayKey == dateformat.format(today.subtract(Duration(days: 1)))) {
                  day = "Ontem";
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              day,
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                            onPressed: () async {
                              await Navigator.of(context).pushNamed(NewTaskPage.routerName, arguments: dayKey);
                              controller.update();
                            },
                          )
                        ],
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listTodos.length,
                        itemBuilder: (_, index) {
                          var todo = listTodos[index];
                          return Dismissible(
                            direction: DismissDirection.startToEnd,
                            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                            background: Container(
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment(-0.9, 0.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Apagar",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onDismissed: (direction) async {
                              await controller.delete(todo);

                              final snack = SnackBar(
                                duration: Duration(seconds: 5),
                                content: Text("Tarefa excluída!"),
                                action: SnackBarAction(
                                    label: "Desfazer",
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      await controller.restore();
                                    }),
                              );
                              _scaffoldKey.currentState
                                ..removeCurrentSnackBar()
                                ..showSnackBar(snack);
                            },
                            child: ListTile(
                              leading: Checkbox(
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) => controller.checkOrUncheck(todo),
                                value: todo.finalizado,
                              ),
                              title: Text(
                                todo.descricao,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  decoration: todo.finalizado ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              trailing: Text(
                                "${todo.dataHora.hour.toString().padLeft(2, '0')}:${todo.dataHora.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  decoration: todo.finalizado ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          );
                        })
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
