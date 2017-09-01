//
//  TangoCardDao.swift
//  TangoBook
//      バックアップファイル情報のDAO
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import RealmSwift

public class BackupFileDao {
    // MARK: Constants
    public static let TAG = "BackupFileDao"

    public static let AUTO_BACKUP_ID : Int = 0
    public static let MAX_BACKUP_NUM : Int = 10

    public static var mRealm : Realm?
    
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    /**
     * 全要素取得
     * @return nameのString[]
     */
    public static func selectAll() -> [BackupFile] {

        let results : Results<BackupFile> = mRealm!.objects(BackupFile.self)
        
        //　返すのはコピー。コピーでないと書き換えができない
        return toChangeable(results)
    }

    /**
     * １件取得
     * @param id
     * @return
     */
    public static func selectById(id : Int) -> BackupFile? {
        let result : BackupFile? = mRealm!.objects(BackupFile.self).filter("id = %d", id).first
        if result == nil {
            return nil
        }
        
        return result!.copy() as? BackupFile
    }

    /**
     * カード数を取得
     * @return カード数
     */
    public static func getNum() -> Int {
        let results = mRealm!.objects(BackupFile.self)
        return results.count
    }
    
    /**
     * アプリ初回起動時にレコードを作成する
     * 実際にバックアップとして使用しているレコードは enabled が trueになる
     */
    public static func createInitialRecords() {
        let count : Int = BackupFileDao.getNum()

        if count == 0 {
            try! mRealm!.write() {

                // 自動バックアップ用
                var backup = BackupFile()
                backup.setId( id: AUTO_BACKUP_ID )
                _ = backup.setEnabled( enabled: false )
                mRealm!.add(backup)

                // マニュアルバックアップ用
                for i in 0 ..< MAX_BACKUP_NUM {
                    backup = BackupFile()
                    backup.setId(id: i+1 )
                    backup.setEnabled( enabled: false)

                    mRealm!.add(backup)
                }
            }
        }
    }

    /**
     * 要素を追加
     * アプリ初回起動時にレコードだけを追加するためのメソッド
     * @param
     * @param
     */
    public static func addOne() {
        let newId : Int = getNextId()

        let backup = BackupFile()
        backup.setId(id: newId)
        backup.setEnabled( enabled: false )
        
        // データを追加
        try! mRealm!.write() {
            mRealm!.add(backup)
        }
    }

    /**
     * １件更新　バックアップが成功した後に呼ぶ
     * @param id
     * @param filePath
     * @param bookNum
     * @param cardNum
     * @return
     */
    public static func updateOne(id : Int, filePath : String, bookNum : Int, cardNum : Int) -> Bool {
        
        try! mRealm!.write() {
            let backup = mRealm!.objects(BackupFile.self)
                .filter("id=%d", id)
                .first

            backup?.setEnabled(enabled: true)
            backup?.setBookNum(bookNum: bookNum)
            backup?.setCardNum(cardNum: cardNum)
            backup?.setFilePath(filePath: filePath)
            backup?.setDateTime(dateTime: Date())
        }

        return true
    }

    /**
     * バックアップ情報をクリアする
     * @param id
     */
    public static func clearOne(id : Int) -> Bool {
        try! mRealm!.write() {
            let backup = mRealm!.objects(BackupFile.self)
                .filter("id=%d", id)
                .first

            if backup == nil {
                return
            }
            backup?.setEnabled(enabled: false)

        }

        return true
    }

    /**
     * かぶらないプライマリIDを取得する
     * @return
     */
    public static func getNextId() -> Int {
        // 初期化
        var nextId : Int = 1
        // userIdの最大値を取得
        let lastId = mRealm!.objects(BackupFile.self).max(ofProperty: "id") as Int?
        
        if lastId != nil {
            nextId = lastId! + 1
        }
        return nextId
    }
    
    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * @param list
     * @return
     */
    public static func toChangeable( _ list : Results<BackupFile>) -> [BackupFile]
    {
        var ret : [BackupFile] = []
        for obj in list {
            ret.append(obj.copy() as! BackupFile)
        }
        return ret
    }

}

