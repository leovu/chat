import 'package:chat/data_model/response/check_user_token_response_model.dart';

class User {
  late String email;
  late String password;
  late String token;
  late String firstName;
  late String lastName;
  late String id;
  User({required this.email, required this.password, required this.token});
  User.fromCheckUserToken(CheckUserTokenResponseModel data) {
    email = data.user!.email ?? '';
    firstName = data.user!.firstName ?? '';
    lastName = data.user!.lastName ?? '';
    email = data.user!.email ?? '';
    token = data.token ?? '';
    id = data.user!.sId ?? '';
    password = data.user!.password ?? '';
  }
}