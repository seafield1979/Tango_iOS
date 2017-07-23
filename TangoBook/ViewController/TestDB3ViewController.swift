//
//  TestDB3ViewController.swift
//  TangoItemPos
//     Realmのテーブル (TangoItemPos)のテスト
//  Created by Shusuke Unno on 2017/07/23.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TestDB3ViewController: UNViewController {
    
    static let BUTTON_AREA_H : CGFloat = 100.0
    
    static let buttonNames : [String] = ["Select All", "Select One", "Add Dummy", "Update One", "Delete One", "Delete All"]
    
    var textView : UITextView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テスト用の処理を呼び出すボタン
        let scrollView = UIViewUtil.createButtonsWithScrollBar2(
            parentView: self,
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
    
    // TangoItemPosの全オブジェクト表示
    func selectAll() {
        // テキストをクリア
        self.textView!.text.removeAll()
        
        let poses = TangoItemPosDao.selectAll()
        
        for pos in poses {
            self.textView!.text.append(pos.debugDescription + "\n")
        }
    }
    
    func selectOne() {
        
    }
    
    // ダミーアイテムを１つ追加
    func addOne() {
        TangoItemPosDao.addDummy()
        
        selectAll()
    }
    
    // １件更新
    func updateOne() {
        // 最初のアイテムを更新
        let poses = TangoItemPosDao.selectAll()
        if poses.count < 1 {
            return
        }
        let itemPos = poses.first
        if itemPos == nil {
            return
        }
        
        TangoItemPosDao.updateOne( oldParentType: itemPos!.parentType,
                                   newParentType: 0,
                                     oldParentId: itemPos!.parentId,
                                     newParentId: 1,
                                     oldPos: itemPos!.pos,
                                     newPos : 1)

        // 表示
        selectAll()
    }
    
    // １件削除
    func deleteOne() {
        // 最初のアイテムを削除
        let poses = TangoItemPosDao.selectAll()
        if poses.count < 1 {
            return
        }
        let itemPos = poses.first
        if itemPos == nil {
            return
        }
        
        _ = TangoItemPosDao.deleteOne(parentType: itemPos!.parentType,
                                       parentId: itemPos!.parentId,
                                       pos: itemPos!.pos)
        // 表示更新
        selectAll()
    }
    
    // 全て削除
    func deleteAll() {
        // 全オブジェクト削除
        _ = TangoItemPosDao.deleteAll()
        
        // 表示更新
        selectAll()
    }
}
