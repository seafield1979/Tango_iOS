//
//  TouchView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/07.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

protocol ViewTouchCallbacks {
    // 長押しされた時の処理
    func longPressed()
}

/**
 * Created by shutaro on 2017/06/14.
 * Viewのタッチの種類
 */
public enum TouchType {
    case None
    case Touch        // タッチ開始
    case LongPress    // 長押し
    case Click        // ただのクリック（タップ)
    case LongClick    // 長クリック
    case Moving       // 移動
    case MoveEnd      // 移動終了
    case MoveCancel    // 移動キャンセル
}

public class ViewTouch {
    public static let TAG = "ViewTouch"
    
    // クリック判定するためのタッチ座標誤差
    public static let CLICK_DISTANCE : CGFloat = 30.0
    
    // ロングクリックの時間(ms)
    public static let LONG_CLICK_TIME : UInt64 = 300
    
    // 移動前の待機時間(ms)
    public static let MOVE_START_TIME : UInt64 = 100
    
    // 長押しまでの時間(ms)
    public static let LONG_TOUCH_TIME : UInt64 = 700
    
    /**
     * Propaties
     */
    private var callbacks : ViewTouchCallbacks?
    
    public var type : TouchType = .None         // 外部用のタイプ(変化があった時に有効な値を返す)
    private var innerType : TouchType = .None    // 内部用のタイプ
    private var timer : Timer? = nil
    
    public private(set) var isTouchUp : Bool = false      // タッチアップしたフレームだけtrueになる
    var isTouching : Bool = false
    private var isLongTouch : Bool = false
    
    // タッチ開始した座標
    public private(set) var touchX : CGFloat = 0.0, touchY : CGFloat = 0.0
    
    public private(set) var x : CGFloat = 0.0
    public private(set) var y : CGFloat = 0.0       // スクリーン座標
    public private(set) var moveX : CGFloat = 0.0, moveY : CGFloat = 0.0
    public private(set) var isMoveStart : Bool = false;
    
    // get/set
    public func touchX(offset: CGFloat) -> CGFloat {
        return touchX + offset
    }
    public func touchY(offset: CGFloat) -> CGFloat {
        return touchY + offset
    }
    
    // タッチ開始した時間
    var touchTime : UInt64 = 0;
    
    convenience init() {
        self.init(callback:nil)
    }
    
    init(callback : ViewTouchCallbacks?) {
        self.callbacks = callback
    }
    
    /**
     * ロングタッチがあったかどうかを取得する
     * このメソッドを呼ぶと内部のフラグをクリア
     * @return true:ロングタッチ
     */
    public func checkLongTouch() -> Bool {
        // ロングタッチが検出済みならそれを返す
        if isLongTouch {
            isLongTouch = false
            return true
        }
        return false
    }
    
    /**
        タッチ開始時の処理
     */
    public func touchStart(touch: UITouch, view: UIView) {
        ULog.printMsg(ViewTouch.TAG, "Touch Down");
        
        isTouching = true
        touchX = touch.location(in: view).x
        touchY = touch.location(in: view).y
        type = TouchType.Touch
        innerType = TouchType.Touch
        touchTime = getMilliTime()
        // todo startLongTouchTimer();
    }
    
    /**
        タッチ中の移動処理
     */
    public func touchEnd(touch: UITouch, view: UIView) -> TouchType {
        ULog.printMsg(ViewTouch.TAG, "Up");
        
        // timer.cancel();
        
        isTouchUp = true
        if isTouching {
            if innerType == TouchType.Moving {
                ULog.printMsg(ViewTouch.TAG, "MoveEnd");
                type = TouchType.MoveEnd
                innerType = TouchType.MoveEnd
                return type
            } else {
                let x = touch.location(in: view).x
                let y = touch.location(in: view).y
                let w = x - touchX;
                let h = y - touchY;
                let dist : CGFloat = sqrt(w * w + h * h)
                
                if (dist <= ViewTouch.CLICK_DISTANCE) {
                    let time : UInt64 = getMilliTime() - touchTime
                    
                    if (time <= ViewTouch.LONG_CLICK_TIME) {
                        type = TouchType.Click
                        ULog.printMsg(ViewTouch.TAG, "SingleClick")
                    } else {
                        type = TouchType.LongClick
                        ULog.printMsg(ViewTouch.TAG, "LongClick")
                    }
                } else {
                    type = TouchType.None;
                }
            }
        } else {
            type = TouchType.None;
        }
        isTouching = false;
        
        return type
    }
    
    /**
        タッチ中の移動処理
     */
    public func touchMove(touch: UITouch, view :UIView) {
        isMoveStart = false
        
        let _x : CGFloat = touch.location(in: view).x
        let _y : CGFloat  = touch.location(in: view).y
        
        ULog.printMsg(ViewTouch.TAG, String(format:"x:%f y:%f", _x, _y))
        
        // クリックが判定できるようにタッチ時間が一定時間以上、かつ移動距離が一定時間以上で移動判定される
        if ( innerType != TouchType.Moving) {
            let dx = _x - touchX
            let dy = _y - touchY
            let dist : CGFloat = sqrt(dx * dx + dy * dy);
            
            if (dist >= ViewTouch.CLICK_DISTANCE) {
                let time : UInt64 = getMilliTime() - touchTime;
                if time >= ViewTouch.MOVE_START_TIME {
                    type = TouchType.Moving
                    innerType = TouchType.Moving;
                    isMoveStart = true;
                    self.x = touchX
                    self.y = touchY
                }
            }
        }
        if  innerType == TouchType.Moving {
            // １フレーム分の移動距離
            moveX = _x - self.x;
            moveY = _y - self.y;
        } else {
            innerType = TouchType.None
            type = TouchType.None;
        }
        x = _x;
        y = _y;
    }
    
    public func getMilliTime() -> UInt64 {
        let today = Date();
        let sec = today.timeIntervalSince1970
        let millisec = UInt64(sec * 1000) // intだとあふれるので注意
        return millisec
    }
    
    /**
     * ２点間の距離が指定の距離内に収まっているかどうかを調べる
     * @return true:距離内 / false:距離外
     */
    public func checkInsideCircle(
        vx : CGFloat, vy : CGFloat, x: CGFloat, y: CGFloat,
        length : CGFloat) -> Bool
    {
        if (vx - x) * (vx - x) + (vy - y) * (vy - y) <= length * length {
            return true
        }
        return false
    }
    
    /**
     * ロングタッチ検出用のタイマーを開始
     */
    private func startLongTouchTimer() {
//    if (timer != null) {
//    timer.cancel();
//    timer = null;
//    }
//    timer = new Timer();
//    timer.scheduleAtFixedRate(new TimerTask(){
//    @Override
//    public void run() {
//    timer.cancel();
//    if (isTouching && type != TouchType.Moving) {
//    // ロングタッチを検出する
//    isLongTouch = true;
//    isTouching = false;
//    innerType = type = TouchType.LongPress;
//    // ロングタッチイベント開始はonTouchから取れないので親に通知する
//    if (callbacks != null) {
//    callbacks.longPressed();
//    }
//    ULog.print(TAG, "timer Long Touch");
//    }
//    }
//    }, LONG_TOUCH_TIME, 1000);
    }
}
