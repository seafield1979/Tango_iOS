//
//  BackupFileInfo.swift
//  TangoBook
//      バックアップファイルの情報
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

public class BackupFileInfo {
    private var cardNum : Int        // 総カード数
    private var bookNum : Int        // 総ブック数
    private var backupDate : Date    // バックアップ日時
    
    // MARK: Accessor
    public func getCardNum() -> Int {
        return cardNum
    }
    
    public func getBookNum() -> Int {
        return bookNum
    }
    
    public func getBackupDate() -> Date {
        return backupDate
    }
    
    // MARK: Initializer
    public init( backupDate : Date, bookNum : Int, cardNum : Int)
    {
        self.backupDate = backupDate
        self.bookNum = bookNum
        self.cardNum = cardNum
    }
}
