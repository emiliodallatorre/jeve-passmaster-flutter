import 'package:jeve_passmaster_flutter/models/group_model.dart';
import 'package:jeve_passmaster_flutter/models/user_model.dart';
import 'package:jeve_passmaster_flutter/resources/provider/group_provider.dart';

class Repository {
  static Future<List<GroupModel>> getAllAccessibleGroups(UserModel user) => GroupProvider.getAllAccessibleGroups(user);
}