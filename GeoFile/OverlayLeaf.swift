//
//  OverlayNode.swift
//  GeoFile
//
//  Created by knut on 06/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class OverlayLeaf: UIView
{
    var xselected:Bool = false
    var overlay:Overlay!
    
    var showButton:UIButton!
    var deleteButton:UIButton!
    var imageView:UIImageView!
    var titleLabel:UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(overlay:Overlay,viewRef:UIView?)
    {
        let rect = CGRectMake(0, 0, leafSize.width, leafSize.height)
        super.init(frame: rect)
        
        self.overlay = overlay
        //test
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor.blackColor().CGColor
        //end test
        
        let singleTapRec = UITapGestureRecognizer(target: viewRef!, action: "overlaySelected:")
        imageView = UIImageView(frame: CGRectMake(0, 0, imageInstanceSides, imageInstanceSides))
        
        imageView.userInteractionEnabled = true
        imageView.layer.borderColor = UIColor.grayColor().CGColor
        imageView.layer.borderWidth = 2.0;
        let image = UIImage(data: overlay.file)
        imageView.image = image
        imageView.center =  CGPointMake(self.frame.width / 2, self.frame.height / 2)
        singleTapRec.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTapRec)
        self.addSubview(imageView)
        setInitialValues(viewRef!)
    }

    
    func setInitialValues(viewRef:UIView!)
    {
        self.backgroundColor = UIColor.clearColor()
        
        titleLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height * 0.35))
        titleLabel.numberOfLines = 2
        titleLabel.text = overlay.title
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
        showButton.setTitle("Set", forState: UIControlState.Normal)
        showButton.addTarget(viewRef, action: "showOverlay", forControlEvents: .TouchUpInside)
        showButton.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(showButton)
        
        deleteButton = CustomButton(frame: CGRectMake(0, 0, imageInstanceSides * 2, buttonIconSideSmall))
        deleteButton.hidden = true
        deleteButton.addTarget(viewRef, action: "deleteOverlay", forControlEvents: .TouchUpInside)
        deleteButton.setTitle("Delete", forState: UIControlState.Normal)
        deleteButton.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(deleteButton)
        
        //self.layer.borderColor = UIColor.grayColor().CGColor
        //self.layer.borderWidth = 2.0;

        xselected = false
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
                self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 2, 2)
                self.showButton.transform = CGAffineTransformIdentity
                self.deleteButton.transform = CGAffineTransformIdentity
                self.titleLabel.transform = CGAffineTransformIdentity
                self.showButton.center = CGPointMake(self.imageView.frame.maxX ,  self.imageView.frame.maxY )
                self.deleteButton.center = CGPointMake(self.imageView.frame.maxX ,  self.showButton.frame.maxY + (self.deleteButton.frame.size.height / 2))
                self.titleLabel.center = CGPointMake(self.frame.size.width / 2,  self.imageView.frame.minY - (self.titleLabel.frame.size.height / 2))
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
            self.bringSubviewToFront(self.imageView)
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.imageView.transform = CGAffineTransformIdentity
                self.deleteButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.showButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.titleLabel.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1)
                self.showButton.center = self.imageView.center
                self.deleteButton.center = self.imageView.center
                self.titleLabel.center = self.imageView.center
                
                }, completion: { (value: Bool) in
                    self.deleteButton.hidden = true
                    self.showButton.hidden = true
                    self.titleLabel.hidden = true
            })
        }
    }
    
}