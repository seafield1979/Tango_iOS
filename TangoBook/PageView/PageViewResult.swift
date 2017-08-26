//
//  PageViewResult.swift
//  TangoBook
//    学習後のリザルトページを管理するクラス
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewResult : UPageView, UButtonCallbacks, UListItemCallbacks {
    
    // MARK: Constants
    public static let TAG = "PageViewResult"

    private let ButtonIdRetry1 = 200
    private let ButtonIdRetry2 = 201
    private let ButtonIdReturn = 202

    // 座標系
    private let TOP_Y = 10
    private let MARGIN_H = 17
    private let MARGIN_V = 17
    private let MARGIN_V_S = 7

    private let TITLE_FONT_SIZE = 23
    private let FONT_SIZE = 17
    private let BUTTON_FONT_SIZE = 17
    private let BUTTON_H = 67

    // 優先順位系
    private let PRIORITY_LV = 100
    private let DRAW_PRIORITY = 100

    // color
    private let TEXT_COLOR = UIColor.black

    private let TITLE_BG_COLOR = UColor.makeColor(100,100,200)
    private let BUTTON_TEXT_COLOR = UIColor.white
    private let BUTTON1_BG_COLOR = UColor.makeColor(100,200,100)
    private let BUTTON2_BG_COLOR = UColor.makeColor(200,100,100)

    // MARK: Properties
    private var mBook : TangoBook?
    private var mListView : ListViewResult?
    private var mOkCards : List<TangoCard>?
    private var mNgCards : List<TangoCard>?
    private var mStudyMode : StudyMode = .SlideOne    // 出題モード
    private var mStudyType : StudyType = .EtoJ        // 出題タイプ(英->日, 日->英)

    private var mTitleText : UTextView?        // タイトル
    private var mResultText : UTextView?       // 結果
    private var mButtonRetry1 : UButtonText?   // 全部リトライ
    private var mButtonRetry2 : UButtonText?   // NGのみリトライ
    private var mButtonExit : UButtonText?     // 戻るボタン

    private var mCardDialog : DialogCard?

    /**
     * Get/Set
     */
    public func setCardsLists( okCards : List<TangoCard>, ngCards : List<TangoCard>) {
        mOkCards = okCards
        mNgCards = ngCards
    }

    public func setBook( mBook : TangoBook) {
        self.mBook = mBook
    }

    // MARK: Initializer
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.StudyResult.rawValue, title: title)
    }
    
    /**
     * Methods
     */
    
    override func onShow() {
        mStudyMode = StudyMode.toEnum(MySharedPref.readInt(MySharedPref.StudyModeKey))
        mStudyType = StudyType.toEnum(MySharedPref.readInt(MySharedPref.StudyTypeKey))
    }

    override func onHide() {
        super.onHide()
    }

    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    override public func initDrawables() {
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()

        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

        var y = UDpi.toPixel(TOP_Y)
        let buttonH = UDpi.toPixel(BUTTON_H)
        let marginH = UDpi.toPixel(MARGIN_H)
        let marginV = UDpi.toPixel(MARGIN_V)

        // Title
        let title = String( format: UResourceManager.getStringByName("title_result2"), mBook!.getName()!)
        mTitleText = UTextView.createInstance(
            text : title, fontSize : UDpi.toPixel(TITLE_FONT_SIZE),
            priority : DRAW_PRIORITY, alignment : UAlignment.CenterX,
            createNode : true, multiLine : false, isDrawBG : false,
            x : width/2, y : y,
            width : width, color : TEXT_COLOR, bgColor : nil)

        mTitleText!.addToDrawManager()
        y += mTitleText!.getHeight() + UDpi.toPixel(MARGIN_V_S)

        // Result
        let text = "OK: \(mOkCards!.count)  NG: \(mNgCards!.count)"
        mResultText = UTextView.createInstance(
            text : text, fontSize : UDpi.toPixel(FONT_SIZE),
            priority : DRAW_PRIORITY, alignment : UAlignment.CenterX,
            createNode : true, multiLine : false, isDrawBG : false,
            x : width/2, y : y, width : width, color : TEXT_COLOR, bgColor : nil)
        
        mResultText!.addToDrawManager()
        
        y += mResultText!.getHeight() + UDpi.toPixel(MARGIN_V_S)
        
        // Buttons
        let buttonW = (width - marginH * 4) / 3
        var x = UDpi.toPixel(MARGIN_H)
        // Retury1
        mButtonRetry1 = UButtonText(
            callbacks : self, type : UButtonType.Press, id : ButtonIdRetry1,
            priority : DRAW_PRIORITY, text : UResourceManager.getStringByName("retry1"), createNode : true,
            x : x, y : y, width : buttonW, height : buttonH,
            fontSize : UDpi.toPixel(BUTTON_FONT_SIZE),
            textColor : BUTTON_TEXT_COLOR, bgColor : BUTTON1_BG_COLOR)
        
        mButtonRetry1!.addToDrawManager()
        x += buttonW + marginH
        
        // Retry2
        mButtonRetry2 = UButtonText(
            callbacks : self, type : UButtonType.Press, id : ButtonIdRetry2,
            priority : DRAW_PRIORITY, text : UResourceManager.getStringByName("retry2"), createNode : true,
            x : x, y : y, width : buttonW, height : buttonH,
            fontSize : UDpi.toPixel(BUTTON_FONT_SIZE), textColor : BUTTON_TEXT_COLOR,
            bgColor : BUTTON1_BG_COLOR)
        mButtonRetry2!.addToDrawManager()
        if mNgCards!.count == 0 {
            mButtonRetry2!.setEnabled(false)
        }
        x += buttonW + marginH
        
        // Exit
        mButtonExit = UButtonText(
            callbacks : self, type : UButtonType.Press, id : ButtonIdReturn,
            priority : DRAW_PRIORITY,
            text : UResourceManager.getStringByName("finish"), createNode : true,
            x : x, y : y,
            width : buttonW, height : buttonH,
            fontSize : UDpi.toPixel(BUTTON_FONT_SIZE), textColor : BUTTON_TEXT_COLOR,
            bgColor : BUTTON2_BG_COLOR)
        
        mButtonExit!.addToDrawManager()

        y += buttonH + marginV

        // ListView
        mListView = ListViewResult(
            topScene : mTopScene, listItemCallbacks : self, okCards : mOkCards!,
            ngCards : mNgCards!, studyMode : mStudyMode, studyType : mStudyType,
            priority : PRIORITY_LV, x : marginH, y : y,
            width : width - marginH * 2, height : height - y-marginV,
            color : .white)
        mListView!.setFrameColor(.gray)
        
        mListView!.addToDrawManager()
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
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
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool
    {
        switch(id) {
        case ButtonIdRetry1:
            PageViewManagerMain.getInstance().startStudyPage(book: mBook!, cards: nil, stack: false)
            
        case ButtonIdRetry2:
            PageViewManagerMain.getInstance().startStudyPage(book: mBook!, cards: mNgCards, stack: false)
            
        case ButtonIdReturn:
            _ = PageViewManagerMain.getInstance().popPage()
        default:
            break
        }
        return false
    }

    /**
      * UListItemCallbacks
      */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked(item : UListItem) {
        // クリックされた項目の詳細を表示する
        if !(item is ListItemResult) {
            return
        }

        if let _item = item as? ListItemResult {
            if _item.getType() != ListItemResult.ListItemResultType.Title {

                mCardDialog = DialogCard(
                    topScene : mTopScene, card : _item.getCard()!, isAnimation : true )
                
                mCardDialog!.addToDrawManager()
            }
        }
    }

    public func ListItemButtonClicked( item : UListItem, buttonId : Int) {

    }
}
