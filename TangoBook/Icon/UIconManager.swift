//
//  UIcon.swift
//  TangoBook
//
//  IconWindowに表示するアイコンを管理するクラス
//  Rect判定の高速化のためにいくつかのアイコンをまとめたブロックのRectを作成し、個々のアイコンのRect判定前に
//  ブロックのRectと判定を行う
//
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class UIconManager : UIconCallbacks {
     /**
     * Enums
     */
    public enum SortMode : EnumEnumerable {
        case None
        case TitleAsc        // タイトル文字昇順(カードはWordA,単語帳はName)
        case TitleDesc       // タイトル文字降順
        case CreateDateAsc   // 更新日時 昇順
        case CreateDateDesc  // 更新日時 降順
    }

    /**
    * Consts
    */
    public static let TAG = "UIconManager"

    /**
    * Member Variables
    */
    private var mParentWindow : UIconWindow? = nil
    private var mIconCallbacks : UIconCallbacks? = nil
    private var icons : List<UIcon> = List()
    private var mBlockManager : UIconsBlockManager? = nil

    private var selectedIcon : UIcon? = nil
    private var dropedIcon : UIcon? = nil       // アイコンをドロップ中のアイコン
    private var mTrashIcon : UIcon? = nil

    /**
    * Get/Set
    */
    public func getIcons() -> List<UIcon> {
        return icons
    }

    public func setIcons( icons : List<UIcon>) {
        self.icons = icons
    }

    public func getParentWindow() -> UIconWindow? {
        return mParentWindow
    }

    public func getSelectedIcon() -> UIcon? {
        return selectedIcon
    }

    public func setSelectedIcon( _ selectedIcon : UIcon?) {
        if self.selectedIcon != nil {
            self.selectedIcon!.selectedBgNode!.isHidden = true
        }

        if selectedIcon != nil {
            selectedIcon!.selectedBgNode!.isHidden = false
        }
        self.selectedIcon = selectedIcon
    }

    public func getDropedIcon() -> UIcon? {
        return dropedIcon
    }

    public func setDropedIcon( _ dropedIcon : UIcon?) {
        // 全てのアイコンのdropフラグを解除
        UIconWindows.getInstance().clearDroped()

        self.dropedIcon = dropedIcon
        if dropedIcon != nil {
            dropedIcon!.isDroped = true
        }
    }

     public func getTrashIcon() -> UIcon? {
         return mTrashIcon
     }

     /**
     * チェックされたアイコンのリストを取得する
     * @return
     */
    public func getCheckedIcons() -> List<UIcon> {
        let checkedIcons : List<UIcon> = List()

        for icon in icons {
            if icon!.isChecked {
                checkedIcons.append(icon!)
            }
        }
        return checkedIcons
    }

     /**
     * Constructor
     */
     public func getBlockManager() -> UIconsBlockManager? {
         return mBlockManager
     }

    public static func createInstance( parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?) -> UIconManager
    {
         let instance = UIconManager()
         instance.mParentWindow = parentWindow
         instance.mIconCallbacks = iconCallbacks
         instance.icons = List()
         instance.mBlockManager = UIconsBlockManager.createInstance(icons: instance.icons)
         return instance
     }

     /**
     * 指定タイプのアイコンを作成してから追加
     * @param copySrc  コピー元のIcon
     * @param addPos
     * @return
     */
    public func copyIcon( copySrc : UIcon, addPos : AddPos) -> UIcon? {
        var icon : UIcon? = nil

        let itemPos : TangoItemPos = copySrc.getTangoItem()!.getItemPos()!

        switch copySrc.getType() {
            case .Card:
                let _card = TangoCard.copyCard(card: copySrc.getTangoItem() as! TangoCard)
                _card.isNew = true
                TangoCardDao.addOne( card: _card,
                                     parentType: TangoParentType.toEnum(itemPos.parentType),
                                     parentId: itemPos.getParentId(),
                                     addPos: itemPos.getPos())
                // 後で書き換えられるようにコピーを作成
                let card = _card.copy() as! TangoCard
                icon = IconCard(card: card,
                                parentWindow: mParentWindow!,
                                iconCallbacks: self)
            
            case .Book:
                let _book : TangoBook = TangoBook.copyBook(book: copySrc.getTangoItem() as! TangoBook)
                _book.isNew = true
                TangoBookDao.addOne(book: _book, addPos: itemPos.getPos())

                // 後で書き換えられるようにコピーを作成
                let book = _book.copy() as! TangoBook
                icon = IconBook(book: book,
                                parentWindow: mParentWindow!,
                                iconCallbacks: self, x: 0, y: 0)
        default:
            break
        }
        if icon == nil {
            return nil
        }
        // SKノードを追加
        self.mParentWindow!.clientNode.addChild2( icon!.parentNode )

        // リストに追加
//        if addPos != nil {
            switch addPos {
                case .SrcNext:
                    let pos = icons.indexOf(obj: copySrc)
                    if pos != -1 {
                        icons.insert(icon!, atIndex: pos + 1)
                        icon!.setPos(copySrc.getPos())
                    }
                
                case .Top:
                    icons.push(icon!)
                
                case .Tail:
                    let lastIcon : UIcon? = icons.last()

                    icons.append(icon!)

                    // 出現位置は最後のアイコン
                    if lastIcon != nil {
                        icon!.setPos(lastIcon!.getPos())
                    }
                }
//        }

        return icon;
    }

     /**
     * アイコンを追加する
     * @param type
     * @param addPos
     * @return
     */
    public func addNewIcon( type : IconType, parentType : TangoParentType,
                            parentId : Int, addPos : AddPos) -> UIcon?
    {
        var icon : UIcon? = nil
        switch type {
            case .Card:
                let card = TangoCard.createCard()
                TangoCardDao.addOne(card: card, parentType: parentType,
                                    parentId: parentId, addPos: -1)
                
                // あとからプロパティを変更できるようにコピーを設定する
                let cardCopy = card.copy() as! TangoCard
                icon = IconCard(card: cardCopy,
                                parentWindow: mParentWindow!,
                                iconCallbacks: self)
           
            case .Book:
                let book = TangoBook.createBook()
                TangoBookDao.addOne(book: book, addPos: -1)
                
                // あとからプロパティを変更できるようにコピーを設定する
                let bookCopy = book.copy() as! TangoBook
                icon = IconBook(book: bookCopy,
                                parentWindow: mParentWindow!,
                                iconCallbacks: self, x: 0, y: 0)
           
            case .Trash:
                icon = IconTrash(parentWindow: mParentWindow!,
                                 iconCallbacks: self)
               mTrashIcon = icon
           
        }
        if icon == nil {
            return nil
        }

        // リストに追加
        if addPos == AddPos.Top {
            icons.push(icon!)
        } else {
            var lastIcon : UIcon? = nil
            if icons.count > 0 {
                lastIcon = icons.last()
            }
            icons.append(icon!)

            // 出現位置は最後のアイコン
            if lastIcon != nil {
                icon!.setPos(lastIcon!.getPos())
            }
        }

        return icon
    }

    /**
     * TangoItemを元にアイコンを追加する
     * @param item
     * @return
     */
    public func addIcon(_ item : TangoItem, addPos : AddPos) -> UIcon?{
       var icon : UIcon? = nil

        switch item.getItemType() {
            case .Card:
                if item is TangoCard {
                    let card : TangoCard = item as! TangoCard
                    icon = IconCard(card: card,
                                    parentWindow: mParentWindow!,
                                    iconCallbacks: self)
                }
            
            case .Book:
                if item is TangoBook {
                    let book = item as! TangoBook
                    icon = IconBook(book: book,
                                    parentWindow: mParentWindow!,
                                    iconCallbacks: self, x: 0, y: 0)
                }
        default:
            break
        }
        if icon == nil{
            return nil
        }

        if (addPos == AddPos.Top) {
            icons.push(icon!)
        } else {
            icons.append(icon!)
            // 出現位置は最後のアイコン
            let lastIcon = icons.last()
            if lastIcon != nil {
                icon!.setPos(lastIcon!.getPos())
            }
        }
        return icon
    }

     /**
     * すでに作成済みのアイコンを追加
     * ※べつのWindowにアイコンを移動するのに使用する
     * @param icon
     * @return
     */
    public func addIcon(_ icon : UIcon) -> Bool {
        // すでに追加されている場合は追加しない
        if !icons.contains(icon) {
            icons.append(icon)
            return true
        }
        return false
    }

    /**
     * アイコンを削除(データベースからも削除）
     * @param icon
     */
    public func removeIcon(_ icon : UIcon) {
        let item : TangoItem? = icon.getTangoItem()
        if item == nil {
            return
        }

        switch icon.getType() {
            case .Card:
                _ = TangoCardDao.deleteById(item!.getId())
            
            case .Book:
                _ = TangoBookDao.deleteById(item!.getId())
            
        default:
            break
        }
        TangoItemPosDao.deleteItem(icon.getTangoItem()!)
        icons.remove(obj: icon)
    }

    /**
    * UIconのリストからTangoItemのリストを作成する
    * @return
    */
    public func getTangoItems() -> List<TangoItem> {
       let list : List<TangoItem> = List()
        for icon in icons {
            if icon!.getTangoItem() != nil {
                list.append(icon!.getTangoItem()!)
            }
        }
        return list
    }

    /**
    * アイコンを内包するRectを求める
    * アイコンの座標確定時に呼ぶ
    */
    public func updateBlockRect() {
        mBlockManager?.update()
    }

    /**
     * 指定座標下にあるアイコンを取得する
     * @param pos
     * @param exceptIcons
     * @return
     */
    public func getOverlappedIcon( pos : CGPoint, exceptIcons : List<UIcon>) -> UIcon?
    {
        return mBlockManager!.getOverlapedIcon(pos: pos, exceptIcons: exceptIcons)
    }

    /**
     * ソートする
     * @param mode
     */
    public func sortWithMode( mode : SortMode) {
        let _icons : List<UIcon> = getIcons()
        let  _ : SortMode = mode

        // _icons を SortMode の方法でソートする
        var _sortedIcons : [UIcon] = []

        // ゴミ箱は常に先頭に配置
        var trashIcon : UIcon? = nil
        for icon in _icons {
            if icon!.getType() == .Trash {
                trashIcon = icon
                _icons.remove(obj: icon!)
                break
            }
        }
        
        switch mode {
        case .TitleAsc:       // タイトル文字昇順(カードはWordA,単語帳はName)
            _sortedIcons = _icons.sort(isOrderedBefore: {
                return $0.getTitle()! < $1.getTitle()!
            })
        case .TitleDesc:      // タイトル文字降順
            _sortedIcons = _icons.sort(isOrderedBefore: {
                return $0.getTitle()! > $1.getTitle()!
            })
        
        case .CreateDateAsc:  // 作成日時 昇順
            _sortedIcons = _icons.sort(isOrderedBefore: {
                return ($0.getTangoItem()?.getCreateTime())! < ($1.getTangoItem()?.getCreateTime())!
            })
        case .CreateDateDesc:  // 作成日時 降順
            _sortedIcons = _icons.sort(isOrderedBefore: {
                return ($0.getTangoItem()?.getCreateTime())! > ($1.getTangoItem()?.getCreateTime())!
            })
        default:
            break
        }

        // ソート済みの新しいアイコンリストを作成する
        icons.removeAll()
        icons.append( trashIcon! )
        
        var pos = 1
        for icon in _sortedIcons {
            icons.append(icon)

           if icon.getTangoItem() == nil {
               continue
           }

            // DB更新用にItemPosを設定しておく
            icon.getTangoItem()!.setPos(pos: pos)
            pos += 1
        }
        // DBの位置情報を更新
        TangoItemPosDao.updateAll(items: getTangoItems().toArray(),
                                  parentType: mParentWindow!.getParentType(),
                                  parentId:mParentWindow!.getParentId())
    }


    /**
    * UIconCallbacks
    */
    public func iconClicked(icon : UIcon) {
        if icon.getParentWindow()!.type == WindowType.Home {
            setSelectedIcon(icon)
        }
        if mIconCallbacks != nil {
            mIconCallbacks!.iconClicked(icon: icon)
        }
    }
    public func longClickIcon(icon : UIcon) {
        if mIconCallbacks != nil {
            mIconCallbacks!.iconClicked(icon: icon)
        }
    }

    public  func iconDroped(icon: UIcon) {

    }
}

