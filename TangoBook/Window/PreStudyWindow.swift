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
    private var marginH : CGFloat, fontSize : CGFloat, buttonIconW : CGFloat
    

    /**
     * Get/Set
     */

    /**
     * Constructor
     */
    public init(windowCallbacks : UWindowCallbacks?, buttonCallbacks : UButtonCallbacks?,
                parentView : TopView)
    {
        // get options
        mStudyMode = MySharedPref.getStudyMode()
        mStudyType = MySharedPref.getStudyType()
        mStudyOrder = MySharedPref.getStudyOrder()
        mStudyFilter = MySharedPref.getStudyFilter()
        
        marginH = UDpi.toPixel(MARGIN_H)
        fontSize = UDpi.toPixel(TEXT_SIZE)
        buttonIconW = UDpi.toPixel(BUTTON_ICON_W)

        // width, height はinit内で計算するのでここでは0を設定
        super.init(parentView: parentView, callbacks: windowCallbacks, priority: DrawPriority.Dialog.rawValue + 1, x: 0, y: 0,
                   width: parentView.getWidth(), height: parentView.getHeight(), bgColor : BG_COLOR, topBarH: 0, frameW: 0, frameH: 0)
        
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
//        isShow = true;
//        mBook = book;
//        updateLayout();
    }
//
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
//        if (!isShow) return false;
//
//        if (offset == null) {
//            offset = new PointF(pos.x, pos.y);
//        }
//        if (super.touchEvent(vt, offset)) {
//            return true;
//        }
//
        var isRedraw = false
//
//        // touch up
//        for (UButton button : buttons) {
//            if (button == null) continue;
//            if (button.touchUpEvent(vt)) {
//                isRedraw = true;
//            }
//        }
//        // touch
//        for (UButton button : buttons) {
//            if (button == null) continue;
//            if (button.touchEvent(vt, offset)) {
//                return true;
//            }
//        }
//
//        if (super.touchEvent2(vt, null)) {
//            return true;
//        }
//
        return isRedraw
    }


    /**
     * 毎フレーム行う処理
     *
     * @return true:描画を行う
     */
    public override func doAction() -> DoActionRet {
        var ret = DoActionRet.None
//        for (UButton button : buttons) {
//            if (button == null) continue;
//
//            DoActionRet _ret = button.doAction();
//            switch(_ret) {
//                case Done:
//                    return _ret;
//                case Redraw:
//                    ret = _ret;
//                    break;
//            }
//        }
        return ret;
    }

    /**
     * Windowのコンテンツ部分を描画する
     * @param canvas
     * @param paint
     */
    public override func drawContent( offset : CGPoint? ) {
//        // BG
//        UDraw.drawRoundRectFill(canvas, paint, new RectF(getRect()), 20,
//                bgColor, UDpi.toPixel(FRAME_WIDTH), FRAME_COLOR);
//
//        // textViews
//        textTitle.draw(canvas, paint, pos);
//        textCount.draw(canvas, paint, pos);
//        if (textLastStudied != null) {
//            textLastStudied.draw(canvas, paint, pos);
//        }
//        textStudyMode.draw(canvas, paint, pos);
//        textStudyType.draw(canvas, paint, pos);
//        textStudyOrder.draw(canvas, paint, pos);
//        textStudyFilter.draw(canvas, paint, pos);
//
//        // buttons
//        for (UButton button : buttons) {
//            button.draw(canvas, paint, pos) ;
//        }
    }

    /**
     * レイアウト更新
     */
    func updateLayout() {
//
//        int y = UDpi.toPixel(TOP_ITEM_Y);
//        int screenW = mParentView.getWidth();
//        int screenH = mParentView.getHeight();
//        int width = screenW;
//
//        // カード数
//        mCardCount = RealmManager.getItemPosDao().countInParentType(
//                TangoParentType.Book, mBook.getId()
//        );
//        mNgCount = RealmManager.getItemPosDao().countCardInBook(mBook.getId(),
//                TangoItemPosDao.BookCountType.NG);
//
//        // タイトル(単語帳の名前)
//        String title = UResourceManager.getInstance().getStringById(R.string.book) + " : " + mBook
//                .getName();
//        textTitle = UTextView.createInstance( title, UDpi.toPixel(TEXT_SIZE_3), 0,
//                UAlignment.CenterX, screenW, false, false,
//                width / 2, y, 0, TEXT_COLOR, 0);
//        y += textTitle.getHeight() + UDpi.toPixel(MARGIN_V);
//
//        // カード数
//        String cardCount = UResourceManager.getStringById(R.string.card_count) + ": " + mCardCount +
//                "  " + UResourceManager.getStringById(R.string.count_not_learned) + ": " + mNgCount;
//
//        textCount = UTextView.createInstance(
//                cardCount,
//                fontSize, 0,
//                UAlignment.CenterX, screenW, false, false,
//                width / 2, y, 0, TEXT_COLOR, 0);
//        y += textCount.getHeight() + UDpi.toPixel(MARGIN_V);
//
//        // 最終学習日時
//        Date date = RealmManager.getBookHistoryDao().selectMaxDateByBook(mBook.getId());
//        if (date != null) {
//            textLastStudied = UTextView.createInstance(
//                    UResourceManager.getStringById(R.string
//                            .last_studied_date) + ": " + UUtil.convDateFormat(date, ConvDateMode.DateTime),
//                    fontSize, 0,
//                    UAlignment.CenterX, screenW, false, false,
//                    width / 2, y, 0, TEXT_DATE_COLOR, 0);
//            y += textLastStudied.getHeight() + UDpi.toPixel(MARGIN_V) * 2;
//        } else {
//            textLastStudied = null;
//        }
//
//        /**
//         * Buttons
//         */
//        float titleX = (width - UDpi.toPixel(BUTTON_W - 40)) / 2;
//        float buttonX = titleX + UDpi.toPixel(8);
//
//        // 出題方法（出題モード)
//        // タイトル
//        textStudyMode = UTextView.createInstance(
//                UResourceManager.getStringById(R.string.study_mode),
//                UDpi.toPixel(TEXT_SIZE_2), 0,
//                UAlignment.Right_CenterY, screenW, false, false,
//                titleX, y + UDpi.toPixel(BUTTON_H) / 2, 0, TEXT_COLOR, 0);
//
//        // Button
//        buttons[ButtonId.Option1.ordinal()] = new UButtonText(this, UButtonType.BGColor,
//                ButtonIdOption1,
//                0, mStudyMode.getString(),
//                buttonX, y, UDpi.toPixel(BUTTON_W), UDpi.toPixel(BUTTON_H),
//                UDpi.toPixel(BUTTON_TEXT_SIZE), TEXT_COLOR, UColor.LightBlue);
//        buttons[ButtonId.Option1.ordinal()].setPullDownIcon(true);
//
//        y += UDpi.toPixel(BUTTON_H) + UDpi.toPixel(MARGIN_V);
//
//        // 出題タイプ(英日)
//        textStudyType = UTextView.createInstance(
//                UResourceManager.getStringById(R.string.study_type),
//                UDpi.toPixel(TEXT_SIZE_2), 0,
//                UAlignment.Right_CenterY, screenW, false, false,
//                titleX, y + UDpi.toPixel(BUTTON_H) / 2, 0, TEXT_COLOR, 0);
//
//        // Button
//        buttons[ButtonId.Option2.ordinal()] = new UButtonText(this, UButtonType.BGColor,
//                ButtonIdOption2,
//                0, mStudyType.getString(),
//                buttonX, y, UDpi.toPixel(BUTTON_W), UDpi.toPixel(BUTTON_H),
//                UDpi.toPixel(BUTTON_TEXT_SIZE), TEXT_COLOR, UColor.LightGreen);
//        buttons[ButtonId.Option2.ordinal()].setPullDownIcon(true);
//
//        y += UDpi.toPixel(BUTTON_H + MARGIN_V);
//
//        // 順番
//        // タイトル
//        textStudyOrder = UTextView.createInstance(
//                UResourceManager.getStringById(R.string.study_order),
//                UDpi.toPixel(TEXT_SIZE_2), 0,
//                UAlignment.Right_CenterY, screenW, false, false,
//                titleX, y + UDpi.toPixel(BUTTON_H) / 2, 0, TEXT_COLOR, Color.argb(1,0,0,0));
//
//        // Button
//        StudyOrder studyOrder = StudyOrder.toEnum(MySharedPref.readInt(MySharedPref.StudyOrderKey));
//        buttons[ButtonId.Option3.ordinal()] = new UButtonText(this, UButtonType.BGColor,
//                ButtonIdOption3,
//                0, studyOrder.getString(),
//                buttonX, y, UDpi.toPixel(BUTTON_W), UDpi.toPixel(BUTTON_H),
//                UDpi.toPixel(BUTTON_TEXT_SIZE), TEXT_COLOR, UColor.Gold);
//        buttons[ButtonId.Option3.ordinal()].setPullDownIcon(true);
//
//        y += UDpi.toPixel(BUTTON_H + MARGIN_V);
//
//
//        // 学習単語
//        // タイトル
//        textStudyFilter = UTextView.createInstance(
//                UResourceManager.getStringById(R.string.study_filter),
//                UDpi.toPixel(TEXT_SIZE_2), 0,
//                UAlignment.Right_CenterY, screenW, false, false,
//                titleX, y + UDpi.toPixel(BUTTON_H) / 2, 0, TEXT_COLOR, 0);
//
//        // Button
//        StudyFilter studyFilter = StudyFilter.toEnum(MySharedPref.readInt(MySharedPref
//                .StudyFilterKey));
//        buttons[ButtonId.Option4.ordinal()] = new UButtonText(this, UButtonType.BGColor,
//                ButtonIdOption4,
//                0, studyFilter.getString(),
//                buttonX, y, UDpi.toPixel(BUTTON_W), UDpi.toPixel(BUTTON_H),
//                UDpi.toPixel(BUTTON_TEXT_SIZE), TEXT_COLOR, UColor.LightPink);
//        buttons[ButtonId.Option4.ordinal()].setPullDownIcon(true);
//
//        y += UDpi.toPixel(BUTTON_H + MARGIN_V);
//
//        // センタリング
//        pos.x = (screenW - size.width) / 2;
//        pos.y = (screenH - size.height) / 2;
//
//        // 開始ボタン
//        buttons[ButtonId.Start.ordinal()] = new UButtonText(this, UButtonType.Press,
//                PageViewStudyBookSelect.ButtonIdStartStudy,
//                0, UResourceManager.getStringById(R.string.start),
//                width / 2 - UDpi.toPixel(BUTTON2_W) - marginH / 2,
//                size.height - UDpi.toPixel(BUTTON2_H + MARGIN_V),
//                UDpi.toPixel(BUTTON2_W), UDpi.toPixel(BUTTON2_H),
//                fontSize, TEXT_COLOR, Color.rgb(100,200,100));
//        if (mCardCount == 0) {
//            buttons[ButtonId.Start.ordinal()].setEnabled(false);
//        }
//
//        // キャンセルボタン
//        buttons[ButtonId.Cancel.ordinal()] = new UButtonText(this, UButtonType.Press,
//                PageViewStudyBookSelect.ButtonIdCancel,
//                0, UResourceManager.getStringById(R.string.cancel),
//                width / 2 + marginH / 2,
//                size.height - UDpi.toPixel(BUTTON2_H) - UDpi.toPixel(MARGIN_V),
//                UDpi.toPixel(BUTTON2_W), UDpi.toPixel(BUTTON2_H),
//                fontSize, Color.WHITE, Color.rgb(200,100,100));
//
//        updateRect();
    }

    /**
     * 出題モード選択ダイアログを表示する
     */
    private func showOption1Dialog() {
//        if (mDialog == null) {
//            mDialog = UDialogWindow.createInstance(this, this, UDialogWindow.ButtonDir.Vertical,
//                    mParentView.getWidth(), mParentView.getHeight());
//            mDialog.setTitle(UResourceManager.getStringById(R.string.study_mode));
//
//            int margin = UDpi.toPixel(17);
//            // Slide one
//            UButtonText button = new UButtonText(
//            this, UButtonType.Press, ButtonIdOption1_1,
//            0, UResourceManager.getStringById(R.string.study_mode_1),
//                    marginH, 0, mDialog.getWidth() - marginH * 2, buttonIconW + margin,
//                    fontSize, TEXT_COLOR, UColor.LightBlue);
//            button.setImage(UResourceManager.getBitmapById(R.drawable.study_mode1), new Size
//                    (buttonIconW,buttonIconW));
//            button.setImageAlignment(UAlignment.Center);
//            button.setImageOffset(-buttonIconW - margin, 0);
//            mDialog.addDrawable(button);
//
//            // Slide multi
//            button = new UButtonText(
//                    this, UButtonType.Press, ButtonIdOption1_2,
//                    0, UResourceManager.getStringById(R.string.study_mode_2),
//                    marginH, 0, mDialog.getWidth() - marginH * 2, buttonIconW + margin,
//                    fontSize, TEXT_COLOR, UColor.LightBlue);
//            button.setImage(UResourceManager.getBitmapById(R.drawable.study_mode2), new Size
//                    (buttonIconW,buttonIconW));
//            button.setImageAlignment(UAlignment.Center);
//            button.setImageOffset(-buttonIconW - margin, 0);
//            mDialog.addDrawable(button);
//
//            // 4 choice
//            button = new UButtonText(
//                    this, UButtonType.Press, ButtonIdOption1_3,
//                    0, UResourceManager.getStringById(R.string.study_mode_3),
//                    marginH, 0, mDialog.getWidth() - marginH * 2, buttonIconW + margin,
//                    fontSize, TEXT_COLOR, UColor.LightBlue);
//            button.setImage(UResourceManager.getBitmapById(R.drawable.study_mode3), new Size
//                    (buttonIconW,buttonIconW));
//            button.setImageAlignment(UAlignment.Center);
//            button.setImageOffset(-buttonIconW - margin, 0);
//            mDialog.addDrawable(button);
//
//            // input correct
//            button = new UButtonText(
//                    this, UButtonType.Press, ButtonIdOption1_4,
//                    0, UResourceManager.getStringById(R.string.study_mode_4),
//                    marginH, 0, mDialog.getWidth() - marginH * 2, buttonIconW + margin,
//                    fontSize, TEXT_COLOR, UColor.LightBlue);
//            button.setImage(UResourceManager.getBitmapById(R.drawable.study_mode4), new Size
//                    (buttonIconW,buttonIconW));
//            button.setImageAlignment(UAlignment.Center);
//            button.setImageOffset(-buttonIconW - margin, 0);
//            mDialog.addDrawable(button);
//
//            mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
//
//            mDialog.addToDrawManager();
//        }
    }

    /**
     * 出題方法を選択するダイアログを表示
     */
    private func showOption2Dialog() {
//        if (mDialog == null) {
//            mDialog = UDialogWindow.createInstance(this, this, UDialogWindow.ButtonDir.Vertical,
//                    mParentView.getWidth(), mParentView.getHeight());
//            mDialog.setTitle(UResourceManager.getStringById(R.string.study_type));
//            mDialog.addTextView(UResourceManager.getStringById(R.string.study_type_exp),
//                    UAlignment.Center, false, false, UDpi.toPixel(TEXT_SIZE_2), TEXT_COLOR, 0);
//            UButton button = mDialog.addButton(ButtonIdOption2_1, UResourceManager.getStringById(R.string
//                    .study_type_1), TEXT_COLOR, UColor.LightGreen);
//            UButton button2 = mDialog.addButton(ButtonIdOption2_2, UResourceManager.getStringById(R.string
//                    .study_type_2), TEXT_COLOR, UColor.LightGreen);
//
//            if (mStudyType == StudyType.EtoJ) {
//                button.setChecked(true);
//            } else {
//                button2.setChecked(true);
//            }
//
//            mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
//
//            mDialog.addToDrawManager();
//        }
    }

    /**
     * 並び順を選択するダイアログを表示
     */
    private func showOption3Dialog() {
//        if (mDialog == null) {
//            mDialog = UDialogWindow.createInstance(this, this, UDialogWindow.ButtonDir.Vertical,
//                    mParentView.getWidth(), mParentView.getHeight());
//            mDialog.setTitle(UResourceManager.getStringById(R.string.study_order));
//            mDialog.addTextView(UResourceManager.getStringById(R.string.study_order_exp),
//                    UAlignment.Center, false, false, UDpi.toPixel(TEXT_SIZE_2), TEXT_COLOR, 0);
//
//            // buttons
//            UButton button1 = mDialog.addButton(ButtonIdOption3_1, UResourceManager.getStringById(R.string
//                    .study_order_1), TEXT_COLOR, UColor.Gold);
//            UButton button2 = mDialog.addButton(ButtonIdOption3_2, UResourceManager.getStringById(R.string
//                    .study_order_2), TEXT_COLOR, UColor.Gold);
//
//            if (mStudyOrder == StudyOrder.Normal) {
//                button1.setChecked(true);
//            } else {
//                button2.setChecked(true);
//            }
//
//            mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
//
//            mDialog.addToDrawManager();
//        }
    }

    /**
     * 出題単語の絞り込みを選択するダイアログ表示
     */
    private func showOption4Dialog() {
//        if (mDialog == null) {
//            mDialog = UDialogWindow.createInstance(this, this, UDialogWindow.ButtonDir.Vertical,
//                    mParentView.getWidth(), mParentView.getHeight());
//            mDialog.setTitle(UResourceManager.getStringById(R.string.study_filter));
//            mDialog.addTextView(UResourceManager.getStringById(R.string.study_filter_exp),
//                    UAlignment.Center, false, false, UDpi.toPixel(TEXT_SIZE_2), TEXT_COLOR, 0);
//            // buttons
//            UButton button1 = mDialog.addButton(ButtonIdOption4_1, UResourceManager.getStringById(R.string
//                    .study_filter_1), TEXT_COLOR, UColor.LightPink);
//            UButton button2 = mDialog.addButton(ButtonIdOption4_2, UResourceManager.getStringById(R.string
//                    .study_filter_2), TEXT_COLOR, UColor.LightPink);
//            if (mStudyFilter == StudyFilter.All) {
//                button1.setChecked(true);
//            } else {
//                button2.setChecked(true);
//            }
//
//
//            mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
//
//            mDialog.addToDrawManager();
//        }
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
//        switch (id) {
//            case PageViewStudyBookSelect.ButtonIdStartStudy:
//                if (mCardCount == 0 || (mStudyFilter == StudyFilter.NotLearned && mNgCount == 0))
//                {
//                    // 未収得カード数が0なら終了
//                    mDialog = UDialogWindow.createInstance(
//                            null, this,
//                            UDialogWindow.ButtonDir.Vertical, mParentView.getWidth(), mParentView
//                                    .getHeight());
//                    mDialog.setTitle(UResourceManager.getStringById(R.string.not_exit_study_card));
//                    mDialog.addCloseButton(UResourceManager.getStringById(R.string.ok));
//                    mDialog.addToDrawManager();
//                    break;
//                }
//                // オプションを保存
//                MySharedPref.writeInt(MySharedPref.StudyModeKey, mStudyMode.ordinal());
//                MySharedPref.writeInt(MySharedPref.StudyTypeKey, mStudyType.ordinal());
//                MySharedPref.writeInt(MySharedPref.StudyOrderKey, mStudyOrder.ordinal());
//                MySharedPref.writeInt(MySharedPref.StudyFilterKey, mStudyFilter.ordinal());
//
//                if (mButtonCallbacks != null) {
//                    mButtonCallbacks.UButtonClicked(id, pressedOn);
//                }
//                break;
//            case PageViewStudyBookSelect.ButtonIdCancel:
//                if (mButtonCallbacks != null) {
//                    mButtonCallbacks.UButtonClicked(id, pressedOn);
//                }
//                break;
//            case ButtonIdOption1:
//                showOption1Dialog();
//                break;
//            case ButtonIdOption2:
//                showOption2Dialog();
//                break;
//            case ButtonIdOption3:
//                showOption3Dialog();
//                break;
//            case ButtonIdOption4:
//                showOption4Dialog();
//                break;
//            case ButtonIdOption1_1:
//                mDialog.startClosing();
//                setStudyMode(StudyMode.SlideOne);
//                break;
//            case ButtonIdOption1_2:
//                mDialog.startClosing();
//                setStudyMode(StudyMode.SlideMulti);
//                break;
//            case ButtonIdOption1_3:
//                mDialog.startClosing();
//                setStudyMode(StudyMode.Choice4);
//                break;
//            case ButtonIdOption1_4:
//                mDialog.startClosing();
//                setStudyMode(StudyMode.Input);
//                break;
//            case ButtonIdOption2_1:
//                mDialog.startClosing();
//                setStudyType(StudyType.EtoJ);
//                break;
//            case ButtonIdOption2_2:
//                mDialog.startClosing();
//                setStudyType(StudyType.JtoE);
//                break;
//            case ButtonIdOption3_1:
//                mDialog.startClosing();
//                setStudyOrder(StudyOrder.Normal);
//                break;
//            case ButtonIdOption3_2:
//                mDialog.startClosing();
//                setStudyOrder(StudyOrder.Random);
//                break;
//            case ButtonIdOption4_1:
//                mDialog.startClosing();
//                setStudyFilter(StudyFilter.All);
//                break;
//            case ButtonIdOption4_2:
//                mDialog.startClosing();
//                setStudyFilter(StudyFilter.NotLearned);
//                break;
//
//        }
//        if (super.UButtonClicked(id, pressedOn)) {
//            return true;
//        }
        return false
    }

    /**
     * 学習モードを設定
     */
    private func setStudyMode( mode : StudyMode) {
//        if (mStudyMode != mode) {
//            mStudyMode = mode;
//            MySharedPref.writeInt(MySharedPref.StudyModeKey, mode.ordinal());
//            buttons[ButtonId.Option1.ordinal()].setText(mode.getString());
//        }
    }

    /**
     * 学習タイプを設定
     */
    private func setStudyType( type : StudyType) {
//        if (mStudyType != type) {
//            mStudyType = type;
//            MySharedPref.writeInt(MySharedPref.StudyTypeKey, type.ordinal());
//            buttons[ButtonId.Option2.ordinal()].setText(type.getString());
//        }
    }

    /**
     * 並び順を設定
     * @param order
     */
    private func setStudyOrder( order : StudyOrder) {
//        if (mStudyOrder != order) {
//            mStudyOrder = order;
//            MySharedPref.writeInt(MySharedPref.StudyOrderKey, order.ordinal());
//            buttons[ButtonId.Option3.ordinal()].setText(order.getString());
//        }
    }

    /**
     * 絞り込みを設定
     */
    private func setStudyFilter( filter : StudyFilter ) {
//        if (mStudyFilter != filter) {
//            mStudyFilter = filter;
//            MySharedPref.writeInt(MySharedPref.StudyFilterKey, filter.ordinal());
//            buttons[ButtonId.Option4.ordinal()].setText(filter.getString());
//        }
    }

    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public func onBackKeyDown() -> Bool {
//        if (mDialog != null) {
//            mDialog.closeDialog();
//            mDialog = null;
//            return true;
//        }
        return false
    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed(dialog : UDialogWindow ) {
//        if (dialog == mDialog) {
//            mDialog = null;
//        }
    }
}
