//
//  EditCardViewController.swift
//  TangoBook
//    単語カードの情報を入力するViewController
//    
//  Created by Shusuke Unno on 2017/08/02.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class EditCardViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var textWordA: UITextField!
    @IBOutlet weak var textWordB: UITextField!
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var colorScrollView: UIScrollView!
    
    public var mCard : TangoCard? = nil
    public var mMode : EditCardDialogMode = .Create
    
    public var delegate : EditCardDialogCallbacks? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if mCard != nil {
            textWordA.text = mCard!.wordA ?? ""
            textWordB.text = mCard!.wordB ?? ""
            colorView.backgroundColor = mCard!.color.toColor()
        }
        
        textWordA.delegate = self
        textWordB.delegate = self
        
        // 色選択用のボタンを追加
        let buttons = createButtons(count: 10, width :50, height: 50)
        
        // 色を設定
        let colors : [UIColor] = [UIColor.white, UIColor.black, UIColor.red, UIColor.blue, UIColor.green, UIColor.brown, UIColor.cyan, UIColor.yellow, UIColor.purple, UIColor.darkGray]
        
        var i : Int = 0
        for button in buttons {
            button.backgroundColor = colors[i]
            button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
            colorScrollView.addSubview(button)
            i += 1
        }
        let width = buttons.last!.frame.origin.x + buttons.last!.frame.size.width
        
        colorScrollView.contentSize.width = width
        
        // 最初のTextFieldにフォーカスを合わせる
        textWordA.becomeFirstResponder()
    }
    
    // カラーボタンを押した時の処理
    // カードの色を設定する
    func buttonTapped(_ button : UIButton) {
        colorView.backgroundColor = button.backgroundColor
    }
    
    // カラーピッカーの色選択用のボタンを作成する
    private func createButtons(count : Int, width: CGFloat, height : CGFloat) -> [UIButton] {
        var buttons : [UIButton] = []
        
        var x : CGFloat = 0
        let y : CGFloat = 0
        
        for i in 0..<count {
            let button = UIViewUtil.createSimpleButton(
                x:x, y:y, width:width, height: UIViewUtil.BUTTON_H, title: "", tagId: i)
            x += width
            buttons.append(button)
        }
        return buttons
    }

    // OKボタンをクリックした
    // 設定を保存してモーダルを閉じる
    @IBAction func okButtonClicked(_ sender: Any)
    {
        dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            // 閉じた時に行いたい処理
            presentingViewController?.viewWillAppear(true)
            
            if self.self.delegate != nil {
                self.delegate?.submitEditCard(mode: self.mMode,
                                              wordA: self.textWordA.text,
                                              wordB: self.textWordB.text,
                                              color: self.colorView.backgroundColor)
            }
        })
    }
    
    // Cancel
    // 設定を保存せずにモーダルを閉じる
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK : UITextFieldDelegate
    
    // テキストフィールドでReturnが押された時に呼ばれるメソッド
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        return true
    }
}
