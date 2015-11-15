//
//  FilepointLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//


import Foundation

protocol PointLeafProtocol
{
    func projectSelectedAction(sender:UITapGestureRecognizer)
    func filepointSelectedFromFilepointAction(sender:UITapGestureRecognizer)
}

class PointLeaf:UIView
{
    
    var type:leafType!
    var imageInstances:[ImageInstanceWithIcon]!
    //var filepoint:Filepoint?
    var mappoint:MapPoint?
    var showButton:UIButton!
    var deleteButton:UIButton!
    var currentImage:Imagefile!
    var currentImageInstance:ImageInstanceWithIcon!
    var titleLabel:UILabel!
    
    var filepoint:Filepoint?
    var parent:PointLeaf?
    //var button:UIImageView!
    private var xselected:Bool = false
    var pointLeafs:[PointLeaf]!
    var viewRef:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_mappoint:MapPoint,viewRef:UIView?)
    {
        let rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)

        //test
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor.blackColor().CGColor
        //end test
        
        mappoint = _mappoint
        
        setInitialValues(viewRef!)
        

        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "projectSelectedAction:")
        initImagefiles(_mappoint.imagefiles,singleTapRecognizer: singleTapRec)
    }

    
    init(_filePoint:Filepoint, _parent:PointLeaf?,viewRef:UIView?)
    {
        let rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)
        //test
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor.blackColor().CGColor
        //end test
        
        filepoint = _filePoint
        
        setInitialValues(viewRef!)
        
        parent = _parent
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepointAction:")
        initImagefiles(_filePoint.imagefiles,singleTapRecognizer: singleTapRec)
    }
    
    func setInitialValues(viewRef:UIView!)
    {
        self.backgroundColor = UIColor.clearColor()
        
        titleLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height * 0.35))
        titleLabel.numberOfLines = 2
        titleLabel.text = self.mappoint != nil ? self.mappoint?.title : self.filepoint?.title
        //titleLabel.layer.borderColor = UIColor.blackColor().CGColor
        //titleLabel.layer.borderWidth = 2.0;
        titleLabel.textAlignment = NSTextAlignment.Center
        
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.layer.shadowColor = UIColor.greenColor().CGColor
        titleLabel.layer.shadowRadius = 5.0
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.shadowOffset = CGSizeMake(0,1)
        titleLabel.layer.masksToBounds = false
        titleLabel.hidden = true
        titleLabel.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(titleLabel!)
        
        showButton = CustomButton(frame: CGRectMake(0, 0, imageInstanceSides * 2, buttonIconSideSmall))
        showButton.hidden = true
        showButton.setTitle("Show", forState: UIControlState.Normal)
        showButton.addTarget(viewRef, action: "showNode", forControlEvents: .TouchUpInside)
        showButton.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(showButton)
        
        deleteButton = CustomButton(frame: CGRectMake(0, 0, imageInstanceSides * 2, buttonIconSideSmall))
        deleteButton.hidden = true
        deleteButton.addTarget(viewRef, action: "deleteNode", forControlEvents: .TouchUpInside)
        deleteButton.setTitle("Delete", forState: UIControlState.Normal)
        deleteButton.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(deleteButton)
        
        //self.layer.borderColor = UIColor.grayColor().CGColor
        //self.layer.borderWidth = 2.0;
        self.viewRef = viewRef
        imageInstances = []
        pointLeafs = []
        xselected = false
    }
    
    
    func initImagefiles(imagefiles:NSSet, singleTapRecognizer:UITapGestureRecognizer, topImageFile:Imagefile? = nil)
    {
        if imagefiles.count == 0
        {
            return
        }
        let sortDescriptor = NSSortDescriptor(key: "sort", ascending: false)
        let sortedImagefiles = imagefiles.sortedArrayUsingDescriptors([sortDescriptor])
        
        //top element
        let topElement = topImageFile ?? sortedImagefiles.last as! Imagefile
        
        let imageSizeWidth = imageInstanceSides
        let imageSizeHeight = imageInstanceSides
        let margin = (leafSize.width / 2) - (imageSizeWidth / 2)
        let topImageInstance = ImageInstanceWithIcon(frame: CGRectMake(margin,margin, imageSizeWidth, imageSizeHeight),imagefile: topElement)
        topImageInstance.userInteractionEnabled = true
        singleTapRecognizer.numberOfTapsRequired = 1
        topImageInstance.addGestureRecognizer(singleTapRecognizer)
        currentImageInstance = topImageInstance
        currentImage = topElement
        
        
        imageInstances.append(topImageInstance)
        
        var index = sortedImagefiles.count
        for imageitem in sortedImagefiles
        {
            if(imageitem as! Imagefile == topElement)
            {
                continue
            }
            
            index--

            let imageInstance = ImageInstanceWithIcon(frame: CGRectMake(margin + (CGFloat(index) * 5),margin + (CGFloat(index) * 3), imageSizeWidth, imageSizeHeight),imagefile: imageitem as! Imagefile)
            imageInstance.alpha = 1 / CGFloat(index)
            imageInstances.append(imageInstance)
            self.addSubview(imageInstance)

            /*
            if(Int(index) == 0)
            {
                imageInstance.userInteractionEnabled = true
                singleTapRecognizer.numberOfTapsRequired = 1
                imageInstance.addGestureRecognizer(singleTapRecognizer)

                currentImageInstance = imageInstance
                currentImage = imageitem as Imagefile
            }
            */
        }
        
        self.addSubview(topImageInstance)
    }
    
    func setImageInstanceOnTop(imageInstance:ImageInstanceWithIcon)
    {
        reloadImageInstances(imageInstance.imagefile)
        if(xselected)
        {
            self.currentImageInstance.transform = CGAffineTransformScale(self.currentImageInstance.transform, 2, 2)
            self.bringSubviewToFront(self.deleteButton)
            self.bringSubviewToFront(self.showButton)
        }
    }
    
    func reloadImageInstances(topImageFile:Imagefile? = nil)
    {
        for item in imageInstances
        {
            item.removeFromSuperview()
        }
        imageInstances = []
        
        
        if let fp = filepoint
        {
            let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepointAction:")
            initImagefiles(fp.imagefiles,singleTapRecognizer: singleTapRec, topImageFile:topImageFile)
        }
        else if let mp = mappoint
        {
            let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "projectSelectedAction:")
            initImagefiles(mp.imagefiles,singleTapRecognizer: singleTapRec, topImageFile:topImageFile)
        }
    }
    
    func selectLeaf()
    {
        if(!xselected)
        {

            xselected = true
            //currentImageInstance.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
            self.deleteButton.hidden = false
            self.showButton.hidden = false
            self.titleLabel.hidden = false
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.currentImageInstance.transform = CGAffineTransformScale(self.currentImageInstance.transform, 2, 2)
                self.showButton.transform = CGAffineTransformIdentity
                self.deleteButton.transform = CGAffineTransformIdentity
                self.titleLabel.transform = CGAffineTransformIdentity
                self.showButton.center = CGPointMake(self.currentImageInstance.frame.maxX ,  self.currentImageInstance.frame.maxY )
                self.deleteButton.center = CGPointMake(self.currentImageInstance.frame.maxX ,  self.showButton.frame.maxY + (self.deleteButton.frame.size.height / 2))
                self.titleLabel.center = CGPointMake(self.frame.size.width / 2,  self.currentImageInstance.frame.minY - (self.titleLabel.frame.size.height / 2))
                }, completion: { (value: Bool) in
                    self.bringSubviewToFront(self.deleteButton)
                    self.bringSubviewToFront(self.showButton)
            })
        }
    }
    
    func unselectLeaf()
    {
        if(xselected)
        {
            xselected = false
        
        
            //currentImageInstance.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
            //currentImageInstance.transform = CGAffineTransformScale(imageInstance.transform, 2, 2)
            //self.addSubview(imageInstance)
            self.bringSubviewToFront(self.currentImageInstance)
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.currentImageInstance.transform = CGAffineTransformIdentity
                self.deleteButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.showButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.titleLabel.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.showButton.center = self.currentImageInstance.center
                self.deleteButton.center = self.currentImageInstance.center
                self.titleLabel.center = self.currentImageInstance.center

                }, completion: { (value: Bool) in
                    self.deleteButton.hidden = true
                    self.showButton.hidden = true
                    self.titleLabel.hidden = true
            })
        }
    }
}
