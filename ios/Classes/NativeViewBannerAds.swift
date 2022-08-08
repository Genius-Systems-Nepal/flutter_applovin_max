import Flutter
import UIKit
import AppLovinSDK

class NativeViewBannerAdsFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeViewBannerAds(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeViewBannerAds: NSObject, FlutterPlatformView {
    
    var adView: MAAdView!
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        var adUnitId = ""
        if let dic = args as? [String: Any], let unitId = dic["UnitId"] as? String {
            adUnitId = unitId
        }
        adView = MAAdView(adUnitIdentifier: adUnitId)
        super.init()
        // iOS views can be created here
        createNativeAdView()
    }
    
    func view() -> UIView {
        return adView
    }
    
    func createNativeAdView() {
        adView.delegate = self

        // Banner height on iPhone and iPad is 50 and 90, respectively
        let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50

        // Stretch to the width of the screen for banners to be fully functional
        let width: CGFloat = UIScreen.main.bounds.width

        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        // Set background or background color for banners to be fully functional
        adView.backgroundColor = UIColor.white

        // Load the first ad
        adView.loadAd()
    }
}

extension NativeViewBannerAds: MAAdViewAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        globalMethodChannel?.invokeMethod("AdLoaded", arguments: nil)
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }

    func didClick(_ ad: MAAd) {
        globalMethodChannel?.invokeMethod("AdClicked", arguments: nil)
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        globalMethodChannel?.invokeMethod("AdFailedToDisplay", arguments: nil)
    }

    func didExpand(_ ad: MAAd) {}

    func didCollapse(_ ad: MAAd) {}
    
    func didDisplay(_ ad: MAAd) {
        globalMethodChannel?.invokeMethod("AdDisplayed", arguments: nil)
    }
    
    func didHide(_ ad: MAAd) {
        globalMethodChannel?.invokeMethod("AdHidden", arguments: nil)
    }
}
