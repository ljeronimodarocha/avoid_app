import 'package:avoid_app/ui/pages/login/login_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/login_button.dart';
import 'components/login_email_input.dart';
import 'components/login_password_input.dart';

class LoginPage extends StatelessWidget {
  final LoginPresenter loginPresenter;
  const LoginPage(this.loginPresenter, {super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: deviceSize.width * 0.75,
          child: Provider(
            create: (context) => loginPresenter,
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EmailInput(),
                  PasswordInput(),
                  LoginButton(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'Criar Conta',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
