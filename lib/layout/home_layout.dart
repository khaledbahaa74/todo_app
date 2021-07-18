import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if(state is AppInsertDatabaseState)
                Navigator.pop(context);
          },
          builder: (context, state) {
            AppCubit cubit = AppCubit.get(context);

            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(
                  cubit.titles[cubit.currentIndex],
                ),
                centerTitle: state is! AppGetDatabaseLoadingState,
              ),
              body: ConditionalBuilder(
                condition: true,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isButtonSheetShown) {
                    if (formKey.currentState.validate()) {
                      cubit.insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text,
                      );
                    }
                  } else {
                    scaffoldKey.currentState
                        .showBottomSheet(
                          (context) => Container(
                            padding: EdgeInsets.all(20),
                            color: Colors.grey[100],
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                    controller: titleController,
                                    inputType: TextInputType.text,
                                    validate: (String value) {
                                      if (value.isEmpty)
                                        return 'title must not me empty';
                                      return null;
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  defaultFormField(
                                    controller: timeController,
                                    inputType: TextInputType.datetime,
                                    validate: (String value) {
                                      if (value.isEmpty)
                                        return 'time must not me empty';
                                      return null;
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text =
                                            value.format(context);
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  defaultFormField(
                                    controller: dateController,
                                    inputType: TextInputType.datetime,
                                    validate: (String value) {
                                      if (value.isEmpty)
                                        return 'date must not me empty';
                                      return null;
                                    },
                                    label: 'Task Date',
                                    prefix: Icons.calendar_today,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2021-08-11'),
                                      ).then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          elevation: 20,
                        )
                        .closed
                        .then((value) {
                      cubit.changeBottomSheetState(
                        isShown: false,
                        icon: Icons.edit,
                      );
                    });
                    cubit.changeBottomSheetState(
                      isShown: true,
                      icon: Icons.add,
                    );
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archived',
                  ),
                ],
              ),
            );
          }),
    );
  }
}
