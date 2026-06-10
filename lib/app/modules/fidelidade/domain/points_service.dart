import '../../../core/base/base_validation.dart';
import '../../../core/base/base_service.dart';
import '../../../core/logging/log_service.dart';
import '../data/sweet_points_model.dart';
import '../data/sweet_points_repository.dart';
class PointsValidation
    extends BaseValidation<SweetPointsModel, SweetPointsRepository> {
  const PointsValidation(super.repository);

  @override
  Future<String?> validateCreate(SweetPointsModel entity) async => null;

  @override
  Future<String?> validateUpdate(SweetPointsModel entity) async => null;
}

class PointsService extends BaseService<SweetPointsModel, SweetPointsRepository,
    PointsValidation> {
  final LogService _logger = LogService();

  PointsService()
      : super(
          SweetPointsRepository(),
          PointsValidation(SweetPointsRepository()),
        );

  Future<SweetPointsModel?> getByUser(int userId) =>
      repository.findByUser(userId);

  Future<String?> adicionar(int userId, int pontos) async {
    try {
      await repository.adicionarPontos(userId, pontos);
      _logger.info('PointsService', 'adicionar', '$pontos pontos adicionados ao user $userId');
      return null;
    } catch (e) {
      _logger.error('PointsService', 'adicionar', e.toString());
      return 'Erro ao adicionar pontos';
    }
  }

  Future<String?> resgatar(int userId, int pontos) async {
    try {
      final erro = await repository.resgatarPontos(userId, pontos);
      if (erro != null) return erro;
      _logger.info('PointsService', 'resgatar', '$pontos pontos resgatados pelo user $userId');
      return null;
    } catch (e) {
      _logger.error('PointsService', 'resgatar', e.toString());
      return 'Erro ao resgatar pontos';
    }
  }
}