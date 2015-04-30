//
//  PictureHelper.swift
//  GeoFile
//
//  Created by knut on 29/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation



func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
    
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage
}