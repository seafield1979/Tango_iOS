//
//  TangoCard.swift
//  TangoBook
//    単語帳のカード１枚分の情報
//    Realmの保存するオブジェクト
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

/**
 * 単語カード
 * RealmObjectのサブクラスなのでそのままテーブルとして使用される
 */
public class TangoCard : Object, TangoItem, NSCopying {
    public dynamic var id : Int = 0
    
    public dynamic var originalId : Int = 0     // コピー元のカードのID
    
    public dynamic var wordA : String? = nil       // 単語帳の表
    public dynamic var wordB : String? = nil      // 単語帳の裏
    public dynamic var comment : String? = nil     // 説明や例文
    public dynamic var createTime : Date? = nil    // 作成日時
    public dynamic var updateTime : Date? = nil    // 更新日時
    
    public dynamic var color : Int = 0          // カードの色
    public dynamic var star : Bool = false         // 覚えたフラグ
    public dynamic var isNew : Bool = true      // 新規作成フラグ
    
    public dynamic var itemPos : TangoItemPos? = nil   // どこにあるか？
    
    // idをプライマリキーに設定
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    //保存しないプロパティ
    override public static func ignoredProperties() -> [String] {
        return ["itemPos"]
    }
    
    /*
     * Override
     */
    
    
    /**
     * Constructor
     */
    
    public static func createCard() -> TangoCard {
        let card = TangoCard()
        card.originalId = 0
        card.isNew = true
        card.color = (UIColor.black).intColor()
        card.wordA = ""
        card.wordB = ""
        card.star = false
        card.createTime = Date()
        card.updateTime = Date()
        
        return card
    }
    
    // テスト用のダミーカードを取得
    public static func createDummyCard() -> TangoCard {
        let randVal : Int = Int(arc4random() % 1000)
        let card = TangoCard()
        card.wordA = " " + String(randVal)
        card.wordB = "あ " + String(randVal)
        card.comment = "C " + String(randVal)
        card.color = (UIColor.black).intColor()
        card.star = false
        card.isNew = true
        return card
    }
    
    
    // コピーを作成する
    // idが異なる別のオブジェクト
    public static func copyCard(card : TangoCard) -> TangoCard {
        let newCard = TangoCard()
        newCard.id = TangoCardDao.getNextId()
        if card.wordA != nil {
            newCard.wordA = card.wordA
        }
        if card.wordB != nil {
            newCard.wordB = card.wordB
        }
        newCard.createTime = Date()
        newCard.updateTime = Date()
        
        newCard.color = card.color
        newCard.star = card.star
        return newCard
    }
    
    /**
     * TangoItem interface
     */
    public func getId() -> Int {
        return id
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
    
    public func getTitle() -> String? {
        return wordA
    }
    public func getItemType() -> TangoItemType {
        return TangoItemType.Card
    }
    
    public func setItemPos(itemPos : TangoItemPos?) {
        self.itemPos = itemPos
    }
    public func getItemPos() -> TangoItemPos? {
        return itemPos
    }
    
    public func getCreateTime() -> Date? {
        return createTime
    }
    public func getUpdateTime() -> Date? {
        return updateTime
    }
    
    // MARK : NSCopying 
    
    // オブジェクトのコピーを返す
    // Realmが返すオブジェクトに変更を加えるにはトランザクションを張らないといけない
    // ただの構造体として値を代入したい場合はコピーを使用する
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TangoCard()
        copy.id = id
        copy.originalId = originalId
        copy.isNew = isNew
        copy.color = color
        copy.wordA = wordA
        copy.wordB = wordB
        copy.star = star
        copy.createTime = createTime
        copy.updateTime = updateTime
        
        return copy
    }
}
