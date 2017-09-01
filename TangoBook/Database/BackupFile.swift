//
//  TangoCard.swift
//  TangoBook
//
//  バックアップファイル情報
//  バックアップは複数作れるのでテーブルで管理する
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import RealmSwift

public class BackupFile : Object, NSCopying {
    public dynamic var id : Int = 0               // バックアップ番号 1,2,3...
    public dynamic var enabled : Bool = false    // 使用中かどうか(アプリ初期化時にレコードを作成するため、レコードがあっても未使用状態もある）
    public dynamic var filePath : String? = nil    // バックアップファイルパス
    public dynamic var cardNum : Int = 0        // 総カード数
    public dynamic var bookNum : Int = 0        // 総ブック数
    public dynamic var dateTime : Date? = nil      // 保存日時
    
    /**
     * Get/Set
     */
    public func getId() -> Int{
        return id
    }
    
    public func setId( id : Int) {
        self.id = id
    }
    
    public func isEnabled() -> Bool{
        return enabled
    }
    
    public func setEnabled( enabled : Bool) {
        self.enabled = enabled
    }
    
    public func getFilePath() -> String? {
        return filePath
    }
    
    public func setFilePath(filePath : String) {
        self.filePath = filePath
    }
    
    public func getCardNum() -> Int{
        return cardNum
    }
    
    public func setCardNum(cardNum : Int) {
        self.cardNum = cardNum
    }
    
    public func getBookNum() -> Int {
        return bookNum
    }
    
    public func setBookNum(bookNum : Int) {
        self.bookNum = bookNum
    }
    
    public func getDateTime() -> Date? {
        return dateTime
    }
    
    public func setDateTime(dateTime : Date?) {
        self.dateTime = dateTime
    }
    
    // idをプライマリキーに設定
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    /**
     * Methods
     */
    /**
     * 自動バックアップのレコードかどうかの判定
     * @return
     */
    public func isAutoBackup() -> Bool {
        if id == BackupFileDao.AUTO_BACKUP_ID {
            return true
        }
        return false
    }
    
    // MARK : NSCopying
    
    // オブジェクトのコピーを返す
    // Realmが返すオブジェクトに変更を加えるにはトランザクションを張らないといけない
    // ただの構造体として値を代入したい場合はコピーを使用する
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BackupFile()
        copy.id = id
        copy.enabled = enabled
        copy.filePath = filePath
        copy.cardNum = cardNum
        copy.bookNum = bookNum
        copy.dateTime = dateTime

        return copy
    }

}
