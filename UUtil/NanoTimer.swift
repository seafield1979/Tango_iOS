//
//  NanoTimer.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

class NanoTimer {
    // ナノ秒から秒に変換するのに使用する
    private static let NANO_TO_SEC = 1000000000;
    private static var info : mach_timebase_info = mach_timebase_info()
    public static var startTime : UInt64 = 0
    
    /**
     初期化処理　システム開始時に読んでください
     */
    public static func initialize() {
        info = mach_timebase_info()
        startTime = mach_absolute_time()
    }
    
    /**
     現在の時間を取得する
     */
    public static func nanoTime() -> Double {
        // 終了時間(ナノ秒)
        let nowTime : UInt64 = mach_absolute_time()
        
        info = mach_timebase_info()
        let nanos = (nowTime - startTime)// * UInt64(info.numer) / UInt64(info.denom)
        let sec = Double(nanos) / Double(NANO_TO_SEC)
        return sec
    }
}
