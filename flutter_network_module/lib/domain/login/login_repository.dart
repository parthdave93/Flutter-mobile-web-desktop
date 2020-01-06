abstract class LoginRepository{
  Future<LoginModel> performLogin(String username, String pass);

}