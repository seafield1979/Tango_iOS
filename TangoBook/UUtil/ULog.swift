//
//  ULog.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit

class ULog {
    public static let TAG = "ULog"
    private static let isEnable = true
    private static let isCount = true
    private static let NANO_TO_SEC = 1000000000
    
    /**
     * Static variables
     */
    static var enables : Dictionary<String, Bool> = Dictionary()
    static var counters : Dictionary<String, Int> = Dictionary()
    // @todo private static var logWindow : ULogWindow
    
    /**
     * Get/Set
     */
    // タグのON/OFFを設定する
    public static func setEnable(_ tag : String, _ enable : Bool) {
        enables[tag] = enable;
    }
    
    // @Todo ULogWindowが実装されたらコメント解除
    //    public static func setLogWindow(_logWindow : ULogWindow) {
    //        logWindow = _logWindow;
    //    }
    
    // 初期化、アプリ起動時に１回だけ呼ぶ
    public static func initialize() {
//        setEnable(ViewTouch.TAG,        false)
//        setEnable(UDrawManager.TAG,     false)
//        setEnable(UMenuBar.TAG,         false)
//        setEnable(UMenuItem.TAG,         false)
//        setEnable(UScrollBar.TAG,       false)
        //        setEnable(UIconWindow.TAG,      false)
        //        setEnable(UButton.TAG,          false)
        setEnable(UColor.TAG,           false)
//        setEnable(UResourceManager.TAG, false)
        //        setEnable(UWindow.TAG,          false)
        //        setEnable(BackupManager.TAG,    false)
        //        setEnable(PageViewDebug.TAG,    false)
        
    }
    
    // ログ出力
    public static func printMsg(_ tag: String,_ msg : String)
    {
        if !isEnable {
            return
        }
        let enable = enables[tag]
        if enable != nil && enable! == true {
            let time = NanoTimer.nanoTime()
            print(time.description + ": " + msg)
        }
    }
    
    /**
     * カウントする
     * start - count ... - end
     */
    public static func startCount(tag : String) {
        if !isCount {
            return
        }
        counters[tag] = 0
    }
    
    public static func startAllCount() {
        if !isCount {
            return
        }
        
        for (key, _) in counters {
            counters[key] = 0
        }
    }
    
    
    public static func count(_ tag: String) {
        if !isCount {
            return
        }
        
        var count = counters[tag];
        if count == nil {
            return
        }
        count = count! + 1;
        counters[tag] = count
    }
    
    public static func showCount(tag : String) {
        if !isCount {
            return
        }
        
        // 有効無効判定
        let enable = enables[tag]
        if enable == nil || enable! == false {
            // 出力しない
        } else {
            print( tag + " count:" + counters[tag]!.description);
        }
    }
    
    public static func showAllCount() {
        if !isCount {
            return
        }
        
        for (key, _) in counters {
            showCount(tag:key);
        }
    }
    
    public static func showRect(rect : CGRect) {
        print( String(format: "Rect left: %f top: %f  right: %f bottom: %f",
                      rect.origin.x,
                      rect.origin.y,
                      rect.origin.x + rect.size.width,
                      rect.origin.y + rect.size.height));
    }
}
