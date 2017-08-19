//
//  StudyCard.swift
//  TangoBook
//      学習カードスタック(StudyCardsStack)に表示されるカード
//      左右にスライドしてボックスに振りわ得ることができる
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/07.
 *
 */

public class StudyCard : UDrawable, UButtonCallbacks {
    /**
     * Enums
     */
    enum State : Int {
        case None
        case Moving
    }

    // 親に対する要求
    public enum RequestToParent : Int {
        case None
        case MoveToOK
        case MoveToNG
        case MoveIntoOK
        case MoveIntoNG
    }

    /**
     * Consts
     */
    public let WIDTH = 170
    public let MIN_HEIGHT = 50

    let MOVE_FRAME = 10
    let MOVE_IN_FRAME = 30

    let TEXT_SIZE_A = 20
    let TEXT_SIZE_B = 17
    let MARGIN_TEXT_H = 13
    let MARGIN_TEXT_V = 20

    let ARROW_W = 50
    let ARROW_H = 50
    let ARROW_MARGIN = 7

    let TEXT_COLOR = UIColor.black
    let BG_COLOR = UIColor.white
    let FRAME_COLOR = UColor.makeColor(150,150,150)
    let OK_BG_COLOR = UColor.makeColor(100,200,100)
    let NG_BG_COLOR = UColor.makeColor(200,100,100)

    let ButtonIdArrowL = 200
    let ButtonIdArrowR = 201

    // スライド系
    // 左右にスライドできる距離。これ以上スライドするとOK/NGボックスに入る
    let SLIDE_LEN = 117

    /**
     * Static Varialbes
     */
    var arrowLImage : UIImage? = nil
    var arrowRImage : UIImage? = nil

    /**
     * Member Variables
     */
    var basePos = CGPoint()
    var mState : State = .None
    var wordA : String? = nil             // 正解（表）のテキスト
    var wordB : String? = nil             // 不正解（裏）のテキスト
    var textSizeA : Int = 0            // 正解のテキストサイズ
    var textSizeB : Int = 0            // 不正解(裏)のテキスト
    var mCard : TangoCard? = nil
    var isTouching : Bool = false
    var slideX : CGFloat = 0
    var showArrow : Bool = false
    var isMoveToBox : Bool = false

    var mArrowL : UButtonImage? = nil
    var mArrowR : UButtonImage? = nil

    // ボックス移動要求（親への通知用)
    var moveRequest = RequestToParent.None;
    var lastRequest = RequestToParent.None;

    public func getMoveRequest() -> RequestToParent{
        return moveRequest
    }

    public func setMoveRequest( moveRequest : RequestToParent) {
        self.moveRequest = moveRequest
    }

    /**
     * Get/Set
     */

    public func getTangoCard() -> TangoCard? {
        return mCard
    }

    public func isShowArrow() -> Bool {
        return showArrow
    }

    /**
     * Constructor
     */
    /**
     *
     * @param card
     * @param isMultiCard 一度に複数のカードを表示するかどうか
     * @param isEnglish 出題タイプ false:英語 -> 日本語 / true:日本語 -> 英語
     */
    public init(card : TangoCard, isMultiCard : Bool, isEnglish : Bool,
                screenW : CGFloat, maxHeight : CGFloat)
    {
        super.init(priority : 0, x : 0, y : 0, width : UDpi.toPixel(WIDTH), height : 0)
        
        let arrowW = UDpi.toPixel(ARROW_W)
        let arrowH = UDpi.toPixel(ARROW_H)
        
        arrowLImage = UResourceManager.getImageWithColor(imageName:
            ImageName.arrow_l, color:UColor.DarkRed)!
        
        arrowRImage = UResourceManager.getImageWithColor(
            imageName: ImageName.arrow_r,
            color: UColor.DarkGreen)!
        
        mArrowL = UButtonImage(
            callbacks : self, id : ButtonIdArrowL, priority : 0,
            x : -(size.width / 2 + UDpi.toPixel(ARROW_MARGIN+ARROW_W)),
            y : (size.height-arrowH)/2,
            width : arrowW, height : arrowH, image : arrowLImage!,
            pressedImage : nil)
        
        mArrowR = UButtonImage(
            callbacks : self, id : ButtonIdArrowR,
            priority : 0,
            x : size.width / 2 + UDpi.toPixel(ARROW_MARGIN),
            y : (size.height-arrowH)/2, width : arrowW, height : UDpi.toPixel(ARROW_H), image : arrowRImage!, pressedImage : nil)
        
        
        if isEnglish {
            wordA = card.wordA
            wordB = card.wordB
            textSizeA = UDpi.toPixelInt(TEXT_SIZE_A)
            textSizeB = UDpi.toPixelInt(TEXT_SIZE_B)
        } else {
            wordA = card.wordB
            wordB = card.wordA
            textSizeA = UDpi.toPixelInt(TEXT_SIZE_B)
            textSizeB = UDpi.toPixelInt(TEXT_SIZE_A)
        }
        mState = State.None
        mCard = card

        // カードのサイズを計算する
        let maxWidth = screenW - UDpi.toPixel(ARROW_W * 2 + ARROW_MARGIN * 4)
        if isMultiCard {
            // WordA,WordBの大きい方の高さに合わせる
            let sizeA = UDraw.getTextSize( text: wordA, textSize: UDpi.toPixelInt(TEXT_SIZE_A))
            let sizeB = UDraw.getTextSize( text: wordB, textSize: UDpi.toPixelInt(TEXT_SIZE_B))

            // width
            var width = (sizeA.width > sizeB.width) ? sizeA.width : sizeB.width;
            width += UDpi.toPixel(MARGIN_TEXT_H) * 2
            if width > maxWidth {
                width = maxWidth
            } else if (width < size.width) {
                // 元のサイズより小さい場合は元のサイズを採用
                width = size.width
            }
            size.width = width

            // height
            var height = (sizeA.height > sizeB.height) ? sizeA.height : sizeB.height
            height += UDpi.toPixel(MARGIN_TEXT_V) * 2

            if height < UDpi.toPixel(MIN_HEIGHT) {
                height = UDpi.toPixel(MIN_HEIGHT)
            }
            else if height > maxHeight {
                height = maxHeight
            }
            size.height = height
        } else {
            size.width = maxWidth
            size.height = maxHeight
        }

    }

    /**
     * Methods
     */
    public override func startMoving( dstX : CGFloat, dstY : CGFloat, frame : Int)
    {
        startMoving(movingType : MovingType.Deceleration, dstX : dstX, dstY : dstY, frame : frame)
        setBasePos(x: dstX, y: dstY)
        showArrow = false
        mState = State.Moving
    }

    /**
     * ボックスの中に移動
     */
    public func startMoveIntoBox( dstX : CGFloat, dstY : CGFloat)
    {
        var width : CGFloat, height : CGFloat
        let dstWidth = UDpi.toPixel(17)
        if size.width > size.height {
            width = dstWidth
            height = dstWidth * (size.height / size.width)
        } else {
            height = dstWidth
            width = dstWidth * (size.width / size.height)
        }

        startMoving(movingType : MovingType.Deceleration, dstX : dstX, dstY : dstY, dstW : width, dstH : height, frame : MOVE_IN_FRAME)
        mState = State.Moving
        isMoveToBox = true
    }

    /**
     * スライドした位置を元に戻す
     */
    public func moveToBasePos( frame : Int ) {
        startMoving(movingType: MovingType.Deceleration,
                    dstX: basePos.x, dstY: basePos.y,
                    frame: frame)
        mState = State.Moving;
    }

    public func setBasePos( x : CGFloat, y : CGFloat) {
        basePos.x = x
        basePos.y = y
    }

    /**
     * 自動で実行される何かしらの処理
     * @return
     */
    public override func doAction() -> DoActionRet {
        if mArrowL!.doAction() != DoActionRet.None {
            return DoActionRet.Redraw
        }
        if mArrowR!.doAction() != DoActionRet.None {
            return DoActionRet.Redraw
        }

        if mState == .Moving {
            if (autoMoving()) {
                return DoActionRet.Redraw;
            }
        }

        return DoActionRet.None
    }

    /**
     * 自動移動完了
     */
    public override func endMoving() {
        mState = State.None
        switch lastRequest {
            case .None:
                showArrow = true
            
            case .MoveToOK:
                moveRequest = RequestToParent.MoveIntoOK
            
            case .MoveToNG:
                moveRequest = RequestToParent.MoveIntoNG
        default:
            break
        }
    }

    /**
     * Drawable methods
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        var _pos = CGPoint(x: pos.x, y: pos.y)
        
        _pos.x += slideX

        // BG
        // スライド量に合わせて色を帰る
        if (isMovingSize) {
        }
        else if (slideX == 0) {
            color = BG_COLOR
        } else if (slideX < 0) {
            color = UColor.mixRGBColor(color1: BG_COLOR, color2: NG_BG_COLOR, ratio: -slideX / UDpi.toPixel(SLIDE_LEN))
        } else {
            color = UColor.mixRGBColor(color1: BG_COLOR, color2: OK_BG_COLOR, ratio: slideX / UDpi.toPixel(SLIDE_LEN));
        }
//        UDraw.drawRoundRectFill(
//            rect: CGRect(x: _pos.x - size.width / 2 ,y:  _pos.y,
//                         width: size.width / 2, height: size.height),
//            cornerR: UDpi.toPixel(3), color: color, strokeWidth: UDpi.toPixel(2), strokeColor: FRAME_COLOR);

        // 矢印
        if showArrow && !isTouching && !isMoveToBox {
            mArrowL!.draw()
            mArrowR!.draw()
        }
        // Text
        if (!isMoveToBox) {
            // タッチ中は正解を表示
            var text : String?
            var textSize : Int
            if isTouching {
                text = wordB
                textSize = textSizeB
            } else {
                text = wordA
                textSize = textSizeA
            }
            if text != nil {
//                UDraw.drawText( text : text!, alignment : UAlignment.Center, textSize : textSize, x : _pos.x, y : _pos.y+size.height/2, color : TEXT_COLOR)
            }
        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch) -> Bool {
        return touchEvent(vt: vt, offset: nil)
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
//        PointF _pos = new PointF(pos.x, pos.y);
//        if (offset != nil) {
//            _pos.x += offset.x;
//            _pos.y += offset.y;
//        }
//        _pos.x += slideX;
//
        var done = false
//
//        // 矢印
//        if ( mArrowL.touchUpEvent(vt) ) {
//            done = true;
//        }
//        if ( mArrowR.touchUpEvent(vt) ) {
//            done = true;
//        }
//
//        if ( mArrowL.touchEvent(vt, _pos) ) {
//            return true;
//        }
//        if ( mArrowR.touchEvent(vt, _pos)) {
//            return true;
//        }
//
//        switch(vt.type) {
//            case Touch:        // タッチ開始
//                Rect _rect = new Rect((int)_pos.x - size.width / 2 , (int)_pos.y,
//                        (int)_pos.x + size.width / 2, (int)_pos.y + size.height);
//                if (_rect.contains((int)(vt.touchX()), (int)(vt.touchY()))) {
//                    isTouching = true;
//                    done = true;
//                }
//                break;
//            case Moving:       // 移動
//                if (isTouching && mState == State.None) {
//                    done = true;
//                    // 左右にスライド
//                    slideX += vt.getMoveX();
//                    // 一定ラインを超えたらボックスに移動
//                    if (slideX <= UDpi.toPixel(-SLIDE_LEN)) {
//                        // NG
//                        pos.x += slideX;
//                        slideX = 0;
//                        moveRequest = lastRequest = RequestToParent.MoveToNG;
//                    } else if (slideX >= UDpi.toPixel(SLIDE_LEN)) {
//                        // OK
//                        pos.x += slideX;
//                        slideX = 0;
//                        moveRequest = lastRequest = RequestToParent.MoveToOK;
//                    }
//                }
//                break;
//            case Click: {
//            }
//                break;
//        }
//        if (vt.isTouchUp()) {
//            if (isTouching) {
//                isTouching = false;
//                done = true;
//                if (mState == State.None && slideX != 0) {
//                    // ベースの位置に戻る
//                    pos.x = basePos.x + slideX;
//                    moveToBasePos(MOVE_FRAME);
//                    slideX = 0;
//                }
//            }
//        }
//
        return done;
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
//        switch(id) {
//            case ButtonIdArrowL:
//                showArrow = false;
//                moveRequest = lastRequest = RequestToParent.MoveToNG;
//                return true;
//            case ButtonIdArrowR:
//                showArrow = false;
//                moveRequest = lastRequest = RequestToParent.MoveToOK;
//                return true;
//        }
        return false
    }
}

