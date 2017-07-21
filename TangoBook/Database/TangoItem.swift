//
//  TangoItem.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


/**
 * 単語帳のアイテムを同じListに入れるためのインターフェース
 * ※RealmObjectを親クラスにしたベースクラスを作ろうとするとRealmでエラーが起きるので
 * やむなくインターフェースで実装
 */
/**
 * 単語帳のアイテムの種類
 */

public enum TangoItemType : Int, EnumEnumerable{
    case Card = 0       // カード
    case Book = 1       // 単語帳
    case Trash = 2      // ゴミ箱
    
    public static func toEnum(_ value : Int) -> TangoItemType {
        if value >= TangoItemType.count {
            // 範囲外は適当な値を返す
            return TangoItemType.Card
        }
        return TangoItemType.cases[value]
    }
}

public protocol TangoItem {
    func getId() -> Int
    func getPos() -> Int
    func setPos(pos : Int)
    
    func getTitle() -> String?
    func getItemType() -> TangoItemType
    
    func setItemPos(itemPos : TangoItemPos?)
    func getItemPos() -> TangoItemPos?
    
    func getCreateTime() -> Date?
    func getUpdateTime() -> Date?
//    func getLastStudiedTime() -> Date
}
