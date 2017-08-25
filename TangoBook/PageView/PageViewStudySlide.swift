//
//  PageViewBackup.swift
//  TangoBook
//      単語学習ページ
//      カードが全てOK/NG処理されるまで上から単語カードが降ってくる
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit
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
    private let COLOR1 = UColor.makeColor(100,50,50)
    private let COLOR2 = UColor.makeColor(100,200,100)

    // button ids
    private let ButtonIdOk = 101
    private let ButtonIdNg = 102


    /**
     * Member variables
     */
    private var mState : State = .Start
    private var mFirstStudy : Bool = true       // 単語帳を選択して最初の学習のみtrue。リトライ時はfalse

    private var mCardsManager : StudyCardsManager?
    private var mCardsStack : StudyCardsStack?

    private var mTextCardCount : UTextView?
    private var mExitButton : UButtonText?
    private var mOkView : UImageView?, mNgView : UImageView?

    // 学習する単語帳 or カードリスト
    private var mBook : TangoBook?
    private var mCards : List<TangoCard>?

    /**
     * Get/Set
     */
    public func setBook( _ book : TangoBook ) {
        mBook = book
    }

    public func setCards( _ cards : List<TangoCard> ) {
        mCards = cards
    }

    public func setFirstStudy( _ firstStudy : Bool ) {
        mFirstStudy = firstStudy
    }

    /**
     * Constructor
     */
    public init( topScene : TopScene, title : String) {
        super.init(topScene: topScene, pageId: PageIdMain.StudySlide.rawValue, title: title)

    }

    /**
     * Methods
     */
    override func onShow() {
        UDrawManager.getInstance().initialize()

        mState = State.Main
        if mCards != nil {
            // リトライ時
            mCardsManager = StudyCardsManager.createInstance(bookId: mBook!.getId(), cards: mCards!.toArray())
        } else {
            // 通常時(選択された単語帳)
            mCardsManager = StudyCardsManager.createInstance(book: mBook!)
        }
    }

    override func onHide() {
        super.onHide()
        mCardsManager = nil
        mCardsStack?.cleanUp()
        mCardsStack = nil
        mCards = nil
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public func doAction() -> DoActionRet {
        switch (mState) {
            case .Start:
                break
            case .Main:
                break
            case .Finish:
                return DoActionRet.Done
        }
        return DoActionRet.None
    }

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        let screenW = mTopScene.getWidth()
        let screenH = mTopScene.getHeight()

        // カードスタック
        mCardsStack = StudyCardsStack(
            cardManager : mCardsManager!, cardsStackCallbacks : self,
            x : screenW / 2,
            y : UDpi.toPixel(TOP_AREA_H),
            width : UDpi.toPixel(StudyCard.WIDTH), maxHeight : mTopScene.getHeight()-UDpi.toPixel(TOP_AREA_H + BOTTOM_AREA_H))
        mCardsStack!.addToDrawManager()
        
        let n = SKNodeUtil.createCrossPoint(pos: mCardsStack!.pos, length: 15, lineWidth: 2, color: .red)
        mTopScene.addChild2(n)

        // あと〜枚
        let title = getCardsRemainText( count: mCardsStack!.getCardCount())
        
        mTextCardCount = UTextView.createInstance(
            text : title, fontSize : UDraw.getFontSize(FontSize.L),
            priority : 1, alignment : UAlignment.CenterX,
            createNode : true, multiLine : false, isDrawBG : true,
            x : screenW/2, y : UDpi.toPixel(10), width : UDpi.toPixel(100),
            color : COLOR1, bgColor : nil)
        
        mTextCardCount!.addToDrawManager()

        // 終了ボタン
        mExitButton = UButtonText(
            callbacks : self, type : UButtonType.Press, id : PageViewStudy.ButtonIdExit,
            priority : 1, text : UResourceManager.getStringByName ("finish"),
            createNode : true, x : (screenW - UDpi.toPixel(BUTTON_W))/2,
            y : screenH-UDpi.toPixel(50), width : UDpi.toPixel(BUTTON_W),
            height : UDpi.toPixel(BUTTON_H), fontSize : UDpi.toPixel(FONT_SIZE),
            textColor : .black, bgColor : COLOR2)
        
        mExitButton!.addToDrawManager()

        // OK
        mOkView = UImageView(
            priority : DRAW_PRIORITY, imageName : ImageName.box1, initNode: false,
            x : screenW - UDpi.toPixel(BOX_W + MARGIN_H),
            y : screenH - UDpi.toPixel(BOX_H + MARGIN_V),
            width : UDpi.toPixel(BOX_W), height : UDpi.toPixel(BOX_H),
            color : UColor.DarkGreen )
        
        mOkView!.setTitle( text: UResourceManager.getStringByName("know"),
                           size: UDpi.toPixel(17),
                           color: UColor.DarkGreen)
        mOkView!.initSKNode()
        mOkView!.addToDrawManager()

        // NG
        mNgView = UImageView(
            priority : DRAW_PRIORITY, imageName : ImageName.box1, initNode: false,
            x : UDpi.toPixel(MARGIN_H), y : screenH - UDpi.toPixel(BOX_H + MARGIN_V),
            width : UDpi.toPixel(BOX_W), height : UDpi.toPixel(BOX_H),
            color : UColor.DarkRed )
        
        mNgView!.setTitle( text: UResourceManager.getStringByName("dont_know"),
                           size: UDpi.toPixel(17), color: UColor.DarkRed)
        mNgView!.initSKNode()
        mNgView!.addToDrawManager()

        // OK/NGボタンの座標をCardsStackに教えてやる
        var _pos = mOkView!.getPos()
        mCardsStack!.setOkBoxPos( x: _pos.x - (mCardsStack!.getX() + mCardsStack!.getWidth() / 2),
                                  y: _pos.y - mCardsStack!.getY())
        _pos = mNgView!.getPos();
        mCardsStack!.setNgBoxPos( x: _pos.x - (mCardsStack!.getX() + mCardsStack!.getWidth() / 2),
                                 y: _pos.y - mCardsStack!.getY())
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
        if (super.UButtonClicked(id: id, pressedOn: pressedOn)) {
            return true
        }

        switch(id) {
            case ButtonIdOk:
                break
            case ButtonIdNg:
                break
        default:
            break
        }
        return false
    }


    /**
     * CardsStackCallbacks
     */
    public func CardsStackChangedCardNum(cardNum : Int) {
        let title = getCardsRemainText(count: cardNum)
        mTextCardCount?.setText(text: title)
    }

    /**
     * 学習終了時のイベント
     */
    public func CardsStackFinished() {
        if mFirstStudy {
            // 学習結果をDBに保存する
            mFirstStudy = false

            saveStudyResult(book: mBook!)
        }

        // カードが０になったので学習完了。リザルトページに遷移
        mState = State.Finish
        PageViewManagerMain.getInstance().startStudyResultPage(
            book: mBook!,
            okCards: mCardsManager!.getOkCards(),
            ngCards: mCardsManager!.getNgCards())
    }
    
    
    /**
     * 学習結果を保存
     */
    func saveStudyResult( book : TangoBook )
    {
        var okCards : List<TangoCard> = mCardsManager!.getOkCards()
        var ngCards : List<TangoCard> = mCardsManager!.getNgCards()
        
        // 単語帳の学習履歴
        var historyId = TangoBookHistoryDao.addOne(
            bookId: book.getId(), okNum: okCards.count, ngNum: ngCards.count)
        
        // 単語帳の最終学習日時
        book.setLastStudiedTime( time: Date())
        TangoBookDao.updateOne( book: book)
        
        // 学習したカード番号
        TangoStudiedCardDao.addStudiedCards( bookHistoryId: historyId, okCards: okCards.toArray(), ngCards: ngCards.toArray())
        
        // カードの学習履歴
        TangoCardHistoryDao.updateCards(okCards: okCards.toArray(), ngCards: ngCards.toArray())
    }
}

