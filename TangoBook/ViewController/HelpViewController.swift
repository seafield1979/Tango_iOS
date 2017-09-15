//
//  HelpViewController.swift
//  TangoBook
//    ヘルプページ用のUIWebViewを表示する
//
//  Created by Shusuke Unno on 2017/09/15.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var mWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mWebView.delegate = self


//        let fileManager = FileManager.default
//        var URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        URL = URL.appendingPathComponent("html/index.html")
//        
//        let request = NSURLRequest(url: URL)
//        mWebView!.loadRequest(request as URLRequest)
        
//        let filePath = ("html" as  NSString).appendingPathComponent("index.html")
//        let url : NSURL = NSURL(fileURLWithPath : filePath)
//        let request : NSURLRequest = NSURLRequest(url : url as URL)
//        mWebView!.loadRequest(request as URLRequest)
        
//        let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "html")!
//        let url = NSURL(string : path)!
//        let urlRequest = URLRequest(url: url as URL)
//        self.mWebView.loadRequest( urlRequest )
        
        
        if let _url = Bundle.main.url(forResource: "index.html", withExtension: nil) {
            let urlRequest = URLRequest(url: _url)
            self.mWebView.loadRequest( urlRequest )
        }
    }

    // MARK: UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        return true
    }
}
