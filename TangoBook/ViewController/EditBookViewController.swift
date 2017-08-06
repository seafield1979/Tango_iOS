//
//  EditBookViewController.swift
//  TangoBook
//    単語帳の情報を入力するViewController
//
//  Created by Shusuke Unno on 2017/08/02.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class EditBookViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var colorView : UIView!
   
    @IBOutlet weak var colorScrollView : UIScrollView!
    
    public var mBook : TangoBook? = nil
    public var mMode : EditBookDialogMode = .Create

    public var delegate : EditBookDialogCallbacks? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mBook != nil {
            nameTextField.text = mBook!.name ?? ""
            commentTextField.text = mBook!.comment ?? ""
            colorView.backgroundColor = mBook!.color.toColor()
        }
        
        nameTextField.delegate = self
        commentTextField.delegate = self
        
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
        nameTextField.becomeFirstResponder()
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
    
    // MARK : UITextFieldDelegate
    
    // テキストフィールドでReturnが押された時に呼ばれるメソッド
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        return true
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
                self.delegate?.submitEditBook(mode: self.mMode,
                                              name: self.nameTextField.text,
                                              comment: self.commentTextField.text,
                                              color: self.colorView.backgroundColor)
            }
        })
    }
    
    // Cancel
    // 設定を保存せずにモーダルを閉じる
    @IBAction func cancelButtonClicked(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
}
