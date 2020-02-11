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
        let controller: FlutterViewController = self.window?.rootViewController as! FlutterViewController;
        let shareChannel:FlutterMethodChannel = FlutterMethodChannel.init(name: shareChannelName, binaryMessenger: controller as! FlutterBinaryMessenger);
        
        shareChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "shareFile") {
                self.shareFile(sharedItems: call.arguments!,controller: controller);
            }
        });    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func shareFile(sharedItems:Any, controller:UIViewController) {
        let filePath:NSMutableString = NSMutableString.init(string: sharedItems as! String);
        let docsPath:NSString = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]) as NSString;
        let imagePath = docsPath.appendingPathComponent(filePath as String);
        let imageUrl = URL.init(fileURLWithPath: imagePath, relativeTo: nil);
        do {
            let imageData = try Data.init(contentsOf: imageUrl);
            let shareImage = UIImage.init(data: imageData);
            let activityViewController:UIActivityViewController = UIActivityViewController.init(activityItems: [shareImage!], applicationActivities: nil);
            controller.present(activityViewController, animated: true, completion: nil);
        } catch let error {
            print(error.localizedDescription);
        }
    }
    
}
