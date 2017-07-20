//
//  TangoCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

/**
 * Created by shutaro on 2016/12/15.
 *
 * TangoBookHistoryの学習で学習したカードを記録したテーブル
 * 学習したカード１枚につき１つ記録する
 */

public class TangoStudiedCard : Object {
    
    public dynamic var bookHistoryId : Int = 0      // TangoBookHistory の id
    
    public dynamic var cardId : Int = 0             // TangoCard の id
    
    public dynamic var okFlag : Bool = false         // 単語を覚えたかどうか ★アイコンの色がついていたらtrue
    
    // インデックス
    override public static func indexedProperties() -> [String] {
        return ["bookHistoryId"]
    }
    
    /**
     * Get/Set
     */
    public func isOkFlag() -> Bool {
        return okFlag;
    }
    
    public func setOkFlag(okFlag : Bool) {
        self.okFlag = okFlag
    }
    
    public func getCardId() -> Int {
        return cardId
    }
    
    public func setCardId(cardId : Int) {
        self.cardId = cardId
    }
    
    public func getBookHistoryId() -> Int {
        return bookHistoryId
    }
    
    public func setBookHistoryId(bookHistoryId : Int) {
        self.bookHistoryId = bookHistoryId
    }
}
