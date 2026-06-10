import '../../../core/base/base_validation.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';

class ProductValidation extends BaseValidation<ProductModel, ProductRepository> {
  const ProductValidation(super.repository);

  @override
  Future<String?> validateCreate(ProductModel entity) async {
    if (!isNotEmpty(entity.nome))     return 'Nome é obrigatório';
    if (!isNotEmpty(entity.descricao)) return 'Descrição é obrigatória';
    if (entity.preco <= 0)            return 'Preço deve ser maior que zero';
    return null;
  }

  @override
  Future<String?> validateUpdate(ProductModel entity) async {
    return validateCreate(entity);
  }
}