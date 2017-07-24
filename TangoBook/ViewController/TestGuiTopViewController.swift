//
//  TestGuiTopViewController.swift
//  TangoBook
//     GUIテスト用ページのViewController
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TestGuiTopViewController: UNViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カスタムView追加
        let newView = TestGuiView()
        newView.setViewController(self)
        let screenSize : CGSize = UIScreen.main.bounds.size
        
        newView.frame.size = CGSize(width:screenSize.width,
                                    height:screenSize.height)
        newView.frame.origin = CGPoint(x:0, y:0)
        self.view.addSubview(newView)
    }
}

