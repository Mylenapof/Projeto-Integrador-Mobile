import '../../../core/base/base_service.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';
import 'product_validation.dart';

class ProductService
    extends BaseService<ProductModel, ProductRepository, ProductValidation> {
  ProductService()
      : super(ProductRepository(), ProductValidation(ProductRepository()));

  Future<List<ProductModel>> getDisponiveis() =>
      repository.findDisponiveis();

  Future<List<ProductModel>> getByCategoria(int categoryId) =>
      repository.findByCategoria(categoryId);

  Future<List<ProductModel>> getDestaques() =>
      repository.findDestaques();
}