//
//  TopViewController.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TopViewController: UNViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // カスタムView追加
        let newView = TangoTopView()
        
        newView.setViewController(self)
        
        let haviH : CGFloat = UUtil.navigationBarHeight()
        var _height = self.view.frame.size.height - haviH - UUtil.statusBarHeight()
            
        
        newView.frame = CGRect(x:0, y:0,
                               width: self.view.frame.size.width,
                                height: _height)
        self.view.addSubview(newView)

    }
}
