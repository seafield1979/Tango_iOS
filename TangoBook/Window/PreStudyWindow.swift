//
//  PreStudyWindow.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/06.
 *
 * Bookを学習する前に表示されるダイアログ
 * 学習の方法のオプションを設定できる
 */

public class PreStudyWindow : UWindow, UDialogCallbacks {
    /**
     * Enum
     */
    enum ButtonId : Int, EnumEnumerable {
        case Start
        case Cancel
        case Option1
        case Option2
        case Option3
        case Option4
    }

    /**
     * Consts
     */
    public let TAG = "PreStudyWindow"
    private let FRAME_WIDTH = 1;
    private let TOP_ITEM_Y = 10;
    private let MARGIN_V = 13;
    private let MARGIN_H = 13;
    private let TEXT_SIZE = 17;
    private let TEXT_SIZE_2 = 13;
    private let TEXT_SIZE_3 = 23;
    private let BUTTON_TEXT_SIZE = 17;

    private let BUTTON_W = 200;
    private let BUTTON_H = 40;
    private let BUTTON2_W = 134;
    private let BUTTON2_H = 67;

    private let BUTTON_ICON_W = 67;

    private let BG_COLOR = UIColor.white
    private let FRAME_COLOR = UColor.makeColor(120,120,120);
    private let TEXT_COLOR = UIColor.black
    private let TEXT_DATE_COLOR = UColor.makeColor(80,80,80);
    private let CANCEL_COLOR = UColor.makeColor(200,100,100)

    // button Id
    private let ButtonIdOption1 = 100;
    private let ButtonIdOption2 = 200;
    private let ButtonIdOption3 = 300;
    private let ButtonIdOption4 = 400;

    // 出題モード
    private let ButtonIdOption1_1 = 101;
    private let ButtonIdOption1_2 = 102;
    private let ButtonIdOption1_3 = 103;
    private let ButtonIdOption1_4 = 104;

    // 出題モード2
    private let ButtonIdOption2_1 = 110;
    private let ButtonIdOption2_2 = 111;

    // 並び順
    private let ButtonIdOption3_1 = 201;
    private let ButtonIdOption3_2 = 202;

    // 絞り込み
    private let ButtonIdOption4_1 = 301;
    private let ButtonIdOption4_2 = 302;

    /**
     * Member Variables
     */
    var mButtonCallbacks : UButtonCallbacks? = nil
    private var textTitle : UTextView? = nil
    private var textCount : UTextView? = nil
    private var textLastStudied : UTextView? = nil
    private var textStudyMode : UTextView? = nil
    private var textStudyType : UTextView? = nil
    private var textStudyOrder : UTextView? = nil
    private var textStudyFilter : UTextView? = nil

    private var mCardCount : Int = 0, mNgCount : Int = 0

    // options
    var mStudyMode : StudyMode
    var mStudyType : StudyType
    var mStudyOrder : StudyOrder
    var mStudyFilter : StudyFilter

    // buttons
    private var buttons : [UButtonText?] = Array(repeating: nil, count: ButtonId.cases.count)

    // ダイアログに情報を表示元のTangoBook
    var mBook : TangoBook? = nil

    // オプション選択ダイアログ
    var mDialog : UDialogWindow? = nil

    // Dpi計算済みの座標
    private var marginH : CGFloat, fontSize : Int, buttonIconW : CGFloat
    

    /**
     * Get/Set
     */

    /**
     * Constructor
     */
    public init(windowCallbacks : UWindowCallbacks?, buttonCallbacks : UButtonCallbacks?,
                topScene : TopScene)
    {
        // get options
        mStudyMode = MySharedPref.getStudyMode()
        mStudyType = MySharedPref.getStudyType()
        mStudyOrder = MySharedPref.getStudyOrder()
        mStudyFilter = MySharedPref.getStudyFilter()
        
        marginH = UDpi.toPixel(MARGIN_H)
        fontSize = UDpi.toPixelInt(TEXT_SIZE)
        buttonIconW = UDpi.toPixel(BUTTON_ICON_W)

        // width, height はinit内で計算するのでここでは0を設定
        super.init(
                topScene: topScene, callbacks: windowCallbacks,
                priority: DrawPriority.Dialog.rawValue + 1,
                createNode: true, cropping: false,
                x: 0, y: 0,
                width: topScene.getWidth(), height: topScene.getHeight(),
                bgColor : BG_COLOR, topBarH: 0, frameW: 0, frameH: 0)
        
        mButtonCallbacks = buttonCallbacks
        isShow = false;     // 初期状態は非表示

    }

    /**
     * Methods
     */
    /**
     * 指定のBook情報でWindowを表示する
     * @param book
     */
    public func showWithBook( book : TangoBook) {
        isShow = true
        mBook = book
        updateLayout()
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        if !isShow {
            return false
        }

        var offset = offset
        if offset == nil {
            offset = CGPoint(x: pos.x, y: pos.y)
        }
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }

        var isRedraw = false

        // touch up
        for button in buttons {
            if button == nil { continue }
            if button!.touchUpEvent(vt: vt) {
                isRedraw = true
            }
        }
        // touch
        for button in buttons {
            if button == nil { continue }
            if button!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }

        if super.touchEvent2(vt: vt, offset: nil) {
            return true
        }

        return isRedraw
    }


    /**
     * 毎フレーム行う処理
     *
     * @return true:描画を行う
     */
    public override func doAction() -> DoActionRet {
        var ret = DoActionRet.None
        for button in buttons {
            if button == nil { continue }

            let _ret : DoActionRet = button!.doAction()
            switch _ret {
            case .Done:
                return _ret
            case .Redraw:
                ret = _ret
            default:
                break
            }
        }
        return ret
    }

    /**
     * Windowのコンテンツ部分を描画する
     * @param canvas
     * @param paint
     */
    public override func drawContent( offset : CGPoint? ) {
        // BG
        if bgColor != nil {
            UDraw.drawRoundRectFill( rect : getRect(),
                                     cornerR : 20, color : bgColor!,
                                     strokeWidth : UDpi.toPixel(FRAME_WIDTH),
                                     strokeColor : FRAME_COLOR)
        }

        // textViews
        if textTitle != nil {
            textTitle!.draw()
        }
        if textCount != nil {
            textCount!.draw()
        }
        if textLastStudied != nil {
            textLastStudied!.draw()
        }
        if textStudyMode != nil {
            textStudyMode!.draw()
        }
        if textStudyType != nil {
            textStudyType!.draw()
        }
        if textStudyOrder != nil {
            textStudyOrder!.draw()
        }
        if textStudyFilter != nil {
            textStudyFilter!.draw()
        }

        // buttons
        for button in buttons {
            button!.draw()
        }
    }

    /**
     * レイアウト更新
     */
    func updateLayout() {

        var y = UDpi.toPixel(TOP_ITEM_Y)
        let screenW = topScene.getWidth()
        let screenH = topScene.getHeight()
        let width = screenW

        // カード数
        mCardCount = TangoItemPosDao.countInParentType(
            parentType: TangoParentType.Book, parentId: mBook!.getId()
        );
        mNgCount = TangoItemPosDao.countCardInBook( bookId: mBook!.getId(),
                                                    countType: TangoItemPosDao.BookCountType.NG);

        // タイトル(単語帳の名前)
        let title : String = UResourceManager.getStringByName("book") + " : " + mBook!.getName()!
        textTitle = UTextView.createInstance(
            text : title, textSize : UDpi.toPixelInt(TEXT_SIZE_3), priority : 0,
            alignment : UAlignment.CenterX, createNode: true,
            multiLine : false, isDrawBG : false,
            x : width/2, y : y, width : 0, color : TEXT_COLOR, bgColor : nil)
        y += textTitle!.getHeight() + UDpi.toPixel(MARGIN_V)
        
        // カード数
        let cardCount = UResourceManager.getStringByName("card_count") + ": " + mCardCount.description +
                "  " + UResourceManager.getStringByName("count_not_learned") + ": " + mNgCount.description

        textCount = UTextView.createInstance(
                text : cardCount, textSize : fontSize, priority : 0,
                alignment : UAlignment.CenterX, createNode: true,
                multiLine : false, isDrawBG : false,
                x : width / 2, y : y, width : 0,
                color : TEXT_COLOR, bgColor : nil);
        y += textCount!.getHeight() + UDpi.toPixel(MARGIN_V)

        // 最終学習日時
        let date = TangoBookHistoryDao.selectMaxDateByBook(bookId: mBook!.getId())
        if date != nil {
            textLastStudied = UTextView.createInstance(
                text : UResourceManager.getStringByName("last_studied_date") + ":" + UUtil.convDateFormat(date: date!, mode: ConvDateMode.DateTime),
                textSize : fontSize, priority : 0,
                alignment : UAlignment.CenterX, createNode: true,
                multiLine : false, isDrawBG : false, x : width/2, y : y, width : 0, color : TEXT_DATE_COLOR, bgColor : nil)
            y += textLastStudied!.getHeight() + UDpi.toPixel(MARGIN_V) * 2
        } else {
            textLastStudied = nil
        }

        /**
         * Buttons
         */
        let titleX = (width - UDpi.toPixel(BUTTON_W - 40)) / 2
        let buttonX = titleX + UDpi.toPixel(8)

        // 出題方法（出題モード)
        // タイトル
        textStudyMode = UTextView.createInstance(
                text : UResourceManager.getStringByName("study_mode"),
                textSize : UDpi.toPixelInt(TEXT_SIZE_2), priority : 0,
                alignment : UAlignment.Right_CenterY, createNode: true,
                multiLine : false,
                isDrawBG : false, x : titleX, y : y + UDpi.toPixel(BUTTON_H) / 2,
                width : 0, color : TEXT_COLOR, bgColor : nil)

        // Button
        buttons[ButtonId.Option1.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.BGColor, id : ButtonIdOption1,
            priority : 0, text : mStudyMode.getString(), createNode: true,
            x : buttonX, y : y,
            width : UDpi.toPixel(BUTTON_W), height : UDpi.toPixel(BUTTON_H),
            textSize : UDpi.toPixelInt(BUTTON_TEXT_SIZE), textColor : TEXT_COLOR, bgColor: UColor.LightBlue)
        
        buttons[ButtonId.Option1.rawValue]!.setPullDownIcon(true)

        y += UDpi.toPixel(BUTTON_H) + UDpi.toPixel(MARGIN_V)

        // 出題タイプ(英日)
        textStudyType = UTextView.createInstance(
                text : UResourceManager.getStringByName("study_type"),
                textSize : UDpi.toPixelInt(TEXT_SIZE_2), priority : 0,
                alignment : UAlignment.Right_CenterY, createNode: true,
                multiLine : false,
                isDrawBG : false, x : titleX, y : y+UDpi.toPixel(BUTTON_H)/2,
                width : 0, color : TEXT_COLOR, bgColor : nil)

        // Button
        buttons[ButtonId.Option2.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.BGColor, id : ButtonIdOption2,
            priority : 0, text : mStudyType.getString(), createNode: true,
            x : buttonX, y : y,
            width : UDpi.toPixel(BUTTON_W), height : UDpi.toPixel(BUTTON_H),
            textSize : UDpi.toPixelInt(BUTTON_TEXT_SIZE), textColor : TEXT_COLOR,
            bgColor : UColor.LightGreen)
        
        buttons[ButtonId.Option2.rawValue]!.setPullDownIcon(true)

        y += UDpi.toPixel(BUTTON_H + MARGIN_V)

        // 順番
        // タイトル
        textStudyOrder = UTextView.createInstance(
                text : UResourceManager.getStringByName("study_order"),
                textSize : UDpi.toPixelInt(TEXT_SIZE_2), priority : 0,
                alignment : UAlignment.Right_CenterY, createNode: true,
                multiLine : false,
                isDrawBG : false, x : titleX, y : y+UDpi.toPixel(BUTTON_H)/2,
                width : 0, color : TEXT_COLOR, bgColor : .black)

        // Button
        let studyOrder = StudyOrder.toEnum(MySharedPref.readInt(MySharedPref.StudyOrderKey))
        buttons[ButtonId.Option3.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.BGColor,
            id : ButtonIdOption3, priority : 0, text : studyOrder.getString(),
            createNode: true,
            x : buttonX, y : y,
            width : UDpi.toPixel(BUTTON_W), height : UDpi.toPixel(BUTTON_H),
            textSize : UDpi.toPixelInt(BUTTON_TEXT_SIZE), textColor : TEXT_COLOR,
            bgColor : UColor.Gold)
        
        buttons[ButtonId.Option3.rawValue]!.setPullDownIcon(true)

        y += UDpi.toPixel(BUTTON_H + MARGIN_V)

        // 学習単語
        // タイトル
        textStudyFilter = UTextView.createInstance(
                text : UResourceManager.getStringByName("study_filter"),
                textSize : UDpi.toPixelInt(TEXT_SIZE_2), priority : 0,
                alignment : UAlignment.Right_CenterY, createNode: true,
                multiLine : false,
                isDrawBG : false, x : titleX, y : y+UDpi.toPixel(BUTTON_H)/2,
                width : 0, color : TEXT_COLOR, bgColor : nil)

        // Button
        let studyFilter = StudyFilter.toEnum(MySharedPref.readInt(MySharedPref
                .StudyFilterKey))
        buttons[ButtonId.Option4.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.BGColor, id : ButtonIdOption4,
            priority : 0, text : studyFilter.getString(), createNode: true,
            x : buttonX, y : y,
            width : UDpi.toPixel(BUTTON_W), height : UDpi.toPixel(BUTTON_H),
            textSize : UDpi.toPixelInt(BUTTON_TEXT_SIZE), textColor : TEXT_COLOR,
            bgColor : UColor.LightPink);
        buttons[ButtonId.Option4.rawValue]!.setPullDownIcon(true);

        y += UDpi.toPixel(BUTTON_H + MARGIN_V);

        // センタリング
        pos.x = (screenW - size.width) / 2;
        pos.y = (screenH - size.height) / 2;

        // 開始ボタン
        buttons[ButtonId.Start.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.Press,
            id : PageViewStudyBookSelect.ButtonIdStartStudy, priority : 0,
            text : UResourceManager.getStringByName("start"), createNode: true,
            x : width/2-UDpi.toPixel(BUTTON2_W)-marginH/2, y : size.height-UDpi.toPixel(BUTTON2_H+MARGIN_V),
            width : UDpi.toPixel(BUTTON2_W), height : UDpi.toPixel(BUTTON2_H),
            textSize : fontSize, textColor : TEXT_COLOR, bgColor : UColor.LightGreen)
        
        if (mCardCount == 0) {
            buttons[ButtonId.Start.rawValue]!.setEnabled(false)
        }

        // キャンセルボタン
        buttons[ButtonId.Cancel.rawValue] = UButtonText(
            callbacks : self, type : UButtonType.Press,
            id : PageViewStudyBookSelect.ButtonIdCancel, priority : 0,
            text : UResourceManager.getStringByName("cancel"), createNode: true,
            x : width / 2 + marginH / 2, y : size.height-UDpi.toPixel(BUTTON2_H) - UDpi.toPixel(MARGIN_V),
            width : UDpi.toPixel(BUTTON2_W), height : UDpi.toPixel(BUTTON2_H),
            textSize: fontSize, textColor : UIColor.white, bgColor : CANCEL_COLOR)

        updateRect()
    }

    /**
     * 出題モード選択ダイアログを表示する
     */
    private func showOption1Dialog() {
        if mDialog == nil {
            mDialog = UDialogWindow.createInstance(
                topScene : topScene,
                buttonCallbacks : self, dialogCallbacks : self,
                buttonDir : UDialogWindow.ButtonDir.Vertical,
                screenW : topScene.getWidth(), screenH : topScene.getHeight())
            
            mDialog!.setTitle(UResourceManager.getStringByName("study_mode"))

            let margin = UDpi.toPixel(17)
            // Slide one
            var button = UButtonText(
            callbacks : self, type : UButtonType.Press, id : ButtonIdOption1_1,
            priority : 0, text : UResourceManager.getStringByName("study_mode_1"),
            createNode: true,
            x : marginH, y : 0,
            width : mDialog!.getWidth() - marginH * 2, height : buttonIconW+margin,
            textSize: fontSize, textColor: TEXT_COLOR, bgColor : UColor.LightBlue)
            
            button.setImage( image: UResourceManager.getImageByName(ImageName.study_mode1)!,
                             imageSize: CGSize(width: buttonIconW, height: buttonIconW))
            button.setImageAlignment(UAlignment.Center)
            button.setImageOffset( x: -buttonIconW - margin, y: 0)
            mDialog!.addDrawable(obj: button)

            // Slide multi
            button = UButtonText(
                    callbacks : self, type : UButtonType.Press, id : ButtonIdOption1_2,
                    priority : 0, text :UResourceManager.getStringByName("study_mode_2"),
                    createNode: true,
                    x : marginH, y : 0, width : mDialog!.getWidth() - marginH * 2,
                    height : buttonIconW+margin, textSize : fontSize, textColor : TEXT_COLOR,  bgColor: UColor.LightBlue)
            
            button.setImage(image: UResourceManager.getImageByName(ImageName.study_mode2)!,
                            imageSize: CGSize(width: buttonIconW, height: buttonIconW))
            button.setImageAlignment(UAlignment.Center)
            button.setImageOffset(x: -buttonIconW - margin, y: 0)
            mDialog!.addDrawable(obj: button)

            // 4 choice
            button = UButtonText(
                    callbacks : self, type : UButtonType.Press,
                    id : ButtonIdOption1_3, priority : 0,
                    text : UResourceManager.getStringByName("study_mode_3"),
                    createNode: true,
                    x : marginH, y : 0,
                    width : mDialog!.getWidth() - marginH * 2,
                    height : buttonIconW+margin, textSize : fontSize, textColor : TEXT_COLOR, bgColor: UColor.LightBlue)
            
            button.setImage(image: UResourceManager.getImageByName(ImageName.study_mode3)!, imageSize: CGSize(width: buttonIconW, height: buttonIconW))
            button.setImageAlignment( UAlignment.Center )
            button.setImageOffset( x: -buttonIconW - margin, y: 0)
            mDialog!.addDrawable(obj: button)

            // input correct
            button = UButtonText(
                    callbacks : self, type : UButtonType.Press, id : ButtonIdOption1_4, priority : 0,
                    text : UResourceManager.getStringByName("study_mode_4"),
                    createNode: true,
                    x : marginH, y : 0,
                    width : mDialog!.getWidth() - marginH * 2,
                    height : buttonIconW+margin, textSize : fontSize, textColor : TEXT_COLOR, bgColor : UColor.LightBlue)
            button.setImage(image: UResourceManager.getImageByName(ImageName.study_mode4)!, imageSize: CGSize(width: buttonIconW, height: buttonIconW))
            button.setImageAlignment(UAlignment.Center)
            button.setImageOffset(x: -buttonIconW - margin, y: 0)
            
            mDialog!.addDrawable(obj: button)
            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
            mDialog!.addToDrawManager();
        }
    }

    /**
     * 出題方法を選択するダイアログを表示
     */
    private func showOption2Dialog() {
        if mDialog == nil {
            mDialog = UDialogWindow.createInstance(
                topScene : topScene, buttonCallbacks : self, dialogCallbacks : self, buttonDir : UDialogWindow.ButtonDir.Vertical, screenW : topScene.getWidth(), screenH : topScene.getHeight())
            
            mDialog!.setTitle(UResourceManager.getStringByName("study_type"));
            _ = mDialog!.addTextView(
                text : UResourceManager.getStringByName("study_type_exp"),
                alignment : UAlignment.Center, multiLine : false,
                isDrawBG : false, textSize : UDpi.toPixelInt(TEXT_SIZE_2),
                textColor : TEXT_COLOR, bgColor : nil)
            
            let button = mDialog!.addButton(id : ButtonIdOption2_1, text : UResourceManager.getStringByName("study_type_1"), textColor : TEXT_COLOR, color : UColor.LightGreen)
            let button2 = mDialog!.addButton(id : ButtonIdOption2_2, text : UResourceManager.getStringByName("study_type_2"), textColor : TEXT_COLOR, color : UColor.LightGreen);

            if (mStudyType == StudyType.EtoJ) {
                button.setChecked(true)
            } else {
                button2.setChecked(true)
            }

            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            mDialog!.addToDrawManager()
        }
    }

    /**
     * 並び順を選択するダイアログを表示
     */
    private func showOption3Dialog() {
        if mDialog == nil {
            mDialog = UDialogWindow.createInstance(
                topScene : topScene, buttonCallbacks : self,
                dialogCallbacks : self, buttonDir : .Vertical,
                screenW : topScene.getWidth(), screenH : topScene.getHeight())
            
            mDialog!.setTitle(UResourceManager.getStringByName("study_order"))
            
            _ = mDialog!.addTextView(
                text : UResourceManager.getStringByName("study_order_exp"),
                alignment : UAlignment.Center, multiLine : false, isDrawBG : false,
                textSize : UDpi.toPixelInt(TEXT_SIZE_2), textColor : TEXT_COLOR,
                bgColor : nil)

            // buttons
            let button1 = mDialog!.addButton(id : ButtonIdOption3_1, text : UResourceManager.getStringByName("study_order_1"), textColor : TEXT_COLOR, color : UColor.Gold)
            let button2 = mDialog!.addButton(id : ButtonIdOption3_2, text : UResourceManager.getStringByName("study_order_2"), textColor : TEXT_COLOR, color : UColor.Gold)

            if (mStudyOrder == StudyOrder.Normal) {
                button1.setChecked(true);
            } else {
                button2.setChecked(true);
            }

            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            mDialog!.addToDrawManager()
        }
    }

    /**
     * 出題単語の絞り込みを選択するダイアログ表示
     */
    private func showOption4Dialog() {
        if mDialog == nil {
            mDialog = UDialogWindow.createInstance(topScene : topScene, buttonCallbacks : self, dialogCallbacks : self, buttonDir : UDialogWindow.ButtonDir.Vertical, screenW : topScene.getWidth(), screenH : topScene.getHeight())
            mDialog!.setTitle(UResourceManager.getStringByName("study_filter"))
            
            _ = mDialog!.addTextView(
                text : UResourceManager.getStringByName("study_filter_exp"),
                alignment : UAlignment.Center, multiLine : false, isDrawBG : false, textSize : UDpi.toPixelInt(TEXT_SIZE_2), textColor : TEXT_COLOR, bgColor : nil);
            // buttons
            let button1 = mDialog!.addButton(id : ButtonIdOption4_1, text : UResourceManager.getStringByName("study_filter_1"), textColor : TEXT_COLOR, color : UColor.LightPink)
            let button2 = mDialog!.addButton(id : ButtonIdOption4_2, text : UResourceManager.getStringByName("study_filter_2"), textColor : TEXT_COLOR, color : UColor.LightPink)
            if (mStudyFilter == StudyFilter.All) {
                button1.setChecked(true)
            } else {
                button2.setChecked(true)
            }

            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            mDialog!.addToDrawManager()
        }
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
        switch (id) {
        case PageViewStudyBookSelect.ButtonIdStartStudy:
            if mCardCount == 0 || (mStudyFilter == StudyFilter.NotLearned && mNgCount == 0)
            {
                // 未収得カード数が0なら終了
                mDialog = UDialogWindow.createInstance(
                        topScene : topScene, buttonCallbacks : nil, dialogCallbacks : self, buttonDir : UDialogWindow.ButtonDir.Vertical, screenW : topScene.getWidth(), screenH : topScene.getHeight())
                mDialog!.setTitle(UResourceManager.getStringByName("not_exit_study_card"))
                mDialog!.addCloseButton(text: UResourceManager.getStringByName("ok"))
                mDialog!.addToDrawManager();
                
            } else {
                // オプションを保存
                MySharedPref.writeInt(key: MySharedPref.StudyModeKey, value: mStudyMode.rawValue);
                MySharedPref.writeInt(key: MySharedPref.StudyTypeKey, value: mStudyType.rawValue);
                MySharedPref.writeInt(key: MySharedPref.StudyOrderKey, value: mStudyOrder.rawValue);
                MySharedPref.writeInt(key: MySharedPref.StudyFilterKey, value: mStudyFilter.rawValue);

                if mButtonCallbacks != nil {
                    _ = mButtonCallbacks!.UButtonClicked(id: id, pressedOn: pressedOn)
                }
            }
            
        case PageViewStudyBookSelect.ButtonIdCancel:
            if mButtonCallbacks != nil {
                _ = mButtonCallbacks!.UButtonClicked(id: id, pressedOn: pressedOn)
            }
            
        case ButtonIdOption1:
            showOption1Dialog()
            
        case ButtonIdOption2:
            showOption2Dialog()
            
        case ButtonIdOption3:
            showOption3Dialog()
            
        case ButtonIdOption4:
            showOption4Dialog()
            
        case ButtonIdOption1_1:
            mDialog!.closeDialog()
            setStudyMode(mode: StudyMode.SlideOne)
            
        case ButtonIdOption1_2:
            mDialog!.closeDialog()
            setStudyMode(mode: StudyMode.SlideMulti)
            
        case ButtonIdOption1_3:
            mDialog!.closeDialog()
            setStudyMode(mode: StudyMode.Choice4)
            
        case ButtonIdOption1_4:
            mDialog!.closeDialog()
            setStudyMode(mode: StudyMode.Input)
            
        case ButtonIdOption2_1:
            mDialog!.closeDialog()
            setStudyType(type: StudyType.EtoJ)
            
        case ButtonIdOption2_2:
            mDialog!.closeDialog()
            setStudyType(type: StudyType.JtoE)
            
        case ButtonIdOption3_1:
            mDialog!.closeDialog()
            setStudyOrder(order: StudyOrder.Normal)
            
        case ButtonIdOption3_2:
            mDialog!.closeDialog()
            setStudyOrder(order: StudyOrder.Random)
            
        case ButtonIdOption4_1:
            mDialog!.closeDialog()
            setStudyFilter(filter: StudyFilter.All)
            
        case ButtonIdOption4_2:
            mDialog!.closeDialog()
            setStudyFilter(filter: StudyFilter.NotLearned)
        default:
            break
        }
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }
        return false
    }

    /**
     * 学習モードを設定
     */
    private func setStudyMode( mode : StudyMode) {
        if mStudyMode != mode {
            self.mStudyMode = mode
            MySharedPref.writeInt(key: MySharedPref.StudyModeKey, value: mode.rawValue);
            buttons[ButtonId.Option1.rawValue]!.setText(mText: mode.getString())
        }
    }

    /**
     * 学習タイプを設定
     */
    private func setStudyType( type : StudyType) {
        if mStudyType != type {
            mStudyType = type
            MySharedPref.writeInt(key: MySharedPref.StudyTypeKey, value: type.rawValue)
            buttons[ButtonId.Option2.rawValue]!.setText(mText: type.getString())
        }
    }

    /**
     * 並び順を設定
     * @param order
     */
    private func setStudyOrder( order : StudyOrder) {
        if mStudyOrder != order {
            mStudyOrder = order
            MySharedPref.writeInt(key: MySharedPref.StudyOrderKey, value: order.rawValue)
            buttons[ButtonId.Option3.rawValue]!.setText(mText: order.getString())
        }
    }

    /**
     * 絞り込みを設定
     */
    private func setStudyFilter( filter : StudyFilter ) {
        if mStudyFilter != filter {
            mStudyFilter = filter
            MySharedPref.writeInt(key: MySharedPref.StudyFilterKey, value: filter.rawValue)
            buttons[ButtonId.Option4.rawValue]!.setText(mText: filter.getString())
        }
    }

    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public func onBackKeyDown() -> Bool {
        if mDialog != nil {
            mDialog!.closeDialog()
            mDialog = nil
            return true
        }
        return false
    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed(dialog : UDialogWindow ) {
        if dialog === mDialog {
            mDialog = nil
        }
    }
}
