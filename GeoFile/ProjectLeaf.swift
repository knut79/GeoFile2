//
//  ProjectLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

protocol ProjectLeafProtocol
{
    func projectSelected(sender:UITapGestureRecognizer)
    func showActionButtonsForProject(sender:AnyObject)
}

class ProjectLeaf
{
    var project:Project
    var button:UIImageView!
    var imageViews:[UIImageView]
    var selected:Bool = false
    var filepointLeafs:[FilepointLeaf]
    
    init(_project:Project, imagesfileItems:NSSet, viewRef:UIView)
    {
        var _button = UIImageView(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
        _button.userInteractionEnabled = true
        _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        _button.userInteractionEnabled = true
        if let imagefile = _project.firstImagefile
        {
            var image = UIImage(data: imagefile.file)
            _button.image = image
        }
        

        var singleTapRecognizer = UITapGestureRecognizer(target: viewRef, action: "projectSelected:")
        singleTapRecognizer.numberOfTapsRequired = 1
        _button.addGestureRecognizer(singleTapRecognizer)
        var doubleTapRecognizer = UITapGestureRecognizer(target: viewRef, action: "showActionButtonsForProject:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        _button.addGestureRecognizer(doubleTapRecognizer)
        imageViews = []
        for imagefile in imagesfileItems
        {
            var image = UIImage(data: (imagefile as Imagefile).file)
            imageViews.append(UIImageView(image: image))
        }
        project = _project
        button = _button
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        selected = false
        filepointLeafs = []
    }
}