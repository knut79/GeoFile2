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
    func projectSelected(sender:UITapGestureRecognizer)
    func filepointSelectedFromFilepoint(sender:UITapGestureRecognizer)
    func showActionButtonsForFilepoint(sender:AnyObject)
}

class PointLeaf:UIView
{
    
    var type:leafType!
    var imageInstances:[ImageInstanceWithIcon]!
    //var filepoint:Filepoint?
    var project:Project?
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_project:Project,viewRef:UIView?)
    {
        var rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)

        project = _project
        
        setInitialValues(viewRef!)
        

        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "projectSelected:")
        initImagefiles(_project.imagefiles,singleTapRecognizer: singleTapRec)
    }

    
    init(_filePoint:Filepoint, _parent:PointLeaf?,viewRef:UIView?)
    {
        var rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)
        
        filepoint = _filePoint
        
        setInitialValues(viewRef!)
        
        parent = _parent
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepoint:")
        initImagefiles(_filePoint.imagefiles,singleTapRecognizer: singleTapRec)
    }
    
    func setInitialValues(viewRef:UIView!)
    {
        self.backgroundColor = UIColor.clearColor()
        
        titleLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height * 0.35))
        titleLabel.numberOfLines = 2
        titleLabel.text = self.project != nil ? self.project?.title : self.filepoint?.title
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
    
    
    func initImagefiles(imagefiles:NSSet, singleTapRecognizer:UITapGestureRecognizer)
    {
        
        var index = imagefiles.count
        for imageitem in imagefiles
        {
            index--
            //var image = UIImage(data: (imageitem as Imagefile).file)
            
            var imageSizeWidth = imageInstanceSides
            var imageSizeHeight = imageInstanceSides
            var margin = (leafSize.width / 2) - (imageSizeWidth / 2)
            var imageInstance = ImageInstanceWithIcon(frame: CGRectMake(margin + (CGFloat(index) * 5),margin + (CGFloat(index) * 3), imageSizeWidth, imageSizeHeight),imagefile: imageitem as Imagefile)
            imageInstance.alpha = 1 / CGFloat(index)
            //imageInstance.image = image
            
            imageInstance.userInteractionEnabled = true
            singleTapRecognizer.numberOfTapsRequired = 1
            imageInstance.addGestureRecognizer(singleTapRecognizer)
            
            imageInstances.append(imageInstance)
            
            self.addSubview(imageInstance)
            
            if(Int(index) == 0)
            {
                
                imageInstance.userInteractionEnabled = true
                singleTapRecognizer.numberOfTapsRequired = 1
                imageInstance.addGestureRecognizer(singleTapRecognizer)


                currentImageInstance = imageInstance
                currentImage = imageitem as Imagefile
            }
        }
    }
    
    func reloadImageInstances()
    {
        for item in imageInstances
        {
            item.removeFromSuperview()
        }
        imageInstances = []
        
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "filepointSelectedFromFilepoint:")
        if let fp = filepoint
        {
            initImagefiles(fp.imagefiles,singleTapRecognizer: singleTapRec)
        }
        else if let proj = project
        {
            initImagefiles(proj.imagefiles,singleTapRecognizer: singleTapRec)
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
