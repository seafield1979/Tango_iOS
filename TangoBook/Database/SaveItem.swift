//
//  SaveItem.swift
//  TangoBook
//      データをファイルに保存するクラスの親クラス
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

public class SaveItem {
    
    // MARK: Properties
    var mBuf : ByteBuffer
    private var intBuf : [Byte]   // BufferedInputStreamから int型のデータを取得するためのバッファ

    // MARK: Initializer
    init( buf : ByteBuffer) {
        mBuf = buf
        intBuf = Array(repeating: 0, count : 4)
    }

    // MARK: Static Methods
    /**
     * Date型のデータをバイナリ形式で書き込む
     * @param date     書き込む日付情報
     */
//    public func writeDate( date : Date) {
//        mBuf.putDate(date)
//    }
//
//    /**
//     * バイナリ形式のDateデータを読み込む
//     */
//    public func readDate() -> Date {
//        return mBuf.getDate()
//    }
//
//    /**
//     * 文字列を書き込む
//     * @param str
//     * @throws IOException
//     */
//    public func writeString(str : String){
//        mBuf.putString(str: str)
//    }
//
//    /**
//     * 文字列を読み込む
//     * @return 読み込んだ文字列
//     */
//    public func readString() -> String {
//        return mBuf.getStringWithSize()
//    }
//
    /**
     * ファイルにShortの値(2byte)を書き込む
     * @param output   書き込み先のファイル
     * @param data     書き込みデータ
     * @throws IOException
     */
    public func writeShort( output : OutputStream, data : Int16) {
        intBuf[0] = Byte(data >> 8)
        intBuf[1] = Byte(data & 0xff)

        output.write(intBuf, maxLength: 2)
    }
//
//    /**
//     * Shortの値(2byte)を読み込む
//     * @param input
//     * @return
//     * @throws IOException
//     */
//    public short readShort(BufferedInputStream input) throws IOException {
//        input.read(intBuf, 0, 4);
//
//        return (short)((intBuf[0] << 8) | intBuf[1]);
//    }
//
//    /**
//     * ファイルにIntの値(4byte)を書き込む
//     * @param output   書き込み先のファイル
//     * @param data     書き込みデータ
//     * @throws IOException
//     */
//    public void writeInt(BufferedOutputStream output, short data) throws IOException {
//        intBuf[0] = (byte)(data >> 24);
//        intBuf[1] = (byte)(data >> 16);
//        intBuf[2] = (byte)(data >> 8);
//        intBuf[3] = (byte)(data & 0xff);
//
//        output.write(intBuf, 0, 4);
//    }
//
//    /**
//     * Intの値(4byte)を読み込む
//     * @param input
//     * @return
//     */
//    public int readInt(BufferedInputStream input) throws IOException {
//        input.read(intBuf, 0, 4);
//
//        return (intBuf[0] << 24) | (intBuf[1] << 16) | (intBuf[3] << 8) | intBuf[3];
//    }
}

