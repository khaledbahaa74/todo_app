import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width: double.infinity,
  Color background: Colors.blue,
  bool isUpperCase: true,
  double radius: 0,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      height: 40,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          radius,
        ),
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType inputType,
  @required Function validate,
  @required String label,
  @required IconData prefix,
  bool isPassword: false,
  bool isClickable: true,
  Function onSubmit,
  Function onChange,
  Function onTap,
  Function suffixPressed,
  IconData suffix,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      onTap: onTap,
      validator: validate,
      enabled: isClickable,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            suffix,
          ),
          onPressed: suffixPressed,
        ),
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map task, context) => Dismissible(
      key: Key('${task['id']}'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                '${task['time']}',
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${task['title']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${task['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: 'done',
                  id: task['id'],
                );
              },
              icon: Icon(
                Icons.check_box,
                color: Colors.green,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: 'archived',
                  id: task['id'],
                );
              },
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      onDismissed: ((direction) {
        AppCubit.get(context)
            .deleteFromDatabase(AppCubit.get(context).database, task['id']);
      }),
    );

Widget tasksBuilder({
  @required List<Map> tasks,
}) {
  return ConditionalBuilder(
    condition: tasks.length > 0,
    builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[300],
      ),
      itemCount: AppCubit.get(context).newTasks.length,
    ),
    fallback: (context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 100,
            color: Colors.grey,
          ),
          Text(
            'No Tasks Yet, Please Add Some Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
