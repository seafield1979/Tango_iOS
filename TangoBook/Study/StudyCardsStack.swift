//
//  StudyCardsStack.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/07.
 *
 * 学習中のカードのスタックを表示するクラス
 * カードをスライドしてボックスにふり分ける
 */
public class StudyCardsStack : UDrawable {
    /**
     * Enums
     */
    public enum State {
        case Starting   // 開始時の演出
        case Main        // 学習中のメイン状態
    }

    /**
     * Consts
     */
    public let TAG = "StudyCardsStack"
    
    // layout
    public let MARGIN_V = 10
    let MOVING_FRAME = 10
    
    
    // MARK: Properties
    
    
    var mCardManager : StudyCardsManager? = nil
    var cardsStackCallbacks : CardsStackCallbacks? = nil
    var mStudyMode : StudyMode = .SlideOne
    
    // 表示前のCard
    var mCardsInBackYard : List<StudyCard> = List()
    
    // 表示中のCard
    var mCards : List<StudyCard> = List()
    // ボックスへ移動中のカード
    var mToBoxCards : List<StudyCard> = List()
    
    var mOkBoxPos = CGPoint(), mNgBoxPos = CGPoint()
    
    // MARK: Get/Set
    public func setOkBoxPos( x : CGFloat, y : CGFloat) {
        self.mOkBoxPos.x = x
        self.mOkBoxPos.y = y
    }
    
    public func setNgBoxPos( x : CGFloat, y : CGFloat) {
        self.mNgBoxPos.x = x
        self.mNgBoxPos.y = y
    }
    
    public func setStudyMode( studyMode : StudyMode ) {
        self.mStudyMode = studyMode
    }
    
    /**
     * 残りのカード枚数を取得する
     * @return
     */
    public func getCardCount() -> Int{
        return mCardsInBackYard.count + mCards.count
    }
    public func getCardCount2() -> Int {
        return mCardsInBackYard.count + mCards.count + mToBoxCards.count
    }
    
    // MARK: Initializer
    public init( cardManager : StudyCardsManager,
                 cardsStackCallbacks : CardsStackCallbacks?,
                x : CGFloat, y : CGFloat,
                width : CGFloat, maxHeight : CGFloat)
    {
        super.init(priority : 90, x : x, y : y, width : width, height : 0)
        
        self.cardsStackCallbacks = cardsStackCallbacks
        size.height = maxHeight;
        mCardManager = cardManager;
        mStudyMode = StudyMode.toEnum(MySharedPref.readInt(MySharedPref.StudyModeKey));
        
        var isMultiCard = false
        if mStudyMode == StudyMode.SlideMulti {
            isMultiCard = true
        }
        setInitialCards( isMultiCard: isMultiCard, maxHeight: maxHeight)
    }

    /**
     * Methods
     */
    /**
     * 初期表示分のカードを取得
     */
    func setInitialCards( isMultiCard : Bool, maxHeight : CGFloat) {
        let isEnglish = (MySharedPref.getStudyType() == StudyType.EtoJ)
        
        while mCardManager!.getCardCount() > 0 {
            let tangoCard : TangoCard? = mCardManager!.popCard()
            let studyCard : StudyCard = StudyCard(
                card : tangoCard!, isMultiCard : isMultiCard,
                isEnglish : isEnglish, screenW : TopScene.getInstance().getWidth(),
                maxHeight : maxHeight)
            mCardsInBackYard.append( studyCard )
        }
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public override func doAction() -> DoActionRet {
        // 表示待ちのカードを表示させるかの判定
        if mCardsInBackYard.count > 0 {
            var startFlag = false
            if mCards.count == 0 {
                // 表示中のカードが0なら無条件で投入
                startFlag = true
            } else {
                // 現在表示中のカードが一定位置より下に来たら次のカードを投入する
                let card : StudyCard? = mCards.last()
                if let _card = card {
                    if _card.getY() >= _card.getHeight() {
                        startFlag = true
                    }
                }
            }
            if startFlag {
                appearCardFromBackYard()
            }
        }

        // スライドしたカードをボックスに移動する処理
        for i in 0..<mCards.count {
            let card : StudyCard = mCards[i]
            
            if card.getMoveRequest() == StudyCard.RequestToParent.MoveToOK ||
                card.getMoveRequest() == StudyCard.RequestToParent.MoveToNG
            {
                let margin = UDpi.toPixel(17)
                
                if card.getMoveRequest() == StudyCard.RequestToParent.MoveToOK {
                    mCardManager!.putCardIntoBox( card: card.getTangoCard()!,
                                                  boxType: .OK)
                    card.startMoveIntoBox( dstX: mOkBoxPos.x + margin,
                                           dstY: mOkBoxPos.y + margin)
                } else {
                    mCardManager!.putCardIntoBox( card: card.getTangoCard()!,
                                                  boxType: .NG)
                    card.startMoveIntoBox( dstX: mNgBoxPos.x + margin,
                                           dstY: mNgBoxPos.y + margin)
                }
                
                card.setMoveRequest( .None )
                
                // スライドして無くなったすきまを埋めるための移動
                var bottomY = card.getBottom()
                
                for j in i+1 ..< mCards.count {
                    let card2 : StudyCard = mCards[j]
                    card2.startMoving( dstX: 0, dstY: bottomY - card2.getHeight(),
                                       frame: MOVING_FRAME + 5)
                    bottomY -= card2.getHeight() + UDpi.toPixel(MARGIN_V)
                }
                mCards.remove(obj: card)
                mToBoxCards.append(card)
            }
        }

        // ボックスへ移動中のカードへの要求を処理
        for i in 0..<mToBoxCards.count {
            let card : StudyCard = mToBoxCards[i]
            // ボックスへの移動開始
            var breakLoop = false
            
            switch card.getMoveRequest() {
            case .MoveIntoOK:
                fallthrough
            case .MoveIntoNG:
                card.setMoveRequest( .None )
                mToBoxCards.remove(obj: card )
                breakLoop = true
                
                if (cardsStackCallbacks != nil) {
                    cardsStackCallbacks?.CardsStackChangedCardNum( cardNum: getCardCount2())
                }
                
                if (getCardCount2() == 0) {
                    cardsStackCallbacks?.CardsStackFinished()
                }
            default:
                break
            }
            if breakLoop {
                break
            }
        }
        
        
        // カードの移動等の処理
        var ret = DoActionRet.None
        for card in mCards {
            if card!.doAction() != DoActionRet.None {
                ret = .Redraw
            }
        }
        for card in mToBoxCards {
            if card!.doAction() != DoActionRet.None {
                ret = .Redraw
            }
        }
        return ret
    }

    /**
     * バックヤードから１つカードを補充
     */
    func appearCardFromBackYard() {
        if mCardsInBackYard.count == 0 {
            return
        }
        
        // バックヤードから取り出して表示用のリストに追加
        let _card : StudyCard? = mCardsInBackYard.pop()
        
        if let card = _card {
            // 初期座標設定
            card.setPos(0, -card.getHeight(), convSKPos: false)
            
            var dstY : CGFloat
            
            if mCards.count > 0 {
                // スタックの最後のカードの上に配置
                var height : CGFloat = 0
                for card2 in mCards {
                    height += card2!.getHeight() + UDpi.toPixel(MARGIN_V)
                }
                dstY = size.height - height - card.getHeight()
            } else {
                dstY = size.height - card.getHeight()
            }
            
            mCards.append(card)
            
            // SpriteKit Node
            parentNode.addChild2( card.parentNode )
            
            card.startMoving(dstX: 0, dstY: dstY, frame: MOVING_FRAME)
            card.setBasePos(x: 0, y: dstY)
        }
    }

    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        // 配下のカードを描画する
        for card in mCards {
            card!.draw()
        }
        for card in mToBoxCards {
            card!.draw()
        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return true:処理中
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint? ) -> Bool {
        let _offset = CGPoint(x: pos.x + size.width / 2, y: pos.y)
        for card in mCards {
            if card!.touchEvent(vt: vt, offset: _offset) {
                return true
            }
        }
        return false
    }
}
