import UIKit
import Flutter

@available(iOS 9.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let shareChannelName = "channel:co.deepseed.deep_seed/share"
        let fontChannelName = "channel:co.deepseed.deep_seed/font"
        let controller: FlutterViewController = self.window?.rootViewController as! FlutterViewController;
        let shareChannel:FlutterMethodChannel = FlutterMethodChannel.init(name: shareChannelName, binaryMessenger: controller as! FlutterBinaryMessenger);
        let fontChannel:FlutterMethodChannel = FlutterMethodChannel.init(name: fontChannelName, binaryMessenger: controller as! FlutterBinaryMessenger);
        
        shareChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "shareFile") {
                self.shareFile(sharedItems: call.arguments as! [String: Any],controller: controller);
            }
        });
        
         fontChannel.setMethodCallHandler({
                   (call: FlutterMethodCall, result: FlutterResult) -> Void in
                   if (call.method == "getEncoding") {
                    result(self.getEncoding())
                   }
               });
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func shareFile(sharedItems:[String: Any], controller:UIViewController) {
        let filePath:NSMutableString = NSMutableString.init(string: (sharedItems["path"] as! String));
        let shareText:NSMutableString = NSMutableString.init(string: (sharedItems["shareText"] as! String));
        let docsPath:NSString = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]) as NSString;
        let imagePath = docsPath.appendingPathComponent(filePath as String);
        let imageUrl = URL.init(fileURLWithPath: imagePath, relativeTo: nil);
        do {
            let imageData = try Data.init(contentsOf: imageUrl);
            let shareImage = UIImage.init(data: imageData);
            let activityViewController:UIActivityViewController = UIActivityViewController.init(activityItems: [shareImage!, shareText], applicationActivities: nil);
            controller.present(activityViewController, animated: true, completion: nil);
        } catch let error {
            print(error.localizedDescription);
        }
    }
    
    func getEncoding() -> Bool {
        let label1 = UILabel()
        let label2 = UILabel()
        label1.text = "က"
        label2.text = "က္က"
        label1.sizeToFit()
        label2.sizeToFit()
        return label2.frame.width == label1.frame.width
      }
}
