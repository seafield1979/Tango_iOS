//
//  ViewController.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class ViewController: UNViewController {

   
    static let BUTTON_AREA_H : CGFloat = 200.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIViewUtil.createButtonsWithScrollBar(
            parentView: self,
            y : 0, height: self.view.frame.size.height, count : 6,
            lineCount: 1, text: "test", tagId: 1,
            selector: #selector(self.tappedButton(_:)))
        
        if scrollView != nil {
            self.view.addSubview(scrollView!)
        }
    }
    
    
    func tappedButton(_ sender: AnyObject) {
        switch sender.tag {
        case 1:
            // Addテストページに遷移
            let viewController = TestDBViewController(nibName: "TestDBViewController", bundle: nil)
            viewController.title = "testDB"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case 2:
            print("mango")
        case 3:
            print("orange")
        case 4:
            print("banana")
        default:
            print("other fruit")
        }
    }
}

