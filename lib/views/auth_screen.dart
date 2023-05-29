import 'package:avoid_app/exceptions/firebase_exception.dart';
import 'package:avoid_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/AuthMode.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.Login;

  final GlobalKey<FormState> _form = GlobalKey();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState?.save();
    try {
      AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
      if (_authMode == AuthMode.Login) {
        await auth.entrar(_authData['username']!, _authData['password']!);
      } else {
        await auth.signup(_authData['username']!, _authData['password']!);
      }
      return Future<void>.value();
    } on FireBaseException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog("Ocorreu um erro inesperado!");
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Ocorreu um erro'),
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fechar'))
              ],
            ));
  }

  final Map<String, String> _authData = {'username': '', 'password': ''};

  final _passwordController = TextEditingController();

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

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
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _authData['username'] = value!,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  onSaved: (value) => _authData['password'] = value!,
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Confirmar Senha'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return "Senhas são diferentes!";
                            }
                            return null;
                          }
                        : null,
                  ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  onPressed: _submit,
                  child: Text(
                    _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISTRAR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    "ALTERNAR PARA ${_authMode == AuthMode.Login ? 'REGISTRAR' : 'LOGIN'}",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
