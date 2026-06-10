import 'package:lourenco_confeitaria_app/app/core/base/base_validation.dart';
import 'package:lourenco_confeitaria_app/app/modules/auth/data/user_model.dart';
import 'package:lourenco_confeitaria_app/app/modules/auth/data/user_repository.dart';

class UserValidation extends BaseValidation<UserModel, UserRepository> {
  const UserValidation(super.repository);

  @override
  Future<String?> validateCreate(UserModel entity) async {
    if (!isNotEmpty(entity.nome))  return 'Nome é obrigatório';
    if (!isNotEmpty(entity.email)) return 'E-mail é obrigatório';
    if (!isValidEmail(entity.email)) return 'E-mail inválido';
    if (!hasMinLength(entity.senha, 6)) return 'Senha deve ter ao menos 6 caracteres';

    final existe = await repository.emailExiste(entity.email);
    if (existe) return 'E-mail já cadastrado';

    return null;
  }

  @override
  Future<String?> validateUpdate(UserModel entity) async {
    if (!isNotEmpty(entity.nome))  return 'Nome é obrigatório';
    if (!isNotEmpty(entity.email)) return 'E-mail é obrigatório';
    if (!isValidEmail(entity.email)) return 'E-mail inválido';
    return null;
  }

  Future<String?> validateLogin(String email, String senha) async {
    if (!isNotEmpty(email)) return 'E-mail é obrigatório';
    if (!isNotEmpty(senha)) return 'Senha é obrigatória';
    if (!isValidEmail(email)) return 'E-mail inválido';
    return null;
  }
}