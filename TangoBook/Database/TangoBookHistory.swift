//
//  TangoBook.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

/**
 * Created by shutaro on 2016/12/04.
 *
 * Bookの学習履歴
 * １つのBookに複数の履歴を持つことも可能
 */

public class TangoBookHistory : Object {
    /**
     * Constants
     */
    public static let CARD_IDS_MAX = 100
    
    public dynamic var id : Int = 0
    
    public dynamic var bookId : Int = 0
    
    // OK数
    public dynamic var okNum : Int = 0
    
    // NG数
    public dynamic var ngNum : Int = 0
    
    // 学習日
    public dynamic var studiedDateTime : Date? = nil
    
    // idをプライマリキーに設定
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    //インデックスの指定にはindexedProperties()をoverrideします。
    //インデックスが指定出来るのは整数型、Bool、String、NSDateのプロパティです。
    override public static func indexedProperties() -> [String] {
        // titleにインデックスを貼る
        return ["bookId"]
    }
}
