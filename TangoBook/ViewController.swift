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
        
        let titles : [String] = ["Card", "Book", "ItemPos", "CardHistory", "BookHistory", "StudiedCard"]
        
        let scrollView = UIViewUtil.createButtonsWithScrollBar2(
            parentView: self,
            y : 0, height: self.view.frame.size.height, count : 6,
            lineCount: 1, texts: titles, tagId: 1,
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
            viewController.title = "TangoCard"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case 2:
            // Addテストページに遷移
            let viewController = TestDB2ViewController(nibName: "TestDB2ViewController", bundle: nil)
            viewController.title = "TangoBook"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case 3:
            // Addテストページに遷移
            let viewController = TestDB3ViewController(nibName: "TestDB3ViewController", bundle: nil)
            viewController.title = "TangoItemPos"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case 4:
            let viewController = TestDB4ViewController(nibName: "TestDB4ViewController", bundle: nil)
            viewController.title = "TangoCardHistory"
            self.navigationController?.pushViewController(viewController, animated: true)
        case 5:
            let viewController = TestDB5ViewController(nibName: "TestDB5ViewController", bundle: nil)
            viewController.title = "TangoBookHistory"
            self.navigationController?.pushViewController(viewController, animated: true)
        case 6:
            let viewController = TestDB6ViewController(nibName: "TestDB6ViewController", bundle: nil)
            viewController.title = "TangoStudiedCard"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        default:
            print("other fruit")
        }
    }
}

