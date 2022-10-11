part of 'farm_card_cubit.dart';

abstract class FarmCardState extends Equatable {
  int farmIndex;
  List? farms;

  FarmCardState({required this.farmIndex, this.farms});

  @override
  List<Object> get props => [];
}

class FarmCardInitial extends FarmCardState {
  FarmCardInitial({required int farmIndex, List? farms})
      : super(farmIndex: farmIndex, farms: farms);
}
