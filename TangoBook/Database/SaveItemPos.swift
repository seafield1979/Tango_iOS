//
//  SaveItemPos.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation



/**
 * TangoItemPos保存用
 */
public class Pos {
    var parentType : Int  // parentType
    var parentId : Int    // parentId
    var pos : Int
    var itemType : Int    // itemType
    var itemId : Int      // itemId
    
    public init(parentType : Int, parentId : Int, pos : Int, itemType : Int, itemId : Int) {
        self.parentType = parentType
        self.parentId = parentId
        self.pos = pos
        self.itemType = itemType
        self.itemId = itemId
    }
}

// TangoItemPosをバックアップファイルに保存、復元する処理を行うクラス
public class SaveItemPos : SaveItem {

    /**
     * Member Variables
     */

    /**
     * Constructor
     * @param buffer
     */
    override public init( buf : ByteBuffer) {
        super.init(buf: buf)
    }

    /**
     * 単語アイテムの位置情報を1件書き込む
     * @param output    書き込み先のファイル
     * @param itemPos
     * @throws IOException
     */
    public func writeData( output : OutputStream, itemPos : TangoItemPos) {
        mBuf.clear()

        // int parentType
        mBuf.putByte(Byte(itemPos.parentType))

        // int parentId
        mBuf.putInt(itemPos.getParentId())

        // int pos
        mBuf.putInt(itemPos.getPos());

        // int itemType
        mBuf.putByte( Byte(itemPos.getItemType()))

        // int itemId
        mBuf.putInt(itemPos.getItemId())

        // ファイルに書き込み(サイズ + 本体)
        writeShort(output: output, data: Int16(mBuf.array().count))
        output.write(mBuf.array(), maxLength: mBuf.array().count)
    }

    /**
     * バックアップファイルからTangoBookデータを読み込む
     * @param inputBuf  データを読み込む元のバイナリデータ
     * @return
     */
    public func readData() -> Pos {
        // カードデータのサイズを取得
        _ = mBuf.getShort()

        let parentType = mBuf.getByte()
        let parentId = mBuf.getInt()
        let position = mBuf.getInt()
        let itemType = mBuf.getByte()
        let itemId = mBuf.getInt()

        let pos = Pos(parentType : Int(parentType), parentId : parentId, pos : position, itemType : Int(itemType), itemId : itemId)
        return pos
    }
}

