//
//  StudyCard.swift
//  TangoBook
//      学習カードスタック(StudyCardsStack)に表示されるカード
//      左右にスライドしてボックスに振りわ得ることができる
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

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

    // MARK: Constants
    public static let WIDTH = 170
    public let MIN_HEIGHT = 50

    let MOVE_FRAME = 10
    let MOVE_IN_FRAME = 30

    let FONT_SIZE_A = 20
    let FONT_SIZE_B = 17
    let MARGIN_TEXT_H = 13
    let MARGIN_TEXT_V = 20

    let ARROW_W = 50
    let ARROW_H = 50
    let ARROW_MARGIN = 7

    let TEXT_COLOR = UIColor.black
    let BG_COLOR = UIColor.white
    let FRAME_COLOR = UColor.makeColor(150,150,150)
    public static let OK_BG_COLOR = UColor.makeColor(100,200,100)
    public static let NG_BG_COLOR = UColor.makeColor(200,100,100)

    let ButtonIdArrowL = 200
    let ButtonIdArrowR = 201

    // スライド系
    // 左右にスライドできる距離。これ以上スライドするとOK/NGボックスに入る
    let SLIDE_LEN = 117

    // MARK: Properties
    var arrowLImage : UIImage? = nil
    var arrowRImage : UIImage? = nil

    // SpriteKit Node
    var bgNode : SKShapeNode?
    var wordANode : SKLabelNode?
    var wordBNode : SKLabelNode?
    
    var basePos = CGPoint()
    var mState : State = .None
    var wordA : String? = nil             // 正解（表）のテキスト
    var wordB : String? = nil             // 不正解（裏）のテキスト
    var fontSizeA : CGFloat = 0            // 正解のテキストサイズ
    var fontSizeB : CGFloat = 0            // 不正解(裏)のテキスト
    var mMaxHeight : CGFloat = 0
    var mCard : TangoCard? = nil
    var isTouching : Bool = false
    var slideX : CGFloat = 0
    var showArrow : Bool = false
    var isMoveToBox : Bool = false

    var mArrowL : UButtonImage?
    var mArrowR : UButtonImage?

    // ボックス移動要求（親への通知用)
    var moveRequest = RequestToParent.None;
    var lastRequest = RequestToParent.None;

    // MARK: Accessor
    public func getMoveRequest() -> RequestToParent{
        return moveRequest
    }

    public func setMoveRequest( _ moveRequest : RequestToParent) {
        self.moveRequest = moveRequest
    }

    public func getTangoCard() -> TangoCard? {
        return mCard
    }

    public func isShowArrow() -> Bool {
        return showArrow
    }

    public override func setColor(_ color: UIColor) {
        super.setColor(color)
        
        bgNode!.fillColor = color
    }
    
    // MARK: Initializer
    /**
     *
     * @param card
     * @param isMultiCard 一度に複数のカードを表示するかどうか
     * @param isEnglish 出題タイプ false:英語 -> 日本語 / true:日本語 -> 英語
     */
    public init(card : TangoCard, isMultiCard : Bool, isEnglish : Bool, maxHeight : CGFloat)
    {
        super.init(priority : 0, x : 0, y : 0, width : UDpi.toPixel(StudyCard.WIDTH), height : 0)
        
        arrowLImage = UResourceManager.getImageWithColor(imageName:
            ImageName.arrow_l, color:UColor.DarkRed)!
        
        arrowRImage = UResourceManager.getImageWithColor(
            imageName: ImageName.arrow_r,
            color: UColor.DarkGreen)!
        
        if isEnglish {
            wordA = card.wordA
            wordB = card.wordB
            fontSizeA = UDpi.toPixel(FONT_SIZE_A)
            fontSizeB = UDpi.toPixel(FONT_SIZE_B)
        } else {
            wordA = card.wordB
            wordB = card.wordA
            fontSizeA = UDpi.toPixel(FONT_SIZE_B)
            fontSizeB = UDpi.toPixel(FONT_SIZE_A)
        }
        mState = State.None
        mCard = card

        initSKNode2( maxHeight : maxHeight, isMultiCard: isMultiCard)
    }
    
    /**
     * SpriteKitのノードを生成
     */
    public func initSKNode2(maxHeight: CGFloat, isMultiCard : Bool) {
        if mArrowL != nil {
            parentNode.addChild2( mArrowL!.parentNode )
        }
        if mArrowR != nil {
            parentNode.addChild2( mArrowR!.parentNode )
        }
        
        let arrowW = UDpi.toPixel(ARROW_W)
        let arrowH = UDpi.toPixel(ARROW_H)
        
        // Text
        var wordASize: CGSize?, wordBSize : CGSize?
        // WordA
        if wordA != nil {
            let ret = SKNodeUtil.createLabelNode(text: wordA!, fontSize: UDpi.toPixel(FONT_SIZE_A), color: .black, alignment: .Center, pos: CGPoint())
            wordANode = ret.node
            wordASize = ret.size
            parentNode.addChild2( wordANode! )
            wordANode!.isHidden = true
        }
        
        // WordB
        if wordB != nil {
            let ret = SKNodeUtil.createLabelNode(text: wordB!, fontSize: UDpi.toPixel(FONT_SIZE_A), color: .black, alignment: .Center, pos: CGPoint())
            wordBNode = ret.node
            wordBSize = ret.size
            parentNode.addChild2( wordBNode! )
            wordBNode!.isHidden = true
        }
        
        // カードのサイズを計算する
        if isMultiCard {
            // WordA,WordBの大きい方の高さに合わせる
            // width
            var width = (wordASize!.width > wordBSize!.width) ? wordASize!.width : wordBSize!.width
            width += UDpi.toPixel(MARGIN_TEXT_H) * 2
            size.width = width
            
            // height
            var height = (wordASize!.height > wordBSize!.height) ? wordASize!.height : wordBSize!.height
            height += UDpi.toPixel(MARGIN_TEXT_V) * 2
            
            if height < UDpi.toPixel(MIN_HEIGHT) {
                height = UDpi.toPixel(MIN_HEIGHT)
            }
            else if height > maxHeight {
                height = maxHeight
            }
            size.height = height
        } else {
            size.width = TopScene.getInstance().getWidth() - UDpi.toPixel(ARROW_W * 2 + ARROW_MARGIN * 4)
            size.height = maxHeight
        }
        mArrowL = UButtonImage(
            callbacks : self, id : ButtonIdArrowL, priority : 0,
            x : -(size.width / 2 + UDpi.toPixel(ARROW_MARGIN + ARROW_W)),
            y : (size.height-arrowH)/2,
            width : arrowW, height : arrowH, image : arrowLImage!,
            pressedImage : nil)
        
        mArrowR = UButtonImage(
            callbacks : self, id : ButtonIdArrowR,
            priority : 0,
            x : size.width / 2 + UDpi.toPixel(ARROW_MARGIN),
            y : (size.height - arrowH)/2, width : arrowW, height : UDpi.toPixel(ARROW_H), image : arrowRImage!, pressedImage : nil)
        
        // BG Node
        bgNode = SKNodeUtil.createRectNode(rect: CGRect(x:-size.width / 2, y:0, width: size.width, height: size.height), color: color, pos: CGPoint(), cornerR: UDpi.toPixel(4))
        bgNode!.strokeColor = .gray
        bgNode!.lineWidth = UDpi.toPixel(2)
        parentNode.addChild2( bgNode! )
        
        // WordA,WordBの位置を設定(オブジェクト生成時はBGのサイズが定まっていないため設定できなかった)
        if let n = wordANode {
            n.position = CGPoint(x: 0, y: size.height / 2).convToSK()
        }
        if let n = wordBNode {
            n.position = CGPoint(x: 0, y: size.height / 2).convToSK()
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
        startMoving(movingType : MovingType.Deceleration,
                    dstX : dstX, dstY : dstY,
                    dstW: size.width, dstH: size.height,
                    dstScale: 0, frame : MOVE_IN_FRAME)
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
        mState = State.Moving
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
        // スライド量に合わせて色を変更
        if (isMoveToBox) {
        } else {
            if (slideX == 0) {
                color = BG_COLOR
            } else if (slideX < 0) {
                color = UColor.mixRGBColor(color1: BG_COLOR, color2: StudyCard.NG_BG_COLOR, ratio: -slideX / UDpi.toPixel(SLIDE_LEN))
            } else {
                color = UColor.mixRGBColor(color1: BG_COLOR, color2: StudyCard.OK_BG_COLOR, ratio: slideX / UDpi.toPixel(SLIDE_LEN));
            }
            setColor(color)
        }

        // 矢印
        if showArrow && !isTouching && !isMoveToBox {
            mArrowL!.draw()
            mArrowR!.draw()
            mArrowL!.parentNode.isHidden = false
            mArrowR!.parentNode.isHidden = false
        } else {
            mArrowL!.parentNode.isHidden = true
            mArrowR!.parentNode.isHidden = true
        }
        // Text
        if (!isMoveToBox) {
            // タッチ中は正解を表示
            if isTouching {
                wordBNode!.isHidden = false
                wordANode!.isHidden = true
            } else {
                wordANode!.isHidden = false
                wordBNode!.isHidden = true
            }
        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch) -> Bool {
        return self.touchEvent(vt: vt, offset: nil)
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        var _pos = pos
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        _pos.x += slideX

        var done = false

        // タッチアップ処理
        if mArrowL!.touchUpEvent(vt: vt) {
            done = true
        }
        if mArrowR!.touchUpEvent(vt: vt) {
            done = true
        }

        // タッチ処理
        if mArrowL!.touchEvent(vt: vt, offset: _pos) {
            return true
        }
        if ( mArrowR!.touchEvent(vt: vt, offset: _pos)) {
            return true
        }

        switch vt.type {
            case .Touch:        // タッチ開始
                let _rect = CGRect( x: _pos.x - size.width / 2 , y: _pos.y,
                                  width: size.width, height: size.height)
                if _rect.contains( x: vt.touchX, y: vt.touchY) {
                    isTouching = true
                    done = true
                }
            case .Moving:       // 移動
                if isTouching && mState == State.None {
                    done = true
                    // 左右にスライド
                    slideX += vt.moveX
                    // 一定ラインを超えたらボックスに移動
                    if (slideX <= UDpi.toPixel(-SLIDE_LEN)) {
                        // NG
                        pos.x += slideX
                        slideX = 0
                        lastRequest = RequestToParent.MoveToNG
                        moveRequest = lastRequest
                        setPos(pos.x, pos.y, convSKPos: true)
                        setColor(StudyCard.NG_BG_COLOR)
                    } else if (slideX >= UDpi.toPixel(SLIDE_LEN)) {
                        // OK
                        pos.x += slideX
                        slideX = 0
                        lastRequest = RequestToParent.MoveToOK
                        moveRequest = lastRequest
                        setPos(pos.x, pos.y, convSKPos: true)
                        setColor(StudyCard.OK_BG_COLOR)
                    } else {
                        parentNode.position = CGPoint(x: pos.x + slideX, y: pos.y).convToSK()
                    }
                }
                break
            case .Click:
                break
        default:
            break
        }

        if vt.isTouchUp {
            if isTouching {
                isTouching = false
                done = true
                if (mState == State.None && slideX != 0) {
                    // ベースの位置に戻る
                    pos.x = basePos.x + slideX
                    moveToBasePos( frame: MOVE_FRAME )
                    slideX = 0
                }
            }
        }

        return done
    }

    // MARK: Callbacks
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
        switch(id) {
        case ButtonIdArrowL:
            showArrow = false
            lastRequest = RequestToParent.MoveToNG
            moveRequest = lastRequest
            return true
        case ButtonIdArrowR:
            showArrow = false
            lastRequest = RequestToParent.MoveToOK
            moveRequest = lastRequest
            return true
        default:
            break
        }
        return false
    }
}

