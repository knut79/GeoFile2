//
//  OverlayDropzone.swift
//  GeoFile
//
//  Created by knut on 31/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class OverlayDropzone:UIView
{
    var title:UILabel!
    var mapIcon:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.userInteractionEnabled = true
        
        mapIcon = UILabel(frame: CGRectMake(0, 0, self.frame.width * 0.7, self.frame.height * 0.7))
        //mapIcon.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        mapIcon.layer.cornerRadius = 5
        mapIcon.clipsToBounds = true
        mapIcon.layer.borderColor = UIColor.grayColor().CGColor
        mapIcon.layer.borderWidth = 2.0;
        mapIcon.text = "🌍"
        mapIcon.textAlignment = NSTextAlignment.Center
        mapIcon.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(mapIcon)
        
        title = UILabel(frame: CGRectMake(0, 0, mapIcon.frame.width, mapIcon.frame.height * 0.2))
        title.text = "Overlay dropzone"
        title.textAlignment = NSTextAlignment.Center
        //title.layer.borderColor = UIColor.grayColor().CGColor
        //title.layer.borderWidth = 2.0;
        
        //self.layer.borderColor = UIColor.grayColor().CGColor
        //self.layer.borderWidth = 2.0;
        mapIcon.addSubview(title)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}