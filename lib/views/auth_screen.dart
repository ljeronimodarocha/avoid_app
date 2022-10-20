import 'package:avoid_app/exceptions/firebase_exception.dart';
import 'package:avoid_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _form = GlobalKey();

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState?.save();
    try {
      AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.entrar(_authData['username']!, _authData['password']!);
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
              title: Text('Ocorreu um erro'),
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Fechar'))
              ],
            ));
  }

  final Map<String, String> _authData = {'username': '', 'password': ''};

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
                    labelText: 'User Name',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _authData['username'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  onSaved: (value) => _authData['password'] = value!,
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Logar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
