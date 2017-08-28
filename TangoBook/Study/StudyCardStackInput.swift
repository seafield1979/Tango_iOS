//
//  StudyCardStackInput.swift
//  TangoBook
//      正解を１文字づつ選択するモード（正解は英語のみ対応）
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class StudyCardStackInput : UDrawable {
    // MARK: Enums
    enum State {
        case Starting       // 開始時の演出
        case Main           // 学習中のメイン状態
        case End            // すべての問題を学習終了
    }

    // MARK: Consts
    // layout
    public let MARGIN_V = 10
    private let FONT_SIZE = 17
    private let DRAW_PRIORITY = 100
    // color
    private let TEXT_COLOR = UIColor.black

    // MARK: Properties
    private var mCardManager : StudyCardsManager?
    private var cardsStackCallbacks : CardsStackCallbacks?
    private var mCanvasW : CGFloat
    private var mStudyMode : StudyMode = .Input
    private var mStudyCard : StudyCardInput?
    private var mState : State = .Main
    
    // 学習中するカードリスト。出題ごとに１つづつ減っていく
    private var mCards : List<TangoCard> = List()

    // MARK: Accessor
    /**
     * 残りのカード枚数を取得する
     * @return
     */
    public func getCardCount() -> Int {
        return mCards.count
    }
    
    /**
     * Constructor
     */
    public init( cardManager : StudyCardsManager,
                    cardsStackCallbacks : CardsStackCallbacks?,
                    x : CGFloat, y : CGFloat, canvasW : CGFloat,
                    width : CGFloat, height : CGFloat)
    {
        mCanvasW = canvasW
        mCardManager = cardManager
        
        super.init(priority: 90, x: x, y: y, width: width, height: height )
        
        self.cardsStackCallbacks = cardsStackCallbacks
        mStudyMode = MySharedPref.getStudyMode()
        
        // カードマネージャーのカードリストをコピー
        for card in mCardManager!.getCards() {
            mCards.append(card!)
        }
        if MySharedPref.getStudyOrder() == StudyOrder.Random {
            mCards.shuffled()
        }
        
        setStudyCard()
    }

    /**
     * Methods
     */
    
    
    /**
     * 出題するカードを準備する
     */
    private func setStudyCard() {
        if mCards.count > 0 {
            let card = mCards.pop()
            
            if mStudyCard != nil {
                mStudyCard!.parentNode.removeFromParent()
            }
            
            mStudyCard = StudyCardInput(card: card!, canvasW: mCanvasW, height: size.height - UDpi.toPixel(MARGIN_V), pos: pos)
            parentNode.addChild2( mStudyCard!.parentNode )
        } else {
            // 終了
            mState = State.End;
            if cardsStackCallbacks != nil {
                cardsStackCallbacks!.CardsStackFinished()
            }
        }
    }
    
    /**
     * 出題中のカードをスキップする
     */
    public func skipCard() {
        if mStudyCard!.mState == .None {
            mStudyCard!.showCorrect( mistaken: true )
        } else {
            setStudyCard()
        }
    }
    
    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public override func doAction() -> DoActionRet{
        
        if mState == .Main {
            if mStudyCard!.getRequest() == StudyCardInput.RequestToParent.End {
                if mStudyCard!.isMistaken {
                    mCardManager!.addNgCard(mStudyCard!.mCard!)
                } else {
                    mCardManager!.addOkCard(mStudyCard!.mCard!)
                }
                // 表示中のカードが終了したので次のカードを表示
                if mCards.count == 0 {
                    // もうカードがないので終了
                    mState = State.End;
                    if cardsStackCallbacks != nil {
                        cardsStackCallbacks!.CardsStackFinished()
                    }
                } else {
                    // 次の問題を準備
                    mState = .Main
                    setStudyCard()
                    if cardsStackCallbacks != nil {
                        cardsStackCallbacks!.CardsStackChangedCardNum(cardNum: mCards.count)
                    }
                }
            }
        }
        
        // カードの移動等の処理
        if mStudyCard!.doAction() != .None {
            return .Redraw
        }
        
        return .None
    }

    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        // 配下のカードを描画する
        mStudyCard!.draw()
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return true:処理中
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        if mStudyCard!.touchEvent(vt: vt, offset: pos) {
            return true;
        }
        return false;
    }
}
