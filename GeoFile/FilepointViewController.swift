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
    //just because we ned temporary coordinates for a label associated with a filepoint
    var childPointsAndLabels = [(UILabel,Filepoint?)]()
    
    var project:Project?
    var frontPicture: Bool = false
    var overviewImageView: UIImageView!
    var overviewScrollView: UIScrollView!
    var drawView:DrawView!
    var saveDrawButton:CustomButton!
    var cancelDrawButton:CustomButton!
    var addPointButton: CustomButton!
    var drawButton:CustomButton!
    var messageButton:CustomButton!
    //var topNavigationBar:TopNavigationView!
    var backOneLevelButton: CustomButton!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var sameLevelFilepointItems = [Filepoint]()
    
    
    var childFilepointItems = [Filepoint]()
    //var sameLevelFilepointsTableView = UITableView(frame: CGRectZero, style: .Plain)
    var addFileButton: CustomButton!
    
    var oneLevelFromProject = false
    
    
    var picker:UIImagePickerController!
    var cameraView:CameraView!
    //MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewFrame = self.view.frame
        

        initForCameraAndPickerView()
        
        /*
        topNavigationBar = TopNavigationView(frame:CGRectMake(0, 0 ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        topNavigationBar.delegate = self
        self.view.addSubview(topNavigationBar)
        */
        
        drawButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        drawButton.setTitle("Draw", forState: .Normal)
        drawButton.addTarget(self, action: "draw", forControlEvents: .TouchUpInside)
        
        messageButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        messageButton.setTitle("Add text", forState: .Normal)
        messageButton.addTarget(self, action: "draw", forControlEvents: .TouchUpInside)
        
        saveDrawButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        saveDrawButton.setTitle("Save", forState: .Normal)
        saveDrawButton.addTarget(self, action: "saveDraw", forControlEvents: .TouchUpInside)
        saveDrawButton.hidden = true
        
        cancelDrawButton = CustomButton(frame: CGRectMake(drawButton.frame.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        cancelDrawButton.setTitle("Cancel", forState: .Normal)
        cancelDrawButton.addTarget(self, action: "cancelDraw", forControlEvents: .TouchUpInside)
        cancelDrawButton.hidden = true
        
        addPointButton = CustomButton(frame: CGRectMake(drawButton.frame.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width * 0.5, buttonBarHeight))
        addPointButton.setTitle("Add point→", forState: .Normal)
        addPointButton.addTarget(self, action: "addPoint", forControlEvents: .TouchUpInside)

        addFileButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        addFileButton.setTitle("Add file", forState: .Normal)
        addFileButton.addTarget(self, action: "addFile", forControlEvents: .TouchUpInside)
        addFileButton.hidden = true
        
        backOneLevelButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        backOneLevelButton.setTitle("🔙", forState: .Normal)
        backOneLevelButton.addTarget(self, action: "goBackOneLevel", forControlEvents: .TouchUpInside)
        
        let strechedHeight = UIScreen.mainScreen().bounds.size.height - (addPointButton.frame.size.height + topNavigationBar.frame.size.height + backOneLevelButton.frame.size.height)
        overviewScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight))
        overviewScrollView.backgroundColor = UIColor.blackColor()
        //!!! overviewScrollView.autoresizesSubviews = false
        drawView = DrawView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight))

        self.view.addSubview(cancelDrawButton)
        self.view.addSubview(saveDrawButton)
        self.view.addSubview(drawButton)
        self.view.addSubview(addPointButton)
        self.view.addSubview(addFileButton)
        self.view.addSubview(backOneLevelButton)
        
        //filesTableView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2))
        /*
        sameLevelFilepointsTableView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, 0)
        self.view.addSubview(sameLevelFilepointsTableView)
        sameLevelFilepointsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        sameLevelFilepointsTableView.delegate = self
        sameLevelFilepointsTableView.dataSource = self
        */
        
        // Reduce the total height by 20 points for the status bar, and 44 points for the bottom button
        //viewFrame.size.height -= (self.tabBarController!.tabBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height + addPointButton.frame.size.height)
        viewFrame.size.height -= (addPointButton.frame.size.height)

        if(currentFilepoint == nil)
        {
            self.fetchFilepointsOnSameLevel()
            currentFilepoint = sameLevelFilepointItems[0]
        }
        if currentFilepoint!.parent == nil
        {
            backOneLevelButton.enabled = false
            backOneLevelButton.alpha = 0.5
        }
        self.fetchFilepointChildren()

        self.view.addSubview(overviewScrollView)
        self.view.addSubview(drawView)
        drawView.hidden = true

        self.setFileLevel()
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
    

    
    //MARK: CoreData
    func fetchFilepointsOnSameLevel() {

        sameLevelFilepointItems = []
        if(oneLevelFromProject)
        {
            println("number of files in project \(project?.filepoints.count)")
            for item in project!.filepoints
            {
                sameLevelFilepointItems.append(item as Filepoint)
            }
        }
        else
        {
            println("number of filepoints on filepoint \(currentFilepoint!.filepoints.count)")
            for item in currentFilepoint!.filepoints
            {
                sameLevelFilepointItems.append(item as Filepoint)
            }
        }
    }

    func fetchFilepointChildren() {

        childFilepointItems = []

        println("number of filepoints on filepoint \(currentFilepoint!.filepoints.count)")
        for item in currentFilepoint!.filepoints
        {
            childFilepointItems.append(item as Filepoint)
        }
    }

    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    func addFile()
    {
        
    }
    
    // MARK: UITableViewDataSource
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sameLevelFilepointItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell") as UITableViewCell
        
        // Get the LogItem for this index
        let fileItem = sameLevelFilepointItems[indexPath.row]
        
        cell.textLabel?.text = fileItem.title
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let fileItem = sameLevelFilepointItems[indexPath.row]
        
        //showFileListButton.enabled = true
        //showFileListButton.alpha = 1.0
        topNavigationBar.showForViewtype(.none)
        addFileButton.hidden = true
        addPointButton.hidden = false
        
        //TODO :animate shrinkage
        sameLevelFilepointsTableView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, 0)
        let strechedHeight = UIScreen.mainScreen().bounds.size.height - (addPointButton.frame.size.height + topNavigationBar.frame.size.height + backOneLevelButton.frame.size.height)
        overviewScrollView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight)

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            
        }
    }
    
    
    func deleteProjectAtIndex(indexPath: NSIndexPath)
    {

    }
    */

    //MARK: UIActions
    

    
    func removeImageAndPointLabels()
    {
        for label in childPointsAndLabels
        {
            label.0.removeFromSuperview()
        }

        overviewImageView.removeFromSuperview()
        self.cleanChildPointsAndLabelsList()
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

    func addPoint()
    {
        addPointButton.enabled = false
        addPointButton.alpha = 0.5
        addPointButton.frame = CGRectMake(addPointButton.frame.minX, addPointButton.frame.minY, (UIScreen.mainScreen().bounds.size.width * 0.5) * 0.7, addPointButton.frame.height)
        //addPointButton.frame.size.width = UIScreen.mainScreen().bounds.size.width * 0.7
        var pointLabel = UILabel(frame: CGRectMake(addPointButton.frame.maxX + 2, addPointButton.frame.minY, (UIScreen.mainScreen().bounds.size.width * 0.5) * 0.30, buttonBarHeight))

        pointLabel.text = "💢"
        pointLabel.textAlignment = NSTextAlignment.Center
        pointLabel.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        pointLabel.userInteractionEnabled = true
        pointLabel.tag =  currentFilepoint!.filepoints.count + 1
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
        tapRecognizer.numberOfTapsRequired = 1
        pointLabel.addGestureRecognizer(tapRecognizer)

        childPointsAndLabels.append((pointLabel,nil))
        self.view.addSubview(pointLabel)
    }
    var chooseFromCameraButton:UIButton!
    var currentTappedTag:Int = 0
    func pointTapped(sender:UITapGestureRecognizer)->Void
    {
        println("tag is \(sender.view!.tag)")
        currentTappedTag = sender.view!.tag
        var pointObj = self.findPointLabelOnTag(currentTappedTag)
        
        if(pointObj!.1!.file? != nil)
        {
            //println("currentFilepoint objID \(currentFilepoint?.objectID) with \(currentFilepoint?.filepoints.count) filepoints")
            //println("changing to filepoint objID \(pointObj!.1!.objectID) with \(pointObj!.1!.filepoints.count) filepoints")
            
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
        self.view.addSubview(imageViewForAnimation)
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            //self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 20)
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
        drawView.showButtons()
        drawView.resetDrawingValues()
        drawView.hidden = false
        
        addPointButton.hidden = true
        cancelDrawButton.hidden = false
        drawButton.hidden = true
        saveDrawButton.hidden = false

    }
    
    func cancelDraw()
    {
        
        drawView.hidden = true
        drawView.clear()
        

        addPointButton.hidden = false
        cancelDrawButton.hidden = true
        drawButton.hidden = false
        saveDrawButton.hidden = true
        for item in childPointsAndLabels
        {
            item.0.hidden = false
        }
    }
    
    func saveDraw()
    {
        //var currentZoomScale = overviewScrollView.zoomScale
        //overviewScrollView.zoomScale = 1.0
        drawView.hideButtons()
        var imagepartToSave = makeImage(drawView)
        //overviewImageView.image = imagepartToSave
        var yVoidOffset = overviewImageView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - overviewImageView.frame.height)/2 : 0.0
        var xVoidOffset = overviewImageView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - overviewImageView.frame.width)/2 : 0.0

        var source = overviewImageView.image
        var size = source!.size
        UIGraphicsBeginImageContext(size)
        var rect = CGRectMake(0, 0, size.width, size.height)
        //source?.drawInRect(rect, blendMode:kCGBlendModeNormal, alpha:1.0)
        source?.drawInRect(rect)


        imagepartToSave.drawInRect(CGRectMake(
            (overviewScrollView.contentOffset.x - xVoidOffset) / overviewScrollView.zoomScale,
            (overviewScrollView.contentOffset.y - yVoidOffset) / overviewScrollView.zoomScale ,
            imagepartToSave.size.width / overviewScrollView.zoomScale,
            imagepartToSave.size.height / overviewScrollView.zoomScale))
        
        var context = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetLineWidth(context, 0.0);
        CGContextStrokeRect(context, rect);
        var testImg =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        overviewImageView.image = testImg
        
        var imageData =  UIImageJPEGRepresentation(testImg,1.0) as NSData
        currentFilepoint?.file = imageData
        save()
        //end test
        
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
            var label = item.0
            var position = CGPointMake(CGFloat(item.1!.x), CGFloat(item.1!.y))
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
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1].0
        var touchLocation = touch!.locationInView(self.view)
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            println("inside touchesBegan")
            
            let point = touches.anyObject()!.locationInView(self.view)
            xOffset = point.x - pointLabel.center.x
            yOffset = point.y - pointLabel.center.y
            pointLabel.transform = CGAffineTransformMakeRotation(10.0 * CGFloat(Float(M_PI)) / 180.0)
            
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
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1].0
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            println("inside touchmoved")
            var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1].0
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
        var pointLabel = childPointsAndLabels[childPointsAndLabels.count - 1].0
        
        self.touchesMoved(touches, withEvent: event)

        var touch = touches.anyObject()
        var touchLocation = touch!.locationInView(self.view)
        var isInnView = CGRectContainsPoint(pointLabel.frame,touchLocation)
        
        //if( (touches.anyObject() as UILabel) == pointLabel )
        if(isInnView)
        {
            println("inside touchended")
            //remove label from buttonbar over to overviewImageView, witch is out scrollwindow
            pointLabel.removeFromSuperview()
            pointLabel.transform = CGAffineTransformMakeRotation(0.0 * CGFloat(Float(M_PI)) / 180.0)
            pointLabel.center = CGPointMake(pointLabel.center.x + overviewScrollView.contentOffset.x, pointLabel.center.y + overviewScrollView.contentOffset.y - (pointLabel.frame.size.height))
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
            
            var newfilepointItem = Filepoint.createInManagedObjectContext(self.managedObjectContext!,title:"filepoint title",file:nil, x: Float(realPosition.x), y: Float(realPosition.y))
            save()
            childPointsAndLabels[childPointsAndLabels.count - 1].1 = newfilepointItem
            println("object id for added filepoint is \(newfilepointItem.objectID)")
            println("x and y values are  \(newfilepointItem.x) \(newfilepointItem.y)")
            
            pointLabel.removeFromSuperview()
            
            overviewScrollView.addSubview(pointLabel)
            
            addPointButton.enabled = true
            addPointButton.alpha = 1
            addPointButton.frame.size.width = UIScreen.mainScreen().bounds.size.width * 0.5
        }
        else
        {
            println("outside touchended")
        }
    }
    
    
    //MARK: CameraViewProtocol and UIImagePickerDelegate
    
    func initForCameraAndPickerView()
    {
        cameraView = CameraView(frame: self.view.frame)
        cameraView.delegate = self
        
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
    
    func savePictureFromCamera(imageData:NSData?)
    {
        if(imageData != nil)
        {
            println("imagedata is not")
            //_? why are we doing both
            //var newFileItem = Filepoint.createInManagedObjectContext(self.managedObjectContext!,title: "a filepoint title", file: imageData!, project: project)
            addImageToFileObject(imageData!)
        }
        else
        {
            println("imagedata is nil")
        }
        cameraView.removeFromSuperview()
    }
    
    func chooseImageFromPhotoLibrary()
    {
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        cameraView.removeFromSuperview()
    }
    
    func addImageToFileObject(imageData:NSData)
    {
        // Update the array containing the table view row data
        var pointObj = self.findPointLabelOnTag(self.currentTappedTag)
        var pointLabel = pointObj!.0
        
        //NOTE: we do not add a completly new entity , only picture . Entity is created earlier at addPoint action
        var newfilepointItem = pointObj!.1
        println("trying to set image for filepoint with objID \(newfilepointItem!.objectID)")
        println("x and y values are  \(newfilepointItem!.x) \(newfilepointItem!.y)")
        newfilepointItem?.file = imageData
        
        self.currentFilepoint?.addFilepointToFilepoint(newfilepointItem!)
        self.save()

        //remove image and pointlabels before we set new current obj
        self.removeImageAndPointLabels()
        self.currentFilepoint = newfilepointItem
        self.setFileLevel()
        
        self.backOneLevelButton.alpha = 1.0
        self.backOneLevelButton.enabled = true
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        dismissViewControllerAnimated(true, completion: nil)
        var imageData =  UIImageJPEGRepresentation(image,1.0) as NSData
        addImageToFileObject(imageData)
        cameraView.removeFromSuperview()
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
    

    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepointList") {
            var svc = segue!.destinationViewController as FilepointListViewController
            svc.filepoint = currentFilepoint
            
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