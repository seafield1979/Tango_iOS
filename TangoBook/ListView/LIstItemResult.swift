//
//  LIstItemResult.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

///**
// * Created by shutaro on 2016/12/11.
// *
// * 学習結果ListView(ListViewResult)のアイテム
// */
//
//public class ListItemResult extends UListItem implements UButtonCallbacks {
//    /**
//     * Enums
//     */
//    public enum ListItemResultType {
//        Title,
//        OK,
//        NG
//    }
//
//    /**
//     * Constants
//     */
//    public static final String TAG = "ListItemOption";
//
//    private static final int MAX_TEXT = 20;
//
//    private static final int ButtonIdStar = 100100;
//
//    // 座標系
//    private static final int TITLE_H = 27;
//    private static final int CARD_H = 40;
//    private static final int TEXT_SIZE = 17;
//    private static final int STAR_ICON_W = 34;
//    private static final int FRAME_WIDTH = 1;
//
//    // color
//    private static final int FRAME_COLOR = Color.BLACK;
//
//    /**
//     * Member variables
//     */
//    private ListItemResultType mType;
//    private String mText, mText2;
//    private boolean isOK;
//    private TangoCard mCard;
//    private int mTextColor;
//    private UButtonImage mStarButton;
//    private int mLearnedTextW;        // "覚えた"のテキストの幅
//
//    /**
//     * Get/Set
//     */
//    public ListItemResultType getType() {
//        return mType;
//    }
//
//    public TangoCard getCard() {
//        return mCard;
//    }
//
//    /**
//     * Constructor
//     */
//    public ListItemResult(UListItemCallbacks listItemCallbacks,
//                          ListItemResultType type, boolean isTouchable, TangoCard card,
//                          float x, int width, int textColor, int color) {
//        super(listItemCallbacks, isTouchable, x, width, 0, color, UDpi.toPixel(FRAME_WIDTH), FRAME_COLOR);
//        mType = type;
//        mTextColor = textColor;
//        mCard = card;
//    }
//
//    // ListItemResultType.Title のインスタンスを生成する
//    public static ListItemResult createTitle(boolean isOK, int width,
//                                             int textColor,int bgColor)
//    {
//        String text = isOK ? "OK" : "NG";
//        ListItemResult instance = new ListItemResult(null, ListItemResultType.Title,
//                false, null, 0, width, textColor, bgColor);
//        instance.isOK = isOK;
//        instance.mText = text;
//        instance.size.height = UDpi.toPixel(TITLE_H);
//        return instance;
//    }
//
//    // ListItemResultType.OKのインスタンスを生成する
//    // @param star 覚えたアイコン(Star)を表示するかどうか
//    public static ListItemResult createOK(TangoCard card, StudyMode studyMode,
//                                          boolean isEnglish, boolean  star,
//                                          int width, int textColor,int bgColor) {
//        ListItemResult instance = new ListItemResult(null,
//                ListItemResultType.OK, true, card,
//                0, width, textColor, bgColor);
//
//        instance.mText = convString(isEnglish ? card.getWordA() : card.getWordB());
//        instance.mText2 = convString(isEnglish ? card.getWordB() : card.getWordA());
//        instance.size.height = UDpi.toPixel(CARD_H);
//        // Starボタンを追加(On/Offあり)
//        if (star) {
//            Bitmap image = UResourceManager.getBitmapWithColor(R.drawable.favorites, UColor
//                    .OrangeRed);
//            Bitmap image2 = UResourceManager.getBitmapWithColor(R.drawable.favorites2, UColor
//                    .OrangeRed);
//            instance.mStarButton = UButtonImage.createButton(instance, ButtonIdStar, 100,
//                    instance.size.width - UDpi.toPixel(67), (instance.size.height - UDpi.toPixel(STAR_ICON_W)) / 2,
//                    UDpi.toPixel(STAR_ICON_W), UDpi.toPixel(STAR_ICON_W), image, null);
//            instance.mStarButton.addState(image2);
//            instance.mStarButton.setState(card.getStar() ? 1 : 0);
////            instance.mStarButton.scaleRect(1.3f, 1.0f);
//        }
//        return instance;
//    }
//
//    // ListItemResultType.NGのインスタンスを生成する
//    public static ListItemResult createNG(TangoCard card, StudyMode studyMode, boolean isEnglish,
//                                          int width, int textColor,int bgColor)
//    {
//        ListItemResult instance = new ListItemResult(null,
//                ListItemResultType.NG, true, card,
//                0, width, textColor, bgColor);
//        instance.mText = convString(isEnglish ? card.getWordA() : card.getWordB());
//        instance.mText2 = convString(isEnglish ? card.getWordB() : card.getWordA());
//        instance.size.height = UDpi.toPixel(CARD_H);
//        return instance;
//    }
//
//    /**
//     * Methods
//     */
//
//    public DoActionRet doAction() {
//        if (mStarButton != null) {
//            return mStarButton.doAction();
//        }
//        return DoActionRet.None;
//    }
//
//    /**
//     * 描画処理
//     * @param canvas
//     * @param paint
//     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
//     */
//    public void draw(Canvas canvas, Paint paint, PointF offset) {
//        PointF _pos = new PointF(pos.x, pos.y);
//        if (offset != null) {
//            _pos.x += offset.x;
//            _pos.y += offset.y;
//        }
//
//        super.draw(canvas, paint, _pos);
//
//        int fontSize = UDpi.toPixel(TEXT_SIZE);
//
//        switch(mType) {
//            case Title:
//                UDraw.drawTextOneLine(canvas, paint, mText, UAlignment.Center, fontSize,
//                        _pos.x + size.width / 2, _pos.y + size.height / 2, mTextColor);
//                // 覚えた
//                if (isOK) {
//                    if (mLearnedTextW == 0) {
//                        mLearnedTextW = UDraw.getTextSize(canvas.getWidth(),
//                                UResourceManager.getStringById(R.string.learned), fontSize).width;
//                    }
//                    UDraw.drawTextOneLine(canvas, paint,
//                            UResourceManager.getStringById(R.string.learned),
//                            UAlignment.Center, fontSize,
//                            _pos.x + size.width - mLearnedTextW / 2 - UDpi.toPixel(23), _pos.y + size.height / 2,
//                            mTextColor);
//                }
//                break;
//            case OK: {
//                String text = isTouching ? mText2 : mText;
//                UDraw.drawTextOneLine(canvas, paint, text, UAlignment.Center, fontSize,
//                        _pos.x + size.width / 2, _pos.y + size.height / 2, mTextColor);
//            }
//                break;
//            case NG: {
//                String text = isTouching ? mText2 : mText;
//                UDraw.drawTextOneLine(canvas, paint, text, UAlignment.Center, fontSize,
//                        _pos.x + size.width / 2, _pos.y + size.height / 2, mTextColor);
//            }
//                break;
//        }
//
//        if (mStarButton != null) {
//            mStarButton.draw(canvas, paint, _pos);
//        }
//    }
//
//    /**
//     *
//     * @param vt
//     * @return
//     */
//    public boolean touchEvent(ViewTouch vt, PointF offset) {
//        // Starボタンのクリック処理
//        if (mStarButton != null) {
//            PointF offset2 = new PointF(pos.x + offset.x, pos.y + offset.y);
//            if (mStarButton.touchEvent(vt, offset2)) {
//                return true;
//            }
//        }
//
//        boolean isDraw = false;
//        switch(vt.type) {
//            case Touch:
//                if (isTouchable) {
//                    if (rect.contains((int) (vt.touchX() - offset.x),
//                            (int) (vt.touchY() - offset.y))) {
//                        isTouching = true;
//                        isDraw = true;
//                    }
//                }
//                break;
//        }
//
//        return isDraw;
//    }
//
//    /**
//     * 高さを返す
//     */
//    public int getHeight() {
//        return size.height;
//    }
//
//    /**
//     * UButtonCallbacks
//     */
//    public boolean UButtonClicked(int id, boolean pressedOn) {
//        if (id == ButtonIdStar) {
//            boolean star = RealmManager.getCardDao().toggleStar(mCard);
//
//            // 表示アイコンを更新
//            mStarButton.setState(star ? 1 : 0);
//            return true;
//        }
//        return false;
//    }
//
//    /**
//     * 表示するためのテキストに変換（改行なし、最大文字数制限）
//     * @param text
//     * @return
//     */
//    private static String convString(String text) {
//        // 改行を除去
//        String _text = text.replace("\n", " ");
//
//        // 最大文字数制限
//        if (_text.length() > MAX_TEXT) {
//            return _text.substring(0, MAX_TEXT - 1);
//        }
//        return _text;
//    }
//}
//
