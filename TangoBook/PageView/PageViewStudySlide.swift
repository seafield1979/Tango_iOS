//
//  PageViewBackup.swift
//  TangoBook
//      単語学習ページ
//      カードが全てOK/NG処理されるまで上から単語カードが降ってくる
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

//public class PageViewStudySlide : UPageView, UButtonCallbacks {
//    /**
//     * Enums
//     */
//    /**
//     * Constants
//     */
//    public static let TAG = "PageViewStudySlide"
//    
//    // button id
//    private static let buttonId1 = 100
//    
//    private static let DRAW_PRIORITY = 100
//    
//    /**
//     * Propaties
//     */
//    
//    /**
//     * Constructor
//     */
//    public override init( topScene : TopScene, title : String) {
//        super.init( topScene: topScene, title: title)
//    }
//    
//    /**
//     * Methods
//     */
//    
//    override func onShow() {
//    }
//    
//    override func onHide() {
//        super.onHide();
//    }
//    
//    /**
//     * 描画処理
//     * サブクラスのdrawでこのメソッドを最初に呼び出す
//     * @param canvas
//     * @param paint
//     * @return
//     */
//    override func draw() -> Bool {
//        if isFirst {
//            isFirst = false
//            initDrawables()
//        }
//        return false
//    }
//    
//    /**
//     * タッチ処理
//     * @param vt
//     * @return
//     */
//    public func touchEvent(vt : ViewTouch) -> Bool {
//        
//        return false
//    }
//    
//    /**
//     * そのページで表示される描画オブジェクトを初期化する
//     */
//    override public func initDrawables() {
//        // 描画オブジェクトクリア
//        UDrawManager.getInstance().initialize()
//        
//        // ここにページで表示するオブジェクト生成処理を記述
//        let width = self.mTopScene.getWidth()
//        
//        let button = UButtonText(
//            callbacks: self, type: UButtonType.Press,
//            id: PageViewStudySlide.buttonId1, priority: PageViewStudySlide.DRAW_PRIORITY,
//            text: "test", x: 50, y: 100,
//            width: width - 100, height: 100,
//            textSize: 20, textColor: UIColor.white, color: UIColor.blue)
//        button.addToDrawManager()
//        
//    }
//    
//    /**
//     * ソフトウェアキーの戻るボタンを押したときの処理
//     * @return
//     */
//    public override func onBackKeyDown() -> Bool {
//        return false
//    }
//    
//    /**
//     * Callbacks
//     */
//    /**
//     * UButtonCallbacks
//     */
//    /**
//     * ボタンがクリックされた時の処理
//     * @param id  button id
//     * @param pressedOn  押された状態かどうか(On/Off)
//     * @return
//     */
//    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool
//    {
//        return true
//    }
//}

public protocol CardsStackCallbacks {
    /**
     * 残りのカード枚数が変わった
     * @param cardNum
     */
    func CardsStackChangedCardNum(cardNum : Int)
    
    /**
     * カードが０になった
     */
    func CardsStackFinished()
}


public class PageViewStudySlide : PageViewStudy, CardsStackCallbacks
{
    /**
     * Enums
     */
    // 学習中の状態
    enum State : Int, EnumEnumerable {
        case Start
        case Main
        case Finish
    }

    /**
     * Constants
     */
    public let TAG = "PageViewStudySlide"

    private let TOP_AREA_H = 50
    private let BOTTOM_AREA_H = 100
    private let FONT_SIZE = 17
    private let BUTTON_W = 100
    private let BUTTON_H = 40
    private let BOX_W = 50
    private let BOX_H = 50
    private let MARGIN_V = 27
    private let MARGIN_H = 17

    private let DRAW_PRIORITY = 100

    // button ids
    private let ButtonIdOk = 101
    private let ButtonIdNg = 102


    /**
     * Member variables
     */
    private var mState : State = .Start
    private var mFirstStudy : Bool = true       // 単語帳を選択して最初の学習のみtrue。リトライ時はfalse

    private var mCardsManager : StudyCardsManager? = nil
    private var mCardsStack : StudyCardsStack? = nil

    private var mTextCardCount : UTextView? = nil
    private var mExitButton : UButtonText? = nil
    private var mOkView : UImageView? = nil, mNgView : UImageView? = nil

    // 学習する単語帳 or カードリスト
    private var mBook : TangoBook? = nil
    private var mCards : List<TangoCard> = List()

    /**
     * Get/Set
     */
    public func setBook( book : TangoBook ) {
        mBook = book
    }

    public func setCards( cards : List<TangoCard> ) {
        mCards = cards
    }

    public func setFirstStudy( firstStudy : Bool ) {
        mFirstStudy = firstStudy
    }

    /**
     * Constructor
     */
    public override init( topScene : TopScene, title : String) {
        super.init(topScene: topScene, title: title)

    }

    /**
     * Methods
     */
    override func onShow() {
//        UDrawManager.getInstance().init();
//
//        mState = State.Main;
//        if (mCards != null) {
//            // リトライ時
//            mCardsManager = StudyCardsManager.createInstance(mBook.getId(), mCards);
//        } else {
//            // 通常時(選択された単語帳)
//            mCardsManager = StudyCardsManager.createInstance(mBook);
//        }
    }

    override func onHide() {
//        super.onHide();
//        mCardsManager = null;
//        mCardsStack.cleanUp();
//        mCardsStack = null;
//        mCards = null;
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public func doAction() -> DoActionRet {
//        switch (mState) {
//            case Start:
//                break;
//            case Main:
//                break;
//            case Finish:
//                return DoActionRet.Done;
//        }
        return DoActionRet.None;
    }

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
//        int screenW = mParentView.getWidth();
//        int screenH = mParentView.getHeight();
//
//        // カードスタック
//        mCardsStack = new StudyCardsStack(mCardsManager, this,
//                (mParentView.getWidth() - StudyCard.WIDTH) / 2, UDpi.toPixel(TOP_AREA_H),
//                screenW, StudyCard.WIDTH,
//                mParentView.getHeight() - UDpi.toPixel(TOP_AREA_H + BOTTOM_AREA_H)
//        );
//        mCardsStack.addToDrawManager();
//
//
//        // あと〜枚
//        String title = getCardsRemainText(mCardsStack.getCardCount());
//        mTextCardCount = UTextView.createInstance( title, UDraw.getFontSize(FontSize.L), DRAW_PRIORITY,
//                UAlignment.CenterX, screenW, false, true,
//                screenW / 2, UDpi.toPixel(10), UDpi.toPixel(100), Color.rgb(100,50,50), 0);
//        mTextCardCount.addToDrawManager();
//
//        // 終了ボタン
//        mExitButton = new UButtonText(this, UButtonType.Press,
//                ButtonIdExit,
//                DRAW_PRIORITY, mContext.getString(R.string.finish),
//                (screenW - UDpi.toPixel(BUTTON_W)) / 2, screenH - UDpi.toPixel(50),
//                UDpi.toPixel(BUTTON_W), UDpi.toPixel(BUTTON_H),
//                UDpi.toPixel(FONT_SIZE), Color.BLACK, Color.rgb(100,200,100));
//        mExitButton.addToDrawManager();
//
//        // OK
//        mOkView = new UImageView(DRAW_PRIORITY, R.drawable.box1,
//                       screenW - UDpi.toPixel( BOX_W + MARGIN_H),
//                        screenH - UDpi.toPixel(BOX_H + MARGIN_V),
//                UDpi.toPixel(BOX_W), UDpi.toPixel(BOX_H), UColor.DarkGreen);
//        mOkView.setTitle(UResourceManager.getStringById(R.string.know), UDpi.toPixel(17), UColor.DarkGreen);
//        mOkView.addToDrawManager();
//
//        // NG
//        mNgView = new UImageView(DRAW_PRIORITY, R.drawable.box1,
//                UDpi.toPixel(MARGIN_H), screenH - UDpi.toPixel(BOX_H + MARGIN_V),
//                UDpi.toPixel(BOX_W), UDpi.toPixel(BOX_H), UColor.DarkRed);
//        mNgView.setTitle(UResourceManager.getStringById(R.string.dont_know), UDpi.toPixel(17), UColor.DarkRed);
//        mNgView.addToDrawManager();
//
//
//        // OK/NGボタンの座標をCardsStackに教えてやる
//        PointF _pos = mOkView.getPos();
//        mCardsStack.setOkBoxPos(_pos.x - (mCardsStack.getX() + mCardsStack.getWidth() / 2),
//                _pos.y - mCardsStack.getY());
//        _pos = mNgView.getPos();
//        mCardsStack.setNgBoxPos(_pos.x - (mCardsStack.getX() + mCardsStack.getWidth() / 2),
//                _pos.y - mCardsStack.getY());
    }

    private func getCardsRemainText(count : Int) -> String {
        return String(format: UResourceManager.getStringByName("cards_remain"), count)
    }


    /**
     * Callbacks
     */

    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
//        if (super.UButtonClicked(id, pressedOn)) {
//            return true;
//        }
//
//        switch(id) {
//            case ButtonIdOk:
//                break;
//            case ButtonIdNg:
//                break;
//        }
        return false;
    }


    /**
     * CardsStackCallbacks
     */
    public func CardsStackChangedCardNum(cardNum : Int) {
//        String title = getCardsRemainText(count);
//        mTextCardCount.setText(title);
    }

    /**
     * 学習終了時のイベント
     */
    public func CardsStackFinished() {
//        if (mFirstStudy) {
//            // 学習結果をDBに保存する
//            mFirstStudy = false;
//
//            StudyUtil.saveStudyResult(mCardsManager, mBook);
//        }
//
//        // カードが０になったので学習完了。リザルトページに遷移
//        mState = State.Finish;
//        PageViewManager.getInstance().startStudyResultPage( mBook,
//                mCardsManager.getOkCards(), mCardsManager.getNgCards());
//
//        mParentView.invalidate();
    }
}

