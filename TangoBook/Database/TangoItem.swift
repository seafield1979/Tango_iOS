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

public enum TangoItemType {
    case Card       // カード
    case Book       // 単語帳
    case Trash      // ゴミ箱
    ;
}

public protocol TangoItem {
    func getId() -> Int
    func getPos() -> Int
    func setPos(pos : Int)
    
    func getTitle() -> String
    func getItemType() -> TangoItemType
    
    func setItemPos(itemPos : TangoItemPos)
    func getItemPos() -> TangoItemPos
    
    func getCreateTime() -> Date
    func getUpdateTime() -> Date
    func getLastStudiedTime() -> Date
}
