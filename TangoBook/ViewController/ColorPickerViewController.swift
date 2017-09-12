//
//  ColorPickerViewController.swift
//  TangoBook
//      デフォルトの色を選択するViewControllerの処理
//
//  Created by Shusuke Unno on 2017/08/30.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * モード
 * デフォルトの単語帳の色とデフォルトのカードの色の２つを設定するのに使用されるのでその判別用
 */
public enum ColorPickerMode : Int, EnumEnumerable{
    case Book
    case Card
}

/**
 *  DialogFragmentのコールバック
 */
protocol OptionColorDialogCallbacks : class {
    func submitOptionColor( color: UIColor, mode : ColorPickerMode )
    func cancelOptionColor()
}


class ColorPickerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var colorScrollView: UIScrollView!
    
    public weak var delegate : OptionColorDialogCallbacks? = nil
    public var mMode : ColorPickerMode = .Book
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // すでに設定済みの色をViewに反映する
        var keyName : String
        var labelTextName : String
        
        if mMode == .Book {
            labelTextName = "default_book_color_message"
            keyName = MySharedPref.DefaultColorBookKey
        } else {
            labelTextName = "default_card_color_message"
            keyName = MySharedPref.DefaultColorCardKey
        }
        
        // title label
        //titleLabel.numberOfLines = 0    //折り返し
        titleLabel.sizeToFit()          //サイズを文字列に合わせる
        titleLabel.lineBreakMode = NSLineBreakMode.byCharWrapping //文字で改行
        
        titleLabel.text = UResourceManager.getStringByName( labelTextName )

        let color = MySharedPref.readInt( keyName )
        if color != 0 {
            currentColorView.backgroundColor = color.toColor()
        }

        // 色選択用のボタンを追加
        let colors : [UIColor] = [ UIColor.black, UIColor.red, UIColor.blue, UIColor.green, UIColor.brown, UIColor.cyan, UIColor.yellow, UIColor.purple, UIColor.darkGray]

        let buttons = createButtons(count: colors.count, width :50, height: 50)
        
        var i : Int = 0
        for button in buttons {
            button.backgroundColor = colors[i]
            button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
            colorScrollView.addSubview(button)
            i += 1
        }
        let width = buttons.last!.frame.origin.x + buttons.last!.frame.size.width
        
        colorScrollView.contentSize.width = width

    }

    @IBAction func okButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            // 閉じた時に行いたい処理
            presentingViewController?.viewWillAppear(true)
            
            if self.delegate != nil {
                self.delegate?.submitOptionColor( color: self.currentColorView.backgroundColor!, mode : self.mMode)
            }
        })

    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.cancelOptionColor()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // カラーボタンを押した時の処理
    // カードの色を設定する
    func buttonTapped(_ button : UIButton) {
        currentColorView.backgroundColor = button.backgroundColor
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

}
