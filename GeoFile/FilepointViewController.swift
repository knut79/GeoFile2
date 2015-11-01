//
//  FilesViewController.swift
//  GeoFile
//
//  Created by knut on 23/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import AVFoundation
import MobileCoreServices

class FilepointViewController: CustomViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, DrawViewProtocol, CameraProtocol{

    
    var currentFilepoint: Filepoint?
    var currentImagefile: Imagefile?
    //just because we ned temporary coordinates for a label associated with a filepoint
    var childPointsAndLabels = [PointElement]()
    
    var project:Project?
    var frontPicture: Bool = false
    var overviewImageView: FilepointView2!
    var overviewScrollView: UIScrollView!
    var drawView:DrawView!
    var sendMailButton: CustomButton!
    var addPointButton: CustomButton!
    var addDrawButton:CustomButton!
    var messageButton:CustomButton!
    var backOneLevelButton: CustomButton!
    var addButton:CustomButton!
    var hideAddMenuButton:CustomButton!

    var nextWorkLevelAcceptanceButton: CustomButton!
    var nextWorkLevelDenialButton: CustomButton!

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var imagefileItems = [Imagefile]()

    var addPictureButton: CustomButton!
    
    var oneLevelFromProject = false
    
    var imageInstances:[ImageInstanceWithIcon]?
    var imageInstancesScrollView:UIScrollView!
    
    
    var picker:UIImagePickerController!
    var cameraView:CameraView!
    
    let emailComposer = EmailComposer()
    //MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewFrame = self.view.frame

        initPickerView()

        messageButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        messageButton.setTitle("Add text", forState: .Normal)
        messageButton.addTarget(self, action: "draw", forControlEvents: .TouchUpInside)

        

        //make space for imageinstances :)
        //var mariginForImageInstances = (elementMargin * 2) + buttonIconSide
        addButton = CustomButton(frame: CGRectMake(elementMargin, UIScreen.mainScreen().bounds.size.height - buttonIconSide - elementMargin, buttonIconSide , buttonIconSide))
        addButton.setTitle("➕", forState: .Normal)
        addButton.addTarget(self, action: "genericAdd", forControlEvents: .TouchUpInside)
        
        hideAddMenuButton = CustomButton(frame: CGRectMake(addButton.frame.minX, addButton.frame.minY, buttonIconSide , buttonIconSide))
        hideAddMenuButton.setTitle("➖", forState: .Normal)
        hideAddMenuButton.addTarget(self, action: "hideAddMenu", forControlEvents: .TouchUpInside)
        hideAddMenuButton.hidden = true
        
        
        addPointButton = CustomButton(frame: CGRectMake(elementMargin, addButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        addPointButton.setTitle("➕ punkt→", forState: .Normal)
        addPointButton.addTarget(self, action: "addPoint", forControlEvents: .TouchUpInside)
        addPointButton.hidden = true
        
        addPictureButton = CustomButton(frame: CGRectMake(elementMargin, addPointButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        addPictureButton.setTitle("➕ Bilde→", forState: .Normal)
        addPictureButton.addTarget(self, action: "addPicture", forControlEvents: .TouchUpInside)
        addPictureButton.hidden = true
        
        addDrawButton = CustomButton(frame: CGRectMake(elementMargin, addPictureButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        addDrawButton.setTitle("➕ Illustrasjon→", forState: .Normal)
        addDrawButton.addTarget(self, action: "draw", forControlEvents: .TouchUpInside)
        addDrawButton.hidden = true
        
        sendMailButton = CustomButton(frame: CGRectMake(elementMargin, addDrawButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        sendMailButton.setTitle("Send skjema→", forState: .Normal)
        sendMailButton.addTarget(self, action: "sendMail", forControlEvents: .TouchUpInside)
        sendMailButton.hidden = true

        backOneLevelButton = CustomButton(frame: CGRectMake(addButton.frame.maxX + elementMargin, UIScreen.mainScreen().bounds.size.height - buttonIconSide - elementMargin, buttonIconSide * 2, buttonIconSide))
        backOneLevelButton.setTitle("🔙", forState: .Normal)
        backOneLevelButton.addTarget(self, action: "goBackOneLevel", forControlEvents: .TouchUpInside)
        
        
        nextWorkLevelAcceptanceButton = CustomButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - buttonIconSide -  elementMargin, topNavigationBar.frame.size.height + elementMargin , buttonIconSide , buttonIconSide))
        //setNextWorkLevelAcceptanceButton()

        nextWorkLevelAcceptanceButton.addTarget(self, action: "nextWorkLevelAcceptance", forControlEvents: .TouchUpInside)
        
        //skal kun vises om vi er i utført arbeid
        nextWorkLevelDenialButton = CustomButton(frame: CGRectMake(nextWorkLevelAcceptanceButton.frame.minX, nextWorkLevelAcceptanceButton.frame.maxY + elementMargin, buttonIconSide , buttonIconSide))
        //setNextWorkLevelDenialButton()
        nextWorkLevelDenialButton.addTarget(self, action: "nextWorkLevelDenial", forControlEvents: .TouchUpInside)

        let strechedHeight = UIScreen.mainScreen().bounds.size.height - (topNavigationBar.frame.size.height)
        overviewScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight))
        overviewScrollView.backgroundColor = UIColor.blackColor()
        //!!! overviewScrollView.autoresizesSubviews = false
        drawView = DrawView(frame: overviewScrollView.frame)


        self.view.addSubview(overviewScrollView)
        self.view.addSubview(drawView)

        self.view.addSubview(sendMailButton)
        self.view.addSubview(addDrawButton)
        self.view.addSubview(addPointButton)
        self.view.addSubview(addPictureButton)
        
        
        self.view.addSubview(addButton)
        self.view.addSubview(hideAddMenuButton)
        self.view.addSubview(backOneLevelButton)

        self.view.addSubview(nextWorkLevelAcceptanceButton)
        self.view.addSubview(nextWorkLevelDenialButton)
        
        // Reduce the total height by 20 points for the status bar, and 44 points for the bottom button
        viewFrame.size.height -= (addPointButton.frame.size.height)

        self.fetchImagefilesOnSameLevel()
        if(project != nil)
        {
            backOneLevelButton.enabled = false
            backOneLevelButton.alpha = 0.5
            
            //currentImage could be sat from treeview
            if(currentImagefile == nil)
            {
                currentImagefile = project?.firstImagefile
            }
        }

        drawView.hidden = true

        self.setFileLevel()
        self.fetchDrawings()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setNextWorkLevelAcceptanceButton()
    {
        nextWorkLevelAcceptanceButton.hidden = false
        if currentImagefile!.locked == true
        {
            nextWorkLevelAcceptanceButton.hidden = true
        }
        else
        {
            switch(self.getStatus())
            {
                case workType.arbeid:
                    nextWorkLevelAcceptanceButton.setTitle(workType.utfortarbeid.icon, forState: .Normal)
                case workType.utfortarbeid:
                    nextWorkLevelAcceptanceButton.setTitle(workType.godkjent.icon, forState: .Normal)
                case workType.godkjent:
                    nextWorkLevelAcceptanceButton.hidden = true
                case workType.mangler:
                    //neste nivå er utført, start på runddans
                    nextWorkLevelAcceptanceButton.setTitle(workType.utfortarbeid.icon, forState: .Normal)
        
                default:
                    nextWorkLevelAcceptanceButton.setTitle(workType.utfortarbeid.icon, forState: .Normal)
            }
        }
    }
    
    func getNextWorkLevel(worktype:workType) -> workType
    {
        var returnValue:workType
        switch(worktype)
        {
        case workType.arbeid:
            returnValue = workType.utfortarbeid
        case workType.utfortarbeid:
            returnValue = workType.godkjent

        case workType.mangler:
            //neste nivå er utført, start på runddans
            returnValue = workType.utfortarbeid
            
        default:
            returnValue = workType.arbeid
        }
        return returnValue
    }
    
    func setNextWorkLevelDenialButton()
    {
        nextWorkLevelDenialButton.hidden = false
        if currentImagefile!.locked == true
        {
            nextWorkLevelDenialButton.hidden = true
        }
        else
        {
            switch(self.getStatus())
            {
            case workType.arbeid:
                nextWorkLevelDenialButton.hidden = true
            case workType.utfortarbeid:
                nextWorkLevelDenialButton.setTitle(workType.mangler.icon, forState: .Normal)
            case workType.godkjent:
                nextWorkLevelDenialButton.hidden = true
            case workType.mangler:
                nextWorkLevelDenialButton.hidden = true
            default:
                nextWorkLevelDenialButton.hidden = true
            }
        }
    }
    
    func setLockMode(locked:Bool)
    {
        if locked
        {
            addButton.hidden = true
        }
        else
        {
            addButton.hidden = false
        }
        
        
    }
    
    func getStatus() -> workType
    {
        if project != nil
        {
            return workType(rawValue: Int(project!.status))!
        }
        else
        {
            return workType(rawValue: Int(currentFilepoint!.status))!
        }
    }
    
    func cleanChildPointsAndLabelsList()
    {
        childPointsAndLabels = []
    }
    
    func fillChildPointsAndLabels()
    {
        let yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        let xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0

        var count = 0
        //for item in childFilepointItems
        for item in currentImagefile!.filepoints
        {
            count++
            let testExtraSize:CGFloat = 100
            let point = PointElement(frame: CGRectMake(addPointButton.frame.maxX + 2 - (testExtraSize / 2), addPointButton.frame.minY - (testExtraSize / 2), buttonIconSide + testExtraSize, buttonIconSide + testExtraSize), icon:"💠",filepoint:item as? Filepoint)

            let tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
            tapRecognizer.numberOfTapsRequired = 1
            point.addGestureRecognizer(tapRecognizer)

            let position = CGPointMake(CGFloat((item as! Filepoint).x), CGFloat((item as! Filepoint).y))
            point.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            point.center = CGPointMake(point.center.x + xVoidOffset,point.center.y + yVoidOffset)

            childPointsAndLabels.append(point)
        }
    }
    

    
    //MARK: CoreData
    func fetchImagefilesOnSameLevel() {

        imagefileItems = []
        if(oneLevelFromProject)
        {
            print("number of files in project \(project?.imagefiles.count)")
            for item in project!.imagefiles
            {
                imagefileItems.append(item as! Imagefile)
            }
        }
        else
        {
            print("number of filepoints on filepoint \(currentFilepoint!.filepoints.count)")
            for item in currentFilepoint!.imagefiles
            {
                imagefileItems.append(item as! Imagefile)
            }
        }
    }

    
    func fetchDrawings()
    {
        
    }

    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }
    

    //MARK: UIActions

    func removeImageAndPointLabels()
    {
        for point in childPointsAndLabels
        {
            point.removeFromSuperview()
        }

        overviewImageView.removeFromSuperview()
        self.cleanChildPointsAndLabelsList()
    }
    
    func setFileLevel()
    {
        overviewImageView = FilepointView2(imagefile: currentImagefile!)
        overviewImageView.backgroundColor = UIColor.clearColor()
        overviewScrollView.addSubview(overviewImageView)


        setNextWorkLevelAcceptanceButton()
        setNextWorkLevelDenialButton()
        setLockMode(currentImagefile!.locked == true)
        
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

        let yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        let xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0

        for filepointAndLabel in childPointsAndLabels
        {
            let point = filepointAndLabel

            let position = CGPointMake(CGFloat(filepointAndLabel.filepoint!.x), CGFloat(filepointAndLabel.filepoint!.y))
            point.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            point.center = CGPointMake(point.center.x + xVoidOffset,point.center.y + yVoidOffset)
            
            print("overviewScrollView.zoomScale : x \(overviewScrollView.zoomScale)")
            print("pointLabel recalculated values : x \(point.center.x) y \(point.center.y)")
            
            point.alpha = 0.75
            
            overviewImageView.addSubview(point)


            point.removeFromSuperview()
            
            overviewScrollView.addSubview(point)
        }

        
        removeImageInstances()
        
        imageInstances = []
        if project?.imagefiles.count > 1
        {
            for imagefile in project!.imagefiles
            {
                let imageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imagefile as! Imagefile)
                imageInstances?.append(imageView)
            }
        }
        else if currentFilepoint?.imagefiles.count > 1
        {
            for imagefile in currentFilepoint!.imagefiles
            {
                let imageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imagefile as! Imagefile)
                imageInstances?.append(imageView)
            }
        }
        addImageInstancesAsIcons()

    }
    

    func addImageInstancesAsIcons()
    {
        //TODO: animate
        if imageInstancesScrollView != nil
        {
            imageInstancesScrollView.removeFromSuperview()
        }
        if imageInstances?.count > 0
        {

            var current:ImageInstanceWithIcon!
            var index:CGFloat = 1
            for imageView in imageInstances!
            {
                imageView.transform = CGAffineTransformIdentity
                imageView.transform = CGAffineTransformScale(imageView.transform, 0.5, 0.5)
                imageView.layer.borderWidth = 0
                if imageView.imagefile == currentImagefile
                {
                    current = imageView
                    imageView.center = CGPointMake(backOneLevelButton.frame.maxX + imageinstanceSideSmall + CGFloat(imageInstances!.count * 10) - CGFloat(imageInstances!.count * 10) , backOneLevelButton.center.y - CGFloat(imageInstances!.count * 2))

                    let tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesSmallTapped:")
                    tapRecognizer.numberOfTapsRequired = 1
                    imageView.addGestureRecognizer(tapRecognizer)
                    
                    self.view.addSubview(imageView)
                }
                else
                {
                    
                    imageView.center = CGPointMake(backOneLevelButton.frame.maxX + imageinstanceSideSmall + CGFloat(imageInstances!.count * 10) - (index * 10), backOneLevelButton.center.y - (index * 2))
                    self.view.addSubview(imageView)
                    index++
                    
                }
            }
            
            self.view.bringSubviewToFront(current)
        }
    }
    
    func addImageInstancesInScrollView()
    {
        
        hideAddMenu()
        if imageInstances?.count > 0
        {
            imageInstancesScrollView = UIScrollView(frame: CGRectMake(elementMargin, addButton.frame.minY - imageinstanceSideBig - elementMargin, self.view.frame.width - (elementMargin * 2), imageinstanceSideBig))
            imageInstancesScrollView.contentSize = CGSizeMake(CGFloat(imageInstances!.count) * imageinstanceSideBig, imageinstanceSideBig)
            imageInstancesScrollView.delegate = self

            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                    var index:CGFloat = 0
                    for imageView in self.imageInstances!
                    {
                        imageView.transform = CGAffineTransformIdentity
                        imageView.center = CGPointMake(self.imageInstancesScrollView.frame.origin.x + (imageView.frame.width / 2) + (index * imageinstanceSideBig),self.imageInstancesScrollView.frame.origin.y +  imageView.frame.height / 2)
                        if imageView.imagefile == self.currentImagefile
                        {
                            imageView.layer.borderColor = UIColor.greenColor().CGColor
                            imageView.layer.borderWidth = 2.0;
                        }
                        index++

                    }

                }, completion: { (value: Bool) in

                    var index:CGFloat = 0
                    for imageView in self.imageInstances!
                    {
                        imageView.transform = CGAffineTransformIdentity
                        imageView.center = CGPointMake((imageView.frame.width / 2) + (index * imageinstanceSideBig), imageView.frame.height / 2)
                        index++

                        let tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesBigTapped:")
                        tapRecognizer.numberOfTapsRequired = 1
                        imageView.addGestureRecognizer(tapRecognizer)

                        self.imageInstancesScrollView.addSubview(imageView)
                    }
            })

            
            self.view.addSubview(imageInstancesScrollView)
        }
    }
    
    func removeImageInstances()
    {
        if imageInstances?.count > 0
        {
            for imageView in imageInstances!
            {
                imageView.removeFromSuperview()
            }
        }
    }
    
    func hideImageInstances(hidden:Bool = true)
    {
        if imageInstances?.count > 0
        {
            for imageView in imageInstances!
            {
                imageView.hidden = hidden
            }
        }
    }
    
    func genericAdd()
    {
        addImageInstancesAsIcons()
        sendMailButton.hidden = false
        addDrawButton.hidden = false
        addPointButton.hidden = false
        addPictureButton.hidden = false
        hideAddMenuButton.hidden = false
        
        addPointButton.transform = CGAffineTransformScale(addPointButton.transform, 0.2, 0.2)
        addPictureButton.transform = CGAffineTransformScale(addPictureButton.transform, 0.2, 0.2)
        addDrawButton.transform = CGAffineTransformScale(addDrawButton.transform, 0.2, 0.2)
        sendMailButton.transform = CGAffineTransformScale(sendMailButton.transform, 0.2, 0.2)
        
        let orgPosAddPointButton = addPointButton.center
        let orgPosAddPictureButton = addPictureButton.center
        let orgPosAddDrawButton = addDrawButton.center
        let orgPosSendMailButton = sendMailButton.center
        
        addPointButton.center = addButton.center
        addPictureButton.center = addButton.center
        addDrawButton.center = addButton.center
        sendMailButton.center = addButton.center
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.addPointButton.transform = CGAffineTransformIdentity
            self.addPictureButton.transform = CGAffineTransformIdentity
            self.addDrawButton.transform = CGAffineTransformIdentity
            self.sendMailButton.transform = CGAffineTransformIdentity
            
            self.addPointButton.center = orgPosAddPointButton
            self.addPictureButton.center = orgPosAddPictureButton
            self.addDrawButton.center = orgPosAddDrawButton
            self.sendMailButton.center = orgPosSendMailButton
        })
    }
    
    func hideAddMenu()
    {
        let orgPosAddPointButton = addPointButton.center
        let orgPosAddPictureButton = addPictureButton.center
        let orgPosAddDrawButton = addDrawButton.center
        let orgPosSendMailButton = sendMailButton.center
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.addPointButton.center = self.addButton.center
            self.addPictureButton.center = self.addButton.center
            self.addDrawButton.center = self.addButton.center
            self.sendMailButton.center = self.addButton.center
            self.addPointButton.transform = CGAffineTransformScale(self.addPointButton.transform, 0.2, 0.2)
            self.addPictureButton.transform = CGAffineTransformScale(self.addPictureButton.transform, 0.2, 0.2)
            self.addDrawButton.transform = CGAffineTransformScale(self.addDrawButton.transform, 0.2, 0.2)
            self.sendMailButton.transform = CGAffineTransformScale(self.sendMailButton.transform, 0.2, 0.2)
            }, completion: { (value: Bool) in
                self.sendMailButton.hidden = true
                self.addDrawButton.hidden = true
                self.addPointButton.hidden = true
                self.addPictureButton.hidden = true
                self.hideAddMenuButton.hidden = true
                self.addPointButton.center = orgPosAddPointButton
                self.addPictureButton.center = orgPosAddPictureButton
                self.addDrawButton.center = orgPosAddDrawButton
                self.sendMailButton.center = orgPosSendMailButton
        })
    }

    //MARK: + menu actions
    
    func nextWorkLevelAcceptance()
    {
        //hideAddMenu()
        let image = UIImage(data: currentImagefile!.file)
        cameraView = CameraView(frame: self.view.frame, image:image!,worktype: getNextWorkLevel(getStatus()))
        cameraView.delegate = self
        self.view.addSubview(cameraView)
    }
    
    func sendMail()
    {
        let configureMailComposerConfiguration = emailComposer.configuredMailComposeViewController()
        if emailComposer.canSendMail()
        {
            presentViewController(configureMailComposerConfiguration, animated: true, completion: nil)
            
        }
        else
        {
            showEmailErrorAlert()
        }
    }
    
    func showEmailErrorAlert()
    {
        let sendEmailErrorAlert = UIAlertView(title: "Could not send email", message: "Your device could not send e-mail. Check your configuration and try again", delegate: self, cancelButtonTitle: "OK")
        sendEmailErrorAlert.show()
    }
    
    func addPicture()
    {
        hideAddMenu()
        let image = UIImage(data: currentImagefile!.file)
        cameraView = CameraView(frame: self.view.frame, image:image!,worktype:workType.dokument)
        cameraView.delegate = self
        self.view.addSubview(cameraView)
    }
    
    func addPoint()
    {
        addPointButton.enabled = false
        addPointButton.alpha = 0.5

        let testExtraSize:CGFloat = 100
        let point = PointElement(frame: CGRectMake(addPointButton.frame.maxX + 2 - (testExtraSize / 2), addPointButton.frame.minY - (testExtraSize / 2), buttonIconSide + testExtraSize, buttonIconSide + testExtraSize), icon:"💢",filepoint:nil)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
        tapRecognizer.numberOfTapsRequired = 1
        point.addGestureRecognizer(tapRecognizer)

        childPointsAndLabels.append(point)
        point.transform = CGAffineTransformScale(point.transform, 0.1, 0.1)
        self.view.addSubview(point)

        UIView.animateWithDuration(0.50, animations: { () -> Void in
            point.transform = CGAffineTransformIdentity
        })
    }
    
    var newFilepointTitle:String = ""
    var chooseFromCameraButton:UIButton!
    var newFilepoint:PointElement?
    func pointTapped(sender:UITapGestureRecognizer)->Void
    {
        let pointTapped =  sender.view as! PointElement
        let filepointToNavigateTowards = pointTapped.filepoint
        
        if(filepointToNavigateTowards != nil && filepointToNavigateTowards!.imagefiles.count > 0)
        {
            let image = UIImage(data: filepointToNavigateTowards!.file!)
            let imageViewForAnimation = UIImageView(frame: sender.view!.frame)
            imageViewForAnimation.center = sender.view!.center
            imageViewForAnimation.alpha = 0.3
            imageViewForAnimation.image = image
            self.view.addSubview(imageViewForAnimation)
            UIView.animateWithDuration(0.50, animations: { () -> Void in
                //self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 20)
                imageViewForAnimation.frame = self.overviewImageView.frame
                imageViewForAnimation.frame.offsetInPlace(dx: 0, dy: self.overviewScrollView.frame.minY)
                imageViewForAnimation.alpha = 0.7
                }, completion: { (value: Bool) in
                    imageViewForAnimation.removeFromSuperview()
                    
                    self.removeImageAndPointLabels()
                    self.currentFilepoint = filepointToNavigateTowards
                    self.project = nil
                    self.currentImagefile = self.currentFilepoint!.firstImagefile
                    print("new imagefile id \(self.currentImagefile!.objectID)")
                       self.backOneLevelButton.alpha = 1.0
                    self.backOneLevelButton.enabled = true
                    self.setFileLevel()
            })
        }
        else
        {
            
            let titlePrompt = UIAlertController(title: "Title for new point",
                message: "Set title for new point",
                preferredStyle: .Alert)
          
            var titleTextField: UITextField?
            titlePrompt.addTextFieldWithConfigurationHandler {
                (textField) -> Void in
                titleTextField = textField
                textField.placeholder = "Title"
                textField.textAlignment = NSTextAlignment.Center
                textField.keyboardType = UIKeyboardType.Default
            }
            
            titlePrompt.addAction(UIAlertAction(title: "Dont need title",
                style: .Default,
                handler: { (action) -> Void in
                    
            }))
            
            titlePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    self.newFilepointTitle = titleTextField!.text!
            }))

            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)
            
            newFilepoint = pointTapped
            cameraView = CameraView(frame: self.view.frame, image:nil, worktype: workType.arbeid)
            cameraView.delegate = self
            self.view.addSubview(cameraView)
        }
    }
    
    func imageinstancesSmallTapped(sender:UITapGestureRecognizer)->Void
    {
        addImageInstancesInScrollView()
        
    }
    
    func imageinstancesBigTapped(sender:UITapGestureRecognizer) -> Void
    {

        
        if (sender.view! as! ImageInstanceWithIcon).imagefile == self.currentImagefile
        {
            self.imageInstancesScrollView.removeFromSuperview()
            self.removeImageAndPointLabels()
            self.setFileLevel()
            return
        }

        let imageinstance = sender.view as! ImageInstanceWithIcon
        let imageViewForAnimation = UIImageView(frame: self.overviewScrollView.frame)

        imageViewForAnimation.transform = CGAffineTransformScale(imageViewForAnimation.transform, 0.1, 0.1)
        
        imageViewForAnimation.center = CGPointMake(imageInstancesScrollView.frame.minX + sender.view!.center.x, imageInstancesScrollView.frame.minY + sender.view!.center.y) //
        imageViewForAnimation.alpha = 0
        let image = UIImage(data: imageinstance.imagefile.file)
        imageViewForAnimation.image = image
        self.view.addSubview(imageViewForAnimation)
        UIView.animateWithDuration(0.30, animations: { () -> Void in
            imageViewForAnimation.center = self.overviewScrollView.center
            imageViewForAnimation.transform = CGAffineTransformIdentity
            imageViewForAnimation.alpha = 0.7
            }, completion: { (value: Bool) in
                self.imageInstancesScrollView.removeFromSuperview()
                self.removeImageAndPointLabels()
                imageViewForAnimation.removeFromSuperview()
                self.currentImagefile = imageinstance.imagefile
                self.setFileLevel()
        })
    }
    
    func goBackOneLevel()
    {
        let image = UIImage(data: currentImagefile!.file)
        
        self.removeImageAndPointLabels()

        currentImagefile = currentFilepoint?.imagefile
        if(currentImagefile?.filepoint == nil)
        {
            backOneLevelButton.enabled = false
            backOneLevelButton.alpha = 0.5

            currentFilepoint = nil
            project = currentImagefile?.project
        }
        else
        {
            currentFilepoint = currentImagefile?.filepoint
        }
        self.setFileLevel()
        
        let imageViewForAnimation = UIImageView(frame: self.overviewImageView.frame)
        imageViewForAnimation.frame.offsetInPlace(dx: 0, dy: self.overviewScrollView.frame.minY)
        imageViewForAnimation.alpha = 1
        imageViewForAnimation.image = image
        self.view.addSubview(imageViewForAnimation)
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            imageViewForAnimation.frame = CGRectMake(0, 0, 40, 40)
            imageViewForAnimation.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/2)
            imageViewForAnimation.alpha = 0.2
            }, completion: { (value: Bool) in
                imageViewForAnimation.removeFromSuperview()

        })
    }
    
    //MARK: DrawViewProtocol
    func setAngleText(label:UILabel)
    {
        let numberPrompt = UIAlertController(title: "Enter",
            message: "Enter angle text",
            preferredStyle: .Alert)
        
        var numberTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            numberTextField = textField
            textField.placeholder = "Number"
            textField.textAlignment = NSTextAlignment.Center
            textField.keyboardType = UIKeyboardType.NumberPad
        }

        numberPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                label.text = "\(numberTextField!.text)°"
        }))
        
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    func setDrawntextText(label:UILabel)
    {
        let textPrompt = UIAlertController(title: "Enter",
            message: "Enter text",
            preferredStyle: .Alert)
        
        var textTextField: UITextField?
        textPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            textTextField = textField
            textField.textAlignment = NSTextAlignment.Center
            textField.placeholder = "Enter text"
            textField.keyboardType = UIKeyboardType.Default
        }

        textPrompt.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: { (action) -> Void in
                label.text = textTextField!.text
        }))
        
        
        self.presentViewController(textPrompt,
            animated: true,
            completion: nil)
    }
    
    func setMeasurementText(label:UILabel)
    {
        let numberPrompt = UIAlertController(title: "Enter",
            message: "Enter measurement text",
            preferredStyle: .Alert)
        
        var numberTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            numberTextField = textField
            textField.textAlignment = NSTextAlignment.Center
            textField.placeholder = "Number"
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        
        var unitTextField: String = ""
        numberPrompt.addAction(UIAlertAction(title: "mm",
            style: .Default,
            handler: { (action) -> Void in
                unitTextField = "mm"
                label.text = "\(numberTextField!.text) \(unitTextField)"
        }))
        numberPrompt.addAction(UIAlertAction(title: "cm",
            style: .Default,
            handler: { (action) -> Void in
                unitTextField = "cm"
                label.text = "\(numberTextField!.text) \(unitTextField)"
        }))
        numberPrompt.addAction(UIAlertAction(title: "m",
            style: .Default,
            handler: { (action) -> Void in
                unitTextField = "m"
                label.text = "\(numberTextField!.text) \(unitTextField)"
        }))
        
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    func setDtextText(label:UILabel)
    {
        let textPrompt = UIAlertController(title: "Enter",
            message: "Enter text",
            preferredStyle: .Alert)
        
        var textTextField: UITextField?
        textPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            textTextField = textField
            textField.textAlignment = NSTextAlignment.Center
            textField.placeholder = "Enter text"
            textField.keyboardType = UIKeyboardType.Default
        }
        
        textPrompt.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: { (action) -> Void in
                label.text = textTextField!.text
        }))
        
        
        self.presentViewController(textPrompt,
            animated: true,
            completion: nil)
    }
    //MARK: Draw
    func draw()
    {

        for item in childPointsAndLabels
        {
            item.hidden = true
        }

        drawView.delegate = self
        drawView.setImage(makeImage(self.overviewScrollView,xOffset: overviewScrollView.contentOffset.x, yOffset: overviewScrollView.contentOffset.y))
        drawView.setZoomscale_custom(overviewScrollView.zoomScale)
        drawView.showButtons()
        drawView.resetDrawingValues()
        drawView.hidden = false
        
        addButton.hidden = true
        addPointButton.hidden = true
        addPictureButton.hidden = true
        addDrawButton.hidden = true
        sendMailButton.hidden = true
        
        hideImageInstances()
        hideAddMenuButton.hidden = true
        backOneLevelButton.hidden = true
    }
    
    func cancelDraw()
    {
        drawView.hidden = true
        drawView.clear()

        backOneLevelButton.hidden = false
        hideImageInstances(false)
        addButton.hidden = false
        
        for item in childPointsAndLabels
        {
            item.hidden = false
        }
    }
    
    func saveDraw()
    {
        let yVoidOffset = overviewScrollView.contentOffset.y
        let xVoidOffset = overviewScrollView.contentOffset.x
        
       
        drawView.hideButtons()
        for line in drawView.lines
        {
            
            let start = CGPointMake((line.start.x + xVoidOffset) / overviewScrollView.zoomScale, (line.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            let end = CGPointMake((line.end.x + xVoidOffset) / overviewScrollView.zoomScale,
                (line.end.y + yVoidOffset) / overviewScrollView.zoomScale)

            let newLine = Drawingline.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,endPoint: end,color: line.color,lastTouchBegan: line.lastTouchBegan)
            currentImagefile!.addDrawingLine(newLine)
        }
        
        for measure in drawView.measures
        {
            
            let start = CGPointMake((measure.start.x + xVoidOffset) / overviewScrollView.zoomScale, (measure.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            let end = CGPointMake((measure.end.x + xVoidOffset) / overviewScrollView.zoomScale,
                (measure.end.y + yVoidOffset) / overviewScrollView.zoomScale)
            
            let newMeasure = Drawingmeasure.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,endPoint: end,color: measure.color,text: measure.getLabel().text!)
            currentImagefile!.addDrawingMeasure(newMeasure)
        }
        
        for dtext in drawView.dTexts
        {
            
            let start = CGPointMake((dtext.start.x + xVoidOffset) / overviewScrollView.zoomScale, (dtext.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            let end = CGPointMake((dtext.end.x + xVoidOffset) / overviewScrollView.zoomScale,
                (dtext.end.y + yVoidOffset) / overviewScrollView.zoomScale)
            
            let newDtext = Drawingtext.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,endPoint: end,color: dtext.color,text: dtext.getLabel().text!, size:Int(drawingTextPointSize))
            currentImagefile!.addDrawingText(newDtext)
        }
        
        for angle in drawView.angles
        {
            
            let start = CGPointMake((angle.start.x + xVoidOffset) / overviewScrollView.zoomScale, (angle.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            let mid = CGPointMake((angle.mid.x + xVoidOffset) / overviewScrollView.zoomScale,
                (angle.mid.y + yVoidOffset) / overviewScrollView.zoomScale)
            let end = CGPointMake((angle.end!.x + xVoidOffset) / overviewScrollView.zoomScale,
                (angle.end!.y + yVoidOffset) / overviewScrollView.zoomScale)
            let newAngle = Drawingangle.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,midPoint: mid, endPoint: end, color: angle.color,text: angle.getLabel().text!)
            currentImagefile!.addDrawingAngle(newAngle)
        }
        
        for text in drawView.drawnTexts
        {
            let center = CGPointMake((text.label!.center.x + xVoidOffset) / overviewScrollView.zoomScale,
                (text.label!.center.y + yVoidOffset) / overviewScrollView.zoomScale)
            let newText = Drawingtext.createInManagedObjectContext(self.managedObjectContext!,centerPoint: center, color: text.color,text: text.label!.text!, size:Int(drawingTextPointSize))
            currentImagefile!.addDrawingText(newText)
        }
        
        save()
        overviewImageView.setNeedsDisplay()

        self.cancelDraw()
    }
    
    func makeImage(_view:UIView,xOffset:CGFloat = 0.0,yOffset:CGFloat = 0.0) -> UIImage {
        
        UIGraphicsBeginImageContext(drawView.bounds.size)

        let context = UIGraphicsGetCurrentContext()

        CGContextTranslateCTM(context, xOffset * -1, yOffset * -1)
        _view.layer.renderInContext(context!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return viewImage
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return overviewImageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {

        let yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        let xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
        
        //for item in currentFilepoint!.filepoints
        for item in childPointsAndLabels
        {
            let label = item
            let position = CGPointMake(CGFloat(item.filepoint!.x), CGFloat(item.filepoint!.y))
            label.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            label.center = CGPointMake(label.center.x + xVoidOffset,label.center.y + yVoidOffset)
        }

        centerScrollViewContents()
    }
    

    
    //NOTE: om man har lyst til å legge label rett på imageview. den vil da skaleres ned med resten av bildet.
    //lables kan ende opp med lite synlig text

    //Mark: UIResponder
    private var xOffset: CGFloat = 0.0
    private var yOffset: CGFloat = 0.0
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //var pointLabel = currentFileAndPoints.getLastAddedPointObj().originPointLabel
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        let touch = touches.first
        let pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        let touchLocation = touch!.locationInView(self.view)
        let isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            self.hideAddMenu()
            
            let point = (touches.first)!.locationInView(self.view)
            xOffset = point.x - pointLabel.center.x
            yOffset = point.y - pointLabel.center.y
            //pointLabel.transform = CGAffineTransformMakeRotation(10.0 * CGFloat(Float(M_PI)) / 180.0)
        }
        else
        {
            print("outside touchesBegan")
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        let touch = touches.first
        let touchLocation = touch!.locationInView(self.view)
        let pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        let isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        if(isInnView)
        {
            let pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
            let point = (touches.first)!.locationInView(self.view) //touches.anyObject()!.locationInView(self.view)
            pointLabel.center = CGPointMake(point.x - xOffset, point.y - yOffset)
        }
        else
        {
            print("outside touchmoved")
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //var pointLabel = currentFileAndPoints.getLastAddedPointObj().originPointLabel
        //get last added label
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        let pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        
        self.touchesMoved(touches, withEvent: event)

        let touch = touches.first
        let touchLocation = touch!.locationInView(self.view)
        let isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            //remove label from buttonbar over to overviewImageView, witch is out scrollwindow
            pointLabel.removeFromSuperview()
            pointLabel.center = CGPointMake(pointLabel.center.x + overviewScrollView.contentOffset.x, pointLabel.center.y + overviewScrollView.contentOffset.y - topNavigationBar.frame.height)
            pointLabel.alpha = 0.75
            //test
            pointLabel.layer.cornerRadius = 8.0
            pointLabel.clipsToBounds = true
            //test end
            overviewImageView.addSubview(pointLabel)
            
            var realPosition = CGPointMake(pointLabel.center.x / overviewScrollView.zoomScale, pointLabel.center.y / overviewScrollView.zoomScale)
            let yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
            let xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
            realPosition = CGPointMake(realPosition.x - (xVoidOffset/overviewScrollView.zoomScale), realPosition.y - (yVoidOffset/overviewScrollView.zoomScale))
            
            let newfilepointItem = Filepoint.createInManagedObjectContext(self.managedObjectContext!,title:"", x: Float(realPosition.x), y: Float(realPosition.y))

            save()
            childPointsAndLabels[childPointsAndLabels.count - 1].filepoint = newfilepointItem
            print("x og y for pointLabel is \(pointLabel.center.x) \(pointLabel.center.y)")
            print("x and y values in newfilepointItem are  \(newfilepointItem.x) \(newfilepointItem.y)")
            
            pointLabel.removeFromSuperview()
            
            overviewScrollView.addSubview(pointLabel)
            
            addPointButton.enabled = true
            addPointButton.alpha = 1
        }
        else
        {
            print("outside touchended")
        }
    }
    
    
    //MARK: CameraViewProtocol and UIImagePickerDelegate
    
    func initPickerView()
    {
        picker = UIImagePickerController()
        picker.providesPresentationContextTransitionStyle = true
        picker.definesPresentationContext = true
        picker.delegate = self
        picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
    }
    
    func cancelImageFromCamera()
    {
        cameraView.removeFromSuperview()
    }
    
    func savePictureFromCamera(imageData:NSData?, saveAsNewInstance:Bool, worktype:workType)
    {
        if(imageData != nil)
        {
            if saveAsNewInstance
            {
                addImageToCurrentFilepointOrProject(imageData!,sourceText: "From camera",worktype: worktype)
            }
            else
            {
                addImageToNewFilepoint(imageData!,sourceText: "From camera", worktype:worktype)
            }
        }
        else
        {
            print("imagedata is nil")
        }
        cameraView.removeFromSuperview()
    }
    
    var saveImageFromLibraryAsNewInstance = false
    var saveImageFromLibraryAsWorktype:workType = workType.arbeid
    func chooseImageFromPhotoLibrary(saveAsNewInstance:Bool, worktype:workType)
    {
        saveImageFromLibraryAsWorktype = worktype
        saveImageFromLibraryAsNewInstance = saveAsNewInstance
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        cameraView.removeFromSuperview()
    }
    
    func addImageToNewFilepoint(imageData:NSData, sourceText:String, worktype:workType)
    {
        // Update the array containing the table view row data
        let pointObj = newFilepoint
        
        //NOTE: we do not add a completly new entity , only picture . Entity is created earlier at addPoint action

        let newfilepointItem = pointObj!.filepoint
        
        print("newfilepointItem id \(newfilepointItem!.objectID)")

        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        let newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"\(sourceText) \(timestamp)",file:imageData, tags:nil, worktype:worktype)
        newfilepointItem!.addImagefile(newImagefileItem)
        newfilepointItem?.status = Int16(worktype.rawValue)
        newfilepointItem?.title = newFilepointTitle
        newFilepointTitle = ""
        self.currentImagefile?.addFilepoint(newfilepointItem!)
        self.save()

        //remove image and pointlabels before we set new current obj
        self.removeImageAndPointLabels()
        self.currentFilepoint = newfilepointItem
        self.setFileLevel()
        
        self.backOneLevelButton.alpha = 1.0
        self.backOneLevelButton.enabled = true
        newFilepoint = nil
    }
    
    func addImageToCurrentFilepointOrProject(imageData:NSData, sourceText:String, worktype:workType)
    {
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        let newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"\(sourceText) \(timestamp)",file:imageData, tags:nil, worktype:worktype)
        if currentFilepoint != nil{
            let sort = currentFilepoint!.getSort()
            newImagefileItem.setNewSort(sort)
            currentFilepoint!.lockImageFiles()
            currentFilepoint!.addImagefile(newImagefileItem)
            currentFilepoint!.status = Int16(worktype.rawValue)
        }
        else
        {
            let sort = project!.getSort()
            newImagefileItem.setNewSort(sort)
            project!.lockImageFiles()
            project!.addImagefile(newImagefileItem)
            project!.status = Int16(worktype.rawValue)
        }

        self.save()
        
        //remove image and pointlabels before we set new current obj
        self.removeImageAndPointLabels()
        self.currentImagefile = newImagefileItem
        self.setFileLevel()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismissViewControllerAnimated(true, completion: nil)
        let imageData =  UIImageJPEGRepresentation(image,1.0)
        if saveImageFromLibraryAsNewInstance
        {
            addImageToCurrentFilepointOrProject(imageData!,sourceText: "From picture library",worktype:saveImageFromLibraryAsWorktype)
        }
        else
        {
            addImageToNewFilepoint(imageData!,sourceText: "From picture library",worktype:saveImageFromLibraryAsWorktype)
        }
        saveImageFromLibraryAsNewInstance = false
        cameraView.removeFromSuperview()
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepointList") {
            let svc = segue!.destinationViewController as! FilepointListViewController
            svc.imagefile = currentImagefile
            
        }
        else if (segue.identifier == "showTreeView") {
            let svc = segue!.destinationViewController as! TreeViewController
            svc.passingFilepoint = currentFilepoint
            svc.pdfImages = self.pdfImages

        }
        else if (segue.identifier == "showProjectInMap") {
            let svc = segue!.destinationViewController as! MapOverviewViewController
            svc.project = project

        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}