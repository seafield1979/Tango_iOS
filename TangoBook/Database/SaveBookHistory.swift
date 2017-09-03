//
//  SaveBookHistory.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation



/**
 * TangoBookHistory保存用
 */
public struct BHistory {
    var id : Int
    var bookId : Int         // bookId
    var okNum : Int          // okNum
    var ngNum : Int          // ngNum
    var studiedDate : Date?  // StudiedDateTime
    
    public init(id : Int, bookId : Int, okNum : Int, ngNum : Int, studiedDate : Date) {
        self.id = id
        self.bookId = bookId
        self.okNum = okNum
        self.ngNum = ngNum
        self.studiedDate = studiedDate
    }
}

/**
 * TangoBookHistory をバックアップファイルに保存、復元するためのクラス
 */
public class SaveBookHistory : SaveItem {

    // MARK: Initializer
    override public init( buf: ByteBuffer) {
        super.init(buf: buf)
    }

    /**
     * バックアップファイルからTangoCardデータを読み込む
     * @param inputBuf データを読み込む元のバイナリデータ
     * @return
     */
    public func readData() -> BHistory? {
        // カードデータのサイズを取得
        let size = mBuf.getShort()
        let buf = mBuf.getBuffer(size: Int(size))
        if buf == nil {
            return nil
        }

        let id : Int = buf!.getInt()
        let bookId : Int = buf!.getInt()
        let okNum : Int16 = buf!.getShort()
        let ngNum : Int16 = buf!.getShort()
        let studiedTime : Date = buf!.getDate()

        let history = BHistory(id : id, bookId : bookId, okNum : Int(okNum), ngNum : Int(ngNum), studiedDate : studiedTime)

        return history;
    }

    /**
     * 単語帳の学習情報を１件書き込む
     * @param output       書き込み先のファイル
     * @param history
     * @throws IOException
     */
    public func writeData( output : OutputStream, history : TangoBookHistory) {
        mBuf.clear()

        // int id
        mBuf.putInt(history.id)

        // int bookId
        mBuf.putInt(history.bookId)

        // int okNum
        mBuf.putShort( Int16(history.okNum) )

        // int ngNum
        mBuf.putShort( Int16(history.ngNum) )

        // Date studiedDateTime
        mBuf.putDate( history.studiedDateTime )

        // ファイルに書き込み(サイズ + 本体)
        writeShort(output: output, data: Int16(mBuf.array().count))
        output.write(mBuf.array(), maxLength: mBuf.array().count)
    }
}

