//
//  TouchView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/07.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import UIKit

public protocol ViewTouchCallbacks {
    // 長押しされた時の処理
    func longPressed()
}

/**
 UIViewが受け取るタッチイベント
 */
public enum TouchEventType {
    case Down       // タッチされた
    case Up         // タッチが離された
    case Move       // タッチ中に移動した
    case Cancel     // 外部からタッチがキャンセルされた
    case LongPress  // 長押し
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
    public static let LONG_CLICK_TIME : Double = 0.3
    
    // 移動前の待機時間(ms)
    public static let MOVE_START_TIME : Double = 0.1
    
    // 長押しまでの時間(s)
    private let LONG_PRESS_INTERVAL : Double = 0.7
    
    // MARK: Propaties
    private var callbacks : ViewTouchCallbacks?
    
    public var type : TouchType = .None         // 外部用のタイプ(変化があった時に有効な値を返す)
    private var innerType : TouchType = .None    // 内部用のタイプ
    private var timer : Timer? = nil
    
    public private(set) var isTouchUp : Bool = false      // タッチアップしたフレームだけtrueになる
    var isTouching : Bool = false
    private var isLongTouch : Bool = false      // 長押しが検出されるか、長押しが無効になったときにtrueになる
    
    // タッチ開始した座標
    public private(set) var touchX : CGFloat = 0.0, touchY : CGFloat = 0.0
    
    public private(set) var x : CGFloat = 0.0
    public private(set) var y : CGFloat = 0.0       // スクリーン座標
    public private(set) var moveX : CGFloat = 0.0, moveY : CGFloat = 0.0
    public private(set) var isMoveStart : Bool = false;
    
    // MARK: Accessor
    public func touchX(offset: CGFloat) -> CGFloat {
        return touchX + offset
    }
    public func touchY(offset: CGFloat) -> CGFloat {
        return touchY + offset
    }
    public func getLongTouch() -> Bool {
        return isLongTouch
    }
    public func setCallbacks(callbacks : ViewTouchCallbacks? ) {
        self.callbacks = callbacks
    }
    
    // タッチ開始した時間
    var touchTime : Double = 0
    
    convenience init() {
        self.init(callback:nil)
    }
    
    init(callback : ViewTouchCallbacks?) {
        self.callbacks = callback
    }
    
    /**
     * 長押しがあったかどうかを取得する
     * このメソッドを呼ぶと内部のフラグをクリア
     * @return true:長押し
     */
    public func checkLongTouch() -> Bool {
        // すでに長押しフラグが立っていたら長押し状態を解除
        if isLongTouch {
            return false
        }
        
        // 長押しのチェック
        if isLongTouch == false && isTouching == true && innerType != .Moving {
            let pressedTime : Double = Date().timeIntervalSince1970 - touchTime
            if pressedTime > LONG_PRESS_INTERVAL {
                isLongTouch = true
                type = TouchType.LongPress
                if let cb = callbacks {
                    cb.longPressed()
                }
                return true
            }
        }
        return false
    }
    
    // タッチ処理
    // 各種タッチ関連のイベントが発生した時に呼び出される
    public func checkTouchType(e : TouchEventType,
                               touch: UITouch?,
                               pos: CGPoint ) -> TouchType {
        isTouchUp = false
        
        switch e {
        case .Down:
            ULog.printMsg(ViewTouch.TAG, "Touch Down: \(pos.x) \(pos.y)")
            
            isTouching = true
            if touch != nil {
                touchX = pos.x
                touchY = pos.y
            }
            type = TouchType.Touch
            innerType = TouchType.Touch
            startLongTouch()
            
        case .Up:
            ULog.printMsg(ViewTouch.TAG, "Up")
            
            isTouchUp = true
            if isTouching {
                if innerType == TouchType.Moving {
                    ULog.printMsg(ViewTouch.TAG, "MoveEnd")
                    type = TouchType.MoveEnd
                    innerType = TouchType.MoveEnd
                    return type
                } else {
                    var x : CGFloat = 0
                    var y : CGFloat = 0
                    if touch != nil {
                        x = pos.x
                        y = pos.y
                    }
                    let w = x - touchX
                    let h = y - touchY
                    let dist : CGFloat = sqrt(w * w + h * h)
                    
                    if (dist <= ViewTouch.CLICK_DISTANCE) {
                        let time : Double = Date().timeIntervalSince1970 - touchTime
                        
                        if (time <= ViewTouch.LONG_CLICK_TIME) {
                            type = TouchType.Click
                            ULog.printMsg(ViewTouch.TAG, "SingleClick")
                        } else {
                            type = TouchType.LongClick
                            ULog.printMsg(ViewTouch.TAG, "LongClick")
                        }
                    } else {
                        type = TouchType.None
                    }
                }
            } else {
                type = TouchType.None
            }
            isTouching = false
        case .Move:
            isMoveStart = false
            isLongTouch = true      // もう長押し判定はしないフラグ
            
            var _x : CGFloat = 0
            var _y : CGFloat = 0
            if touch != nil {
                _x = pos.x
                _y = pos.y
            }
            
            ULog.printMsg(ViewTouch.TAG, String(format:"x:%f y:%f", _x, _y))
            
            // クリックが判定できるようにタッチ時間が一定時間以上、かつ移動距離が一定時間以上で移動判定される
            if ( innerType != TouchType.Moving) {
                let dx = _x - touchX
                let dy = _y - touchY
                let dist : CGFloat = sqrt(dx * dx + dy * dy)
                
                if (dist >= ViewTouch.CLICK_DISTANCE) {
                    let time : Double = Date().timeIntervalSince1970 - touchTime
                    if time >= ViewTouch.MOVE_START_TIME {
                        type = TouchType.Moving
                        innerType = TouchType.Moving
                        isMoveStart = true
                        self.x = touchX
                        self.y = touchY
                    }
                }
            }
            if  innerType == TouchType.Moving {
                // １フレーム分の移動距離
                moveX = _x - self.x
                moveY = _y - self.y
            } else {
                innerType = TouchType.None
                type = TouchType.None
            }
            x = _x
            y = _y
        case .Cancel:
            isTouching = false
            isTouchUp = true
            
        case .LongPress:
            // 長押しを検出する
            if isTouching && type != TouchType.Moving {
                isLongTouch = true
                isTouching = false
                type = TouchType.LongPress
                innerType = type
                // 長押しイベント開始はonTouchから取れないので親に通知する
                if callbacks != nil {
                    callbacks!.longPressed()
                }
            }
        }
        
        return type
    }

    /**
     * 長押しチェック開始時に行う処理
     */
    private func startLongTouch() {
        // 長押し判定用のタイマーを開始
        touchTime = Date().timeIntervalSince1970
        isLongTouch = false
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
}
