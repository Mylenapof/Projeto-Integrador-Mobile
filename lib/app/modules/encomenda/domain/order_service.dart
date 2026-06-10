import '../../../core/base/base_validation.dart';
import '../../../core/base/base_service.dart';
import '../../../core/logging/log_service.dart';
import '../data/order_model.dart';
import '../data/order_repository.dart';

class OrderValidation extends BaseValidation<OrderModel, OrderRepository> {
  const OrderValidation(super.repository);

  @override
  Future<String?> validateCreate(OrderModel entity) async {
    if (!isNotEmpty(entity.tipo)) return 'Tipo de encomenda é obrigatório';
    if (entity.tipo == 'personalizada') {
      if (!isNotEmpty(entity.tipoProduto)) return 'Tipo de produto é obrigatório';
      if (!isNotEmpty(entity.tamanho))     return 'Tamanho é obrigatório';
      if (!isNotEmpty(entity.sabor))       return 'Sabor é obrigatório';
    }
    if (entity.tipo == 'salgados') {
      if (!isNotEmpty(entity.tipoProduto)) return 'Tipo de salgado é obrigatório';
      if (!isNotEmpty(entity.tamanho))     return 'Quantidade é obrigatória';
    }
    return null;
  }

  @override
  Future<String?> validateUpdate(OrderModel entity) async =>
      validateCreate(entity);
}

class OrderService
    extends BaseService<OrderModel, OrderRepository, OrderValidation> {
  final LogService _logger = LogService();

  OrderService()
      : super(OrderRepository(), OrderValidation(OrderRepository()));

  Future<List<OrderModel>> getByUser(int userId) =>
      repository.findByUser(userId);

  Future<(int?, String?)> enviar(OrderModel order) async {
    final result = await create(order);
    if (result.$1 != null) {
      _logger.info('OrderService', 'enviar',
          'Encomenda ${result.$1} criada para user ${order.userId}');
    }
    return result;
  }
}