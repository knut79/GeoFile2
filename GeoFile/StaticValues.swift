//
//  StaticValues.swift
//  GeoFile
//
//  Created by knut on 09/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
//🎨📝↩❌🔙⚫️⚪️🔵🔴↩️〽️📥 📤✏️〰✒💾
//❌ ⭕️❗️ ❓✖️ ✔️✅📑📄💠💢
//♤ ♡ ♢ ♧ 💭 💬
//↕️ ↔️🔄⤴️ ⤵️
//🔒 🔓🌍
enum drawColorEnum
{
    case white
    case black
}

enum viewtypeEnum
{
    case map
    case list
    case tree
    case none
}

enum drawTypeEnum
{
    case free
    case measure
    case angle
    case text
    case undo
}

func getUIColor(color:drawColorEnum) -> UIColor
{
    switch(color)
    {
    case .white:
        return UIColor.whiteColor()
    case .black:
        return UIColor.blackColor()
    default:
        return UIColor.blackColor()
    }
}

let buttonBarHeight:CGFloat = 44

let buttonIconSide:CGFloat = 50
let buttonIconSideSmall:CGFloat = 40
//UIScreen.mainScreen().bounds.size.width * 0.5



