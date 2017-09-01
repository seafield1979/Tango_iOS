//
//  SaveCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


/**
 * TangoCard保存用
 */
public struct Card {
    var id : Int
    var wordA : String?       // 単語帳の表
    var wordB : String?       // 単語帳の裏
    var comment : String?     // 説明や例文
    var createdTime : Date?    // 作成日時
    var updateDate : Date?     // 更新日時
    var studiedDate : Date?    // 最終学習日時

    var color : UInt          // カードの色
    var star : Bool           // 覚えたフラグ
    var isNew : Bool        // 新規作成フラグ

    // Simple XML がデシリアイズするときに呼ぶダミーのコントストラクタ
    public init(id : Int, wordA : String?, wordB : String?, comment : String?, createTime : Date?,
            updateDate : Date?, studiedDate : Date?,
            color : UInt, star : Bool, isNew : Bool)
    {
        self.id = id
        self.wordA = wordA
        self.wordB = wordB
        self.comment = comment
        self.createdTime = createTime
        self.updateDate = updateDate
        self.studiedDate = studiedDate
        self.color = color
        self.star = star
        self.isNew = isNew
    }
}


/**
 * Created by shutaro on 2017/06/27.
 *
 * TangoCardをバックアップファイルに書き込むためのクラス
 */

public class SaveCard : SaveItem {
    
    // MARK: Initializer
    override init( buf : ByteBuffer ) {
        super.init(buf: buf)
    }
    
    
    // MARK: Methods
    /**
     * カード情報(TangoCard)を１件分書き込む
     * @param output  書き込み先のファイル
     * @param card    書き込むカードデータ
     */
    public func writeData( output : OutputStream, card : TangoCard) {
        mBuf.clear()
        
        // id
        mBuf.putInt(card.getId())
        
        // wordA
        // 長さと文字列
        mBuf.putString(card.wordA)
        
        // wordB
        mBuf.putString(card.wordB)
        
        // comment
        mBuf.putString(card.comment)
        
        // createTime
        mBuf.putDate(card.getCreateTime())
        
        // updateTime
        mBuf.putDate(card.getUpdateTime())
        
        // color
        mBuf.putInt(card.color)
        
        // star
        mBuf.putByte((card.star ? 1 : 0))
        
        // isNew
        mBuf.putByte((card.isNew ? 1 : 0))
        
        // ファイルに書き込み(サイズ + 本体)
        writeShort(output: output, data: Int16(mBuf.position()))
        output.write(mBuf.array(), maxLength: mBuf.array().count)
    }
    
    
    /**
     * バックアップファイルからTangoCardデータを読み込む
     * @param inputBuf  データを読み込む元のバイナリデータ
     * @return
     */
    public func readData() -> Card {
        // カードデータのサイズを取得
        _ = mBuf.getShort()
        
        // 読み込んだバッファからデータを取得
        let id = mBuf.getInt()
        let wordA = mBuf.getStringWithSize()
        let wordB = mBuf.getStringWithSize()
        let comment = mBuf.getStringWithSize()
        let createTime = mBuf.getDate()
        let updateTime = mBuf.getDate()
        let studiedTime = mBuf.getDate()
        let color = mBuf.getUInt()
        let star = mBuf.getByte() == 0 ? false : true
        let isNew = mBuf.getByte() == 0 ? false : true
        
        let card = Card(id : id, wordA : wordA, wordB : wordB, comment : comment,
                        createTime : createTime, updateDate : updateTime,
                        studiedDate : studiedTime, color : color, star : star,
                        isNew : isNew)
        return card
    }
}
