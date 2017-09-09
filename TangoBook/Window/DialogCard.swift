//
//  DialogCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * Created by shutaro on 2016/12/22.
 *
 * カードの情報を表示するダイアログ
 * カード編集ページでカードアイコンをクリックした際に表示される
 */

public class DialogCard : UDialogWindow {
    // MARK: Constants
    public static let TAG = "DialogCard"
    private let OKButtonId = 10005000
    
    // MARK: Properties
    private var mCard : TangoCard?
    
    // MARK: Initializer
    public init(topScene: TopScene,
                card : TangoCard,
                isAnimation : Bool)
    {
        super.init( topScene : topScene, type : .Modal,
                    buttonCallbacks : nil, dialogCallbacks : nil,
                    dir : .Horizontal, posType : .Center,
                    isAnimation : isAnimation,
                    x : 0, y : 0,
                    screenW : topScene.size.width, screenH : topScene.size.height,
                    textColor : .black,
                    dialogColor : .white)
        
        self.buttonCallbacks = self
        self.frameColor = .black
        mCard = card
        
        // Text views
        // WordA
        if (card.wordA != nil && card.wordA!.characters.count > 0) {
            _ = addTextView(text : UResourceManager.getStringByName("word_a"),
                        alignment : UAlignment.CenterX, isFit : false,
                        isDrawBG : false, fontSize : UDraw.getFontSize(FontSize.M),
                        textColor : .black, bgColor : nil)
            
            _ = addTextView(text : card.wordA!, alignment : UAlignment.CenterX,
                        isFit : false, isDrawBG : true, fontSize : UDraw.getFontSize(FontSize.M),
                        textColor : .black, bgColor : .lightGray)
        }
        
        // WordB
        if card.wordB != nil && card.wordB!.characters.count > 0 {
            _ = addTextView(text : UResourceManager.getStringByName("word_b"),
                        alignment : UAlignment.CenterX, isFit : false,
                        isDrawBG : false, fontSize : UDraw.getFontSize(FontSize.M),
                        textColor : .black, bgColor : nil)
            
            _ = addTextView(text : card.wordB!, alignment : UAlignment.CenterX,
                        isFit : false, isDrawBG : true, fontSize : UDraw.getFontSize(FontSize.M),
                        textColor : .black, bgColor : .lightGray)
        }
        
        // Comment
//        if card.getComment() != nil && card.getComment().length() > 0) {
//            addTextView(UResourceManager.getStringById(R.string.comment),
//                        UAlignment.CenterX, true, false,
//                        UDraw.getFontSize(FontSize.M), Color.BLACK, 0);
//            addTextView(card.getComment(), UAlignment.CenterX, true, true,
//                        UDraw.getFontSize(FontSize.M), Color.BLACK, Color.LTGRAY);
//        }
        
        // Cancel
        addCloseButton( text: UResourceManager.getStringByName("close") )
        
        setFrameColor( .darkGray )
    }
    
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }
        
        switch(id) {
        case OKButtonId:
            closeDialog()
            return true
        default:
            break
        }
        return false
    }
}
