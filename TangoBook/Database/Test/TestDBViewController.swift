//
//  TestDBViewController.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/22.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TestDBViewController: UNViewController {
    
    static let BUTTON_AREA_H : CGFloat = 100.0
    
    var textView : UITextView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // テスト用の処理を呼び出すボタン
        let scrollView = UIViewUtil.createButtonsWithScrollBar(
            parentView: self,
            y : 0, height: TestDBViewController.BUTTON_AREA_H, count : 10,
            lineCount: 3, text: "test", tagId: 1,
            selector: #selector(self.tappedButton(_:)))
        
        if scrollView != nil {
            self.view.addSubview(scrollView!)
        }
        
        // UITextViewを作成
        self.textView = createTextView(
            frame: CGRect(x:0, y:TestDBViewController.BUTTON_AREA_H,
                            width: self.view.frame.size.width,
                            height: self.view.frame.size.height - TestDBViewController.BUTTON_AREA_H))
        
        if self.textView != nil {
            self.view.addSubview(self.textView!)
            self.textView!.text = "hello world"
        }

    }
    
    /**
     UITextViewを生成する
     */
    func createTextView(frame: CGRect) -> UITextView {
        let textView = UITextView(frame: frame)
        // textView.delegate = self
        
        // いろいろ設定
        // フォント
        //textView.font = UIFont(name:"Helvetica", size: 30.0)
        
        // 背景色
        textView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        // 編集可能(falseだとリードオンリーになる)
        textView.isEditable = true
        
        // テキストの色
        textView.textColor = UIColor.blue
        
        // テキストの水平揃え
        // left,center,right
        textView.textAlignment = NSTextAlignment.left
        
        // 入力時のキーボードを指定する
        // textView.keyboardType = UIKeyboardType.asciiCapable
        
        return textView
    }
    
    func tappedButton(_ sender: AnyObject) {
        switch sender.tag {
        case 1:
            print("apple")
        case 2:
            print("mango")
        case 3:
            print("orange")
        case 4:
            print("banana")
        default:
            print("other fruit")
            break
        }
    }

    
}
