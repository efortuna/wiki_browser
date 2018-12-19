import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

void main() => runApp(MaterialApp(home: WikipediaExplorer()));

class WikipediaExplorer extends StatefulWidget {
  @override
  _WikipediaExplorerState createState() => _WikipediaExplorerState();
}

class _WikipediaExplorerState extends State<WikipediaExplorer> {
  Completer<WebViewController> _controllerAccess = Completer<WebViewController>();
  final Set<String> favorites = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Wikipedia Explorer'),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          actions: <Widget>[
            NavigationControls(_controllerAccess.future),
            const SampleMenu(),
          ],
        ),
        body: WebView(
          initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
          //javaScriptMode: JavaScriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controllerAccess.complete(webViewController);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveBookmark,
          child: WebView(
             onWebViewCreated: (WebViewController webViewController) async {
           print('EEEEEE ${ await webViewController.currentUrl()}');
          },

          ), //Icon(Icons.favorite),
        ));
  }

  _saveBookmark() async {
    if (_controllerAccess.isCompleted) {
      var controller = await _controllerAccess.future;
      print(await controller.currentUrl());
    }

  }
}

class SampleMenu extends StatelessWidget {
  const SampleMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('You selected: $value')));
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Item 1',
              child: Text('Item 1'),
            ),
            const PopupMenuItem<String>(
              value: 'Item 2',
              child: Text('Item 2'),
            ),
          ],
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: true),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: false),
            ),
          ],
        );
      },
    );
  }

  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    bool canNavigate =
        goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text("No ${goBack ? 'back' : 'forward'} history item")),
      );
    }
  }
}

