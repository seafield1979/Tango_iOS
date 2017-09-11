//
//  PageViewBackup.swift
//  TangoBook
//      学習モードのページ
//      正解を１文字ずつ入力する。１文字でも間違って入力したらNG
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewStudyInputCorrect : PageViewStudy, CardsStackCallbacks {

    // MARK: Enums
    enum State {
        case Start
        case Main
        case Finish
    }

    // MARK: Constants
    private let TOP_AREA_H = 50;
    private let BOTTOM_AREA_H = 50;
    private let FONT_SIZE = 17;
    private let BUTTON_W = 100;
    private let BUTTON_H = 40;
    private let SETTING_BUTTON_W = 40;
    private let MARGIN_H = 15

    private let DRAW_PRIORITY = 100;
    private let COLOR1 = UColor.makeColor(100,50,50)
    private let COLOR2 = UColor.LightBlue
    
    // button ids
    private let ButtonIdSkip = 101;
    private let ButtonIdSetting = 102;
    private let ButtonIdStudySorted = 300;
    private let ButtonIdStudyRandom = 301;

    // MARK: Properties
    private var mState : State = .Start
    
    private var mCardsManager : StudyCardsManager?
    private var mCardsStack : StudyCardStackInput?

    private var mTextCardCount : UTextView?
    private var mExitButton : UButtonText?
    private var mSkipButton : UButtonText?
    private var mSettingButton : UButtonImage?

    // 設定用のダイアログ
    private var mDialog : UDialogWindow?

    // MARK: Accessor

    // MARK: Initializer
    public init(topScene : TopScene, title : String) {
        super.init(topScene: topScene, pageId: PageIdMain.StudyInputCorrect.rawValue, title : title)
    }

    // MARK: Methods

    /**
     * Methods
     */
    public override func onShow() {
        UDrawManager.getInstance().initialize()

        mState = .Main
        if mCards != nil {
            // リトライ時
            mCardsManager = StudyCardsManager.createInstance(bookId: mBook!.getId(), cards: mCards!.toArray())
        } else {
            // 通常時(選択された単語帳)
            mCardsManager = StudyCardsManager.createInstance(book: mBook!)
        }
    }

    public override func onHide() {
        super.onHide()
        mCardsManager = nil
        mCardsStack!.cleanUp()
        mCardsStack = nil
        mCards = nil
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public func doAction() -> DoActionRet{
        switch mState {
            case .Start:
                break
            case .Main:
                break
            case .Finish:
                return .Done
        }
        return .None
    }

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        let width = mTopScene.getWidth();
        let height = mTopScene.getHeight()

        // カードスタック
        mCardsStack = StudyCardStackInput(
            cardManager : mCardsManager!, cardsStackCallbacks : self,
            x : UDpi.toPixel(MARGIN_H), y : UDpi.toPixel(TOP_AREA_H),
            canvasW : width, width : mTopScene.getWidth() - UDpi.toPixel(MARGIN_H) * 2,
            height : mTopScene.getHeight() - UDpi.toPixel(TOP_AREA_H + BOTTOM_AREA_H)
        )
        mCardsStack!.addToDrawManager()

        // あと〜枚
        let title = getCardsRemainText( count: mCardsStack!.getCardCount() )
        
        mTextCardCount = UTextView.createInstance(
            text : title, fontSize : UDpi.toPixel(FONT_SIZE), priority : DRAW_PRIORITY,
            alignment : UAlignment.CenterX, createNode : true, isFit : false,
            isDrawBG : true, x : width/2, y : UDpi.toPixel(17),
            width : UDpi.toPixel(100), color : COLOR1, bgColor : nil)
        
        mTextCardCount!.addToDrawManager()

        let buttonW = UDpi.toPixel(BUTTON_W)

        // 終了ボタン
        mExitButton = UButtonText(
            callbacks : self, type : UButtonType.Press, id : PageViewStudy.ButtonIdExit,
            priority : 1,
            text : UResourceManager.getStringByName("finish"),
            createNode : true, x : width/2-buttonW-UDpi.toPixel(MARGIN_H)/2,
            y : height-UDpi.toPixel(50),
            width : buttonW, height : UDpi.toPixel(BUTTON_H),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor : .black,
            bgColor : COLOR2)
        
        mExitButton!.addToDrawManager()

        // 現在のカードをスキップボタン
        mSkipButton = UButtonText(
            callbacks : self, type : UButtonType.Press,
            id : ButtonIdSkip, priority : 1,
            text : UResourceManager.getStringByName("skip"), createNode : true,
            x : width/2+UDpi.toPixel(MARGIN_H)/2,
            y : height-UDpi.toPixel(50),
            width : buttonW, height : UDpi.toPixel(BUTTON_H),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor : .black,
            bgColor : UColor.LightPink)
        
        mSkipButton!.addToDrawManager()

        // 設定ボタン
        let image = UResourceManager.getImageWithColor( imageName: ImageName.settings_1, color: UColor.Green)
        mSettingButton = UButtonImage(
            callbacks : self, id : ButtonIdSetting, priority : 1,
            x : width-UDpi.toPixel(SETTING_BUTTON_W+MARGIN_H),
            y : height-UDpi.toPixel(50), width : UDpi.toPixel(SETTING_BUTTON_W),
            height : UDpi.toPixel(SETTING_BUTTON_W),
            image : image!, pressedImage : nil)
        
        mSettingButton!.addToDrawManager()
    }

    private func getCardsRemainText( count : Int ) -> String{
        return String( format: UResourceManager.getStringByName("cards_remain"), count + 1)
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public override func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }

        switch id {
        case ButtonIdSkip:
            // 次の問題へ
            mCardsStack!.skipCard()
            break
        case ButtonIdSetting:
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            showSettingDialog()
            break
        case ButtonIdStudySorted:
            fallthrough
        case ButtonIdStudyRandom:
            let flag = (id == ButtonIdStudyRandom) ? true : false
            MySharedPref.writeBool(key: MySharedPref.StudyMode4OptionKey, value: flag)
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            break
        default:
            break
        }
        return false
    }

    /**
     * 設定用のダイアログを開く
     */
    private func showSettingDialog() {
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, type : .Modal,
            buttonCallbacks : self, dialogCallbacks : self,
            dir : .Vertical, posType : .Center, isAnimation : true,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(),
            textColor : .black, dialogColor : UColor.LightGray)
        
        mDialog!.setTitle(UResourceManager.getStringByName("option_mode4_22"))
        
        let button1 : UButtonText = (mDialog!.addButton(
            id : ButtonIdStudySorted,
            text : UResourceManager.getStringByName("option_mode4_3"),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor : .black, color : UColor.White) as? UButtonText)!
        
        let button2 : UButtonText = (mDialog!.addButton(
            id : ButtonIdStudyRandom,
            text : UResourceManager.getStringByName("option_mode4_4"),
            fontSize : UDpi.toPixel(FONT_SIZE),
            textColor : .black, color : .white) as? UButtonText)!
        
        mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

        if MySharedPref.readBool(MySharedPref.StudyMode4OptionKey) {
            button2.setChecked(true, initNode: false)
        } else {
            button1.setChecked(true, initNode: false)
        }
        
        mDialog!.addToDrawManager()
    }


    /**
     * CardsStackCallbacks
     */
    public func CardsStackChangedCardNum(cardNum count : Int) {
        mTextCardCount!.setText(  getCardsRemainText(count: count) )
    }

    /**
     * 学習終了時のイベント
     */
    public func CardsStackFinished() {
        if mFirstStudy {
            // 学習結果をDBに保存する
            mFirstStudy = false

            PageViewStudy.saveStudyResult( cardManager: mCardsManager!, book: mBook!)
        }

        // カードが０になったので学習完了。リザルトページに遷移
        mState = State.Finish;
        PageViewManagerMain.getInstance().startStudyResultPage(
            book: mBook!,
            okCards: mCardsManager!.getOkCards(),
            ngCards: mCardsManager!.getNgCards())
    }
}
