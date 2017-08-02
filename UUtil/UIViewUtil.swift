//
//  UIViewUtil.swift
//  UIViewTest
//
//  UIView関連の便利関数
//
//  Created by Shusuke Unno on 2017/07/22.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import UIKit

public enum UButtonOptions : Int {
    case Title              // タイトル
    case TappedTitle        // タップされた時のタイトル
    case TextColor          // テキストの色
    case BGColor            // ボタンの背景色
    case TappedBGColor      // タップ時の背景色
    case CornerRadius       // 角丸の半径
    case FrameWidth         // 枠の幅
    
}
/**
 UIView関連の便利クラス
 各種UIViewを簡単に生成できるメソッドを用意
 */
public class UIViewUtil {
    static let BUTTON_H : CGFloat = 50.0
    
    /**
     シンプルなボタンを作成
     - parameter pos: ボタンの座標
     - parameter tagId: ボタンのId(押された時の判定用に使用する)
     - returns: 生成したボタン
     */
    public static func createSimpleButton(x: CGFloat, y: CGFloat,
                                          width: CGFloat, height: CGFloat,
                                          title: String, tagId : Int )
        -> UIButton {
            let button = UIButton(frame: CGRect(x:x, y:y, width:width, height: height))
            
            button.setTitle(title, for: UIControlState())
            button.setTitleColor(UIColor.black, for: UIControlState())
            button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
            button.backgroundColor = UIColor.init(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
            button.showsTouchWhenHighlighted = true
            button.tag = tagId
            
            return button
    }
    /**
     カスタマイズされたボタンを作成
     - parameter pos: ボタンの座標
     - parameter tagId: ボタンのId(押された時の判定用に使用する)
     - returns: 生成したボタン
     */
    public static func createButton(_ pos : CGPoint, tagId : Int,
                                    options : Dictionary<UButtonOptions, AnyObject>) -> UIButton {
        // ボタンを生成
        let button = UIButton()
        
        //表示されるテキスト
        if options[.Title] != nil {
            button.setTitle(options[.Title] as? String, for: UIControlState())
        }
        
        //テキストの色
        if options[.TextColor] != nil {
            button.setTitleColor(options[.TextColor] as? UIColor, for: UIControlState())
        }
        
        //タップした状態のテキスト
        if options[.TappedTitle] != nil {
            button.setTitle(options[.TappedTitle] as? String, for: .highlighted)
        }
        
        //タップした状態の色
        if options[.TappedBGColor] != nil {
            button.setTitleColor(options[.TappedBGColor] as? UIColor, for: .highlighted)
        }
        
        //サイズ、座標
        let width = UIScreen.main.bounds.size.width - pos.x * 2
        button.frame = CGRect(x: pos.x, y: pos.y,
                              width: width,
                              height: 50)
        
        //タグ番号
        button.tag = tagId
        
        //背景色(通常時、ハイライト時、選択時)
        //        button.setBackgroundImage(createImageFromUIColor(UIColor.white), for: UIControlState())
        //        button.setBackgroundImage(createImageFromUIColor(UIColor.gray), for: UIControlState.highlighted)
        //        button.setBackgroundImage(createImageFromUIColor(UIColor.orange), for: UIControlState.selected)
        
        //角丸
        if options[.CornerRadius] != nil {
            button.layer.cornerRadius = options[.CornerRadius] as! CGFloat
        }
        //ボーダー幅
        if options[.FrameWidth] != nil {
            button.layer.borderWidth = options[.FrameWidth] as! CGFloat
        }
        
        return button
    }
    
    /**
     ボタンをまとめて作成する
     - parameter y: 先頭のボタンのy座標
     - parameter count: 作成するボタンの数
     - parameter lineCount: 一行に配置するボタンの数
     - parameter text:ボタンのテキスト
     - parameter tagId: ボタンのtagId(２つ目以降は+1される)
     - returns: 作成したボタン
     */
    public static func createButtons(_ y : CGFloat, count : Int,
                                     lineCount: Int, text: String, tagId: Int)
        -> [UIButton]
    {
        // ボタンのテキストを生成
        var texts : [String] = []
        for i in 0..<count {
            texts.append(text + (i+1).description)
        }
        
        let buttons = self.createButtons(y, count: count, lineCount: lineCount, texts: texts, tagId: tagId)
        return buttons
    }
    
    public static func createButtons(_ y : CGFloat, count : Int,
                                     lineCount: Int, texts: [String], tagId: Int)
        -> [UIButton]
    {
        var buttons : [UIButton] = []
        
        var x : CGFloat = 0
        var y : CGFloat = y
        let width : CGFloat = UIScreen.main.bounds.size.width / CGFloat(lineCount)
        var _text : String? = nil
        
        for i in 0...count-1 {
            if i != 0 && i % lineCount == 0 {
                x = 0.0
                y += UIViewUtil.BUTTON_H
            }
            
            if i < texts.count {
                _text = texts[i]
            } else {
                _text = "test" + (i+1).description
            }
            
            let button = createSimpleButton(
                x:x, y:y, width:width, height: UIViewUtil.BUTTON_H, title: _text!, tagId: tagId + i)
            x += width
            buttons.append(button)
        }
        return buttons
    }
    
    /**
     ボタンとそれを囲むScrollViewを作成する
     */
    public static func createButtonsWithScrollBar(
        parentView: UIViewController,
        y : CGFloat, height: CGFloat, count : Int,
        lineCount: Int, text: String, tagId: Int,
        selector: Selector ) -> UIScrollView?
    {
        // ボタンのテキストを生成
        var texts : [String] = []
        for i in 0..<count {
            texts.append(text + (i+1).description)
        }
        
        let scrollView = self.createButtonsWithScrollBar2(
            parentView: parentView, y: y, height: height,
            count: count, lineCount: lineCount, texts: texts, tagId: tagId, selector: selector)
        
        return scrollView
    }
    
    public static func createButtonsWithScrollBar2(
        parentView: UIViewController,
        y : CGFloat, height: CGFloat, count : Int,
        lineCount: Int, texts: [String], tagId: Int,
        selector: Selector ) -> UIScrollView?
    {
        let screenW = UIScreen.main.bounds.size.width
        // UIScrollViewを作成
        let scrollView = UIScrollView(
            frame: CGRect( x: 0,y: y,
                           width: screenW,
                           height: height))
        
        // ボタンを作成
        let buttons = createButtons(y, count : count,
                                    lineCount: lineCount,
                                    texts: texts, tagId: tagId)
        if buttons.count == 0 {
            return nil
        }
        let contentW = screenW
        let contentH = buttons.last!.frame.origin.y - y + buttons.last!.frame.size.height
        
        scrollView.contentSize = CGSize(width: contentW, height: contentH)
        
        scrollView.backgroundColor = UIColor.lightGray
        
        // ステータスバータップでトップにスクロールする機能をOFFにする
        scrollView.scrollsToTop = false;
        
        for button in buttons {
            button.addTarget(parentView, action: selector, for: .touchUpInside)
            scrollView.addSubview(button)
        }
        
        return scrollView
    }
    
    /**
     UITextViewを生成する
     - parameter frame: 生成するUITextViewの座標、サイズ
     - returns: 生成したUITextViewオブジェクト
     */
    public static func createTextView(frame: CGRect) -> UITextView {
        let textView = UITextView(frame: frame)
        // textView.delegate = self
        
        // いろいろ設定
        // 背景色
        textView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        // 編集可能(falseだとリードオンリーになる)
        textView.isEditable = true
        
        // テキストの色
        textView.textColor = UIColor.blue
        
        // テキストの水平揃え
        // left,center,right
        textView.textAlignment = NSTextAlignment.left
        
        return textView
    }
}
