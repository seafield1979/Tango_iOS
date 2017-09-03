//
//  SaveStudiedCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

/**
 * Created by shutaro on 2017/06/14.
 *
 * TangoStudiedCard保存用
 * 単語帳を学習するたびに学習した単語帳の情報を保持するBHistoryレコードが作成され、このレコードの配下に
 * どのカードを学習した情報が入る。ここクラスはその情報を保持する。
 */
public class StudiedC {
    var bookHistoryId : Int   // bookHistoryId
    var cardId : Int        // cardId
    var okFlag : Bool     // okFlag
    
    public init(bookHistoryId : Int, cardId : Int, okFlag : Bool) {
        self.bookHistoryId = bookHistoryId
        self.cardId = cardId
        self.okFlag = okFlag
    }
}

/**
 * バックアップファイルにTangoStudiedCardを保存、復元する処理を行うクラス
 */
public class SaveStudiedCard : SaveItem {

    /**
     * Constructor
     * @param buffer
     */
    override public init( buf: ByteBuffer) {
        super.init(buf: buf)
    }

    /**
     * カードの学習履歴を１件書き込む
     * @param output
     * @param card
     * @throws IOException
     */
    public func writeData( output : OutputStream, card : TangoStudiedCard) {
        mBuf.clear()

        // int bookHistoryId
        mBuf.putInt(card.getBookHistoryId())

        // int cardId
        mBuf.putInt(card.getCardId())

        // boolean okFlag
        mBuf.put( card.isOkFlag() ? 1 : 0)

        // ファイルに書き込み(サイズ + 本体)
        writeShort(output: output, data: Int16(mBuf.array().count))
        output.write(mBuf.array(), maxLength: mBuf.array().count)
    }

    /**
     * バックアップファイルからTangoCardデータを読み込む
     * @param inputBuf  データを読み込む元のバイナリデータ
     * @return
     */
    public func readData() -> StudiedC? {
        // カードデータのサイズを取得
        let size = mBuf.getShort()
        let buf = mBuf.getBuffer(size: Int(size))
        if buf == nil {
            return nil
        }
        
        let historyId : Int = buf!.getInt()
        let cardId : Int = buf!.getInt()
        let okFlag : Bool = buf!.getByte() == 0 ? false : true
        
        let card = StudiedC(bookHistoryId: historyId, cardId : cardId, okFlag : okFlag)
        
        return card
    }
}

