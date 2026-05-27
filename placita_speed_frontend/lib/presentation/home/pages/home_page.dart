import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'student_home_page.dart';

class HomePage extends StudentHomePage {
  const HomePage({super.key, required UserEntity user}) : super(user: user);
}
