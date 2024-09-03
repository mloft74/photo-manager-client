import 'package:photo_manager_client/src/data_structures/fp/fp.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/semigroup.dart';

abstract interface class Monoid<TBrand, TVal,
        TImpl extends Monoid<TBrand, TVal, TImpl>>
    implements Semigroup<TBrand, TVal, TImpl> {}

typedef Mconcat<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>> = TImpl
    Function(List<TImpl> list, TImpl mempty);

TImpl mconcat<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>(
  List<TImpl> list,
  TImpl mempty,
) {
  return foldr((a, b) => a.combine(b), mempty, list);
}

extension MConcatExt<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>
    on List<TImpl> {
  /// Extension version of [mconcat] to fix type inference.
  TImpl mconcatExt(TImpl mempty) => mconcat<TBrand, TVal, TImpl>(this, mempty);
}
