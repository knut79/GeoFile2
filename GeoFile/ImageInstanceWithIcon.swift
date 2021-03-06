//
//  ImageInstanceWithIcon.swift
//  GeoFile
//
//  Created by knut on 22/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class ImageInstanceWithIcon:UIView
{
    var imagefile:Imagefile!
    var imageView:UIImageView!
    var iconLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame:CGRect, imagefile:Imagefile)
    {
        super.init(frame: frame)
        self.imagefile = imagefile
        var image = UIImage(data: imagefile.file)
        if imagefile.locked == true
        {
            image = convertImageToGrayScale(image!)
        }
        let imageView = UIImageView(frame: CGRectMake(self.frame.width * 0.05, self.frame.height * 0.05, self.frame.width * 0.9, self.frame.height * 0.9))
        imageView.image = image
        self.addSubview(imageView)

        iconLabel = UILabel(frame: CGRectMake(self.frame.width * 0.70, 0, self.frame.width * 0.3, self.frame.height * 0.3))
        iconLabel.font = UIFont.systemFontOfSize(8)
        iconLabel.text = workType(rawValue:Int(imagefile.worktype))?.icon
        iconLabel.textAlignment = NSTextAlignment.Center
        print("worktype : \(workType(rawValue:Int(imagefile.worktype))?.icon)")
        self.addSubview(iconLabel)
    }
    
    var icon:String?
        {
        get{
            return iconLabel.text
        }
        set{
            iconLabel.text = icon
        }
    }
    
    var image:UIImage?
        {
        get{
            return imageView.image
        }
        set{
            imageView.image = image
        }
    }
    
    
}