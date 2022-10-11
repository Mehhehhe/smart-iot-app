import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

part 'farm_card_state.dart';

class FarmCardCubit extends Cubit<FarmCardInitial> {
  FarmCardCubit() : super(FarmCardInitial(farmIndex: 0, farms: const []));

  void chooseIndex(int index, List farms) =>
      emit(FarmCardInitial(farmIndex: index));

  int currentIndex() => state.farmIndex;

  getOwnedFarmsList() async {
    var res = await Amplify.Auth.getCurrentUser();
    var data = await getUserById(res.username);
    //emit(data);
    return data;
  }
}
