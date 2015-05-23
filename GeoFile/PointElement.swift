//
//  PointElement.swift
//  GeoFile
//
//  Created by knut on 23/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class PointElement: UIView {
    
    var filepoint:Filepoint?
    var pointIcon:UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame:CGRect,icon:String,filepoint:Filepoint?)
    {
        super.init(frame: frame)
        self.filepoint = filepoint
        pointIcon = UILabel(frame: CGRectMake(0, 0, buttonIconSide, buttonIconSide))
        pointIcon.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        pointIcon.text = icon
        pointIcon.textAlignment = NSTextAlignment.Center
        pointIcon.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        pointIcon.userInteractionEnabled = true
        pointIcon.layer.cornerRadius = 8.0
        pointIcon.clipsToBounds = true
        
        self.addSubview(pointIcon)
        
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0;

    }
}