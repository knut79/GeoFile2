//
//  SetOverlayButtons.swift
//  GeoFile
//
//  Created by knut on 12/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol SetOverlayButtonsProtocol
{
    func resizeOverlay()
    func rotateOverlay()
}
class SetOverlayButtons : NSObject{
    var delegate:SetOverlayButtonsProtocol?
    var gmaps:GMSMapView?

    var bearing:CGFloat = 0

    var lockUnlockButton:UIButton!
    var overlayInfoLabel:UILabel!
    var rotateButton:UIButton!
    
    var precisionToggleButton:UIButton!
    var rotateClockwiseButton:UIButton!
    var rotateCounterclockwiseButton:UIButton!
    var resizeButton:UIButton!
    var moveRightButton:UIButton!
    var moveLeftButton:UIButton!
    var moveUpButton:UIButton!
    var moveDownButton:UIButton!
    var zoomInButton:UIButton!
    var zoomOutButton:UIButton!
    
    var mapLocked = false
    var canRotate = false
    var canResize = true
    
    var newOverlayToSet:UIImageView!
    
    init(view:GMSMapView, overlay:UIImageView)
    {
        super.init()
        gmaps = view
        newOverlayToSet = overlay
        
        mapLocked = true
        
        //adding buttons for overlay
        var buttonSize = CGRectMake(0, 0, buttonIconSideSmall, buttonIconSideSmall)
        lockUnlockButton = CustomButton(frame: buttonSize)
        lockUnlockButton.setTitle("🔓", forState: .Normal)
        lockUnlockButton.addTarget(self, action: "lockMapToggle:", forControlEvents: .TouchUpInside)
        
        overlayInfoLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width / 2, buttonIconSideSmall))
        overlayInfoLabel.text = "Map is unlocked."
        overlayInfoLabel.textAlignment = NSTextAlignment.Center
        overlayInfoLabel.hidden = true
        
        
        
        
        rotateButton = CustomButton(frame: buttonSize)
        rotateButton.setTitle("🔄", forState: .Normal)
        rotateButton.addTarget(self, action: "rotateOverlay", forControlEvents: .TouchUpInside)
        
        
        
        precisionToggleButton = CustomButton(frame: buttonSize)
        precisionToggleButton.setTitle("🎯", forState: .Normal)
        precisionToggleButton.addTarget(self, action: "precisionToggle", forControlEvents: .TouchUpInside)
        
        rotateClockwiseButton = CustomButton(frame: buttonSize)
        rotateClockwiseButton.setTitle("↩️", forState: .Normal)
        rotateClockwiseButton.addTarget(self, action: "rotateOneTickClockwise", forControlEvents: .TouchUpInside)
        rotateClockwiseButton.alpha = 0
        
        rotateCounterclockwiseButton = CustomButton(frame: buttonSize)
        rotateCounterclockwiseButton.setTitle("↪️", forState: .Normal)
        rotateCounterclockwiseButton.addTarget(self, action: "rotateOneTickCounterclockwise", forControlEvents: .TouchUpInside)
        rotateCounterclockwiseButton.alpha = 0
        
        moveLeftButton = CustomButton(frame: buttonSize)
        moveLeftButton.setTitle("⏪", forState: .Normal)
        moveLeftButton.addTarget(self, action: "moveOverlayLeft", forControlEvents: .TouchUpInside)
        moveLeftButton.alpha = 0
        
        moveRightButton = CustomButton(frame: buttonSize)
        moveRightButton.setTitle("⏩", forState: .Normal)
        moveRightButton.addTarget(self, action: "moveOverlayRight", forControlEvents: .TouchUpInside)
        moveRightButton.alpha = 0
        
        moveUpButton = CustomButton(frame: buttonSize)
        moveUpButton.setTitle("⏫", forState: .Normal)
        moveUpButton.addTarget(self, action: "moveOverlayUp", forControlEvents: .TouchUpInside)
        moveUpButton.alpha = 0
        
        moveDownButton = CustomButton(frame: buttonSize)
        moveDownButton.setTitle("⏬", forState: .Normal)
        moveDownButton.addTarget(self, action: "moveOverlayDown", forControlEvents: .TouchUpInside)
        moveDownButton.alpha = 0
        
        zoomInButton = CustomButton(frame: buttonSize)
        zoomInButton.setTitle("➕", forState: .Normal)
        zoomInButton.addTarget(self, action: "zoomInOverlay", forControlEvents: .TouchUpInside)
        zoomInButton.alpha = 0
        
        zoomOutButton = CustomButton(frame: buttonSize)
        zoomOutButton.setTitle("➖", forState: .Normal)
        zoomOutButton.addTarget(self, action: "zoomOutOverlay", forControlEvents: .TouchUpInside)
        zoomOutButton.alpha = 0
        
        resizeButton = CustomButton(frame: buttonSize)
        resizeButton.setTitle("↔️", forState: .Normal)
        resizeButton.addTarget(self, action: "resizeOverlay", forControlEvents: .TouchUpInside)
        resizeButton.alpha = 0.5
        resizeButton.layer.borderColor = UIColor.blackColor().CGColor
        resizeButton.layer.borderWidth = 2.0;
        resizeButton.enabled = false
        
        
        
        precisionToggleButton.center = CGPointMake(buttonSize.width * 0.75  , gmaps!.frame.maxY - (buttonSize.height * 0.75) - gmaps!.frame.origin.y)
        lockUnlockButton.center = CGPointMake(precisionToggleButton.frame.maxX + buttonSize.width, gmaps!.frame.maxY - (buttonSize.height * 0.75) - gmaps!.frame.origin.y)
        overlayInfoLabel.center = CGPointMake(lockUnlockButton.frame.maxX + (overlayInfoLabel.frame.width / 2), lockUnlockButton.center.y)
        rotateButton.center = CGPointMake(lockUnlockButton.frame.maxX + buttonSize.width, gmaps!.frame.maxY - (buttonSize.height * 0.75) - gmaps!.frame.origin.y)
        resizeButton.center = CGPointMake(rotateButton.frame.maxX + buttonSize.width, gmaps!.frame.maxY - (buttonSize.height * 0.75) - gmaps!.frame.origin.y)
        rotateClockwiseButton.center = CGPointMake(rotateClockwiseButton.frame.width / 2, gmaps!.center.y)
        rotateCounterclockwiseButton.center = CGPointMake(gmaps!.frame.maxX - (rotateClockwiseButton.frame.width / 2), gmaps!.center.y)
        
        moveLeftButton.center = CGPointMake(moveLeftButton.frame.width / 2, gmaps!.center.y - rotateClockwiseButton.frame.height)
        moveRightButton.center = CGPointMake(gmaps!.frame.maxX - (moveRightButton.frame.width / 2), gmaps!.center.y - rotateClockwiseButton.frame.height)
        moveUpButton.center = CGPointMake(gmaps!.center.x , moveUpButton.frame.height/2)
        moveDownButton.center = CGPointMake(gmaps!.center.x ,precisionToggleButton.center.y)
        
        zoomInButton.center = CGPointMake(gmaps!.frame.maxX - (zoomInButton.frame.width / 2), rotateClockwiseButton.frame.maxY + (zoomInButton.frame.height*2))
        zoomOutButton.center = CGPointMake(gmaps!.frame.maxX - (zoomOutButton.frame.width / 2), zoomInButton.frame.maxY + zoomOutButton.frame.height)
        
        gmaps?.addSubview(lockUnlockButton)
        gmaps?.addSubview(overlayInfoLabel)
        gmaps?.addSubview(rotateButton)
        gmaps?.addSubview(resizeButton)
        
        gmaps?.addSubview(precisionToggleButton)
        gmaps?.addSubview(rotateClockwiseButton)
        gmaps?.addSubview(rotateCounterclockwiseButton)
        
        gmaps?.addSubview(moveLeftButton)
        gmaps?.addSubview(moveRightButton)
        gmaps?.addSubview(moveUpButton)
        gmaps?.addSubview(moveDownButton)
        gmaps?.addSubview(zoomInButton)
        gmaps?.addSubview(zoomOutButton)
        

    }
    
    func lockMapToggle(sender:UIButton)
    {
        if(mapLocked)
        {
            //map is unlocked and picture is hidden
            overlayInfoLabel.hidden = false
            resizeButton.alpha = 0
            resizeButton.enabled = true
            resizeButton.layer.borderWidth = 0;
            
            rotateButton.alpha = 0
            rotateButton.enabled = true
            rotateButton.layer.borderWidth = 0;
            
            gmaps?.settings.scrollGestures = true
            gmaps?.settings.zoomGestures = true
            gmaps?.settings.rotateGestures = false
            mapLocked = false
            sender.setTitle("🔒", forState: .Normal)
            newOverlayToSet.alpha = 0.3
            newOverlayToSet.userInteractionEnabled = false
            
        }
        else
        {
            overlayInfoLabel.hidden = true
            resizeButton.alpha = 1
            resizeButton.enabled = true
            resizeButton.layer.borderWidth = 0
            
            rotateButton.alpha = 1
            rotateButton.enabled = true
            rotateButton.layer.borderWidth = 0
            if(canRotate)
            {
                rotateButton.alpha = 0.5
                rotateButton.enabled = false
                rotateButton.layer.borderWidth = 2
            }
            else if(canResize)
            {
                resizeButton.alpha = 0.5
                resizeButton.enabled = false
                resizeButton.layer.borderWidth = 2
            }
            
            
            gmaps?.settings.scrollGestures = false
            gmaps?.settings.zoomGestures = false
            gmaps?.settings.rotateGestures = false
            mapLocked = true
            sender.setTitle("🔓", forState: .Normal)
            newOverlayToSet.alpha = 0.5
            newOverlayToSet.userInteractionEnabled = true
        }
    }
    
    var precisionOn = false
    func precisionToggle()
    {
        var alphaPresicionBtns:CGFloat = 0
        var alphaNonPresicionBtns:CGFloat = 0
        if(precisionOn)
        {
            precisionOn = false
            alphaNonPresicionBtns = 1
            alphaPresicionBtns = 0
            precisionToggleButton.setTitle("🎯", forState: .Normal)
            
        }
        else
        {
            precisionOn = true
            precisionToggleButton.setTitle("🔙", forState: .Normal)
            alphaNonPresicionBtns = 0
            alphaPresicionBtns = 1
            
        }
        lockUnlockButton.alpha = alphaNonPresicionBtns
        overlayInfoLabel.alpha = alphaNonPresicionBtns
        rotateButton.alpha = alphaNonPresicionBtns
        resizeButton.alpha = alphaNonPresicionBtns
        
        rotateClockwiseButton.alpha = alphaPresicionBtns
        rotateCounterclockwiseButton.alpha = alphaPresicionBtns
        moveRightButton.alpha = alphaPresicionBtns
        moveLeftButton.alpha = alphaPresicionBtns
        moveUpButton.alpha = alphaPresicionBtns
        moveDownButton.alpha = alphaPresicionBtns
        zoomInButton.alpha = alphaPresicionBtns
        zoomOutButton.alpha = alphaPresicionBtns
    }
    
    func rotateOverlay()
    {
        resizeButton.alpha = 1
        resizeButton.enabled = true
        resizeButton.layer.borderWidth = 0;
        
        lockUnlockButton.alpha = 1
        lockUnlockButton.enabled = true
        lockUnlockButton.layer.borderWidth = 0;
        
        rotateButton.alpha = 0.5
        rotateButton.enabled = false
        rotateButton.layer.borderColor = UIColor.blackColor().CGColor
        rotateButton.layer.borderWidth = 2.0;
        
        canRotate = true
        canResize = false
        delegate?.rotateOverlay()
    }
    
    func resizeOverlay()
    {
        resizeButton.alpha = 0.5
        resizeButton.enabled = false
        resizeButton.layer.borderColor = UIColor.blackColor().CGColor
        resizeButton.layer.borderWidth = 2.0;
        
        rotateButton.alpha = 1
        rotateButton.enabled = true
        rotateButton.layer.borderWidth = 0;
        
        lockUnlockButton.alpha = 1
        lockUnlockButton.enabled = true
        lockUnlockButton.layer.borderWidth = 0;
        canRotate = false
        canResize = true
        delegate?.resizeOverlay()
    }
    
    func rotateOneTickClockwise()
    {
        newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, -0.01)
    }
    
    func rotateOneTickCounterclockwise()
    {
        newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, 0.01)
    }
    

    
    func moveOverlayDown()
    {
        newOverlayToSet.center = CGPointMake(newOverlayToSet.center.x, newOverlayToSet.center.y + 1)
    }
    
    func moveOverlayUp()
    {
        newOverlayToSet.center = CGPointMake(newOverlayToSet.center.x, newOverlayToSet.center.y - 1)
    }
    
    func moveOverlayRight()
    {
        newOverlayToSet.center = CGPointMake(newOverlayToSet.center.x + 1, newOverlayToSet.center.y)
    }
    
    func moveOverlayLeft()
    {
        newOverlayToSet.center = CGPointMake(newOverlayToSet.center.x - 1, newOverlayToSet.center.y)
    }
    
    func zoomInOverlay()
    {
        var currentTransform = newOverlayToSet.transform
        newOverlayToSet.transform = CGAffineTransformIdentity
        
        let scale:CGFloat = 1.01
        let oldCenter = newOverlayToSet.center
        newOverlayToSet.frame.size = CGSizeMake(newOverlayToSet.frame.size.width * scale, newOverlayToSet.frame.size.height * scale)
        newOverlayToSet.center = oldCenter
        
        newOverlayToSet.transform = currentTransform
    }
    
    func zoomOutOverlay()
    {
        var currentTransform = newOverlayToSet.transform
        newOverlayToSet.transform = CGAffineTransformIdentity
        
        let scale:CGFloat = 1.01
        let oldCenter = newOverlayToSet.center
        newOverlayToSet.frame.size = CGSizeMake(newOverlayToSet.frame.size.width / scale, newOverlayToSet.frame.size.height / scale)
        newOverlayToSet.center = oldCenter
        
        newOverlayToSet.transform = currentTransform
    }
    
    func cancelOverlay()
    {
        lockUnlockButton.removeFromSuperview()
        resizeButton.removeFromSuperview()
        rotateButton.removeFromSuperview()
        //cancelOverlayButton.removeFromSuperview()
        //setOverlayButton.removeFromSuperview()
        //newOverlayToSet.removeFromSuperview()
        overlayInfoLabel.removeFromSuperview()
        precisionToggleButton.removeFromSuperview()
        
        rotateClockwiseButton.removeFromSuperview()
        rotateCounterclockwiseButton.removeFromSuperview()
        moveDownButton.removeFromSuperview()
        moveUpButton.removeFromSuperview()
        moveRightButton.removeFromSuperview()
        moveLeftButton.removeFromSuperview()
        zoomInButton.removeFromSuperview()
        zoomOutButton.removeFromSuperview()
        
        gmaps?.settings.scrollGestures = true
        gmaps?.settings.zoomGestures = true
        gmaps?.settings.rotateGestures = true
    }
    
    
}