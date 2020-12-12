import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kidelivercompany/models/singleton/singletons.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../contracts/order/cupon_contract.dart';
import '../../contracts/order/order_contract.dart';
import '../../models/order/cupon.dart';
import '../../models/order/order.dart';
import '../../services/parse/parse_cupon_service.dart';
import '../../services/parse/parse_order_service.dart';
import '../../strings.dart';
import '../../utils/log_util.dart';
import '../../utils/preferences_util.dart';

class OrdersPresenter implements OrderContractPresenter {
  final OrderContractView _view;

  OrdersPresenter(this._view);

  OrderContractService orderService = ParseOrderService();
  CuponContractService cuponService = ParseCuponService();

  LiveQuery liveQuery;
  Subscription subscriptionCreate, subscriptionUpdate;

  void pause() {
    if (liveQuery != null) liveQuery.client.disconnect();
  }

  void resume() {
    if (liveQuery != null) liveQuery.client.reconnect();
  }

  void unSubscribe() {
    if (liveQuery != null) {
      liveQuery.client.unSubscribe(subscriptionCreate);
      liveQuery.client.unSubscribe(subscriptionUpdate);
    }
  }

  @override
  dispose() {
    orderService = null;
    if (liveQuery != null) {
      if (subscriptionCreate != null) {
        liveQuery.client.unSubscribe(subscriptionCreate);
      }
      if (subscriptionUpdate != null) {
        liveQuery.client.unSubscribe(subscriptionUpdate);
      }
    }
  }

  @override
  Future<Order> create(Order item) async {
    return await orderService.create(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> read(Order item) async {
    return await orderService.read(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> update(Order item) async {
    return await orderService.update(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> delete(Order item) async {
    return await orderService.delete(item).then((value) {
      if (_view != null) _view.onSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Order>> findBy(String field, value) async {
    return await orderService.findBy(field, value).then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Order>> list() async {
    return await orderService.list().then((value) {
      if (_view != null) _view.listSuccess(value);
      return value;
    }).catchError((error) {
      if (_view != null) _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Order> readSnapshot(Order item) async {
    liveQuery = LiveQuery();

    QueryBuilder query = QueryBuilder(ParseObject("Order"))
      ..whereEqualTo("objectId", item.id);

    subscriptionUpdate = await liveQuery.client.subscribe(query);

    subscriptionUpdate.on(LiveQueryEvent.update, (value) async {
      var order = Order.fromMap(value.toJson());
      var cuponJson = value["cupon"];
      if (cuponJson != null) {
        var cupon =
            await cuponService.read(Cupon()..id = cuponJson["objectId"]);
        order.cupon = cupon;
      }
      _view != null ? _view.onSuccess(order) : null;
    });
  }

  @override
  Future<List<Order>> listDayOrdersSnapshot(DateTime day) async {
    var includes = ["cupon"];
    liveQuery = LiveQuery();

    QueryBuilder query;

    if (kDebugMode) {
      query = QueryBuilder(ParseObject("Order"))
        //..whereEqualTo("company", Singletons.company().toPointer())
        ..whereGreaterThanOrEqualsTo("createdAt", day)
        ..whereLessThan("createdAt", day.add(Duration(days: 1)))
        ..includeObject(includes)
        ..orderByDescending("createdAt");
    } else {
      query = QueryBuilder(ParseObject("Order"))
        ..whereEqualTo("company", Singletons.company().toPointer())
        ..whereGreaterThanOrEqualsTo("createdAt", day)
        ..whereLessThan("createdAt", day.add(Duration(days: 1)))
        ..includeObject(includes)
        ..orderByDescending("createdAt");
    }

    subscriptionCreate = await liveQuery.client.subscribe(query);
    subscriptionUpdate = await liveQuery.client.subscribe(query);

    subscriptionCreate.on(LiveQueryEvent.create, (value) async {
      var order = Order.fromMap(value.toJson());
      var cuponJson = value["cupon"];
      if (cuponJson != null) {
        var cupon =
            await cuponService.read(Cupon()..id = cuponJson["objectId"]);
        order.cupon = cupon;
      }
      if (order.createdAt.isAfter(day) &&
          order.createdAt.isBefore(day.add(Duration(days: 1)))) {
        if (_view != null) {
          _view.listSuccess([order]);
        }
      }
    });

    int filter = await PreferencesUtil.getOrderFilter();

    subscriptionUpdate.on(LiveQueryEvent.update, (value) async {
      var order = Order.fromMap(value.toJson());
      var cuponJson = value["cupon"];
      if (cuponJson != null) {
        var cupon =
            await cuponService.read(Cupon()..id = cuponJson["objectId"]);
        order.cupon = cupon;
      }
      if (order.createdAt.isAfter(day) &&
          order.createdAt.isBefore(day.add(Duration(days: 1)))) {
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
    var includes = ["cupon"];

    QueryBuilder query;

    if (kDebugMode) {
      query = QueryBuilder(ParseObject("Order"))
        //..whereEqualTo("company", Singletons.company().toPointer())
        ..whereGreaterThanOrEqualsTo("createdAt", day)
        ..whereLessThan("createdAt", day.add(Duration(days: 1)))
        ..includeObject(includes)
        ..orderByDescending("createdAt");
    } else {
      query = QueryBuilder(ParseObject("Order"))
        ..whereEqualTo("company", Singletons.company().toPointer())
        ..whereGreaterThanOrEqualsTo("createdAt", day)
        ..whereLessThan("createdAt", day.add(Duration(days: 1)))
        ..includeObject(includes)
        ..orderByDescending("createdAt");
    }

    int filter = await PreferencesUtil.getOrderFilter();

    await query.query().then((value) async {
      if (value.success) {
        if (value.result == null) {
          if (_view != null) _view.listSuccess([]);
        } else {
          List<ParseObject> listObj = value.result;

          var list = listObj.map<Order>((obj) {
            var objectJson = obj.toJson();

            for (var include in includes) {
              try {
                var json = obj.get(include).toJson();
                objectJson[include] = json;
              } catch (error) {
                print("sem $include");
              }
            }

            return Order.fromMap(objectJson);
          }).toList();

          if (filter == null) {
            filter = 0;
          }

          var filterList = list.where((order) {
            var current = order.status.current;
            var index = order.status.getIndex(current);
            switch (filter) {
              case 0:
                return true;
              case 1:
                return index > 0 && index < 3;
              case 2:
                return index > 2 && index < 5;
              case 3:
                return index > 4;
            }
            return false;
          }).toList();

          filterList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (_view != null) _view.listSuccess(filterList);
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
