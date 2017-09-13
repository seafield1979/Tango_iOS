//
//  StudyCardSelect.swift
//  TangoBook
//      ４択学習モードで表示するカード
//      出題中の４枚のカードのうちの１つ
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class StudyCardSelect : UDrawable {
    public enum State : Int{
        case None
        case Appearance         // 出現
        case ShowAnswer         // 正解表示中
        case Disappearance      // 消える
    }
    
    // 親に対する要求
    public enum RequestToParent : Int{
        case None
        case Touch
        case End
    }

    // MARK: Constants
    private let FONT_SIZE = 17;
    private let TEXT_COLOR : UIColor = .black
    private let BG_COLOR : UIColor = .white
    private let FRAME_COLOR = UColor.makeColor(150,150,150)
    
    // MARK: Properties
    
    // SpriteKit Node
    private var bgNode : SKShapeNode?
    private var shapeNode : SKShapeNode?        // 正解表示時の◯×用
    
    private var mState : State
    private var wordA : String?, wordB : String?
    private var mCard : TangoCard?
    private var basePos : CGPoint?
    
    // 正解のカードかどうか
    public var isCorrect : Bool = false
    
    // 正解、不正解のまるばつを表示するかどうか
    private var isShowCorrect : Bool = false
    
    // ボックス移動要求（親への通知用)
    private var mRequest = RequestToParent.None
    
    private var mTextView : UTextView?
    
    public func getRequest() -> RequestToParent {
        return mRequest
    }
    
    public func setRequest( _ request : RequestToParent) {
        mRequest = request
    }

    // MARK: Accessor
    public func getTangoCard() -> TangoCard? {
        return mCard
    }
    
    public func setState( _ state : State) {
        mState = state
    }
    
    /**
     * 正解/不正解を設定する
     * @param showCorrect
     */
    public func setShowCorrect() {
        mState = State.ShowAnswer
        isShowCorrect = true
        
        // 正解表示中
        mTextView!.setText(wordA! + "\n" + wordB!)
    }
    
    /**
     * 正解の○を表示する
     */
    public func setOkMark() {
        // ○×を表示
        shapeNode = SKNodeUtil.createCircleNode(
            pos: CGPoint(), radius: UDpi.toPixel(18),
            lineWidth: UDpi.toPixel(6), color: UColor.DarkGreen)
        parentNode.addChild2( shapeNode! )
        
        // BGの色
        bgNode!.fillColor = UColor.LightGreen
        bgNode!.strokeColor = UColor.addBrightness(argb: UColor.LightGreen, addY: -0.3)
    }
    
    /**
     * 不正解の×を表示する
     */
    public func setNgMark() {
        shapeNode = SKNodeUtil.createCrossPoint(
            type: .Type2, pos: CGPoint(), length: UDpi.toPixel(23),
            lineWidth: UDpi.toPixel(6), color: .red, zPos: 0)
        parentNode.addChild2( shapeNode! )
        
        color = .white
        bgNode!.fillColor = color
        
        // BGの色
        bgNode!.fillColor = UColor.LightRed
        bgNode!.strokeColor = UColor.addBrightness(argb: UColor.LightRed, addY: -0.3)
    }

    public override func getRect() -> CGRect {
        return CGRect(x: pos.x - size.width / 2,
                      y: pos.y - size.height / 2,
                      width: pos.x + size.width / 2,
                      height: pos.y + size.height / 2)
    }
    
    // MARK: Initializer
    /**
     * @param card
     * @param isCorrect 正解のカードかどうか(true:正解のカード / false:不正解のカード)
     * @param isEnglish 出題タイプ false:英語 -> 日本語 / true:日本語 -> 英語
     */
    public init(card : TangoCard, isCorrect : Bool, isEnglish : Bool, screenW : CGFloat, height : CGFloat, pos: CGPoint)
    {
        mState = State.None;
        mCard = card;

        super.init(priority : 0, x : pos.x, y : pos.y, width : screenW - UDpi.toPixel(67), height : height)
        
        self.isCorrect = isCorrect
        
        if isEnglish {
            wordA = card.wordA
            wordB = card.wordB
        } else {
            wordA = card.wordB
            wordB = card.wordA
        }
        
        basePos = CGPoint(x: size.width / 2, y: size.height / 2)
        
        initSKNode()
    }
    
    public override func initSKNode() {
        // bg
        bgNode = SKNodeUtil.createRectNode(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width : size.width, height: size.height), color: BG_COLOR, pos: CGPoint(), cornerR: UDpi.toPixel(10))
        bgNode!.strokeColor = FRAME_COLOR
        bgNode!.lineWidth = UDpi.toPixel(2)
        parentNode.addChild2(bgNode!)
        
        // TextView
        mTextView = UTextView(text: wordA!, fontSize: UDpi.toPixel(FONT_SIZE), priority: 1, alignment: .Center, createNode: true, isFit: true, isDrawBG: false, margin: 0, x: 0, y: 0, width: size.width - UDpi.toPixel(16), color: TEXT_COLOR, bgColor: nil)
        parentNode.addChild2( mTextView!.parentNode )
    }

    // MARK: Methods
    /**
     * 出現時の拡大処理
     */
    public func startAppearance(frame : Int) {
        mScale = 0.0
        startMovingScale(dstScale: 1.0, frame: frame)
        mState = State.Appearance
    }

    /**
     * 消えるときの縮小処理
     * @param frame
     */
    public func startDisappearange(frame : Int) {
        mScale = 1.0
        startMovingScale(dstScale: 0, frame: frame)
        mState = State.Disappearance
    }

    /**
     * 自動で実行される何かしらの処理
     * @return
     */
    public override func doAction() -> DoActionRet {
        switch (mState) {
        case .Appearance:
            fallthrough
        case .Disappearance:
            if (autoMoving()) {
                return DoActionRet.Redraw
            }
            break
        default:
            break
        }
        return DoActionRet.None
    }
    
    /**
     * 自動移動完了
     */
    public override func endMoving() {
        if (mState == State.Disappearance) {
            // 親に非表示完了を通知する
            mRequest = RequestToParent.End
        }
        else {
            mState = State.None
        }
    }
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch ) -> Bool {
        return touchEvent(vt: vt, offset: nil)
    }
    
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        var done = false
        
        // アニメーションや移動中はタッチ受付しない
        if mState == .Appearance || mState == .Disappearance {
            return false
        }
        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        
        switch vt.type {
        case .Touch:        // タッチ開始
            break
        case .Click:
            let rect = CGRect(x: pos.x + offset!.x - size.width / 2,
                              y: pos.y + offset!.y - size.height / 2,
                              width: size.width,
                              height: size.height )
            if rect.contains(x: vt.touchX, y: vt.touchY) {
                setRequest(.Touch)
                done = true
            }
            break
        default:
            break
        }
        
        return done
    }
}
