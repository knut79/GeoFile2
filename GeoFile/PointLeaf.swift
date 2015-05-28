//
//  FilepointLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//


//OBSOLETE

import Foundation

protocol PointLeafProtocol
{
    func filepointSelectedFromFilepoint(sender:UITapGestureRecognizer)
    func showActionButtonsForFilepoint(sender:AnyObject)
}

class PointLeaf:UIView
{
    
    var type:leafType!
    var imageInstances:[UIImageView]!
    //var filepoint:Filepoint?
    var project:Project?
    var showButton:UIButton!
    var deleteButton:UIButton!
    var currentImage:Imagefile!
    
    var filepoint:Filepoint?
    var parent:PointLeaf?
    //var button:UIImageView!
    var selected:Bool = false
    var pointLeafs:[PointLeaf]!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_project:Project,viewRef:UIView?)
    {
        var rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)
        //button = _button
        //button.layer.cornerRadius = 5
        //button.clipsToBounds = true
        selected = false
        pointLeafs = []
        project = _project
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "projectSelected:")
        initImagefiles(_project.imagefiles,singleTapRecognizer: singleTapRec)
    }
    
    init(_filePoint:Filepoint, _parent:PointLeaf?,viewRef:UIView?)
    {
        var rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)
        
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 2.0;
        imageInstances = []
        
        filepoint = _filePoint
        //button = _button
        //button.layer.cornerRadius = 5
        //button.clipsToBounds = true
        selected = false
        pointLeafs = []
        parent = _parent
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepoint:")
        initImagefiles(_filePoint.imagefiles,singleTapRecognizer: singleTapRec)
    }
    
    func initImagefiles(imagefiles:NSSet, singleTapRecognizer:UITapGestureRecognizer)
    {
        var index:CGFloat = 0
        for imageitem in imagefiles
        {
            var image = UIImage(data: (imageitem as Imagefile).file)
            
            var imageInstance = UIImageView(frame: CGRectMake(index * 5, index * 5, frame.size.width * 0.8, frame.size.height * 0.8))
            imageInstance.image = image
            index++
            
            imageInstances.append(imageInstance)
            
            self.addSubview(imageInstance)
            
            if(Int(index) == imagefiles.count)
            {
                
                imageInstance.userInteractionEnabled = true

                singleTapRecognizer.numberOfTapsRequired = 1
                imageInstance.addGestureRecognizer(singleTapRecognizer)
                /*
                var doubleTapRecognizer = UITapGestureRecognizer(target: viewRef!, action: "showActionButtonsForFilepoint:")
                doubleTapRecognizer.numberOfTapsRequired = 2
                singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
                imageInstance.addGestureRecognizer(doubleTapRecognizer)
                */
                currentImage = imageitem as Imagefile
            }
        }
    }
}
