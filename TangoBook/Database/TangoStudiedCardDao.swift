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
    * 取得系(Selection type)
    */
    /**
    * TangoTag 全要素取得
    * @return nameのString[]
    */
    public static func selectAll() -> [TangoStudiedCard] {
        let results = mRealm!.objects(TangoStudiedCard.self)
        
        if (UDebug.debugDAO) {
            for card in results {
                print( String(format: " historyId:%d cardId:%d okFlag:%@",
                              card.getBookHistoryId(),
                              card.getCardId(),
                              card.okFlag.description
                        ))
            }
        }
        return Array(results)
    }

    /**
    * 指定bookHistoryIdに関連付けられたカードを取得
    * @param bookHistoryId
    * @return
    */
    public static func selectByHistoryId(bookHistoryId : Int) -> [TangoStudiedCard]{

        let results = mRealm!.objects(TangoStudiedCard.self)
            .filter("bookHistoryId = %d", bookHistoryId)

        if (UDebug.debugDAO) {
            for card in results {
                print(" historyId:%d  cardId:%d  okFlag:%@",
                      card.getBookHistoryId(),
                      card.getCardId(),
                      card.isOkFlag().description
                )
            }
        }
        return Array(results)
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
    public static func deleteByHistoryId(bookHistoryId : Int) {
        let results = mRealm!.objects(TangoStudiedCard.self)
            .filter("bookHistoryId", bookHistoryId)
        
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
    // todo StudiedC を実装後に対応
//    public static func addXmlCard( studiedCard: [StudiedC], transaction : Bool) {
//        if studiedCard.count == 0 {
//            return
//        }
//        if transaction {
//            try! mRealm!.write() {
//                for _card : studiedCard {
//                    let card = TangoStudiedCard()
//                    card.setCardId( _card.getCardId());
//                    card.setBookHistoryId( _card.getBookHistoryId());
//                    card.setOkFlag( _card.isOkFlag());
//                    
//                    mRealm.copyToRealm(card);
//                }
//            }
//        } else {
//            
//        }
//        
//    }
}
