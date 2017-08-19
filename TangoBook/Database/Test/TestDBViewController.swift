//
//  TestDBViewController.swift
//  TangoBook
//     Realmのテーブル (TangoCard)のテスト
//  Created by Shusuke Unno on 2017/07/22.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TestDBViewController: UNViewController {
    
    static let BUTTON_AREA_H : CGFloat = 100.0
    
    static let buttonNames : [String] = ["Select All", "Select On", "Add Dummy", "Update One", "Delete One", "Delete All"]
    
    var textView : UITextView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // テスト用の処理を呼び出すボタン
        let scrollView = UIViewUtil.createButtonsWithScrollBar2(
            topScene: self,
            y : 0, height: TestDBViewController.BUTTON_AREA_H, count : 10,
            lineCount: 3, texts: TestDBViewController.buttonNames, tagId: 1,
            selector: #selector(self.tappedButton(_:)))
        
        if scrollView != nil {
            self.view.addSubview(scrollView!)
        }
        
        // UITextViewを作成
        self.textView = UIViewUtil.createTextView(
            frame: CGRect(x:0, y:TestDBViewController.BUTTON_AREA_H,
                            width: self.view.frame.size.width,
                            height: self.view.frame.size.height - TestDBViewController.BUTTON_AREA_H))
        
        if self.textView != nil {
            self.view.addSubview(self.textView!)
            self.textView!.text = "hello world"
        }

    }
        
    func tappedButton(_ sender: AnyObject) {
        switch sender.tag {
        case 1:
            selectAll()
        case 2:
            selectOne()
        case 3:
            addOne()
        case 4:
            updateOne()
        case 5:
            deleteOne()
        case 6:
            deleteAll()
        default:
            print("other fruit")
            break
        }
    }
    
    // TangoCardの全オブジェクト表示
    func selectAll() {
        // テキストをクリア
        self.textView!.text.removeAll()
        
        let cards = TangoCardDao.selectAll()
        
        for card in cards {
            self.textView!.text.append(card.debugDescription + "\n")
        }
    }

    func selectOne() {
        
    }
    
    // ダミーカードを１つ追加
    func addOne() {
        TangoCardDao.addDummy()
        
        selectAll()
    }
    
    // １件更新
    func updateOne() {
        // 最初のカードを更新
        let cards = TangoCardDao.selectAll()
        if cards.count < 1 {
            return
        }
        let card = cards.first
        
        TangoCardDao.updateOne(id: card!.getId(), wordA: "update A", wordB: "update B")
        
        // 表示
        selectAll()
    }
    
    // １件削除
    func deleteOne() {
        // 最初のカードを削除
        let cards = TangoCardDao.selectAll()
        if cards.count < 1 {
            return
        }
        let card = cards.first
        
        _ = TangoCardDao.deleteById(card!.getId())
        
        // 表示更新
        selectAll()
    }
    
    // 全て削除
    func deleteAll() {
        // 全オブジェクト削除
        _ = TangoCardDao.deleteAll()
        
        // 表示更新
        selectAll()
    }
}
