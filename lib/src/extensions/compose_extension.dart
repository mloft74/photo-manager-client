import 'package:photo_manager_client/src/data_structures/fp/fp.dart' as fp;

extension ComposeExtension<B, C> on C Function(B) {
  C Function(A) comp<A>(B Function(A) fn) => fp.compUncurried(this, fn);
}
