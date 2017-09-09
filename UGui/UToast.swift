//
//  UToast.swift
//  TangoBook
//    一定時間最前面に表示された後に消えるView(AndroidのToast)
//  Created by Shusuke Unno on 2017/09/09.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

class UToast : UDrawable {
    // MARK: Enums
    enum ToastState : Int, EnumEnumerable {
        case Appear
        case Show
        case Disappear
    }
    
    // MARK: Constants
    private let PRIORITY : Int = 1000
    private let MARGIN : Int = 30
    private static let FONT_SIZE : Int = 20                // デフォルトのフォントサイズ
    private let FADE_DURATION : Double = 0.6      // フェードにかかる時間
    
    // MARK: Properties
    private var mState : ToastState = .Appear
    private var mTextView : UTextView?
    private var mDuration : Double = 0
    private var mStartTime : Double
    
    // SpriteKit Node
    private var mBgNode : SKShapeNode?
    
    // MARK: Initializer
    init(x: CGFloat, y: CGFloat, text : String, fontSize: CGFloat, alignment : UAlignment, duration : Double)
    {
        mStartTime = Date().timeIntervalSince1970
        
        super.init(priority: PRIORITY, x: x, y: y, width: 0, height: 0)
        
        mDuration = duration
        
        mTextView = UTextView(text: text, fontSize: fontSize, priority: 0, alignment: alignment, createNode: true, isFit: false, isDrawBG: true, margin: UDpi.toPixel(MARGIN), x: 0, y: 0, width: 0, color: UIColor.white, bgColor: UColor.Gray)
    }
    
    /**
     * UToastオブジェクトを生成する(Android互換用)
     */
    public static func makeText( text: String, duration: Double) -> UToast {
        return UToast(x: TopScene.getInstance().getWidth() / 2,
                      y: TopScene.getInstance().getHeight() - 60,
                      text: text, fontSize: UDpi.toPixel(FONT_SIZE),
                      alignment: .CenterX_Bottom, duration: duration)
    }
    
    public override func initSKNode() {
        if let textView = mTextView {
            parentNode.addChild2( textView.parentNode )
            parentNode.alpha = 0
        }
    }
    
    // MARK: Methods
    public override func doAction() -> DoActionRet {
        let nowTime = Date().timeIntervalSince1970
        switch mState {
        case .Appear:
            // 表示中
            let time : Double = nowTime - mStartTime
            let alpha : CGFloat
            if time > FADE_DURATION {
                mState = ToastState.Show
                mStartTime = nowTime
                alpha = 1.0
            } else {
                alpha = CGFloat(time / FADE_DURATION)
            }
            parentNode.alpha = alpha
            
            break
        case .Show:
            // 一定時間で非表示にする
            let time : Double = nowTime - mStartTime
            if time > mDuration {
                // 非表示状態に遷移
                mStartTime = nowTime
                mState = ToastState.Disappear
            }
            parentNode.alpha = 1.0
        case .Disappear:
            let time : Double = nowTime - mStartTime
            if time > FADE_DURATION {
                // 表示を抹消
                removeFromDrawManager()
                parentNode.removeFromParent()
                mState = ToastState.Show
            } else {
                parentNode.alpha = 1.0 - CGFloat(time / FADE_DURATION)
            }
            break
        }
        
        return .None
    }
    
    public override func draw() {
        
    }
    
    /**
     * 表示する
     */
    public func show() {
        initSKNode()
        addToDrawManager()
    }
    
    /**
     * 非表示にする
     */
    public func cancel() {
        removeFromDrawManager()
        parentNode.removeFromParent()
    }
    
    // MARK: Callbacks
}
