//
//  TestDB5ViewController.swift
//  TangoBook
//     Realmのテーブル (TangoBookHistory)のテスト
//  Created by Shusuke Unno on 2017/07/23.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TestDB5ViewController: UNViewController {
    
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
    
    /**
     UITextViewを生成する
     */
    
    
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
    
    // TangoBookの全オブジェクト表示
    func selectAll() {
        // テキストをクリア
        self.textView!.text.removeAll()
        
        let books = TangoBookDao.selectAll()
        
        for book in books {
            self.textView!.text.append(book.debugDescription + "\n")
        }
    }
    
    func selectOne() {
        
    }
    
    // ダミーアイテムを１つ追加
    func addOne() {
        TangoBookDao.addDummy()
        
        selectAll()
    }
    
    // １件更新
    func updateOne() {
        // 最初のアイテムを更新
        let books = TangoBookDao.selectAll()
        if books.count < 1 {
            return
        }
        let book = books.first
        
        TangoBookDao.updateOne(id: book!.getId(), name: "update A")
        
        // 表示
        selectAll()
    }
    
    // １件削除
    func deleteOne() {
        // 最初のアイテムを削除
        let books = TangoBookDao.selectAll()
        if books.count < 1 {
            return
        }
        let book = books.first
        
        _ = TangoBookDao.deleteById(book!.getId())
        
        // 表示更新
        selectAll()
    }
    
    // 全て削除
    func deleteAll() {
        // 全オブジェクト削除
        _ = TangoBookDao.deleteAll()
        
        // 表示更新
        selectAll()
    }
}
