part of 'farm_card_re_bloc.dart';

abstract class FarmCardReEvent extends Equatable {
  const FarmCardReEvent();

  @override
  List<Object> get props => [];
}

class _OnChoosingIndex extends FarmCardReEvent {
  final int index;

  const _OnChoosingIndex({required this.index});
}

// When fetched farm of user.
class _OnFarmFetched extends FarmCardReEvent {
  final List farms;
  final int defaultIndex;

  const _OnFarmFetched({
    required this.farms,
    required this.defaultIndex,
  });
}

// After fetching farms are completed, fetch devices.
class _OnDeviceFetched extends FarmCardReEvent {
  final List devices;
  final String locateAt;

  const _OnDeviceFetched({
    required this.devices,
    required this.locateAt,
  });
}

// When everything is fetched, complete the event;
class _OnCompletedFetching extends FarmCardReEvent {
  final int currentIndex;
  final List farms;
  final List devices;
  final String data;
  final Map<String, dynamic> pt;

  const _OnCompletedFetching({
    required this.currentIndex,
    required this.farms,
    required this.devices,
    required this.data,
    required this.pt,
  });
}

class OnFetchingEnds extends FarmCardReEvent {}
