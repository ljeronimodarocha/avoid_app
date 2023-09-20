import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../login_presenter.dart';

class UserNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginPresenter = Provider.of<LoginPresenter>(context, listen: false);

    return StreamBuilder<UIError?>(
        stream: loginPresenter.userNameErrorStream,
        builder: (context, snapshot) {
          return TextFormField(
            decoration: InputDecoration(
              labelText: 'User Name',
              errorText: snapshot.data?.description,
              icon: Icon(
                Icons.person,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            keyboardType: TextInputType.name,
            onChanged: loginPresenter.validateUserName,
          );
        });
  }
}
