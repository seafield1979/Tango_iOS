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
 * Created by shutaro on 2016/12/04.
 *
 * Cardの学習履歴等の情報
 * 1枚のカードにつき１レコード
 */

public class TangoCardHistory : Object, NSCopying {
    /**
     * Constants
     */
    // OK/NG履歴数
    public static let CORRECT_HISTORY_MAX = 10
    
    /**
     * Member varialbes
     */
    public dynamic var cardId : Int = 0
    
    // 正解フラグの数(最大 CORRECT_HISTORY_MAX)
//    public dynamic var correctFlagNum : Int = 0
    
    // 正解フラグ
    // Realm(Swift)では 配列をサポートしていないのでiOS版では履歴なし
//    public dynamic var correctFlags : [UInt8] = Array(repeating: 0, count: TangoCardHistory.CORRECT_HISTORY_MAX)
    
    // 最後に学習した日付
    public dynamic var studiedDate : Date? = nil
    
    public dynamic var isCopied : Bool = false      // コピーオブジェクト
    // 正解フラグリスト
//    public dynamic var correctFlagsList : [UInt8] = []
    
    
    //インデックスの指定にはindexedProperties()をoverrideします。
    //インデックスが指定出来るのは整数型、Bool、String、NSDateのプロパティです。
    override public static func indexedProperties() -> [String] {
        // titleにインデックスを貼る
        return ["cardId"]
    }
    
    //保存しないプロパティを指定する場合、ignoredProperties()をoverrideします。
    override public static func ignoredProperties() -> [String] {
        return ["correctFlagsList", "isCopied"]
    }

    // オブジェクトのコピーを返す
    // Realmが返すオブジェクトに変更を加えるにはトランザクションを張らないといけない
    // ただの構造体として値を代入したい場合はコピーを使用する
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TangoCardHistory()

        copy.cardId = cardId
        copy.studiedDate = studiedDate
        copy.isCopied = true
        
        return copy
    }

    /**
     * Member methods
     */
    /**
     * correctFlags -> correctFlagsList に変換
     */
//    private func toCorrectList() {
//        correctFlagsList.removeAll()
//        
//        for i in 0...correctFlagNum - 1 {
//            correctFlagsList.append(UInt8(correctFlags[i]))
//        }
//    }
    
    /**
     * correctFlagsList -> correctFlags 変換
     */
//    private func toCorrectArray() {
//        if (correctFlagsList.count > TangoCardHistory.CORRECT_HISTORY_MAX) {
//            return
//        }
//        
//        self.correctFlagNum = correctFlagsList.count
//        
//        var flags : [UInt8] = Array(repeating: 0,
//                                    count: TangoCardHistory.CORRECT_HISTORY_MAX)
//        for i in 0...correctFlagNum - 1 {
//            flags[i] = correctFlagsList[i]
//        }
//        self.correctFlags = flags
//    }
    
    /**
     * correctFlagsListに正解フラグを１つ追加
     * 少し遅いが一旦LinkedListに変換してから使用する
     * @param correctFlag
     */
//    public func addCorrectFlags(_ correctFlag : Bool) {
//        // ArrayからListに変換
//        toCorrectList()
//        
//        // リストがいっぱいなら古いもの（先頭）から削除
//        if correctFlagsList.count >= TangoCardHistory.CORRECT_HISTORY_MAX {
//            correctFlagsList.removeFirst()
//        }
//        correctFlagsList.append( UInt8(correctFlag ? 1 : 0))
//        
//        // Arrayに戻す
//        toCorrectArray()
//    }
    
    /**
     * correctFlagsを文字列で取得
     * 正解は○、不正解は×
     */
//    public func getCorrectFlagsAsString() -> String {
//        if (correctFlagNum == 0) {
//            return "---"
//        }
//        
//        var strBuf = "old: "
//        for i in 0...correctFlagNum - 1 {
//            strBuf.append((correctFlags[i] == 0) ? "×" : "○")
//        }
//        strBuf.append(" :new")
//        return strBuf
//    }
    
}
