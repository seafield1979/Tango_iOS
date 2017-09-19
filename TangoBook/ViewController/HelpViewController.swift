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

    private var mRequest : URLRequest?
    
    // MARK : Accessor
    public func setRequest( _ request: URLRequest ) {
        mRequest = request
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mWebView.delegate = self

        if let request = mRequest {
            self.mWebView.loadRequest( request )
        } else {
            if let _url = Bundle.main.url(forResource: "index.html", withExtension: nil) {
                let urlRequest = URLRequest(url: _url)
                self.mWebView.loadRequest( urlRequest )
            }
        }
    }

    // MARK: UIWebViewDelegate
    /**
     * ページ内のリンクがクリックされた時に呼ばれる処理
     */
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        if navigationType == .linkClicked {
            // "戻る"のリンクならページバック
            if let url = request.url {
                if url.absoluteString.hasSuffix("return") {
                    self.navigationController?.popViewController(animated: true)
                    return false
                } else if url.absoluteString.hasSuffix("index.html") {
                    // ヘッダをクリックした際の処理
                    if (self.navigationController?.viewControllers.count)! > 2 {
                        self.navigationController?.popViewController(animated: true)
                        return false
                    } else {
                        // ルートなので何もしない
                        return false
                    }
                }
             }
            
            // リンクをクリックされたのでページ遷移
            let viewController = HelpViewController(
                nibName: "HelpViewController",
                bundle: nil)
            viewController.setRequest( request )

            self.navigationController?.pushViewController(viewController, animated: true)
            return false
        }
        return true
    }
}
