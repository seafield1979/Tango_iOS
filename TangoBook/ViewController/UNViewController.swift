//
//  UNViewController.swift
//  UIViewTest
//
//  Created by Shusuke Unno on 2017/07/22.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import UIKit

class UNViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーにViewが重ならないようにする
        self.edgesForExtendedLayout = []
    }
}
