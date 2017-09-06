//
//  PageViewBackup.swift
//  TangoBook
//      学習ページ(４択)
//      正解を１つだけふくむ４つの選択肢から正解を選ぶ学習モード
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewStudySelect4 : PageViewStudy, CardsStackCallbacks {
    // MARK: Constants
    public enum State {
        case Start
        case Main
        case Finish
    }

    // 座標系
    private let TOP_AREA_H = 50
    private let BOTTOM_AREA_H = 50
    private let FONT_SIZE = 17
    private let BUTTON_W = 100
    private let BUTTON_H = 40
    private let SETTING_BUTTON_W = 40
    private let CARD_STACK_MARGIN_H = 35

    private let COLOR1 = UColor.makeColor(100,50,50)
    private let COLOR2 = UColor.LightBlue

    // button ids
    private let ButtonIdOk = 101
    private let ButtonIdNg = 102
    private let ButtonIdSetting = 103
    private let ButtonIdSelectFromAll = 104
    private let ButtonIdSelectFromOneBook = 105

    // MARK: Properties
    private var mState : State = .Start

    private var mCardsManager : StudyCardsManager?
    private var mCardsStack : StudyCardStackSelect?

    private var mTextCardCount : UTextView?
    private var mExitButton : UButtonText?
    private var mSettingButton : UButtonImage?

    // 設定用のダイアログ
    private var mDialog : UDialogWindow?

    // MARK: Initizaler
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.StudySelect4.rawValue, title: title)
    }

    // MARK: Accessor


    // MARK: Methods
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
        if mCardsStack != nil {
            mCardsStack!.cleanUp()
        }
        mCardsStack = nil
        mCards = nil
    }
    
    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public func doAction() -> DoActionRet {
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
        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

        // カードスタック
        mCardsStack = StudyCardStackSelect(
            cardManager : mCardsManager!, cardsStackCallbacks : self,
            x : width / 2, y : UDpi.toPixel(TOP_AREA_H),
            screenW : width,
            width : mTopScene.getWidth() - UDpi.toPixel(CARD_STACK_MARGIN_H) * 2,
            height : mTopScene.getHeight() - UDpi.toPixel(TOP_AREA_H+BOTTOM_AREA_H)
        )
        mCardsStack!.addToDrawManager()

        // あと〜枚
        let title = getCardsRemainText(count: mCardsStack!.getCardCount())
        
        mTextCardCount = UTextView.createInstance(
            text : title, fontSize : UDpi.toPixel(FONT_SIZE),
            priority : 1, alignment : .CenterX, createNode : true,
            multiLine : false, isDrawBG : true, x : width/2, y : UDpi.toPixel(17),
            width : UDpi.toPixel(100), color : COLOR1, bgColor : nil)
        
        mTextCardCount!.addToDrawManager()

        // 終了ボタン
        mExitButton = UButtonText(
            callbacks : self, type : UButtonType.Press, id : PageViewStudy.ButtonIdExit,
            priority : 1,
            text : UResourceManager.getStringByName("finish"), createNode : true,
            x : (width-UDpi.toPixel(BUTTON_W))/2, y : height-UDpi.toPixel(50),
            width : UDpi.toPixel(BUTTON_W), height : UDpi.toPixel(BUTTON_H),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor : .black, bgColor : COLOR2)
        
        mExitButton!.addToDrawManager()

        // 設定ボタン
        let image = UResourceManager.getImageWithColor(
            imageName: ImageName.settings_1, color: UColor.Green)
        
        mSettingButton = UButtonImage(
            callbacks : self, id : ButtonIdSetting, priority : 1,
            x : width + UDpi.toPixel( -SETTING_BUTTON_W - UPageView.MARGIN_H),
            y : height - UDpi.toPixel(50),
            width : UDpi.toPixel(SETTING_BUTTON_W), height : UDpi.toPixel(SETTING_BUTTON_W),
            image : image!, pressedImage : nil)
        mSettingButton!.addToDrawManager();
    }
    
    private func getCardsRemainText( count : Int ) -> String{
        return String( format: UResourceManager.getStringByName("cards_remain"),  count)
    }

    /**
     * 設定用のダイアログを開く
     */
    private func showSettingDialog() {
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, type : .Modal,
            buttonCallbacks : self, dialogCallbacks : self,
            dir : .Vertical, posType : .Center,
            isAnimation : true,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(),
            textColor : .black, dialogColor : .lightGray)
        
        mDialog!.setTitle(UResourceManager.getStringByName("option_mode3_1"));
        
        let button = mDialog!.addButton(
            id : ButtonIdSelectFromAll,
            text : UResourceManager.getStringByName("option_mode3_2"),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor : .black, color : .white)

        let button2 : UButton = mDialog!.addButton(
            id: ButtonIdSelectFromOneBook, text: UResourceManager
                .getStringByName("option_mode3_3"),
            fontSize : UDpi.toPixel(FONT_SIZE), textColor: .black, color: .white)

        if (MySharedPref.readBool(MySharedPref.StudyMode3OptionKey)) {
            if let _button = button as? UButtonText {
                _button.setChecked(true, initNode: false)
            }
        } else {
            if let _button = button2 as? UButtonText {
                _button.setChecked(true, initNode: false)
            }
        }

        mDialog!.addCloseButton( text: UResourceManager.getStringByName("cancel"))
        mDialog!.addToDrawManager()
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
    public override func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }
        switch id {
        case ButtonIdOk:
            break
        case ButtonIdNg:
            break
        case ButtonIdSetting:
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            showSettingDialog()
            break
        case ButtonIdSelectFromAll:
            fallthrough
        case ButtonIdSelectFromOneBook:
            let flag = (id == ButtonIdSelectFromAll) ? true : false
            MySharedPref.writeBool(key: MySharedPref.StudyMode3OptionKey, value: flag)
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
     * CardsStackCallbacks
     */
    public func CardsStackChangedCardNum(cardNum count : Int) {
        let title : String = getCardsRemainText(count: count)
        mTextCardCount!.setText(title)
    }
    
    /**
     * 学習終了時のイベント
     */
    public func CardsStackFinished() {
        if mFirstStudy {
            // 学習結果をDBに保存する
            mFirstStudy = false;
            
            PageViewStudy.saveStudyResult(cardManager: mCardsManager!, book: mBook!)
        }
        
        // カードが０になったので学習完了。リザルトページに遷移
        mState = State.Finish;
        PageViewManagerMain.getInstance().startStudyResultPage(
            book: mBook!,
            okCards: mCardsManager!.getOkCards(),
            ngCards: mCardsManager!.getNgCards())
    }
}
