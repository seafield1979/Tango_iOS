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

/**
 * Created by shutaro on 2016/12/04.
 *
 * Cardの履歴のDAO
 */
public class TangoCardHistoryDao {
    /**
     * Constants
     */
    public static let TAG = "TangoCardDao";

    public static var mRealm : Realm?
    
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    /**
     * 要素数を取得
     */
    public static func getNum() -> Int {
        return mRealm!.objects(TangoCardHistory.self).count
    }

    /**
     * Choice4
     */
    public static func selectAll() -> [TangoCardHistory] {
        let results = mRealm!.objects(TangoCardHistory.self)

        if UDebug.debugDAO {
            print("TangoCardHistory selectAll")
            for history in results {
                // todo
                print( String(format: "cardId:%d correctNum:%d flags:%d",
                              history.cardId,
                              history.correctFlagNum))
            }
        }
        
        return Array(results)
     }

     /**
     * Book情報から選択
     * @param card
     * @return
     */
    public static func selectByCard(card : TangoCard) -> TangoCardHistory? {
        let result = mRealm!.objects(TangoCardHistory.self)
            .filter("cardId = %d", card.getId())
            .first
        return result
    }

     /**
     * Add
     */
    public static func addOne(cardId : Int, correctFlag : Bool) -> Bool {
        let history = TangoCardHistory()
        history.cardId = cardId
//        history.addCorrectFlags(correctFlag)
        history.studiedDate = Date()

        try! mRealm!.write() {
            mRealm!.add(history)
        }
        return true
    }

    /**
    * Delete
    */

    /**
    * 配下の学習カード履歴も含めてすべて削除
    */
    public static func deleteAll() {
        let results = mRealm!.objects(TangoCardHistory.self)
        
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
    }

    /**
     指定のカードに対応する履歴を１件削除
     - parameter cadId: カードID
     */
    public static func deleteByCardId(cardId : Int) -> Bool {
        let result = mRealm!.objects(TangoCardHistory.self)
            .filter("cardId = %d", cardId)
            .first
        if result == nil {
            return false
        }

        try! mRealm!.write() {
            mRealm!.delete(result!)
        }
        return true
    }

    /**
    * Update
    */
    /**
     指定のカードの履歴を１件更新
     - parameter cardId: 更新するカードID
     - parameter correctFlag: 新しい正解フラグ
     */
    public static func updateOne(cardId : Int, correctFlag : Bool) -> Bool {
        let result = mRealm!.objects(TangoCardHistory.self)
            .filter("cardId = %d", cardId)
            .first
        if result == nil {
            // なかったら追加する
            _ = addOne(cardId: cardId, correctFlag: correctFlag)
            return true
        }

        try! mRealm!.write() {
            // 更新
//            result!.addCorrectFlags(correctFlag)
        }
        return true
    }

     /**
     * Add or Update list
     */
    public static func updateCards( okCards : [TangoCard], ngCards : [TangoCard]) {
         for card in okCards {
            _ = updateOne(cardId: card.getId(), correctFlag: true)
         }
         for card in ngCards {
            _ = updateOne(cardId: card.getId(), correctFlag: false)
         }
     }

     /**
     * XMLファイルから読み込んだデータを追加する
     */
    // todo CHistoryを実行するまで未実装
//     public void addXmlCard(List<CHistory> cardHistory, boolean transaction) {
//         if (cardHistory == null || cardHistory.size() == 0) {
//             return;
//         }
//         if (transaction) {
//             mRealm!.beginTransaction();
//         }
//         for (CHistory _history : cardHistory) {
//             TangoCardHistory history = new TangoCardHistory();
//             history.setCardId( _history.getCardId());
//             history.setCorrectFlagNum( _history.getCorrectFlagNum());
//             history.setCorrectFlags( _history.getCorrectFlag());
//             history.setStudiedDate( _history.getStudiedDate());
//             mRealm!.insert(history);
//         }
//         if (transaction) {
//             mRealm!.commitTransaction();
//         }
//     }
 }

