import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersItem{
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrdersItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime

  });
}

class Orders with ChangeNotifier{
  List<OrdersItem> _orders=[];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId, this._orders);
  List<OrdersItem> get orders{
    return[..._orders];
  }

  Future<void> fetchAndSetOrders() async{
    final url =
        'https://flutter-shoppingapp-d3948.firebaseio.com/orders/$userId.json?auth=$authToken';
        final response= await http.get(url);
        final List<OrdersItem> loadedOrders=[];
        final extractedData=json.decode(response.body) as Map<String,dynamic>;
        if(extractedData==null){
          return;
        }
        extractedData.forEach((orderId, orderData) { 
          loadedOrders.add(OrdersItem(
            id: orderId, 
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']), 
            products: (orderData['products'] as List<dynamic>).map((item) => CartItem(
              id: item['id'],
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            ) ).toList(), 
            ));

        });
        _orders=loadedOrders.reversed.toList();
        notifyListeners();
  }
  Future<void> addOrder(List<CartItem> cartProducts, double total) async{
    final url =
        'https://flutter-shoppingapp-d3948.firebaseio.com/orders/$userId.json?auth=$authToken';
        final timeStamp=DateTime.now();
        final response= await http.post(url , body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts.map((cp) => {
            'id': cp.id,
            'title': cp.title,
            'quantity':cp.quantity,
            'price' : cp.price,
          }).toList()

        }));
    _orders.insert(0, 
    OrdersItem(
      id: json.decode(response.body)['name'],
      amount: total,
      dateTime: timeStamp,
      products: cartProducts, 
      
      )
      );
      notifyListeners();
  }

}

