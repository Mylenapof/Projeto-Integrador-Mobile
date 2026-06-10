import '../../../core/base/base_validation.dart';
import '../../../core/base/base_service.dart';
import '../../../core/logging/log_service.dart';
import '../data/cart_item_model.dart';
import '../data/cart_repository.dart';

class CartValidation extends BaseValidation<CartItemModel, CartRepository> {
  const CartValidation(super.repository);

  @override
  Future<String?> validateCreate(CartItemModel entity) async => null;

  @override
  Future<String?> validateUpdate(CartItemModel entity) async => null;
}

class CartService
    extends BaseService<CartItemModel, CartRepository, CartValidation> {
  final LogService _logger = LogService();

  CartService() : super(CartRepository(), CartValidation(CartRepository()));

  Future<List<CartItemModel>> getItens(int userId) =>
      repository.findByUser(userId);

  Future<void> adicionar(int userId, int productId) async {
    try {
      await repository.adicionar(userId, productId);
      _logger.info('CartService', 'adicionar', 'Produto $productId adicionado');
    } catch (e) {
      _logger.error('CartService', 'adicionar', e.toString());
    }
  }

  Future<void> diminuir(int itemId, int quantidade) async {
    try {
      await repository.diminuir(itemId, quantidade);
    } catch (e) {
      _logger.error('CartService', 'diminuir', e.toString());
    }
  }

  Future<void> remover(int itemId) async {
    try {
      await repository.delete(itemId);
    } catch (e) {
      _logger.error('CartService', 'remover', e.toString());
    }
  }

  Future<void> limpar(int userId) async {
    try {
      await repository.limparCarrinho(userId);
    } catch (e) {
      _logger.error('CartService', 'limpar', e.toString());
    }
  }
}