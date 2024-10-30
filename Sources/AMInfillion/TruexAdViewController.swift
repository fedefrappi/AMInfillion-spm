//
//  TruexAdViewController.swift
//  JSAPIReferenceApp-iOS
//
//  Created by Jesse Albini on 2/23/24.
//

import UIKit
import WebKit
import JavaScriptCore
import SafariServices

class TruexAdViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet private var webView: WKWebView!

    private var ad: InfillionManager.Ad!
    private var onStart: ((_ vc: TruexAdViewController) -> Void)!
    private var onCredit: ((_ vc: TruexAdViewController) -> Void)!
    private var onClickthrough: ((_ vc: TruexAdViewController) -> Void)!
    private var onFinish: ((_ vc: TruexAdViewController) -> Void)!
    private var onClose: ((_ vc: TruexAdViewController) -> Void)!

    static func instantiate(
        ad: InfillionManager.Ad,
        onStart: @escaping (_ vc: TruexAdViewController) -> Void,
        onCredit: @escaping (_ vc: TruexAdViewController) -> Void,
        onClickthrough: @escaping (_ vc: TruexAdViewController) -> Void,
        onFinish: @escaping (_ vc: TruexAdViewController) -> Void,
        onClose: @escaping (_ vc: TruexAdViewController) -> Void
    ) -> TruexAdViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .module)
        let vc = storyboard.instantiateViewController(withIdentifier: "truexvc") as! TruexAdViewController
        vc.ad = ad
        vc.onStart = onStart
        vc.onCredit = onCredit
        vc.onClickthrough = onClickthrough
        vc.onFinish = onFinish
        vc.onClose = onClose
        vc.modalPresentationStyle = .fullScreen
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        if #available(iOS 16.4, *) {
            #if DEBUG
            webView.isInspectable = true
            #endif
        }
        
        // add event handler for javascript messages
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "truexMessageHandler")
        
        // load adLoader.html
        if let filePath = Bundle.module.url(forResource: "adLoader", withExtension: "html"),
           let contentData = FileManager.default.contents(atPath: filePath.path) {
            webView.load(contentData, mimeType: "html", characterEncodingName: "utf8", baseURL: URL(string:"https://media.truex.com") ?? filePath)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // TrueX will configure your placement to be either portrait locked or landscape locked, make sure to set this to
        // whichever style you've discussed with your TrueX rep
        return .portrait
    }

    // handle events from Javascript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "truexMessageHandler" {
            guard let event = message.body as? [String : String] else {
                return
            }
            
            let eventName = event["eventName"];

            print("[TrueX Event] \(eventName ?? "")")

            // event handlers

            switch eventName {
            case "onStart": onStart(self)
            case "onCredit": onCredit(self)
            case "onClickthrough":
                guard let url = event["eventData"] else { break }
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "clickthroughvc") as! ClickthroughViewController
                vc.url = URL(string: url);
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)

                onClickthrough(self)
            case "onClose": onClose(self)
            case "onFinish": onFinish(self)
            default: break
            }
        }
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // trigger showAd() function in adLoader.html
        let command = "showAd('\(ad.placementKey)','\(ad.userId)',\(ad.rawString))"
        self.webView.evaluateJavaScript(command, completionHandler: nil)
    }
}
