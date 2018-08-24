library navigate;

import 'dart:async';
import 'dart:core';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';

/* ChangePage type */
class Navigate {
  static final Navigate _instance = Navigate.internal();
  Navigate.internal();
  factory Navigate() => _instance;
  /* defualt Navigate Transactiontype */
  static TransactionType defultTransactionType;
  /* routes information */
  static Map<String, Handler> _appRoutes;

  static Future<dynamic> navigate(BuildContext context, String routeName,
      {arg,
      TransactionType transactionType,
      ReplaceRoute replaceRoute = ReplaceRoute.none}) async {
    if (_appRoutes.containsKey(routeName)) {
      var handler = _appRoutes[routeName];
      return await handler.renderWithAnimation(
          context, arg, transactionType, replaceRoute);
    } else {
      throw ("ROUTE NOT MATCH");
    }
  }

  static registerRoutes(
      {Map<String, Handler> routes,
      TransactionType defualtTransactionType = TransactionType.fromBottom}) {
    _appRoutes = routes;
    defultTransactionType = defualtTransactionType;
  }
}

/* Route ChangePage handler */
class Handler {
  final Function(BuildContext context, dynamic arg) pageBuilder;
  TransactionType transactionType;
  Handler({this.pageBuilder, this.transactionType});

  Future<dynamic> renderWithAnimation(BuildContext context, arg,
      transactionType, ReplaceRoute replaceRoute) async {
    if (replaceRoute == ReplaceRoute.none) {
      return await Navigator.push(
          context,
          new PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return pageBuilder(context, arg);
              },
              transitionsBuilder: pageTransaction(transactionType)));
    } else if (replaceRoute == ReplaceRoute.thisOne) {
      return await Navigator.pushReplacement(
          context,
          new PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return pageBuilder(context, arg);
              },
              transitionsBuilder: pageTransaction(transactionType)));
    } else if (replaceRoute == ReplaceRoute.all) {
      return await Navigator.pushAndRemoveUntil(
          context,
          new PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return pageBuilder(context, arg);
              },
              transitionsBuilder: pageTransaction(transactionType)),
          (Route<dynamic> route) => false);
    }
  }

  pageTransaction(TransactionType comeFromParam) {
    TransactionType pageTras = comeFromParam != null
        ? comeFromParam
        : (this.transactionType != null)
            ? this.transactionType
            : Navigate.defultTransactionType;

    if (pageTras != TransactionType.fadeIn) {
      double x = 0.0;
      double y = 0.0;

      switch (pageTras) {
        case TransactionType.fromBottom:
          y = 1.0;
          break;
        case TransactionType.fromTop:
          y = -1.0;
          break;
        case TransactionType.fromLeft:
          x = -1.0;
          break;
        case TransactionType.fromRight:
          x = 1.0;
          break;
      }
   
      return (___, Animation<double> animation, ____, Widget child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constrains) {
            return new ClipOval(
              // position: Tween(begin: Offset(x, y), end: Offset(0.0, 0.0))
              //     .animate(animation),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              clipper: PageCome(revalPercentage: animation.value),
              child: child
              
            );
          },
        );
      };
    } else {
      return (___, Animation<double> animation, ____, Widget child) {
        return new FadeTransition(
          opacity: animation,
          child: child,
        );
      };
    }
  }
}

/* Clip Oval Transaction */
class PageCome extends CustomClipper<ui.Rect> {
  final revalPercentage;

  PageCome({this.revalPercentage = 0.7});
  @override
  ui.Rect getClip(ui.Size size) {
    // TODO: implement getClip
   
    final escpactor = Offset(size.width / 2, size.height * 0.9);
     print("espactor" + escpactor.toString());

    double theta = atan(escpactor.dy / escpactor.dx);
    print("theta" + theta.toString());
    
    final distanceToCover = escpactor.dy / sin(theta);
    print("distance" + distanceToCover.toString());

    final radius = distanceToCover * revalPercentage;
    print("radius" + radius.toString());

    final diamerter = (radius * 2.0);
    print("diamerter" + diamerter.toString());


    var rect = ui.Rect.fromLTWH(
        escpactor.dx - radius, escpactor.dy - radius, diamerter, diamerter);

    print(rect);
    return rect;    
  }

  @override
  bool shouldReclip(CustomClipper<ui.Rect> oldClipper) {
    // TODO: implement shouldReclip
  }
}

/* enum of page translation type */
enum TransactionType {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
  fadeIn,
  custom,
}
/* replacement type enum */
enum ReplaceRoute { thisOne, all, none }
