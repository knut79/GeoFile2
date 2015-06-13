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

//show 💡 🔦🔎
//delete 🚮

//send 📤

//📷

enum drawColorEnum: Int
{
    case white = 0,black,red,blue
}

enum leafType: Int
{
    case mappoint = 0,imagepoint
}

enum commonTags:Int
{
    case skinnebrudd = 0
    case asfalt
    case vannavløp
    case skinnegang
    
    var description: String {
        switch self {
        case .skinnebrudd:
            return "skinnebrudd"
        case .asfalt:
            return "asfalt"
        case .vannavløp:
            return "vannavløp"
        case .skinnegang:
            return "skinnegang"
        default:
            return "skinnegang"
        }
    }
}

enum workType:Int
{
    case info = 0
    case arbeid
    case utfortarbeid
    case godkjent
    case mangler
    case dokument
    
    static var count: Int {
        var max: Int = 0
        while let _ = self(rawValue: ++max) {}
        return max
    }
    
    var description: String {
        switch self {
        case .info:
            return "til informasjon"
        case .arbeid:
            return "arbeid"
        case .utfortarbeid:
            return "utført arbeid"
        case .godkjent:
            return "godkjent arbeid"
        case .mangler:
            return "mangler ved ettersyn"
        case .dokument:
            return "dokument"
        default:
            return "til informasjon"
        }
    }
    
    var icon: String {
        switch self {
        case .info:
            return "ℹ️"
        case .arbeid:
            return "♻️"
        case .utfortarbeid:
            return "☑️"
        case .godkjent:
            return "✅"
        case .mangler:
            return "❗"
        case .dokument:
            return "📄"
        default:
            return "ℹ️"
        }
    }
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

//used by drawing
let drawingLineWidth:CGFloat = 4
let drawingArcRadius:CGFloat = 40
let drawingTextPointSize:CGFloat = 17

//used by treeview
let leafSize = CGSizeMake( 200 , 200)
let horizontalLineLength:CGFloat = 20
let verticalLineLength:CGFloat = 20

let buttonBarHeight:CGFloat = 44
let buttonIconSide:CGFloat = 50
let buttonIconSideSmall:CGFloat = 40
let imageInstanceSides:CGFloat = 40
let imageinstanceSideSmall:CGFloat = 50
let imageinstanceSideBig:CGFloat = imageinstanceSideSmall * 2
let elementMargin:CGFloat = 10
let leafMargin:CGFloat = 5
//UIScreen.mainScreen().bounds.size.width * 0.5



