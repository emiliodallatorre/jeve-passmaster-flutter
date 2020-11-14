import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jeve_passmaster_flutter/generated/l10n.dart';
import 'package:jeve_passmaster_flutter/models/password_model.dart';
import 'package:jeve_passmaster_flutter/models/state_model.dart';
import 'package:jeve_passmaster_flutter/models/user_model.dart';
import 'package:jeve_passmaster_flutter/resources/helper/password_helper.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class PasswordEditorScreen extends StatefulWidget {
  static const String route = "/passwordEditorScreen";

  @override
  _PasswordEditorScreenState createState() => _PasswordEditorScreenState();
}

class _PasswordEditorScreenState extends State<PasswordEditorScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PasswordModel password;

  @override
  Widget build(BuildContext context) {
    if (password == null) {
      password = ModalRoute.of(context).settings.arguments as PasswordModel;
      if (password == null) password = PasswordModel(id: randomAlphaNumeric(20), creationDate: DateTime.now(), groupIds: Set<String>());
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.current.editGroup)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: S.current.name,
                          ),
                          initialValue: password.service,
                          validator: RequiredValidator(errorText: S.current.requiredError),
                          onSaved: (String value) => password.service = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: S.current.credential,
                            alignLabelWithHint: true,
                          ),
                          initialValue: password.email,
                          onSaved: (String value) => password.email = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: S.current.password,
                            alignLabelWithHint: true,
                          ),
                          initialValue: password.password,
                          onSaved: (String value) => password.password = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: S.current.description,
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          minLines: 4,
                          initialValue: password.note,
                          onSaved: (String value) => password.note = value,
                        ),
                      ],
                    ),
                  ),
                ),
                Consumer<StateModel>(
                  builder: (BuildContext context, StateModel currentState, Widget child) => ListView.builder(
                    itemCount: Provider.of<StateModel>(context).groupBloc.groups.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) => CheckboxListTile(
                      title: Text(currentState.groupBloc.groups.elementAt(index).name),
                      value: password.groupIds.contains(currentState.groupBloc.groups.elementAt(index).id),
                      onChanged: (bool newValue) => setState(() => newValue
                          ? password.groupIds.add(currentState.groupBloc.groups.elementAt(index).id)
                          : password.groupIds.remove(currentState.groupBloc.groups.elementAt(index).id)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          child: Text(S.current.save),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              if (password.groupIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.requiredGroup)));
                return;
              }

              _formKey.currentState.save();
              if (password.reference == null)
                await PasswordHelper.createPassword(password);
              else
                await PasswordHelper.editPassword(password);

              Provider.of<StateModel>(context, listen: false).groupBloc.getAllGroups(Provider.of<UserModel>(context, listen: false));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
