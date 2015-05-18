//
//  StaticValues.swift
//  GeoFile
//
//  Created by knut on 09/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
//🎨📝↩❌🔙⚫️⚪️🔵🔴↩️〽️📥 📤✏️〰✒💾
//❌ ⭕️❗️ ❓✖️ ✔️✅📑📄💠💢
//⭕️ work to be done
//✔️ All done
//❗️ Ettersyn
//♤ ♡ ♢ ♧ 💭 💬
//delete 🍃 🍃
//↕️ ↔️🔄⤴️ ⤵️
//🔒 🔓🌍
// 0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ 🔟


//instanser av bilder/filer som ligger under et punkt
//📄 added dokument
//ℹ️ ℹ❕info pictures/files
//♻️ 🔨🔧⚠ arbeid
//☑️utført arbeid
//✅ godkjentr
//❗mangler ved ettersyn
//❓(text) spørsmål


//kategorier/ tagger
//⚡️ elektriker
//🚊 sporjobber
//🔧 rørlegger

//↪️ ↩️ rotate clockwise/ counter clockwise
//⏫ ⏬ ⏪ ⏩ move
//↕️ ↔️ expand
// ➕ ➖ ➗ zoom

enum drawColorEnum: Int
{
    case white = 0,black,red,blue
}

enum workType: Int
{
    case info = 0,arbeid,utfortarbeid,mangler,dokument
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
    case .red:
        return UIColor.redColor()
    case .blue:
        return UIColor.blueColor()
    default:
        return UIColor.blackColor()
    }
}

let drawingLineWidth:CGFloat = 4
let drawingArcRadius:CGFloat = 40
let drawingTextPointSize:CGFloat = 17

let buttonBarHeight:CGFloat = 44
let buttonIconSide:CGFloat = 50
let buttonIconSideSmall:CGFloat = 40
//UIScreen.mainScreen().bounds.size.width * 0.5



