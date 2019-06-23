import 'package:flutter/material.dart';

class BadPageWidget extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String errorMessage;
  final String errorDetails;
  final Function onBackPressed;

  BadPageWidget({
    this.icon,
    this.iconSize,
    this.errorDetails,
    this.errorMessage,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildIcon(),
            SizedBox(height: 10.0),
            buildErrorMessage(),
            SizedBox(height: 5.0),
            buildErrorDetails(),
            SizedBox(height: 15.0),
            buildBackButton(context)
          ],
        ),
      ),
    );
  }

  RaisedButton buildBackButton(BuildContext context) {
    return RaisedButton(
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      child: Text(
        "Go Back",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Text buildErrorDetails() {
    return Text(
      errorDetails ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w300,
        color: Colors.red,
        fontSize: 20.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Text buildErrorMessage() {
    return Text(
      errorMessage ?? 'Something went wrong!',
      style: TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.blueGrey,
        fontSize: 20.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Icon buildIcon() {
    return Icon(
      icon ?? Icons.error,
      size: iconSize ?? 96.0,
    );
  }
}
