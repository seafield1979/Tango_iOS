//
//  UDebug.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/20.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit

public class UDebug {
    // Debug mode
    public static var isDebug = false
    
    // IconをまとめたブロックのRECTを描画するかどうか
    public static var DRAW_ICON_BLOCK_RECT = false
    
    public static var drawIconId = false
    
    // UDrawableオブジェクトの描画範囲をライン描画
    public static var drawRectLine = false
    
    // Select時にログを出力
    public static var debugDAO = false
    
    // テキストのベース座標に+を描画
    public static var drawTextBaseLine = false
    
    
    /**
     * Methods
     */
    /**
     * システムの全データクリア
     * アプリインストールと同じ状態に戻る
     */
    public static func clearSystemData() {
        
        // todo
        
        // MySharedPref
//        MySharedPref.clearAllData()
//        
//        // Realm
//        // データベースを削除
//        RealmManager.clearAll()
//        
//        // セーブデータを初期化
//        RealmManager.getBackupFileDao().createInitialRecords()
//        // デフォルト単語帳を追加
//        PresetBookManager.getInstance().addDefaultBooks()
//        
//        MySharedPref.getInstance().writeBoolean(MySharedPref.InitializeKey, true)
    }
}
