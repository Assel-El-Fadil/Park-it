import 'dart:html' as html;

Future<void> redirectToStripe(String url) async {
  html.window.location.href = url;
}

String getOrigin() => html.window.location.origin;
