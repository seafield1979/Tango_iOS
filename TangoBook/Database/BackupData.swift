//
//  BackupData.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


public struct BackupData {
    // backup file version
    public let version = 100
    
    // Number of card
    public var cardNum : Int = 0
    
    // Number of book
    public var bookNum : Int = 0
    
    // last update date
    public var updateDate : Date?
    
    /**
     * Database
     */
    // card
    public var cards : [TangoCard]?
    
    // book
    public var books : [TangoBook]?
    
    // card&book location
    public var itemPoses : [TangoItemPos]?
    
    // 学習単語帳履歴(1学習1履歴)
    public var bookHistories : [TangoBookHistory]?
    
    // 学習カード(1回学習するたびに1つ)
    public var studiedCards : [TangoStudiedCard]?
}
