//
//  StudyCardInput.swift
//  TangoBook
//    正解入力学習モードで使用するカード
//
//    正解の文字(ボタン)をタップする
//    正解なら次の文字へ、不正解なら別のボタンをタップする
//    全ての文字をタップしたら次のカードへ
//    １文字でも間違いをタップしたら不正解
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class StudyCardInput : UDrawable, UButtonCallbacks {
    /**
     * Enums
     */
    public enum State {
        case None
        case Appearance         // 出現
        case ShowAnswer         // 正解表示中
        case Disappearance       // 消える
    }

    // 親に対する要求
    public enum RequestToParent {
        case None
        case End
    }

    /**
     * Consts
     */
    public let ANIME_FRAME = 10;

    // layout
    private let MARGIN_H = 17
    private let MARGIN_V = 17
    private let QBUTTON_W = 40
    private let QBUTTON_H = 40
    private static let FONT_SIZE = 17
    private let FONT_SIZE_L = 23
    private let TEXT_COLOR = UIColor.black
    private let FRAME_COLOR = UColor.makeColor(150,150,150)

    private let TEXT_MARGIN_H2 = 10
    private let TEXT_MARGIN_V = 10
    private let ONE_TEXT_WIDTH = FONT_SIZE + 7
    private let ONE_TEXT_HEIGHT = FONT_SIZE + 7

    // color
    private let BUTTON_COLOR = UColor.LightGray
    private let NG_BUTTON_COLOR = UColor.LightRed


    /**
     * Member Variables
     */
    public var mState : State = .Appearance
    public var mCard : TangoCard?
    private var mWord : String?

    // 正解の文字列を１文字づつStringに分割したもの
    private var mCorrectWords : List<String> = List()
    private var mCorrectFlags : List<Bool> = List()

    // 正解入力用の文字をバラしてランダムに並び替えた配列
    private var mQuestionButtons : List<UButtonText> = List()
    private var isTouching : Bool = false
    private var basePos : CGPoint = CGPoint()

    // 正解入力位置
    private var inputPos : Int = 0

    // １回でも間違えたかどうか
    public var isMistaken : Bool = false

    // 親への通知用
    private var mRequest : RequestToParent = .None

    public func getRequest() -> RequestToParent {
        return mRequest
    }

    // MARK: Accessor
    public func setState( state : State) {
        mState = state
    }

    private func getButtonById(id : Int) -> UButtonText? {
        for button in mQuestionButtons {
            if button!.getId() == id {
                return button
            }
        }
        return nil
    }

    // MARK: Initializer
    public init( card : TangoCard, canvasW : CGFloat, height : CGFloat)
    {
        super.init(priority: 0, x: 0, y: 0, width: canvasW - UDpi.toPixel(MARGIN_H) * 2, height: height)

//        mState = .None
//        mCard = card
//        mWord = card.getWordA()
//        String[] strArray = card.getWordA().toLowerCase().split("")
//
//        // strArrayの先頭に余分な空文字が入っているので除去
//        // 空白も除去
//        for (int i=1; i<strArray.length; i++) {
//            mCorrectWords.add(strArray[i]);
//            mCorrectFlags.add(true);
//        }
//
//        basePos = new PointF(size.width / 2, size.height / 2);
//        inputPos = 0;
//
//        ArrayList<String> questions = new ArrayList<>();
//
//        // 出題文字化どうかの判定を行う（記号や数字使用しない）
//        for (int i=1; i<strArray.length; i++) {
//            if (!isIgnoreStr(strArray[i])) {
//                questions.add(strArray[i]);
//            }
//        }
//
//        // 出題文字列を並び替える
//        String[] _questions = questions.toArray(new String[0]);
//
//        if (MySharedPref.readBoolean(MySharedPref.StudyMode4OptionKey)) {
//            // ランダムに並び替える
//            // リストの並びをシャッフルします。
//            // 配列はシャッフルできないので一旦リストに変換する
//            List<String> list = Arrays.asList(_questions);
//            Collections.shuffle(list);
//            _questions = list.toArray(new String[0]);
//        } else {
//            // アルファベット順に並び替える
//            Arrays.sort(_questions, new Comparator<String>() {
//                public int compare(String str1, String str2) {
//                    return str1.compareTo(str2);
//                }
//            });
//        }
//
//        int i=0;
//        for (String str : _questions) {
//            UButtonText button = new UButtonText(this, UButtonType.BGColor, i, 0, str,
//                    0, 0, UDpi.toPixel(QBUTTON_W), UDpi.toPixel(QBUTTON_H), UDpi.toPixel(FONT_SIZE_L), TEXT_COLOR, BUTTON_COLOR);
//            mQuestionButtons.add(button);
//            i++;
//        }
//
//        // 出現アニメーション
//        startAppearance(ANIME_FRAME);
    }

    /**
     * Methods
     */
    /**
     * 出現時の拡大処理
     */
    private func startAppearance(frame : Int) {
//        Size _size = new Size(size.width, size.height);
//        setSize(0, 0);
//        startMovingSize(_size.width, _size.height, frame);
//        mState = State.Appearance;
    }

    /**
     * 消えるときの縮小処理
     * @param frame
     */
    private func startDisappearange( frame : Int) {
//        startMovingSize(0, 0, frame);
//        mState = State.Disappearance;
    }

    /**
     * 正解を表示する
     * 強制的に表示したのでNG判定
     */
    public func showCorrect() {
//        mState = State.ShowAnswer;
//        isMistaken = true;
//        inputPos = mWord.length();
//        for (UButtonText button : mQuestionButtons) {
//            button.setEnabled(false);
//        }
    }

    /**
     * 自動で実行される何かしらの処理
     * @return
     */
    public override func doAction() -> DoActionRet{
//        switch (mState) {
//            case Appearance:
//            case Disappearance:
//                if (autoMoving()) {
//                    return DoActionRet.Redraw;
//                }
//                break;
//            case None:
//                for (UButtonText button : mQuestionButtons) {
//                    if (button.doAction() != DoActionRet.None) {
//                        return DoActionRet.Redraw;
//                    }
//                }
//                break;
//        }
        return .None
    }

    /**
     * 自動移動完了
     */
    public override func endMoving() {
//        if (mState == State.Disappearance) {
//            // 親に非表示完了を通知する
//            mRequest = RequestToParent.End;
//        }
//        else {
//            mState = State.None;
//        }
    }

    /**
     * 指定の1文字が、ユーザーの入力が必要でないかどうかを判定する
     * @param str
     * @return
     */
    private func isIgnoreStr( str : String ) -> Bool{
//        if (str.matches("[0-9a-zA-Z]+")) {
//            return false;
//        }
        return true
    }


    /**
     * Drawable methods
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
//        PointF _pos = new PointF(pos.x, pos.y);
//        if (offset != null) {
//            _pos.x += offset.x;
//            _pos.y += offset.y;
//        }
//
//        // BG
//        int color = 0;
//        if (mState == State.ShowAnswer) {
//            // 解答表示時
//            if (isMistaken) {
//                color = UColor.LightRed;
//            } else {
//                color = UColor.LightGreen;
//            }
//        } else {
//            color = Color.WHITE;
//        }
//
//        if (isMovingSize) {
//            // Open/Close animation
//            float x = _pos.x + basePos.x - size.width / 2;
//            float y = _pos.y + basePos.y - size.height / 2;
//
//            UDraw.drawRoundRectFill(canvas, paint,
//                    new RectF(x, y, x + size.width, y + size.height),
//                    UDpi.toPixel(3), color, UDpi.toPixel(2), FRAME_COLOR);
//        } else {
//            UDraw.drawRoundRectFill(canvas, paint,
//                    new RectF(_pos.x, _pos.y,
//                            _pos.x + size.width, _pos.y + size.height),
//                    UDpi.toPixel(3), color, UDpi.toPixel(2), FRAME_COLOR);
//        }
//
//        // 正解中はマルバツを表示
//        PointF _pos2 = new PointF(_pos.x + size.width / 2, _pos.y + size.height / 2);
//
//        // Text
//        if (mState == State.None || mState == State.ShowAnswer) {
//            float x, y = _pos.y + UDpi.toPixel(MARGIN_V);
//            // 出題単語(日本語)
//            Size _size = UDraw.drawText(canvas, mCard.getWordB(), UAlignment.CenterX, UDpi.toPixel(FONT_SIZE),
//                    _pos2.x, y, TEXT_COLOR);
//            y += _size.height + UDpi.toPixel(MARGIN_V);
//
//            // 正解文字列
//            y = drawInputTexts(canvas, paint, _pos.x, y);
//
//            // 正解入力用のランダム文字列
//            drawQuestionTexts(canvas, paint, _pos, y);
//        }
//
//        if (mState == State.ShowAnswer) {
//            if (isMistaken) {
//                UDraw.drawCross(canvas, paint, new PointF(_pos2.x, _pos2.y),
//                        UDpi.toPixel(23), UDpi.toPixel(7), UColor.Red);
//            } else {
//                UDraw.drawCircle(canvas, paint, new PointF(_pos2.x, _pos2.y),
//                        UDpi.toPixel(23), UDpi.toPixel(7), UColor.Green);
//            }
//        }
    }

    /**
     * 正解文字列を１文字づつ表示する
     *
     * @param x   描画先頭座標x
     * @param y   描画先頭座標y
     */
    private func drawInputTexts( x : CGFloat, y : CGFloat) -> CGFloat{

//        float _x;
//        int width;
//        // 一行に表示できる文字数
//        int lineTexts = (size.width - UDpi.toPixel(MARGIN_H) * 2) / UDpi.toPixel(ONE_TEXT_WIDTH);
//        int lineTextCnt = 0;
//
//        if (lineTexts < mCorrectWords.size()) {
//            // １行に収まりきらない場合
//            width = size.width - UDpi.toPixel(MARGIN_H) * 2;
//        } else {
//            width = mCorrectWords.size() * UDpi.toPixel(ONE_TEXT_WIDTH);
//        }
//
//        _x = (size.width - width) / 2 + x;
//        float topX = _x;
//        String text;
//
//        int textW = UDpi.toPixel(ONE_TEXT_WIDTH);
//
//        for (int i = 0; i < mCorrectWords.size(); i++) {
//            text = mCorrectWords.get(i);
//            if (isIgnoreStr(text)) {
//
//            } else if(text.equals("\n")) {
//                // 改行
//                _x = topX;
//                y += textW;
//                lineTextCnt = 0;
//                continue;
//            } else if (i >= inputPos ) {
//                // 未入力文字
//                text = "_";
//            }
//
//            int bgColor = 0;
//            if (!mCorrectFlags.get(i)) {
//                bgColor = UColor.LightRed;
//            } else if (i == inputPos) {
//                bgColor = UColor.LightGreen;
//            }
//
//            UDraw.drawTextOneLine(canvas, paint, text, UAlignment.None, textW,
//                    _x, y, TEXT_COLOR, bgColor, UDpi.toPixel(7));
//
//            _x += textW;
//            lineTextCnt++;
//            if (lineTextCnt > lineTexts) {
//                _x = topX;
//                y += textW;
//                lineTextCnt = 0;
//            }
//        }
//        return y;
        return 0
    }

    /**
     * 正解タッチ用のTextViewを表示する
     * @param canvas
     * @param paint
     * @param offset
     * @param y
     * @return
     */
    private func drawQuestionTexts( offset : CGPoint, y : CGFloat) -> CGFloat {

//        int lineButtons = (size.width - UDpi.toPixel(TEXT_MARGIN_H2)) / UDpi.toPixel(QBUTTON_W + TEXT_MARGIN_H2);
//        int width;
//        if (lineButtons > mWord.length()) {
//            lineButtons = mWord.length();
//        }
//        width = lineButtons * UDpi.toPixel(QBUTTON_W + TEXT_MARGIN_H2) - UDpi.toPixel(TEXT_MARGIN_H2);
//        float topX = (size.width - width) / 2;
//        float x = topX;
//
//        for (UButtonText button : mQuestionButtons) {
//            button.setPos(x, y);
//            button.draw(canvas, paint, offset);
//            x += UDpi.toPixel(QBUTTON_H + TEXT_MARGIN_H2);
//
//            // 改行判定
//            if (x + button.getWidth() + UDpi.toPixel(TEXT_MARGIN_H2) > size.width) {
//                x = topX;
//                y += button.getHeight() + UDpi.toPixel(TEXT_MARGIN_V);
//            }
//        }
//        return y;
        return 0
    }

    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch) -> Bool{
        return self.touchEvent(vt: vt, offset: nil)
    }

    public func touchEvent( vt : ViewTouch, parentPos : CGPoint) -> Bool{
        var done = false

//        // アニメーションや移動中はタッチ受付しない
//        if (isMovingSize) {
//            return false;
//        }
//
//        // 問題ボタン
//        for (UButton button : mQuestionButtons) {
//            if (button.touchUpEvent(vt)) {
//                done = true;
//            }
//        }
//        for (UButton button : mQuestionButtons) {
//            if (button.touchEvent(vt, parentPos)) {
//                return true;
//            }
//        }
//
//        switch(vt.type) {
//            case Touch:        // タッチ開始
//                break;
//            case Click: {
//                if (mState == State.ShowAnswer) {
//                    startDisappearange(ANIME_FRAME);
//                    done = true;
//                }
//            }
//            break;
//        }

        return done
    }

    public override func endAnimation() {
        mRequest = RequestToParent.End
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        // 判定を行う
//        UButtonText button = getButtonById(id);
//        String text1 = mCorrectWords.get(inputPos);
//        String text2 = button.getmText();
//        if (text1.equals(text2)) {
//            // 正解のボタンをタップ
//            // すでに正解用として使用したので使えなくする
//            button.setEnabled(false);
//            inputPos++;
//            // スペースや改行をスキップする
//            for(int i = inputPos; i < mCorrectWords.size(); i++) {
//                if (isIgnoreStr(mCorrectWords.get(i))) {
//                    inputPos++;
//                } else {
//                    break;
//                }
//            }
//
//            if (inputPos >= mWord.length()) {
//                // 終了
//                mState = State.ShowAnswer;
//            }
//            // 色を元に戻す
//            for (UButtonText _button : mQuestionButtons) {
//                if (_button.getEnabled() == true && _button.getColor() == NG_BUTTON_COLOR) {
//                    _button.setColor(BUTTON_COLOR);
//                }
//            }
//            return true;
//        } else {
//            // 不正解のボタンをタップ
//            isMistaken = true;
//            button.setColor(NG_BUTTON_COLOR);
//            mCorrectFlags.set(inputPos, false);
//            return true;
//        }
        return false
    }
}

