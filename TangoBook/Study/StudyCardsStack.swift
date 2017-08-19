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
    
    
    /**
     * Member Variables
     */
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
    
    /**
     * Get/Set
     */
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
    
    /**
     * Constructor
     */
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
//        boolean isEnglish = (MySharedPref.getStudyType() == StudyType.EtoJ);
//        
//        while(mCardManager.getCardCount() > 0) {
//            TangoCard tangoCard = mCardManager.popCard();
//            StudyCard studyCard = new StudyCard(tangoCard, isMultiCard, isEnglish,
//                                                canvasW, maxHeight);
//            mCardsInBackYard.add(studyCard);
//        }
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public override func doAction() -> DoActionRet {
//        // 表示待ちのカードを表示させるかの判定
//        if (mCardsInBackYard.count > 0) {
//            boolean startFlag = false;
//            if (mCards.count == 0 ) {
//                // 表示中のカードが0なら無条件で投入
//                startFlag = true;
//            } else {
//                // 現在表示中のカードが一定位置より下に来たら次のカードを投入する
//                StudyCard card = mCards.getLast();
//                if (card.getY() >= card.getHeight()) {
//                    startFlag = true;
//                }
//            }
//            if (startFlag) {
//                appearCardFromBackYard();
//            }
//        }
//        
//        // スライドしたカードをボックスに移動する処理
//        for (int i=0; i<mCards.count; i++) {
//            StudyCard card = mCards.get(i);
//            
//            if (card.getMoveRequest() == StudyCard.RequestToParent.MoveToOK ||
//                card.getMoveRequest() == StudyCard.RequestToParent.MoveToNG)
//            {
//                int margin = UDpi.toPixel(17);
//                
//                if (card.getMoveRequest() == StudyCard.RequestToParent.MoveToOK ) {
//                    mCardManager.putCardIntoBox(card.getTangoCard(), StudyCardsManager.BoxType.OK);
//                    card.startMoveIntoBox(mOkBoxPos.x + margin, mOkBoxPos.y + margin);
//                } else {
//                    mCardManager.putCardIntoBox(card.getTangoCard(), StudyCardsManager.BoxType.NG);
//                    card.startMoveIntoBox(mNgBoxPos.x + margin, mNgBoxPos.y + margin);
//                }
//                
//                card.setMoveRequest(StudyCard.RequestToParent.None);
//                
//                // スライドして無くなったすきまを埋めるための移動
//                float bottomY = card.getBottom();
//                
//                for (int j=i+1; j<mCards.count; j++) {
//                    StudyCard card2 = mCards.get(j);
//                    card2.startMoving(0, bottomY - card2.getHeight(),
//                                      MOVING_FRAME + 5);
//                    bottomY -= card2.getHeight() + UDpi.toPixel(MARGIN_V);
//                }
//                mCards.remove(card);
//                mToBoxCards.add(card);
//            }
//        }
//        
//        // ボックスへ移動中のカードへの要求を処理
//        for (int i=0; i<mToBoxCards.count; i++) {
//            StudyCard card = mToBoxCards.get(i);
//            // ボックスへの移動開始
//            boolean breakLoop = false;
//            
//            switch (card.getMoveRequest()) {
//            case MoveIntoOK:
//            case MoveIntoNG:
//                card.setMoveRequest(StudyCard.RequestToParent.None);
//                mToBoxCards.remove(card);
//                breakLoop = true;
//                
//                if (cardsStackCallbacks != nil) {
//                    cardsStackCallbacks.CardsStackChangedCardNum(getCardCount2());
//                }
//                
//                if (getCardCount2() == 0) {
//                    cardsStackCallbacks.CardsStackFinished();
//                }
//                break;
//            }
//            if (breakLoop) break;
//        }
//        
//        
        // カードの移動等の処理
        var ret = DoActionRet.None
//        for (StudyCard card : mCards) {
//            if (card.doAction() != DoActionRet.None) {
//                ret = DoActionRet.Redraw;
//            }
//        }
//        for (StudyCard card : mToBoxCards) {
//            if (card.doAction() != DoActionRet.None) {
//                ret = DoActionRet.Redraw;
//            }
//        }
        return ret;
    }

    /**
     * バックヤードから１つカードを補充
     */
    func appearCardFromBackYard() {
//        if (mCardsInBackYard.count == 0) {
//            return;
//        }
//        
//        // バックヤードから取り出して表示用のリストに追加
//        StudyCard card = mCardsInBackYard.pop();
//        
//        // 初期座標設定
//        card.setPos(0, -card.getHeight());
//        
//        float dstY;
//        
//        if (mCards.count > 0) {
//            // スタックの最後のカードの上に配置
//            int height = 0;
//            for (StudyCard _card : mCards) {
//                height += _card.getHeight() + UDpi.toPixel(MARGIN_V);
//            }
//            dstY = size.height - height - card.getHeight();
//        } else {
//            dstY = size.height - card.getHeight();
//        }
//        
//        mCards.add(card);
//        
//        card.startMoving(0, dstY, MOVING_FRAME);
//        card.setBasePos(0, dstY);
    }

    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
//        PointF _offset = new PointF(pos.x + size.width / 2, pos.y);
//        // 配下のカードを描画する
//        for (StudyCard card : mCards) {
//            card.draw(canvas, paint, _offset);
//        }
//        for (StudyCard card : mToBoxCards) {
//            card.draw(canvas, paint, _offset);
//        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return true:処理中
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint? ) -> Bool {
//        PointF _offset = new PointF(pos.x + size.width / 2, pos.y);
//        for (StudyCard card : mCards) {
//            if (card.touchEvent(vt, _offset)) {
//                return true;
//            }
//        }
        return false
    }
}
