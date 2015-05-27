//
//  FilepointLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

protocol FilepointLeafProtocol
{
    func filepointSelectedFromFilepoint(sender:UITapGestureRecognizer)
    func showActionButtonsForFilepoint(sender:AnyObject)
}

class FilepointLeaf
{
    var filepoint:Filepoint
    var parent:FilepointLeaf?
    var button:UIImageView!
    var selected:Bool = false
    var filepointLeafs:[FilepointLeaf]
    
    init(_filePoint:Filepoint, _parent:FilepointLeaf?,viewRef:UIView?)
    {
        
        var image = UIImage(data: _filePoint.firstImagefile!.file)
        var _button:UIImageView!
        if viewRef != nil{
            _button = UIImageView(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
            _button.userInteractionEnabled = true
            _button.image = image
            var singleTapRecognizer = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepoint:")
            singleTapRecognizer.numberOfTapsRequired = 1
            _button.addGestureRecognizer(singleTapRecognizer)
            var doubleTapRecognizer = UITapGestureRecognizer(target: viewRef!, action: "showActionButtonsForFilepoint:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
            _button.addGestureRecognizer(doubleTapRecognizer)
        }
        else
        {
            _button = UIImageView()
        }
        filepoint = _filePoint
        button = _button
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        selected = false
        filepointLeafs = []
        parent = _parent
    }
}
