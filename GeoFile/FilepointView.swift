//
//  FilepointView.swift
//  GeoFile
//
//  Created by knut on 08/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class FilepointView:UIView ,UIScrollViewDelegate
{
    var overviewImageView: UIImageView!
    var overviewScrollView: UIScrollView!
    
    var currentFilepoint: Filepoint?
    //just because we ned temporary coordinates for a label associated with a filepoint
    var childPointsAndLabels = [(UILabel,Filepoint?)]()
    
    var addPointButton: CustomButton!
    var backOneLevelButton: CustomButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        overviewScrollView = UIScrollView(frame: frame)
        overviewScrollView.backgroundColor = UIColor.blackColor()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func cleanChildPointsAndLabelsList()
    {
        childPointsAndLabels = []
    }
    
    func fillChildPointsAndLabels()
    {
        
        
        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0

        //println("printing coordinates for \(childFilepointItems.count) filepoints")
        println("printing coordinates for \(currentFilepoint!.filepoints.count) filepoints")
        
        
        
        var count = 0
        //for item in childFilepointItems
        for item in currentFilepoint!.filepoints
        {
            count++
            
            var pointLabel = UILabel(frame: CGRectMake(addPointButton.frame.maxX + 2, addPointButton.frame.minY, (UIScreen.mainScreen().bounds.size.width * 0.5) * 0.30, buttonBarHeight))
            pointLabel.text = "💠"
            pointLabel.textAlignment = NSTextAlignment.Center
            pointLabel.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            pointLabel.userInteractionEnabled = true
            pointLabel.layer.cornerRadius = 8.0
            pointLabel.clipsToBounds = true
            pointLabel.tag =  count
            var tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
            tapRecognizer.numberOfTapsRequired = 1
            pointLabel.addGestureRecognizer(tapRecognizer)
            
            var position = CGPointMake(CGFloat((item as Filepoint).x), CGFloat((item as Filepoint).y))
            pointLabel.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            pointLabel.center = CGPointMake(pointLabel.center.x + xVoidOffset,pointLabel.center.y + yVoidOffset)
            
            println("recalculated values : x \(pointLabel.center.x) y \(pointLabel.center.y)")
            
            childPointsAndLabels.append((pointLabel,item as? Filepoint))
        }
    }

    func goBackOneLevel()
    {
        var image = UIImage(data: currentFilepoint!.file!)
        
        var pointObj = currentFilepoint?.parent
        self.removeImageAndPointLabels()
        currentFilepoint = pointObj
        self.setFileLevel()
        if(currentFilepoint?.parent == nil)
        {
            backOneLevelButton.enabled = false
            backOneLevelButton.alpha = 0.5
        }
        
        var imageViewForAnimation = UIImageView(frame: self.overviewImageView.frame)
        imageViewForAnimation.frame.offset(dx: 0, dy: self.overviewScrollView.frame.minY)
        imageViewForAnimation.alpha = 1
        imageViewForAnimation.image = image
        self.addSubview(imageViewForAnimation)
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            //self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 20)
            imageViewForAnimation.frame = CGRectMake(0, 0, 40, 40)
            imageViewForAnimation.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/2)
            imageViewForAnimation.alpha = 0.2
            }, completion: { (value: Bool) in
                imageViewForAnimation.removeFromSuperview()
                
        })
    }
    
    func setFileLevel()
    {
        var image = UIImage(data: currentFilepoint!.file!)
        overviewImageView = UIImageView(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
        overviewImageView.image = image
        overviewScrollView.addSubview(overviewImageView)
        overviewScrollView.contentSize = overviewImageView.frame.size
        
        //populate the childPointsAndLabelsList
        overviewScrollView.delegate = self
        
        let scrollViewFrame = overviewScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / overviewScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / overviewScrollView.contentSize.height
        //TODO:
        let minScale = max(scaleWidth, scaleHeight);
        //let minScale = min(scaleWidth, scaleHeight);
        overviewScrollView.minimumZoomScale = minScale;
        overviewScrollView.maximumZoomScale = 1.0
        overviewScrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        self.fillChildPointsAndLabels()
        
        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
        
        //for filepoint in filepointItems[0].filepoints
        for filepointAndLabel in childPointsAndLabels
        {
            var pointLabel = filepointAndLabel.0
            var position = CGPointMake(CGFloat(filepointAndLabel.1!.x), CGFloat(filepointAndLabel.1!.y))
            
            pointLabel.center = CGPointMake(pointLabel.center.x + overviewScrollView.contentOffset.x, pointLabel.center.y + overviewScrollView.contentOffset.y - (pointLabel.frame.size.height/2))
            
            pointLabel.alpha = 0.75
            
            overviewImageView.addSubview(pointLabel)
            
            //TODO: Do we need this here
            var realPosition = CGPointMake(pointLabel.center.x / overviewScrollView.zoomScale, pointLabel.center.y / overviewScrollView.zoomScale)
            var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
            var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
            //realPosition = CGPointMake(realPosition.x - xVoidOffset, realPosition.y - yVoidOffset)
            realPosition = CGPointMake(realPosition.x - (xVoidOffset/overviewScrollView.zoomScale), realPosition.y - (yVoidOffset/overviewScrollView.zoomScale))
            pointLabel.removeFromSuperview()
            
            overviewScrollView.addSubview(pointLabel)
        }
    }
    
    var chooseFromCameraButton:UIButton!
    var currentTappedTag:Int = 0
    func pointTapped(sender:UITapGestureRecognizer)->Void
    {
        //delegate to controller
        /*
        println("tag is \(sender.view!.tag)")
        currentTappedTag = sender.view!.tag
        var pointObj = self.findPointLabelOnTag(currentTappedTag)
        
        if(pointObj!.1 != nil && pointObj!.1!.file? != nil)
        {
            var image = UIImage(data: pointObj!.1!.file!)
            var imageViewForAnimation = UIImageView(frame: sender.view!.frame)
            imageViewForAnimation.center = sender.view!.center
            imageViewForAnimation.alpha = 0.3
            imageViewForAnimation.image = image
            self.view.addSubview(imageViewForAnimation)
            UIView.animateWithDuration(0.50, animations: { () -> Void in
                //self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 20)
                imageViewForAnimation.frame = self.overviewImageView.frame
                imageViewForAnimation.frame.offset(dx: 0, dy: self.overviewScrollView.frame.minY)
                imageViewForAnimation.alpha = 0.7
                }, completion: { (value: Bool) in
                    imageViewForAnimation.removeFromSuperview()
                    
                    self.removeImageAndPointLabels()
                    self.currentFilepoint = pointObj!.1
                    self.setFileLevel()
                    self.backOneLevelButton.alpha = 1.0
                    self.backOneLevelButton.enabled = true
            })
            
            
        }
        else
        {
            self.view.addSubview(cameraView)
        }
*/
    }
    
    func findPointLabelOnTag(tag:Int) -> (UILabel,Filepoint?)?
    {
        for item in childPointsAndLabels
        {
            if(item.0.tag == tag)
            {
                return item
            }
        }
        return nil
    }
    
    func removeImageAndPointLabels()
    {
        for label in childPointsAndLabels
        {
            label.0.removeFromSuperview()
        }
        
        overviewImageView.removeFromSuperview()
        self.cleanChildPointsAndLabelsList()
    }
    
    
    //MARK: UIScrollViewDelegate
    
    func centerScrollViewContents() {
        let boundsSize = overviewScrollView.bounds.size
        var contentsFrame = overviewImageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        overviewImageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return overviewImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        
        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
        
        //for item in currentFilepoint!.filepoints
        for item in childPointsAndLabels
        {
            var label = item.0
            var position = CGPointMake(CGFloat(item.1!.x), CGFloat(item.1!.y))
            label.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            label.center = CGPointMake(label.center.x + xVoidOffset,label.center.y + yVoidOffset)
        }
        
        centerScrollViewContents()
    }
}