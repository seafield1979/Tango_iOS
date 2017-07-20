//
//  TangoBook.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

public class TangoBook : Object, TangoItem {
    
    public dynamic var id : Int = 0
    
    public dynamic var name : String? = nil        // 単語帳の名前
    public dynamic var comment : String? = nil     // 単語帳の説明
    public dynamic var color : UInt32 = 0          // 表紙の色
    
    // メタデータ
    public dynamic var createTime : Date? = nil    // 作成日時
    public dynamic var updateTime : Date? = nil    // 更新日時
    public dynamic var lastStudiedTime : Date? = nil  // 最終学習日
    
    public dynamic var newFlag : Bool = false    // NEW
    
    public dynamic var itemPos : TangoItemPos? = nil   // どこにあるか？
    
    // idをプライマリキーに設定
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    //保存しないプロパティ
    override public static func ignoredProperties() -> [String] {
        return ["itemPos"]
    }
    
    
    public static func createBook() -> TangoBook {
        var book = TangoBook()
        book.newFlag = true
        book.name = ""
        book.color = (UIColor.black).intColor()
        book.createTime = Date()
        book.updateTime = Date()
        
        return book
    }
    
    // テスト用のダミーカードを取得
    public static func createDummyBook() -> TangoBook {
        let randVal = String(arc4random() % 1000)
        
        let book = TangoBook()
        book.name = "Name " + randVal
        book.comment = "Comment " + randVal
        book.color = UColor.getRandomColor()
        book.newFlag = true
        book.createTime = Date()
        book.updateTime = Date()
        
        return book
    }
    
    /**
     * Get/Set
     */
    public func getId() -> Int {
        return id;
    }
    
    public func setId(id : Int) {
        self.id = id
    }
    
    public func getTitle() -> String? {
        return name
    }
    
    public func getName() -> String? {
        return name
    }
    
    public func setName(name : String?) {
        self.name = name
    }
    
    public func getComment() -> String? {
        return comment
    }
    
    public func setComment(comment : String) {
        self.comment = comment
    }
    
    public func getColor() -> UInt32 {
        return color
    }
    
    public func setColor(color : UInt32) {
        self.color = color
    }
    
    public func getCreateTime() -> Date? {
        return createTime
    }
    
    public func setCreateTime(createTime : Date?) {
        self.createTime = createTime
    }
    
    public func getUpdateTime() -> Date? {
        return updateTime
    }
    
    public func setUpdateTime(updateTime : Date?) {
        self.updateTime = updateTime
    }
    
    public func getLastStudiedTime() -> Date? {
        return self.lastStudiedTime
    }
    
    public func setLastStudiedTime(time : Date) {
        lastStudiedTime = time
    }
    
    public func getItemPos() -> TangoItemPos? {
        return itemPos
    }
    public func setItemPos(itemPos : TangoItemPos?) {
        self.itemPos = itemPos
    }
    
    public func isNewFlag() -> Bool {
        return newFlag
    }
    
    public func setNewFlag(newFlag : Bool) {
        self.newFlag = newFlag
    }
    
    public func getPos() -> Int {
        if itemPos == nil {
            return 0
        }
        return itemPos!.getPos()
    }
    
    public func setPos(pos : Int) {
        if itemPos == nil {
            return
        }
        itemPos!.pos = pos
    }
    
    
    /**
     * コピーを作成する
     * IDはコピー元とは別物ものを割りふる
     * @param book
     * @return
     */
    public static func copyBook(book : TangoBook) -> TangoBook {
        var newBook = TangoBook()
        newBook.id = TangoBookDao.getNextId()
        if book.name != nil {
            newBook.name = book.name
        }
        if book.comment != nil {
            newBook.comment = book.comment
        }
        newBook.color = book.color
        
        // メタデータ
        newBook.createTime = Date()
        newBook.updateTime = Date()
        
        return newBook
    }
    
    /**
     * TangoItem interface
     */
    public func getItemType() -> TangoItemType {
        return TangoItemType.Book
    }
}
