import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<void> injectDisableZoom(InAppWebViewController controller) async {
  await controller.evaluateJavascript(source: '''
    function disableZoom() {
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
      
      document.body.style.touchAction = "pan-x pan-y"; 
      document.body.style.userSelect = "none"; 
      document.body.style.zoom = "86%"; 
      document.body.style.imageRendering = "auto";
      document.body.style.webkitFilter = "none";
      document.body.style.setProperty("image-rendering", "auto");    

      // Limit scroll speed by modifying the wheel event
      window.addEventListener('wheel', function(event) {
        event.preventDefault(); // Prevent default scrolling behavior
        var scrollSpeed = 0.3; // Set the desired scroll speed
        window.scrollBy(0, event.deltaY * scrollSpeed); // Adjust scroll speed
      });
    }
    disableZoom();
  ''');

}
