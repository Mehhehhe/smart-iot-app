part of 'farm_card_re_bloc.dart';

class FarmCardReState extends Equatable {
  // current farm index user chose or at default
  final int farmIndex;
  // fetched farms of the user; use with farmIndex to get current farm name(encoded)
  final List farms;
  // fetched devices of the user
  // **Cautions** : this only works with current farm
  // other farms' devices are not fetched or discared!
  final List devices;
  // hold fetched data
  final String data;
  // hold on constructed data
  final Map<String, dynamic> pt;

  // Blank state
  const FarmCardReState._({
    this.farmIndex = 0,
    this.devices = const [],
    this.farms = const [],
    this.data = "",
    this.pt = const {},
  });

  // For unknowned state, go back to 'not loaded'
  const FarmCardReState.notLoaded() : this._();

  // For initialization, data is prepared
  const FarmCardReState.loaded(
    int ind,
    List fFarm,
    List fDevice,
    String data,
    Map<String, dynamic> pt,
  ) : this._(
          farmIndex: ind,
          farms: fFarm,
          devices: fDevice,
          data: data,
          pt: pt,
        );

  // Diff states
  // data may not fetched @ the same time
  @override
  List<Object> get props => [
        farmIndex,
        farms,
        devices,
        data,
        pt,
      ];
}
