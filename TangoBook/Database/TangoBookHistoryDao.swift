//
//  TangoBookDao.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

 public class TangoBookHistoryDao {
    /**
     * Constants
     */
    public static let TAG = "TangoBookHistoryDao"
    public static var mRealm : Realm?
    
    // アプリ起動時にRealmオブジェクトを生成したタイミングで呼び出す
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    /**
     * 要素数を取得
     */
    public static func getNum() -> Int {
        let count = mRealm!.objects(TangoBookHistory.self).count as Int!
        
        return count!
    }
    
    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * @param list
     * @return
     */
    public static func toChangeable( _ list : Results<TangoBookHistory>) -> [TangoBookHistory]
    {
        var ret : [TangoBookHistory] = []
        for obj in list {
            ret.append(obj.copy() as! TangoBookHistory)
        }
        return ret
    }

     /**
     * 全て選択
     * @param reverse  並び順を逆順にする
     * @return
     */
    public static func selectAll(reverse : Bool) -> [TangoBookHistory] {
        let results = mRealm!.objects(TangoBookHistory.self)
            .sorted(byKeyPath: "studiedDateTime", ascending: !reverse)
        
        return toChangeable(results)
    }
    
    /**
     * 全てのオブジェクトを表示する for Debug
     */
    public static func showAll() {
        let objects = selectAll(reverse : false)
        
        print("TangoBookHistory num: " + objects.count.description)
        
        for obj in objects {
            print(obj.description)
        }
    }

    /**
     件数を制限してオブジェクトを検索する
     ※ Realmは遅延読み込みのため、Limitを使用しなくても遅くなることがない。そのためLimit的な命令が存在しない
     - parameter reverse: trueなら降順
     - parameter limit: 最大取得件数
     */
    public static func selectAllWithLimit(reverse : Bool, limit : Int) -> [TangoBookHistory]
    {
        let results = mRealm!.objects(TangoBookHistory.self)
            .sorted(byKeyPath: "studiedDateTime", ascending: !reverse)
        
        let histories = toChangeable(results)
        
        if (histories.count > limit) {
            // リミット以上ならリミット数まで削減して返す
            var limitList : [TangoBookHistory] = []
            var limitCount = 0
            for history in histories {
                limitList.append(history)
                limitCount += 1
                if ( limitCount >= limit) {
                    break
                }
            }
            return limitList
        }

        return histories
     }


    /**
     * Book情報から選択
     * @param book
     * @return
     */
    public static func selectByBook(book : TangoBook) -> [TangoBookHistory] {
        let results = mRealm!.objects(TangoBookHistory.self)
            .filter("bookId = %d", book.id)
        
        return toChangeable(results)
    }

    /**
     * 指定のBookの最後の学習日を取得
     * @param bookId
     * @return
     */
    public static func selectMaxDateByBook(bookId : Int) -> Date? {
        let date = mRealm!.objects(TangoBookHistory.self)
            .filter("bookId = %d", bookId)
            .max(ofProperty: "studiedDateTime") as Date!
        
        if date == nil {
            return nil
        }
        
        return date!
    }

     /**
     * Add
     */
     /**
     * レコードを１つ追加
     * @param bookId
     * @param okNum
     * @param ngNum
     * @return 作成したレコードのid
     */
    public static func addOne(bookId : Int, okNum : Int, ngNum : Int) -> Int
    {
        let history = TangoBookHistory()
        let id = getNextId()
        history.id = id
        history.bookId = bookId
        history.okNum  = okNum
        history.ngNum = ngNum
        history.studiedDateTime = Date()

        try! mRealm!.write() {
            mRealm!.add(history)
        }

        return id;
    }

     /**
     * Delete
     */
     /**
     * 配下の学習カード履歴も含めてすべて削除
     */
     public static func deleteAll() {
        let results = mRealm!.objects(TangoBookHistory.self)

        // 学習カード履歴削除
        for history in results {
            TangoStudiedCardDao.deleteByHistoryId(history.id)
        }

        try! mRealm!.write() {
            mRealm!.delete(results)
        }
    }

    /**
     指定した単語帳の学習履歴を削除
     - parameter bookId: 単語帳Id
     */
    public static func deleteByBookId(bookId : Int) -> Bool {
         let results = mRealm!.objects(TangoBookHistory.self)
            .filter("bookId = %d", bookId)
        
        if results.count == 0 {
            return false
        }

        try! mRealm!.write() {
            mRealm!.delete(results)
        }
        
        return true
     }

     /**
     * Update
     */

     /**
     * かぶらないプライマリIDを取得する
     * @return
     */
     public static func getNextId() -> Int {
        // 初期化
        var nextId : Int = 1
        // userIdの最大値を取得
        let lastId = mRealm!.objects(TangoBookHistory.self).max(ofProperty: "id") as Int?
        
        if lastId != nil {
            nextId = lastId! + 1
        }
        return nextId

     }


     /**
     * ファイルから読み込んだデータを追加する
     */
    public static func addBackupBook( histories : [BHistory], transaction : Bool) {
        if histories.count == 0 {
            return
        }
        
        if transaction {
           try! mRealm!.write() {
               addBackupBookCore(histories: histories)
            }
        } else {
            addBackupBookCore(histories: histories)
        }
     }
    
    private static func addBackupBookCore( histories : [BHistory]) {
        for _history in histories {
            let history = TangoBookHistory()
            history.id = _history.id
            history.bookId = _history.bookId
            history.okNum = _history.okNum
            history.ngNum = _history.ngNum
            history.studiedDateTime = _history.studiedDate
            
            mRealm!.add(history)
        }
    }
 }

