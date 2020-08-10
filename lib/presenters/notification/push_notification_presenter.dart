import '../../services/parse/parse_push_notification_service.dart';
import '../../models/notification/push_notification.dart';
import '../../contracts/notification/push_notification_contract.dart';

class PushNotificationPresenter implements PushNotificationContractPresenter {
  PushNotificationContractView _view;

  PushNotificationPresenter(this._view);

  ParsePushNotificationService service = ParsePushNotificationService();

  @override
  dispose() {
    service = null;
    _view = null;
  }

  @override
  Future<PushNotification> create(PushNotification item) async {
    return await service.create(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<PushNotification> read(PushNotification item) async {
    return await service.read(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<PushNotification> update(PushNotification item) async {
    return await service.update(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<PushNotification> delete(PushNotification item) async {
    return await service.delete(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<PushNotification>> findBy(String field, value) async {
    return await service.findBy(field, value).then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<PushNotification>> list() async {
    return await service.list().then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      print(error);
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

}