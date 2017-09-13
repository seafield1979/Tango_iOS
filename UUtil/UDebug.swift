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
    public static let isDebug = true
    
    // IconをまとめたブロックのRECTを描画するかどうか
    public static let DRAW_ICON_BLOCK_RECT = false
    
    public static let drawIconId = false
    
    // UDrawableオブジェクトの描画範囲をライン描画
    public static let drawRectLine = false
    
    // Select時にログを出力
    public static let debugDAO = false
    
    // テキストのベース座標に+を描画
    public static let drawTextBaseLine = false
    
    
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
//        MySharedPref.getInstance().writeBool(MySharedPref.InitializeKey, true)
    }
}
