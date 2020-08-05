import '../../utils/log_util.dart';
import '../../utils/preferences_util.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'dart:async';
import '../../models/singleton/singletons.dart';
import '../../services/parse/parse_order_service.dart';
import '../../contracts/order/order_contract.dart';
import '../../models/order/order.dart';
import '../../strings.dart';

class OrdersPresenter implements OrderContractPresenter {
  final OrderContractView _view;

  OrdersPresenter(this._view);

  OrderContractService service = ParseOrderService();

  LiveQuery liveQuery;
  Subscription subscription;

  void pause() {
    if (liveQuery != null) liveQuery.client.disconnect();
  }

  void resume() {
    if (liveQuery != null) liveQuery.client.reconnect();
  }

  void unSubscribe() {
    if (liveQuery != null) liveQuery.client.unSubscribe(subscription);
  }

  @override
  dispose() {
    service = null;
    if (liveQuery != null) liveQuery.client.unSubscribe(subscription);
  }

  @override
  Future<Order> create(Order item) async {
    return await service.create(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> read(Order item) async {
    return await service.read(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> update(Order item) async {
    return await service.update(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> delete(Order item) async {
    return await service.delete(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Order>> findBy(String field, value) async {
    return await service.findBy(field, value).then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Order>> list() async {
    return await service.list().then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Order>> listDayOrdersSnapshot(DateTime day) async {
    liveQuery = LiveQuery();

    QueryBuilder query = QueryBuilder(ParseObject("Order"))
      //..whereEqualTo("company", Singletons.company().toPointer())
      ..whereGreaterThanOrEqualsTo("createdAt", day)
      ..whereLessThan("createdAt", day.add(Duration(days: 1)))
      ..orderByDescending("createdAt");

    subscription = await liveQuery.client.subscribe(query);

    subscription.on(LiveQueryEvent.create, (value) {
      var order = Order.fromMap(value.toJson());
      if (order.createdAt.isAfter(day) && order.createdAt.isBefore(day.add(Duration(days: 1)))) {
        if (_view != null) {
          _view.listSuccess([order]);
        }
      }
    });

    int filter = await PreferencesUtil.getOrderFilter();

    subscription.on(LiveQueryEvent.update, (value) {
      var order = Order.fromMap(value.toJson());
      print(order.toMap());
      if (order.createdAt.isAfter(day) && order.createdAt.isBefore(day.add(Duration(days: 1)))) {
        var current = order.status.current;
        var index = order.status.getIndex(current);

        if (filter == null) {
          filter = 0;
        }

        switch (filter) {
          case 0:
            _view != null ? _view.listSuccess([order]) : null;
            break;
          case 1:
            if (index > 0 && index < 3) {
              _view != null ? _view.listSuccess([order]) : null;
            } else {
              _view != null ? _view.removeOrder(order) : null;
            }
            break;
          case 2:
            if (index > 2 && index < 5) {
              _view != null ? _view.listSuccess([order]) : null;
            } else {
              _view != null ? _view.removeOrder(order) : null;
            }
            break;
          case 3:
            if (index > 4) {
              _view != null ? _view.listSuccess([order]) : null;
            } else {
              _view != null ? _view.removeOrder(order) : null;
            }
            break;
        }
      }
    });
  }

  @override
  Future<List<Order>> listDayOrders(DateTime day) async {
    QueryBuilder query = QueryBuilder(ParseObject("Order"))
      ..whereEqualTo("company", Singletons.company().toPointer())
      ..whereGreaterThanOrEqualsTo("createdAt", day)
      ..whereLessThan("createdAt", day.add(Duration(days: 1)))
      ..orderByDescending("createdAt");

    int filter = await PreferencesUtil.getOrderFilter();

    await query.query().then((value) async {
      if (value.success) {
        if (value.result == null) {
          if(_view != null) _view.listSuccess([]);
        } else {
          List<ParseObject> listObj = value.result;
          var list = listObj.map<Order>((obj) {
            return Order.fromMap(obj.toJson());
          }).toList();

          if (filter == null) {
            filter = 0;
          }

          var filterList = list.where((order) {
            var current = order.status.current;
            var index = order.status.getIndex(current);
            switch (filter) {
              case 0: return true;
              case 1: return index > 0 && index < 3;
              case 2: return index > 2 && index < 5;
              case 3: return index > 4;
            }
            return false;
          }).toList();

          filterList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if(_view != null) _view.listSuccess(filterList);
          return filterList;
        }
      } else {
        throw value.error;
      }
    }).catchError((error) {
      Log.e(error);
      switch (error.code) {
        case -1:
          _view.onFailure(ERROR_NETWORK);
          break;
        default:
          _view.onFailure(SOME_ERROR);
      }
    });
  }

}