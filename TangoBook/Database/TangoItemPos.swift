//
//  TangoCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

/**
 * 単語帳を保持する親の種類
 */
public enum TangoParentType : Int, EnumEnumerable {
    case Home = 0       // ホーム画面
    case Book           // 単語帳
    case Trash          // ゴミ箱
    
    static func toString(value : TangoParentType) -> String {
        switch(value) {
        case .Home:
            return "Home"
        case .Book:
            return "Book"
        case .Trash:
            return "Trash"
        }
    }
    }

/**
 * 単語帳のアイテムの場所を特定する情報
 *
 * 特定のアイテム以下にあるアイテムを検索するのに使用する
 * 例: ホーム以下
 *      指定の単語帳以下
 *      指定のボックス以下
 *      ゴミ箱以下
 * posは自分が所属するグループ内での配置位置
 */
public class TangoItemPos : Object {
    
    // 親の種類 TangoParentType(0:ホーム / 1:単語帳 / 2:ゴミ箱)
    public dynamic var parentType : Int = TangoParentType.Home.rawValue
    
    // 親のID
    public dynamic var parentId : Int = 0
    
    // 表示場所 0...
    public dynamic var pos : Int = 0
    
    // アイテムの種類 TangoItemType( 0:カード / 1:単語帳 / 2:ボックス)
    public dynamic var itemType : Int = 0
    
    // 各アイテムのID
    public dynamic var itemId : Int = 0
    
    public dynamic var isChecked : Bool = false
    
    // インデックス
    override public static func indexedProperties() -> [String] {
        return ["parentType", "parentId", "pos", "itemType", "itemId", "isChecked"]
    }
    
    /**
     * Get/Set
     */
    public func getParentId() -> Int {
        return parentId
    }
    
    public func setParentId(parentId : Int) {
        self.parentId = parentId
    }
    
    public func getPos() -> Int {
        return pos
    }
    
//    public func setPos(_ pos : Int) {
//        self.pos = pos
//    }
    
    public func getItemType() -> Int {
        return itemType
    }
    
//    public func setItemType(_ itemType : Int) {
//        self.itemType = itemType
//    }
    
    public func getItemId() -> Int{
        return itemId
    }
    
    public func setItemId(id : Int) {
        self.itemId = id
    }
    
    public func setChecked(_ checked : Bool) {
        isChecked = checked
    }
    
    public func setParams(pos : Int, type : Int, id : Int) {
        self.pos = pos
        self.itemType = type
        self.itemId = id
    }
}
