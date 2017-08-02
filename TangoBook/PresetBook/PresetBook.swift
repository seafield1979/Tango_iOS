//
//  PresetBook.swift
//  TangoBook
//      プリセット単語帳を保持するクラス
//  Created by Shusuke Unno on 2017/07/31.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


public class PresetBook {
    public var mName : String = ""
    public var mComment : String? = nil
    public var mColor : UIColor? = nil
    private var mCsvName : String? = nil    // リソースファイルのファイルパス
    private var mFile : String? = nil       // ストレージに保存したファイルのパス

    private var mCards : List<PresetCard>? = nil

    /**
     * Get/Set
     */
    public func getCards() -> List<PresetCard> {
        if mCards == nil {
            if mCsvName != nil {
                mCards = CsvParser.getPresetCardsFromResourceFile(csvName: mCsvName!)
            } else if mFile != nil {
                mCards = CsvParser.getPresetCardsFromStorageFile(csvName: mFile!)
            }
        }
        return mCards!
    }
//    public func getFileName() -> String {
//        if mFile != nil {
//            return "(" + mFile.getName() + ")"
//        }
//        return ""
//    }

    /**
     * Constructor
     */
    // アプリ内のCSVから追加する
    public init( csvName : String, name : String, comment : String?, color : UIColor?) {
        mCsvName = csvName
        mName = name
        mComment = comment
        mColor = color
    }
    // ストレージにあるCSVから追加する
//    public init( file : String, name : String, comment : String?, color : UIColor?) {
//        mName = name
//        mFile = file
//        mComment = comment
//        mColor = color
//    }

    public func addCard( _ card : PresetCard) {
        if mCards != nil {
            mCards!.append(card)
        }
    }

    public func log() {
        ULog.printMsg(PresetBookManager.TAG, "bookName:" + mName + " comment:" + mComment!)
    }
}
