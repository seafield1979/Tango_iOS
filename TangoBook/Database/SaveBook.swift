//
//  SaveBook.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


/**
 * TangoBook保存用
 */
public struct Book {
    var id : Int
    var name : String?        // 単語帳の名前
    var comment : String?      // 単語帳の説明
    var color : UInt          // 表紙の色
    var createdDate : Date?         // 作成日時
    var studiedDate : Date?       // 学習日時
    var isNew : Bool      // 新規作成フラグ

    public init(id : Int, name : String?, comment : String?, color : UInt,
                createDate : Date?, studiedDate : Date?, isNew : Bool) {
        self.id = id
        self.name = name
        self.comment = comment
        self.color = color
        self.createdDate = createDate
        self.studiedDate = studiedDate
        self.isNew = isNew
    }
}

public class SaveBook : SaveItem {

    /**
     * Member Variables
     */

    // MARK: Initializer
    override public init( buf : ByteBuffer) {
        super.init(buf: buf)
    }

    /**
     * 単語帳データを１件書き込む
     * @param output    書き込み先のファイル
     * @param book      書き込み単語帳
     * @throws IOException
     */
    public func writeData( output : OutputStream, book : TangoBook) {
        mBuf.clear()

        // id
        mBuf.putInt(book.getId())

        // name
        mBuf.putStringWithSize(book.getName())
        // comment
        mBuf.putStringWithSize(book.getComment())
        // color
        mBuf.putInt(book.getColor())

        // createTime   作成日時
        mBuf.putDate(book.getCreateTime())
        // lastStudiedTime 最終学習日
        mBuf.putDate(book.getLastStudiedTime())

        // isNew
        mBuf.putByte( book.isNewFlag() ? 1 : 0 )

        // ファイルに書き込み(サイズ + 本体)
        writeShort(output: output, data: Int16(mBuf.array().count))
        
        output.write(mBuf.array(), maxLength: mBuf.array().count)
    }

    /**
     * バックアップファイルからTangoBookデータを読み込む
     * @param inputBuf データを読み込む元のバイナリデータ
     * @return
     */
    public func readData() -> Book? {
        // データのサイズを取得
        let size = mBuf.getShort()
        let buf = mBuf.getBuffer(size: Int(size))
        if buf == nil {
            return nil
        }
        
        // 読み込んだバッファからデータを取得
        let id = buf!.getInt()
        let name = buf!.getStringWithSize()
        let comment = buf!.getStringWithSize()
        let color = buf!.getUInt()
        let createDate = buf!.getDate()
        let studiedDate = buf!.getDate()
        let isNew = buf!.getByte() == 0 ? false : true

        let book = Book(id : id, name : name, comment : comment, color : color, createDate : createDate, studiedDate : studiedDate, isNew : isNew)
        return book
    }
}

