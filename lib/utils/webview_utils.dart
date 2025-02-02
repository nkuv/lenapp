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

      // Scroll speed limiter
      let scrollSpeedFactor = 0.08; // Reduce this for slower scrolling
      window.addEventListener('wheel', function(event) {
        event.preventDefault();
        window.scrollBy(0, event.deltaY * scrollSpeedFactor);
      }, { passive: false });

      // Disable scroll acceleration (momentum scrolling)
      let isTouching = false;
      window.addEventListener('touchstart', function() {
        isTouching = true;
      });

      window.addEventListener('touchmove', function(event) {
        if (!isTouching) {
          event.preventDefault();
        }
      }, { passive: false });

      window.addEventListener('touchend', function() {
        isTouching = false;
      });

      // Disable momentum scrolling on iOS
      document.documentElement.style.overscrollBehavior = 'none';
      document.body.style.overscrollBehavior = 'none';
    }
    disableZoom();
  ''');
}
