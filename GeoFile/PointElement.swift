//
//  PointElement.swift
//  GeoFile
//
//  Created by knut on 23/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import QuartzCore

class PointElement: UIView {
    
    var filepoint:Filepoint?
    var pointIcon:UILabel!
    var titleLabel:UILabel!
    required init?(coder aDecoder: NSCoder) {
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
        
        if self.filepoint != nil && self.filepoint!.title != ""
        {
            titleLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height * 0.35))
            titleLabel.numberOfLines = 2
            titleLabel.text = self.filepoint?.title
            //titleLabel.layer.borderColor = UIColor.blackColor().CGColor
            //titleLabel.layer.borderWidth = 2.0;
            titleLabel.textAlignment = NSTextAlignment.Center
            
            titleLabel.layer.shadowColor = UIColor.whiteColor().CGColor
            titleLabel.layer.shadowRadius = 5.0
            titleLabel.layer.shadowOpacity = 1
            titleLabel.layer.shouldRasterize = true
            titleLabel.layer.shadowOffset = CGSizeMake(0,1)
            titleLabel.layer.masksToBounds = false
            self.addSubview(titleLabel!)
        }
        
        //self.layer.borderColor = UIColor.blackColor().CGColor
        //self.layer.borderWidth = 2.0;

    }
}