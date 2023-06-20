//
//  PrivacyViewController.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//


import WebKit
import UIKit
import SwiftUI
@available(iOS 14.5, *)
public class PrivacyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        dump(message)
        if message.name == "onSub" {
            if UserDefaultsManager.shared.getRoute() == "true" {
                closePrivacyVC(window: window)
                launchVC(window: window)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url?.absoluteString
        
        if(url!.contains("sms:"))
        {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    public  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    lazy var webView: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0,
                                                          width: UIScreen.main.bounds.width,
                                                          height: UIScreen.main.bounds.height))
    lazy var closeButton: UIButton = UIButton(frame:CGRect(x: 0, y: 0,
                                                           width: 30, height: 30))
    
    @objc func closeButtonTapped() {
        closePrivacyVC(window: window)
    }
    
    var window = UIWindow(frame: UIScreen.main.bounds)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(closeButton)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
       
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(named: "AccentColor")
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        closeButton.isHidden = true
        
        let config = self.webView.configuration
        config.userContentController.add(self,name: "onSub")
        
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.navigationDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        webView.uiDelegate = self
        
        if SettingsScenesPrivate.global.privacyB == true {
            do {
                closeButton.isHidden = true
                guard let filePath = Bundle.main.path(forResource: SettingsScenesPrivate.global.url, ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
                }
                
                let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
                let baseUrl = URL(fileURLWithPath: filePath)
                webView.loadHTMLString(contents as String, baseURL: baseUrl)
            }
            catch {
                print ("File HTML error")
            }
            
        } else {
            closeButton.isHidden = true

            if let webViewLinkString = UserDefaultsManager.shared.loadUrl() {
                print("@@@@@@@@@ \(webViewLinkString)")
                guard let url = URL(string: webViewLinkString) else { return }
                webView.load(URLRequest(url: url))
                webView.allowsBackForwardNavigationGestures = true
            } else {
                //                        print("%%% Can't loade link from UserDefaults")
            }
        }
    }
//    func dismissVCAfterSeconds(for seconds: Int) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(seconds)) {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
    
    func closePrivacyVC(window: UIWindow) {
        self.dismiss(animated: true) {
            SettingsScenesPrivate.global.privacyB = true
            UserDefaultsManager.shared.preference = .CommonContent
            UserDefaultsManager.shared.setUrl(to: nil)
            
        }
//        UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.dismiss(animated: true) {
//        }
    }
    
    public func launchVC(window: UIWindow) {
        UIApplication.shared.keyWindow?.rootViewController = UIHostingController(rootView: LaunchView(isPresented: true))
    }
}
