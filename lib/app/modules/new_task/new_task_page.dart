import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/modules/new_task/new_task_controller.dart';
import 'package:todo_list/app/shared/time_component.dart';

class NewTaskPage extends StatefulWidget {
  static String routerName = "/new";

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  var _scaffolKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<NewTaskController>().addListener(() {
        var controller = context.read<NewTaskController>();
        if (controller.error != null) {
          _scaffolKey.currentState.showSnackBar(
            SnackBar(
              content: Text(controller.error),
            ),
          );
        }

        if (controller.saved) {
          _scaffolKey.currentState.showSnackBar(
            SnackBar(
              content: Text("ToDo cadastrado com sucesso."),
            ),
          );
          Future.delayed(
            Duration(seconds: 2),
            () => Navigator.pop(context),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    context.read<NewTaskController>().removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewTaskController>(
      builder: (context, controller, _) {
        return Scaffold(
          key: _scaffolKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nova Atividade",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Data",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      controller.dayFormated,
                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Nome da Atividade",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: controller.nameTaskController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Nome da ativade é obrigatório";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Hora",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TimeComponent(
                        date: controller.daySelected,
                        onSelectedTime: (value) {
                          controller.daySelected = value;
                        }),
                    SizedBox(
                      height: 50,
                    ),
                    _buildButton(controller)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(NewTaskController controller) {
    return Center(
      child: InkWell(
        onTap: !controller.loading
            ? () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Future.delayed(Duration(milliseconds: 200), () =>controller.save());
              }
            : null,
        child: AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.decelerate,
            width: controller.saved ? 80 : MediaQuery.of(context).size.width,
            height: controller.saved ? 80 : 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: controller.saved ? BorderRadius.circular(100) : BorderRadius.circular(0),
              boxShadow: [
                controller.saved
                    ? BoxShadow(blurRadius: 30, color: Theme.of(context).primaryColor, offset: Offset(2, 2))
                    : BoxShadow(blurRadius: 1, color: Theme.of(context).primaryColor),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: !controller.saved ? 0 : 80,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeInBack,
                    opacity: controller.saved ? 1 : 0,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ),
                Visibility(
                  visible: !controller.saved,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Salvar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
