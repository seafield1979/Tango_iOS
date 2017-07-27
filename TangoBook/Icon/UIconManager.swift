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

    public func setSelectedIcon(selectedIcon : UIcon?) {
        self.selectedIcon = selectedIcon
    }

    public func getDropedIcon() -> UIcon? {
        return dropedIcon
    }

    public func setDropedIcon( dropedIcon : UIcon?) {
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
         var instance = UIconManager()
         instance.mParentWindow = parentWindow
         instance.mIconCallbacks = iconCallbacks
         instance.icons = List()
         instance.mBlockManager = UIconsBlockManager.createInstance(icons: instance.icons)
         return instance
     }

//     /**
//     * 指定タイプのアイコンを作成してから追加
//     * @param copySrc  コピー元のIcon
//     * @param addPos
//     * @return
//     */
//     public UIcon copyIcon(UIcon copySrc, AddPos addPos) {
//         UIcon icon = nil;

//         TangoItemPos itemPos = copySrc.getTangoItem().getItemPos();

//         switch (copySrc.getType()) {
//             case Card: {
//                 TangoCard card = TangoCard.copyCard((TangoCard)copySrc.getTangoItem());
//                 card.setNewFlag(true);
//                 RealmManager.getCardDao().addOne(card,
//                         TangoParentType.toEnum(itemPos.getParentType()),
//                         itemPos.getParentId(),itemPos.getPos());
//                 icon = new IconCard(card, mParentWindow, self);
//             }
//             break;
//             case Book:
//             {
//                 TangoBook book = TangoBook.copyBook((TangoBook)copySrc.getTangoItem());
//                 book.setNewFlag(true);
//                 RealmManager.getBookDao().addOne(book, itemPos.getPos());
//                 icon = new IconBook(book, mParentWindow, self);

//             }
//             break;
//         }
//         if (icon == nil) return nil;

//         // リストに追加
//         if (addPos != nil) {
//             switch (addPos) {
//                 case SrcNext: {
//                     int pos = icons.indexOf(copySrc);
//                     if (pos != -1) {
//                         icons.add(pos + 1, icon);
//                         icon.setPos(copySrc.getPos());
//                     }
//                 }
//                     break;
//                 case Top:
//                     icons.push(icon);
//                     break;
//                 case Tail: {
//                     UIcon lastIcon = icons.getLast();

//                     icons.add(icon);

//                     // 出現位置は最後のアイコン
//                     if (lastIcon != nil) {
//                         icon.setPos(lastIcon.getPos());
//                     }
//                 }
//                     break;
//             }
//         }

//         return icon;
//     }

//     /**
//     * アイコンを追加する
//     * @param type
//     * @param addPos
//     * @return
//     */
//     public UIcon addNewIcon(IconType type, TangoParentType parentType,
//                             int parentId, AddPos addPos) {
//         UIcon icon = nil;
//         switch (type) {
//             case Card: {
//                 TangoCard card = TangoCard.createCard();
//                 RealmManager.getCardDao().addOne(card, parentType, parentId, -1);
//                 icon = new IconCard(card, mParentWindow, self);
//             }
//                 break;
//             case Book:
//             {
//                 TangoBook book = TangoBook.createBook();
//                 RealmManager.getBookDao().addOne(book, -1);
//                 icon = new IconBook(book, mParentWindow, self);
//             }
//                 break;
//             case Trash:
//             {
//                 mTrashIcon = icon = new IconTrash(mParentWindow, self);
//             }
//                 break;
//         }
//         if (icon == nil) return nil;

//         // リストに追加
//         if (addPos == AddPos.Top) {
//             icons.push(icon);
//         } else {
//             UIcon lastIcon = nil;
//             if (icons.size() > 0) {
//                 lastIcon = icons.getLast();
//             }
//             icons.add(icon);

//             // 出現位置は最後のアイコン
//             if (lastIcon != nil) {
//                 icon.setPos(lastIcon.getPos());
//             }
//         }

//         return icon;
//     }

//     /**
//     * TangoItemを元にアイコンを追加する
//     * @param item
//     * @return
//     */
//     public UIcon addIcon(TangoItem item, AddPos addPos) {
//         UIcon icon = nil;

//         switch(item.getItemType()) {
//             case Card:
//                 if (item instanceof  TangoCard) {
//                     TangoCard card = (TangoCard) item;
//                     icon = new IconCard(card, mParentWindow, self);
//                 }
//                 break;
//             case Book:
//                 if (item instanceof  TangoBook) {
//                     TangoBook book = (TangoBook) item;
//                     icon = new IconBook(book, mParentWindow, self);
//                 }
//                 break;
//         }
//         if (icon == nil) return nil;

//         if (addPos == AddPos.Top) {
//             icons.push(icon);

//         } else {
//             icons.add(icon);
//             // 出現位置は最後のアイコン
//             UIcon lastIcon = icons.getLast();
//             if (lastIcon != nil) {
//                 icon.setPos(lastIcon.getPos());
//             }
//         }
//         return icon;
//     }

//     /**
//     * すでに作成済みのアイコンを追加
//     * ※べつのWindowにアイコンを移動するのに使用する
//     * @param icon
//     * @return
//     */
//     public boolean addIcon(UIcon icon) {
//         // すでに追加されている場合は追加しない
//         if (!icons.contains(icon)) {
//             icons.add(icon);
//             return true;
//         }
//         return false;
//     }

//     /**
//     * アイコンを削除(データベースからも削除）
//     * @param icon
//     */
//     public void removeIcon(UIcon icon) {
//         TangoItem item = icon.getTangoItem();
//         if (item == nil) return;

//         switch(icon.getType()) {
//             case Card:
//                 RealmManager.getCardDao().deleteById(item.getId());
//                 break;
//             case Book:
//                 RealmManager.getBookDao().deleteById(item.getId());
//                 break;
//         }
//         RealmManager.getItemPosDao().deleteItem(icon.getTangoItem());
//         icons.remove(icon);
//     }

//     /**
//     * UIconのリストからTangoItemのリストを作成する
//     * @return
//     */
//     public List<TangoItem> getTangoItems() {
//         LinkedList<TangoItem> list = new LinkedList<>();
//         for (UIcon icon : icons) {
//             if (icon.getTangoItem() != nil) {
//                 list.add(icon.getTangoItem());
//             }
//         }
//         return list;
//     }

//     /**
//     * アイコンを内包するRectを求める
//     * アイコンの座標確定時に呼ぶ
//     */
//     public void updateBlockRect() {
//         mBlockManager.update();
//     }

//     /**
//     * 指定座標下にあるアイコンを取得する
//     * @param pos
//     * @param exceptIcons
//     * @return
//     */
//     public UIcon getOverlappedIcon(Point pos, List<UIcon> exceptIcons) {
//         return mBlockManager.getOverlapedIcon(pos, exceptIcons);
//     }

//     /**
//     * ソートする
//     * @param mode
//     */
//     public void sortWithMode(SortMode mode) {
//         UIcon[] _icons = getIcons().toArray(new UIcon[0]);
//         final SortMode _mode = mode;

//         // _icons を SortMode の方法でソートする
//         Arrays.sort(_icons, new Comparator<UIcon>() {
//             public int compare(UIcon icon1, UIcon icon2) {
//                 TangoItem item1 = icon1.getTangoItem();
//                 TangoItem item2 = icon2.getTangoItem();
//                 if (item1 == nil || item2 == nil) {
//                     return 0;
//                 }
//                 switch(_mode) {
//                     case TitleAsc:       // タイトル文字昇順(カードはWordA,単語帳はName)
//                         return item1.getTitle().compareTo (
//                                 item2.getTitle());
//                     case TitleDesc:      // タイトル文字降順
//                         return item2.getTitle().compareTo(
//                                 item1.getTitle());
//                     case CreateDateAsc:  // 作成日時 昇順
//                         if (item1.getCreateTime() == nil || item2.getCreateTime() == nil)
//                             break;
//                         return item1.getCreateTime().compareTo(
//                                 item2.getCreateTime());
//                     case CreateDateDesc:  // 作成日時 降順
//                         if (item1.getCreateTime() == nil || item2.getCreateTime() == nil)
//                             break;
//                         return item2.getCreateTime().compareTo(
//                                 item1.getCreateTime());
//                 }
//                 return 0;
//             }
//         });

//         // ソート済みの新しいアイコンリストを作成する
//         icons.clear();

//         int pos = 1;
//         for (UIcon icon : _icons) {
//             icons.add(icon);

//             if (icon.getTangoItem() == nil) continue;

//             // DB更新用にItemPosを設定しておく
//             icon.getTangoItem().setPos(pos);
//             pos++;
//         }
//         // DBの位置情報を更新
//         RealmManager.getItemPosDao().updateAll(getTangoItems(),
//                 mParentWindow.getParentType(),
//                 mParentWindow.getParentId());
//     }


    /**
    * UIconCallbacks
    */
    public func iconClicked(icon : UIcon) {
        if icon.getParentWindow()!.type == WindowType.Home {
            selectedIcon = icon
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

