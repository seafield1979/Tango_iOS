//
//  TangoCardDao.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit


public class TangoStudiedCardDao {
    /**
    * Constants
    */
    public static let TAG = "TangoStudiedCardDao"

    public static var mRealm : Realm?
    
    // アプリ起動時にRealmオブジェクトを生成したタイミングで呼び出す
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    /**
    * 要素数を取得
    */
    public static func getNum() -> Int {
        return mRealm!.objects(TangoStudiedCard.self).count
    }
    
    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * @param list
     * @return
     */
    public static func toChangeable( _ list : Results<TangoStudiedCard>) -> [TangoStudiedCard]
    {
        var ret : [TangoStudiedCard] = []
        for obj in list {
            ret.append(obj.copy() as! TangoStudiedCard)
        }
        return ret
    }

    /**
    * 取得系(Selection type)
    */
    /**
    * TangoTag 全要素取得
    * @return nameのString[]
    */
    public static func selectAll() -> [TangoStudiedCard] {
        let results = mRealm!.objects(TangoStudiedCard.self)
        return toChangeable(results)
    }
    
    public static func showAll() {
        let results = selectAll()
        for card in results {
            print( String(format: " historyId:%d cardId:%d okFlag:%@",
                          card.getBookHistoryId(),
                          card.getCardId(),
                          card.okFlag.description
            ))
        }
    }

    /**
    * 指定bookHistoryIdに関連付けられたカードを取得
    * @param bookHistoryId
    * @return
    */
    public static func selectByHistoryId(_ bookHistoryId : Int) -> [TangoStudiedCard]{

        let results = mRealm!.objects(TangoStudiedCard.self)
            .filter("bookHistoryId = %d", bookHistoryId)
//
//        if (UDebug.debugDAO) {
//            for card in results {
//                print(" historyId:%d  cardId:%d  okFlag:%@",
//                      card.getBookHistoryId(),
//                      card.getCardId(),
//                      card.isOkFlag().description
//                )
//            }
//        }
        return toChangeable(results)
    }

    /**
    * 追加系 (Addition type)
    */
    public static func addStudiedCards(bookHistoryId : Int,
                                       okCards : [TangoCard],
                                       ngCards : [TangoCard])
    {
        try! mRealm!.write() {
            for card in okCards {
                let item = TangoStudiedCard()
                item.setBookHistoryId(bookHistoryId: bookHistoryId);
                item.setCardId(cardId: card.getId());
                item.setOkFlag(okFlag: true);
                mRealm!.add(item)
            }
            for card in ngCards {
                let item = TangoStudiedCard()
                item.setBookHistoryId(bookHistoryId: bookHistoryId)
                item.setCardId(cardId: card.getId())
                item.setOkFlag(okFlag: false)
                mRealm?.add(item)
            }
        }
    }
    /**
    * 削除系 (Delete type)
    */
    /**
    * 全削除 for Debug
    */
    public static func deleteAll() {
        let results = mRealm!.objects(TangoStudiedCard.self)
        if results.count == 0 {
            return
        }
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
    }

    /**
    * 指定の BookHistoryIdのレコードを削除
    * @param bookHistoryId
    */
    public static func deleteByHistoryId(_ bookHistoryId : Int) {
        let results = mRealm!.objects(TangoStudiedCard.self)
            .filter("bookHistoryId = %d", bookHistoryId)
        
        if results.count == 0 {
            return
        }

        try! mRealm!.write() {
            mRealm!.delete(results)
        }
    }

    /**
    * XMLファイルから読み込んだデータを追加する
    */
    public static func addBackupCard( studiedCards: [StudiedC], transaction : Bool) {
        if studiedCards.count == 0 {
            return
        }
        if transaction {
            try! mRealm!.write() {
                addBackupCardCore(studiedCards : studiedCards)
            }
        } else {
            addBackupCardCore(studiedCards : studiedCards)
        }
    }
    
    private static func addBackupCardCore( studiedCards : [StudiedC]) {
        for _card in studiedCards {
            let card = TangoStudiedCard()
            
            card.cardId = _card.cardId
            card.bookHistoryId = _card.bookHistoryId
            card.okFlag = _card.okFlag
            mRealm!.add(card)
        }
    }
}

