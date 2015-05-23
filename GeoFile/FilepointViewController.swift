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

class FilepointViewController: CustomViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, DrawViewProtocol, CameraProtocol, TopNavigationViewProtocol{

    
    var currentFilepoint: Filepoint?
    var currentImagefile: Imagefile?
    //just because we ned temporary coordinates for a label associated with a filepoint
    var childPointsAndLabels = [PointElement]()
    
    var project:Project?
    var frontPicture: Bool = false
    var overviewImageView: FilepointView2!
    var filepointImageView: UIImageView!
    var overviewScrollView: UIScrollView!
    var drawView:DrawView!
    var addPointButton: CustomButton!
    var addDrawButton:CustomButton!
    var messageButton:CustomButton!
    
    var backOneLevelButton: CustomButton!
    var addButton:CustomButton!
    var hideAddMenuButton:CustomButton!

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var imagefileItems = [Imagefile]()

    var addPictureButton: CustomButton!
    
    var oneLevelFromProject = false
    
    var imageInstances:[ImageInstanceWithIcon]?
    var imageInstancesScrollView:UIScrollView!
    
    
    var picker:UIImagePickerController!
    var cameraView:CameraView!
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
        addPointButton.setTitle("Add point→", forState: .Normal)
        addPointButton.addTarget(self, action: "addPoint", forControlEvents: .TouchUpInside)
        addPointButton.hidden = true
        
        addPictureButton = CustomButton(frame: CGRectMake(elementMargin, addPointButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        addPictureButton.setTitle("Add picture→", forState: .Normal)
        addPictureButton.addTarget(self, action: "addPicture", forControlEvents: .TouchUpInside)
        addPictureButton.hidden = true
        
        addDrawButton = CustomButton(frame: CGRectMake(elementMargin, addPictureButton.frame.minY - elementMargin - buttonIconSide, buttonIconSide * 3, buttonIconSide))
        addDrawButton.setTitle("Add drawing→", forState: .Normal)
        addDrawButton.addTarget(self, action: "draw", forControlEvents: .TouchUpInside)
        addDrawButton.hidden = true

        backOneLevelButton = CustomButton(frame: CGRectMake(addButton.frame.maxX + elementMargin, UIScreen.mainScreen().bounds.size.height - buttonIconSide - elementMargin, buttonIconSide * 2, buttonIconSide))
        backOneLevelButton.setTitle("🔙", forState: .Normal)
        backOneLevelButton.addTarget(self, action: "goBackOneLevel", forControlEvents: .TouchUpInside)
        

        let strechedHeight = UIScreen.mainScreen().bounds.size.height - (topNavigationBar.frame.size.height)
        overviewScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight))
        overviewScrollView.backgroundColor = UIColor.blackColor()
        //!!! overviewScrollView.autoresizesSubviews = false
        drawView = DrawView(frame: overviewScrollView.frame)


        self.view.addSubview(overviewScrollView)
        self.view.addSubview(drawView)

        self.view.addSubview(addDrawButton)
        self.view.addSubview(addPointButton)
        self.view.addSubview(addPictureButton)
        
        
        self.view.addSubview(addButton)
        self.view.addSubview(hideAddMenuButton)
        self.view.addSubview(backOneLevelButton)

        // Reduce the total height by 20 points for the status bar, and 44 points for the bottom button
        viewFrame.size.height -= (addPointButton.frame.size.height)

        self.fetchImagefilesOnSameLevel()
        if(project != nil)
        {
            backOneLevelButton.enabled = false
            backOneLevelButton.alpha = 0.5
            currentImagefile = project?.firstImagefile
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
    
    
    func cleanChildPointsAndLabelsList()
    {
        childPointsAndLabels = []
    }
    
    func fillChildPointsAndLabels()
    {
        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0

        var count = 0
        //for item in childFilepointItems
        for item in currentImagefile!.filepoints
        {
            count++
            let testExtraSize:CGFloat = 100
            var point = PointElement(frame: CGRectMake(addPointButton.frame.maxX + 2 - (testExtraSize / 2), addPointButton.frame.minY - (testExtraSize / 2), buttonIconSide + testExtraSize, buttonIconSide + testExtraSize), icon:"💠",filepoint:item as? Filepoint)

            var tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
            tapRecognizer.numberOfTapsRequired = 1
            point.addGestureRecognizer(tapRecognizer)

            var position = CGPointMake(CGFloat((item as Filepoint).x), CGFloat((item as Filepoint).y))
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
            println("number of files in project \(project?.imagefiles.count)")
            for item in project!.imagefiles
            {
                imagefileItems.append(item as Imagefile)
            }
        }
        else
        {
            println("number of filepoints on filepoint \(currentFilepoint!.filepoints.count)")
            for item in currentFilepoint!.imagefiles
            {
                imagefileItems.append(item as Imagefile)
            }
        }
    }

    
    func fetchDrawings()
    {
        
    }

    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
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
        var image = UIImage(data: currentImagefile!.file)
        filepointImageView = UIImageView(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
        filepointImageView.image = image
        overviewImageView = FilepointView2(imagefile: currentImagefile!)
        overviewImageView.backgroundColor = UIColor.clearColor()
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

        for filepointAndLabel in childPointsAndLabels
        {
            var point = filepointAndLabel

            var position = CGPointMake(CGFloat(filepointAndLabel.filepoint!.x), CGFloat(filepointAndLabel.filepoint!.y))
            point.center = CGPointMake(position.x * overviewScrollView.zoomScale,position.y * overviewScrollView.zoomScale)
            point.center = CGPointMake(point.center.x + xVoidOffset,point.center.y + yVoidOffset)
            
            println("overviewScrollView.zoomScale : x \(overviewScrollView.zoomScale)")
            println("pointLabel recalculated values : x \(point.center.x) y \(point.center.y)")
            
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
                let imageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imagefile as Imagefile)
                imageInstances?.append(imageView)
            }
        }
        else if currentFilepoint?.imagefiles.count > 1
        {
            for imagefile in currentFilepoint!.imagefiles
            {
                let imageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imagefile as Imagefile)
                imageInstances?.append(imageView)
            }
        }
        addImageInstancesAsIcons()

    }
    

    func addImageInstancesAsIcons()
    {
        if imageInstances?.count > 0
        {

            var current:ImageInstanceWithIcon!
            var index:CGFloat = 1
            for imageView in imageInstances!
            {
                imageView.transform = CGAffineTransformIdentity
                imageView.transform = CGAffineTransformScale(imageView.transform, 0.5, 0.5)
                if imageView.imagefile == currentImagefile
                {
                    current = imageView
                    imageView.center = CGPointMake(backOneLevelButton.frame.maxX + imageinstanceSideSmall + CGFloat(imageInstances!.count * 10) - CGFloat(imageInstances!.count * 10) , backOneLevelButton.center.y - CGFloat(imageInstances!.count * 2))

                    var tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesSmallTapped:")
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
                        index++

                    }

                }, completion: { (value: Bool) in

                    var index:CGFloat = 0
                    for imageView in self.imageInstances!
                    {
                        imageView.transform = CGAffineTransformIdentity
                        imageView.center = CGPointMake((imageView.frame.width / 2) + (index * imageinstanceSideBig), imageView.frame.height / 2)
                        index++

                        var tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesBigTapped:")
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
        addDrawButton.hidden = false
        addPointButton.hidden = false
        addPictureButton.hidden = false
        hideAddMenuButton.hidden = false
        
        addPointButton.transform = CGAffineTransformScale(addPointButton.transform, 0.2, 0.2)
        addPictureButton.transform = CGAffineTransformScale(addPictureButton.transform, 0.2, 0.2)
        addDrawButton.transform = CGAffineTransformScale(addDrawButton.transform, 0.2, 0.2)
        
        let orgPosAddPointButton = addPointButton.center
        let orgPosAddPictureButton = addPictureButton.center
        let orgPosAddDrawButton = addDrawButton.center
        
        addPointButton.center = addButton.center
        addPictureButton.center = addButton.center
        addDrawButton.center = addButton.center
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.addPointButton.transform = CGAffineTransformIdentity
            self.addPictureButton.transform = CGAffineTransformIdentity
            self.addDrawButton.transform = CGAffineTransformIdentity
            
            self.addPointButton.center = orgPosAddPointButton
            self.addPictureButton.center = orgPosAddPictureButton
            self.addDrawButton.center = orgPosAddDrawButton
        })
    }
    
    func hideAddMenu()
    {
        let orgPosAddPointButton = addPointButton.center
        let orgPosAddPictureButton = addPictureButton.center
        let orgPosAddDrawButton = addDrawButton.center
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.addPointButton.center = self.addButton.center
            self.addPictureButton.center = self.addButton.center
            self.addDrawButton.center = self.addButton.center
            self.addPointButton.transform = CGAffineTransformScale(self.addPointButton.transform, 0.2, 0.2)
            self.addPictureButton.transform = CGAffineTransformScale(self.addPictureButton.transform, 0.2, 0.2)
            self.addDrawButton.transform = CGAffineTransformScale(self.addDrawButton.transform, 0.2, 0.2)
            }, completion: { (value: Bool) in
                self.addDrawButton.hidden = true
                self.addPointButton.hidden = true
                self.addPictureButton.hidden = true
                self.hideAddMenuButton.hidden = true
                self.addPointButton.center = orgPosAddPointButton
                self.addPictureButton.center = orgPosAddPictureButton
                self.addDrawButton.center = orgPosAddDrawButton
        })
    }

    func addPicture()
    {
        hideAddMenu()
        var image = UIImage(data: currentImagefile!.file)
        cameraView = CameraView(frame: self.view.frame, image:image!,showtypes:true)
        cameraView.delegate = self
        self.view.addSubview(cameraView)
    }
    
    func addPoint()
    {
        addPointButton.enabled = false
        addPointButton.alpha = 0.5

        let testExtraSize:CGFloat = 100
        var point = PointElement(frame: CGRectMake(addPointButton.frame.maxX + 2 - (testExtraSize / 2), addPointButton.frame.minY - (testExtraSize / 2), buttonIconSide + testExtraSize, buttonIconSide + testExtraSize), icon:"💢",filepoint:nil)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
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
        var pointTapped =  sender.view as PointElement
        var filepointToNavigateTowards = pointTapped.filepoint
        
        if(filepointToNavigateTowards != nil && filepointToNavigateTowards!.imagefiles.count > 0)
        {
            var image = UIImage(data: filepointToNavigateTowards!.file!)
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
                    self.currentFilepoint = filepointToNavigateTowards
                    self.project = nil
                    self.currentImagefile = self.currentFilepoint!.firstImagefile
                    println("new imagefile id \(self.currentImagefile!.objectID)")
                       self.backOneLevelButton.alpha = 1.0
                    self.backOneLevelButton.enabled = true
                    self.setFileLevel()
            })
        }
        else
        {
            
            var titlePrompt = UIAlertController(title: "Title for new point",
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
                    self.newFilepointTitle = titleTextField!.text
            }))

            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)
            
            newFilepoint = pointTapped
            cameraView = CameraView(frame: self.view.frame, image:nil, showtypes:true)
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
        addImageInstancesAsIcons()
        imageInstancesScrollView.removeFromSuperview()
        var imageinstance = sender.view as ImageInstanceWithIcon
        self.removeImageAndPointLabels()
        currentImagefile = imageinstance.imagefile
        self.setFileLevel()
    }
    
    func goBackOneLevel()
    {
        var image = UIImage(data: currentImagefile!.file)
        
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
        
        var imageViewForAnimation = UIImageView(frame: self.overviewImageView.frame)
        imageViewForAnimation.frame.offset(dx: 0, dy: self.overviewScrollView.frame.minY)
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
        var numberPrompt = UIAlertController(title: "Enter",
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
        var textPrompt = UIAlertController(title: "Enter",
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
        var numberPrompt = UIAlertController(title: "Enter",
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
    //MARK: Draw
    func draw()
    {
        for item in childPointsAndLabels
        {
            item.0.hidden = true
        }

        drawView.delegate = self
        drawView.setImage(makeImage(self.overviewScrollView,xOffset: overviewScrollView.contentOffset.x, yOffset: overviewScrollView.contentOffset.y))
        drawView.setZoomscale(overviewScrollView.zoomScale)
        drawView.showButtons()
        drawView.resetDrawingValues()
        drawView.hidden = false
        
        addButton.hidden = true
        addPointButton.hidden = true
        addPictureButton.hidden = true
        addDrawButton.hidden = true
        
        hideImageInstances()
        hideAddMenuButton.hidden = true
        backOneLevelButton.hidden = true
    }
    
    func cancelDraw()
    {
        drawView.hidden = true
        drawView.clear()

        backOneLevelButton.hidden = false
        hideImageInstances(hidden: false)
        addButton.hidden = false
        
        for item in childPointsAndLabels
        {
            item.0.hidden = false
        }
    }
    
    func saveDraw()
    {
        var yVoidOffset = overviewScrollView.contentOffset.y
        var xVoidOffset = overviewScrollView.contentOffset.x
        
       
        drawView.hideButtons()
        for line in drawView.lines
        {
            
            var start = CGPointMake((line.start.x + xVoidOffset) / overviewScrollView.zoomScale, (line.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            var end = CGPointMake((line.end.x + xVoidOffset) / overviewScrollView.zoomScale,
                (line.end.y + yVoidOffset) / overviewScrollView.zoomScale)

            var newLine = Drawingline.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,endPoint: end,color: line.color,lastTouchBegan: line.lastTouchBegan)
            currentImagefile!.addDrawingLine(newLine)
        }
        
        for measure in drawView.measures
        {
            
            var start = CGPointMake((measure.start.x + xVoidOffset) / overviewScrollView.zoomScale, (measure.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            var end = CGPointMake((measure.end.x + xVoidOffset) / overviewScrollView.zoomScale,
                (measure.end.y + yVoidOffset) / overviewScrollView.zoomScale)
            
            var newMeasure = Drawingmeasure.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,endPoint: end,color: measure.color,text: measure.getLabel().text!)
            currentImagefile!.addDrawingMeasure(newMeasure)
        }
        
        for angle in drawView.angles
        {
            
            var start = CGPointMake((angle.start.x + xVoidOffset) / overviewScrollView.zoomScale, (angle.start.y + yVoidOffset) / overviewScrollView.zoomScale)
            var mid = CGPointMake((angle.mid.x + xVoidOffset) / overviewScrollView.zoomScale,
                (angle.mid.y + yVoidOffset) / overviewScrollView.zoomScale)
            var end = CGPointMake((angle.end!.x + xVoidOffset) / overviewScrollView.zoomScale,
                (angle.end!.y + yVoidOffset) / overviewScrollView.zoomScale)
            var newAngle = Drawingangle.createInManagedObjectContext(self.managedObjectContext!,startPoint: start,midPoint: mid, endPoint: end, color: angle.color,text: angle.getLabel().text!)
            currentImagefile!.addDrawingAngle(newAngle)
        }
        
        for text in drawView.drawnTexts
        {
            var center = CGPointMake((text.label!.center.x + xVoidOffset) / overviewScrollView.zoomScale,
                (text.label!.center.y + yVoidOffset) / overviewScrollView.zoomScale)
            var newText = Drawingtext.createInManagedObjectContext(self.managedObjectContext!,centerPoint: center, color: text.color,text: text.label!.text!, size:Int(drawingTextPointSize))
            currentImagefile!.addDrawingText(newText)
        }
        
        save()
        overviewImageView.setNeedsDisplay()

        self.cancelDraw()
    }
    
    func makeImage(_view:UIView,xOffset:CGFloat = 0.0,yOffset:CGFloat = 0.0) -> UIImage {
        
        UIGraphicsBeginImageContext(drawView.bounds.size)

        var context = UIGraphicsGetCurrentContext()

        CGContextTranslateCTM(context, xOffset * -1, yOffset * -1)
        _view.layer.renderInContext(context)
        var viewImage = UIGraphicsGetImageFromCurrentImageContext()
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return overviewImageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView!) {

        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
        
        //for item in currentFilepoint!.filepoints
        for item in childPointsAndLabels
        {
            var label = item
            var position = CGPointMake(CGFloat(item.filepoint!.x), CGFloat(item.filepoint!.y))
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //var pointLabel = currentFileAndPoints.getLastAddedPointObj().originPointLabel
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        var touch = touches.anyObject()
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        var touchLocation = touch!.locationInView(self.view)
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            self.hideAddMenu()
            
            let point = touches.anyObject()!.locationInView(self.view)
            xOffset = point.x - pointLabel.center.x
            yOffset = point.y - pointLabel.center.y
            //pointLabel.transform = CGAffineTransformMakeRotation(10.0 * CGFloat(Float(M_PI)) / 180.0)
        }
        else
        {
            println("outside touchesBegan")
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        var touch = touches.anyObject()
        var touchLocation = touch!.locationInView(self.view)
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        if(isInnView)
        {
            var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
            let point = touches.anyObject()!.locationInView(self.view)
            pointLabel.center = CGPointMake(point.x - xOffset, point.y - yOffset)
        }
        else
        {
            println("outside touchmoved")
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        //var pointLabel = currentFileAndPoints.getLastAddedPointObj().originPointLabel
        //get last added label
        if(childPointsAndLabels.count <= 0)
        {
            return
        }
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1]
        
        self.touchesMoved(touches, withEvent: event)

        var touch = touches.anyObject()
        var touchLocation = touch!.locationInView(self.view)
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
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
            var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
            var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0
            realPosition = CGPointMake(realPosition.x - (xVoidOffset/overviewScrollView.zoomScale), realPosition.y - (yVoidOffset/overviewScrollView.zoomScale))
            
            var newfilepointItem = Filepoint.createInManagedObjectContext(self.managedObjectContext!,title:newFilepointTitle, x: Float(realPosition.x), y: Float(realPosition.y))
            newFilepointTitle = ""
            save()
            childPointsAndLabels[childPointsAndLabels.count - 1].filepoint = newfilepointItem
            println("x og y for pointLabel is \(pointLabel.center.x) \(pointLabel.center.y)")
            println("x and y values in newfilepointItem are  \(newfilepointItem.x) \(newfilepointItem.y)")
            
            pointLabel.removeFromSuperview()
            
            overviewScrollView.addSubview(pointLabel)
            
            addPointButton.enabled = true
            addPointButton.alpha = 1
        }
        else
        {
            println("outside touchended")
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
            println("imagedata is nil")
        }
        cameraView.removeFromSuperview()
    }
    
    var saveImageFromLibraryAsNewInstance = false
    var saveImageFromLibraryAsWorktype:workType = workType.info
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
        var pointObj = newFilepoint
        
        //NOTE: we do not add a completly new entity , only picture . Entity is created earlier at addPoint action

        var newfilepointItem = pointObj!.filepoint
        
        println("newfilepointItem id \(newfilepointItem!.objectID)")

        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        var newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"\(sourceText) \(timestamp)",file:imageData, tags:nil, worktype:worktype)
        newfilepointItem!.addImagefile(newImagefileItem)
        
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
        var newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"\(sourceText) \(timestamp)",file:imageData, tags:nil, worktype:worktype)
        if currentFilepoint != nil{
            currentFilepoint!.addImagefile(newImagefileItem)
        }
        else
        {
            project?.addImagefile(newImagefileItem)
        }

        self.save()
        
        //remove image and pointlabels before we set new current obj
        self.removeImageAndPointLabels()
        self.currentImagefile = newImagefileItem
        self.setFileLevel()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        dismissViewControllerAnimated(true, completion: nil)
        var imageData =  UIImageJPEGRepresentation(image,1.0) as NSData
        if saveImageFromLibraryAsNewInstance
        {
            addImageToCurrentFilepointOrProject(imageData,sourceText: "From picture library",worktype:saveImageFromLibraryAsWorktype)
        }
        else
        {
            addImageToNewFilepoint(imageData,sourceText: "From picture library",worktype:saveImageFromLibraryAsWorktype)
        }
        saveImageFromLibraryAsNewInstance = false
        cameraView.removeFromSuperview()
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepointList") {
            var svc = segue!.destinationViewController as FilepointListViewController
            svc.imagefile = currentImagefile
            
        }
        else if (segue.identifier == "showTreeView") {
            var svc = segue!.destinationViewController as TreeViewController
            svc.passingFilepoint = currentFilepoint
            svc.pdfImages = self.pdfImages

        }
        else if (segue.identifier == "showProjectInMap") {
            var svc = segue!.destinationViewController as MapOverviewViewController
            svc.project = project

        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}