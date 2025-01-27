import 'package:webview_flutter/webview_flutter.dart';

Future<void> injectDisableZoom(WebViewController controller) async {
  await controller.runJavaScript(
      '''
    function disableZoom() {
      document.body.style.touchAction = "pan-x pan-y"; 
      document.body.style.userSelect = "none"; 
      document.body.style.zoom = "86%"; 
      document.body.style.imageRendering = "auto";
      document.body.style.imageRendering = "auto";  
      document.body.style.webkitFilter = "none";
      document.body.style.setProperty("image-rendering", "auto");    
    }
    disableZoom();
    '''
  );
}