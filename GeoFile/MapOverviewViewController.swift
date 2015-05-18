//
//  ViewController.swift
//  GeoFile
//
//  Created by knut on 23/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import MobileCoreServices


class MapOverviewViewController: CustomViewController, GMSMapViewDelegate, NewProjectProtocol, UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate, CameraProtocol,UIGestureRecognizerDelegate, SetOverlayButtonsProtocol{
    

    var gmaps: GMSMapView?
    var project: Project?
    //var topNavigationBar:TopNavigationView!
    var addProjectButton:CustomButton!
    var saveEditProjectButton:CustomButton!
    var newProjectView:NewProjectView?
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var projectItems = [Project]()
    
    var editProject = false
    var editProjectAtIndex:Int = -1

    var locationManager:CLLocationManager!
    var geocoder:CLGeocoder!
    var placemark:CLPlacemark!
    
    var localAddressText:String!
    var localAddressSet:Bool = false
    
    var newProjectTitle:String!
    var currentLocation:CLLocation!
    
    var picker:UIImagePickerController!
    var cameraView:CameraView!
    var initialTarget:CLLocationCoordinate2D?
    //MARK:

    var newOverlayToSet:UIImageView!
    var overlayButtons:SetOverlayButtons!
    
    var setOverlayButton:CustomButton!
    var cancelOverlayButton:CustomButton!
    


    

    var overlayToSet:Overlay?

    override func viewDidLoad() {
        super.viewDidLoad()

        initForCameraAndPickerView()

        initialTarget = project != nil ? CLLocationCoordinate2D(latitude: project!.latitude, longitude: project!.longitude) : nil
        var target: CLLocationCoordinate2D = initialTarget ?? CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75)
        var camera = GMSCameraPosition(target: target, zoom: 10, bearing: 0, viewingAngle: 0)
        
        
        self.view.backgroundColor = UIColor.whiteColor()

        topNavigationBar.showForViewtype(.map)
        
        addProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        addProjectButton.setTitle("Add project", forState: .Normal)
        addProjectButton.addTarget(self, action: "addNewProject", forControlEvents: .TouchUpInside)
        self.view.addSubview(addProjectButton)

        saveEditProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveEditProjectButton.setTitle("Save", forState: .Normal)
        saveEditProjectButton.addTarget(self, action: "saveEditProject", forControlEvents: .TouchUpInside)

        gmaps = GMSMapView(frame: CGRectMake(0, buttonBarHeight , self.view.bounds.width,
            self.view.bounds.height - (buttonBarHeight*2)))
        
        if let map = gmaps? {
            map.myLocationEnabled = true
            map.camera = camera
            map.delegate = self
            
            self.view.addSubview(gmaps!)
        }
        
        
        

        if let overlay = overlayToSet
        {
            setNewOverlay(overlay)
        }

        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        geocoder = CLGeocoder()
        fetchProjects()
        
        printTestDatastructure()
        
        fetchOverlays()
        
        setMarkers(editProject,atIndex: editProjectAtIndex)
    }
    
    func setNewOverlay(overlay:Overlay)
    {
        var image = UIImage(data: overlay.file)
        //var scaleFactor = image!.size.width / UIScreen.mainScreen().bounds.size.width
        //newOverlayToSet = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, image!.size.height / scaleFactor))
        newOverlayToSet = UIImageView(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
        
        println("sizes should match \(image!.size.width) \(image!.size.height) and \(newOverlayToSet.frame.width) \(newOverlayToSet.frame.height)")
        newOverlayToSet.center = gmaps!.center
        newOverlayToSet.alpha = 0.5
        newOverlayToSet.image = image
        newOverlayToSet.userInteractionEnabled = true
        newOverlayToSet.multipleTouchEnabled = true
        newOverlayToSet.contentMode = UIViewContentMode.ScaleToFill
        var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "scaleImage:")
        pinchRecognizer.delegate = self
        newOverlayToSet.addGestureRecognizer(pinchRecognizer)
        var rotationRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateImage:")
        rotationRecognizer.delegate = self
        newOverlayToSet.addGestureRecognizer(rotationRecognizer)
        
        gmaps?.settings.scrollGestures = false
        gmaps?.settings.zoomGestures = false
        gmaps?.settings.rotateGestures = false

        
        overlayButtons = SetOverlayButtons(view: gmaps!, overlay:newOverlayToSet)
        overlayButtons.delegate = self

        
        gmaps?.addSubview(newOverlayToSet)
        

        
        
        setOverlayButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight  ,UIScreen.mainScreen().bounds.size.width / 2, buttonBarHeight))
        setOverlayButton.setTitle("Set overlay", forState: .Normal)
        setOverlayButton.addTarget(self, action: "setOverlay", forControlEvents: .TouchUpInside)
        self.view.addSubview(setOverlayButton)
        
        cancelOverlayButton = CustomButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height - buttonBarHeight  ,UIScreen.mainScreen().bounds.size.width / 2, buttonBarHeight))
        cancelOverlayButton.setTitle("Cancel", forState: .Normal)
        cancelOverlayButton.addTarget(self, action: "cancelOverlay", forControlEvents: .TouchUpInside)
        self.view.addSubview(cancelOverlayButton)
    }
    

    
    var touchLocationFromCenterInOverlay:CGPoint!
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject()
        //var theImageView = touch?.view
        if let ovview = newOverlayToSet
        {
            touchLocationFromCenterInOverlay = touch!.locationInView(ovview)
            touchLocationFromCenterInOverlay = CGPointMake(touchLocationFromCenterInOverlay.x - (ovview.frame.width / 2) , touchLocationFromCenterInOverlay.y - (ovview.frame.height / 2))
            println("sizes \(newOverlayToSet.frame.width) \(newOverlayToSet.frame.height) and positions \(touchLocationFromCenterInOverlay.x) \(touchLocationFromCenterInOverlay.y)")
        }
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        
        var touch = touches.anyObject()
        //var theImageView = touch?.view
        if let view = newOverlayToSet
        {
            var touchLocation = touch!.locationInView(self.gmaps)
            view.center = CGPointMake(touchLocation.x - touchLocationFromCenterInOverlay.x, touchLocation.y - touchLocationFromCenterInOverlay.y)
        }
    }

    
    func cancelOverlay()
    {
        overlayButtons.cancelOverlay()
        
        cancelOverlayButton.removeFromSuperview()
        setOverlayButton.removeFromSuperview()
        newOverlayToSet.removeFromSuperview()
        
        //gmaps?.settings.scrollGestures = true
        //gmaps?.settings.zoomGestures = true
        //gmaps?.settings.rotateGestures = true
    }
    
    func setOverlay()
    {
        
        let radians = atan2( newOverlayToSet.transform.b, newOverlayToSet.transform.a)
        let degrees = radians * (180 / CGFloat(M_PI) )
        newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, radians * -1)


        newOverlayToSet.transform = CGAffineTransformIdentity
        /*
        var currentTransform = newOverlayToSet.transform
        var currentTransformScale = newOverlayToSet.transform
        newOverlayToSet.transform = CGAffineTransformIdentity
        var originalFrame = newOverlayToSet.frame
        */
        
        var northEast = gmaps!.projection.coordinateForPoint(CGPointMake(newOverlayToSet.frame.minX, newOverlayToSet.frame.minY))
        var southWest = gmaps!.projection.coordinateForPoint(CGPointMake(newOverlayToSet.frame.maxX, newOverlayToSet.frame.maxY))

        //let degrees = CGFloat(gmaps!.camera.bearing) * (180 / CGFloat(M_PI) )
        
        var overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)

        if let newOverlayOnMap = overlayToSet
        {
            var icon = UIImage(data: newOverlayOnMap.file)
            icon = imageResize(icon!, newOverlayToSet.frame.size)
            
            var overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
            //var overlay = GMSGroundOverlay(position: southWest, icon: icon, zoomLevel: 0)
            
            //gmaps!.clear()
            overlay.bearing = CLLocationDirection(degrees) //360.0 - gmaps!.camera.bearing  //CLLocationDirection(degrees)
            overlay.map = gmaps
            
            newOverlayOnMap.active = 1
            newOverlayOnMap.bearing = overlay.bearing
            newOverlayOnMap.latitudeSW = southWest.latitude
            newOverlayOnMap.longitudeSW = southWest.longitude
            newOverlayOnMap.latitudeNE = northEast.latitude
            newOverlayOnMap.longitudeNE = northEast.longitude
            save()
        }
        cancelOverlay()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    enum PinchAxis{
    case PinchAxisNone,PinchAxisHorizontal,PinchAxisVertical
    }
    
    func pinchGestureRecognizerAxis(r:UIPinchGestureRecognizer) ->  PinchAxis
    {
        if(r.numberOfTouches() == 2 )
        {
            var view = r.view;
            var touch0 = r.locationOfTouch(0, inView: view) //[r locationOfTouch:0 inView:view];
            var touch1 = r.locationOfTouch(1, inView: view)
            var tangent = fabsf( Float(touch1.y - touch0.y) / Float(touch1.x - touch0.x) )
            return tangent <= 0.2679491924 ? PinchAxis.PinchAxisHorizontal // 15 degrees
            : (tangent >= 3.7320508076 ? PinchAxis.PinchAxisVertical   // 75 degrees
            : PinchAxis.PinchAxisNone)
        }
        else
        {
            return PinchAxis.PinchAxisNone
        }
    }
    
    func scaleImage(sender: UIPinchGestureRecognizer) {
        if(canResize){
            
            let radians = atan2( newOverlayToSet.transform.b, newOverlayToSet.transform.a)
            let degrees = radians * (180 / CGFloat(M_PI) )
            newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, radians * -1)
            
            var view = sender.view
            var axis = pinchGestureRecognizerAxis(sender)
            switch(axis)
            {
            case .PinchAxisHorizontal:
                var center = view!.center
                view!.frame.size = CGSizeMake(view!.frame.size.width * sender.scale, view!.frame.size.height)//.width = view!.frame.width * sender.scale
                view!.center = center
                //view!.transform = CGAffineTransformScale(view!.transform, sender.scale, 1)
                break
            case .PinchAxisVertical:
                var center = view!.center
                view!.frame.size = CGSizeMake(view!.frame.size.width, view!.frame.size.height  * sender.scale)
                view!.center = center
                //view!.transform = CGAffineTransformScale(view!.transform, 1, sender.scale)
                break
            default:
                //view!.transform = CGAffineTransformScale(view!.transform, sender.scale, sender.scale)
                break
            }
            
            newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, radians)
            sender.scale = 1
        }
    }
    
    var _lastRotation:CGFloat = 0.0
    func rotateImage(sender: UIRotationGestureRecognizer) {
        
        if(canRotate)
        {
            var rotation = 0.0 - (_lastRotation - sender.rotation)
            
            var view = sender.view
            view!.transform = CGAffineTransformRotate(view!.transform, rotation)
            //view!.transform = CGAffineTransformMakeTranslation(10, 10)
            //view!.transform = CGAffineTransformRotate(view!.transform, rotation)
            //view!.transform = CGAffineTransformTranslate(view!.transform,-10,-10)
            _lastRotation = sender.rotation
            
        }
    }
    

    var canRotate = false
    var canResize = true
    func resizeOverlay()
    {
        canRotate = false
        canResize = true
    }
    
    func rotateOverlay()
    {
        canRotate = true
        canResize = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let transitionToWide = size.width > size.height
        
        if(transitionToWide)
        {
            println("transition to wide")
        }
        else
        {
            println("transition to portrait")
        }

        topNavigationBar.frame = CGRectMake(topNavigationBar.frame.size.width , 0 , size.width * 0.33, buttonBarHeight)
        addProjectButton.frame = CGRectMake(0, size.height - buttonBarHeight ,size.width, buttonBarHeight)
        saveEditProjectButton.frame = CGRectMake(0, size.height - buttonBarHeight ,size.width, buttonBarHeight)

        gmaps!.frame = CGRectMake(0, buttonBarHeight , size.width,
            size.height - (buttonBarHeight*2))
    }
    //MARK: Locationmanager
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error \(error.description)")
        
    }

    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            if let map = gmaps? {
                map.myLocationEnabled = true
                map.settings.myLocationButton = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            if let map = gmaps? {
            
                var target = initialTarget ?? location.coordinate
                map.camera = GMSCameraPosition(target: target, zoom: 15, bearing: 0, viewingAngle: 0)
                println("location is  \(location.coordinate.latitude) \(location.coordinate.longitude)")
                locationManager.stopUpdatingLocation()
                
                // Reverse Geocoding
                geocoder.reverseGeocodeLocation(location, completionHandler: {(stuff, error)->Void in
                    
                    if (error != nil) {
                        println("reverse geodcode fail: \(error.localizedDescription)")
                        return
                    }
                    
                    if stuff.count > 0 {
                        
                        self.currentLocation = location
                        self.localAddressSet = true
                        
                        self.placemark = CLPlacemark(placemark: stuff[0] as CLPlacemark)
                        
                        println("\(self.placemark.country)")
                        println("\(self.placemark.administrativeArea)")
                        println("\(self.placemark.locality)")
                        println("\(self.placemark.postalCode)")
                        println("\(self.placemark.thoroughfare)")
                        println("\(self.placemark.subThoroughfare)")

                        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
                        self.localAddressText = ("\(self.placemark.thoroughfare) \(self.placemark.locality) \(timestamp)")

                    }
                    else {
                        println("No Placemarks!")
                        return
                    }
                    
                })

            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setMarkers(edit:Bool,atIndex:Int)
    {
        var index = 0
        for item in projectItems
        {
            var marker = GMSMarker()
            marker.title = item.title
            if(edit && atIndex == index)
            {
                marker.draggable = true
                marker.icon = UIImage(named: "red-pushpin")
                currentEditableMarker = marker
                addProjectButton.removeFromSuperview()
                self.view.addSubview(saveEditProjectButton)
                
            }
            else
            {
                marker.draggable = false
                //marker.snippet = "\(item.title)";
                //marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
                marker.icon = UIImage(named: "flag_icon")
            }
            marker.position = CLLocationCoordinate2DMake(item.latitude, item.longitude)
            marker.appearAnimation = kGMSMarkerAnimationPop
            
            marker.map = gmaps
            index++
        }
    }

    func getProjectOnTitle(title:String) -> Project?
    {
        println("searching for project \(title)")
        for item in projectItems
        {
            println("project with title \(item.title)")
            if(item.title == title)
            {
                return item
            }
        }
        return nil
    }
    
    //MARK: gmap functions
    var newProjectmarker:GMSMarker!
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        println("tapped at coordinate \(coordinate.latitude) \(coordinate.longitude)")
        if(setPositonForNewProject)
        {
            setPositonForNewProject = false
            
            newProjectmarker = GMSMarker()
            newProjectmarker.title = newProjectTitle
            newProjectmarker.draggable = true
            newProjectmarker.position = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude)
            newProjectmarker.appearAnimation = kGMSMarkerAnimationPop
            newProjectmarker.icon = UIImage(named: "red-pushpin")
            newProjectmarker.map = gmaps
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        println("marker title \(marker.title)")
        
        project = self.getProjectOnTitle(marker.title)
        
        println("number of files in project \(project?.imagefiles.count)")
        
        
        //TODO: maby show info worktype at first
        if(project?.imagefiles.count > 1)
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("FilepointListViewController") as FilepointListViewController
            self.performSegueWithIdentifier("showFilepointList", sender: nil)
        }
        else if(project?.imagefiles.count > 0)
        {
            let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as FilepointViewController
            self.performSegueWithIdentifier("showFilepoint", sender: nil)
        }
        else
        {
            self.view.addSubview(cameraView)
        }
        return true
    }
    
    func mapView(mapView: GMSMapView!, didBeginDraggingMarker marker: GMSMarker!) {
       
    }
    
    func mapView(mapView: GMSMapView!, didDragMarker marker: GMSMarker!) {
        
    }
    
    var currentEditableMarker:GMSMarker!
    func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        
        currentEditableMarker = marker
    }
    
    //var newProjectTitleTextBox:UITextField!
    func addNewProject()
    {
        newProjectView = NewProjectView(frame: self.view.frame)
        newProjectView!.delegate = self
        
        if(localAddressSet)
        {
            newProjectView!.newProjectTitle.text = localAddressText
        }
        else
        {
            newProjectView!.setCurrentPositionButton.alpha = 0.5
            newProjectView!.setCurrentPositionButton.enabled = false
            newProjectView!.newProjectTitle.text = "Could not recieve current address"
            newProjectView!.setPositionButton.setTitle("Set position", forState: .Normal)
         }

        self.view.addSubview(newProjectView!)
    }
    
    func saveNewProject(sender:UIButton!)
    {
        sender.removeFromSuperview()
        self.view.addSubview(addProjectButton)
        newProjectmarker.icon = UIImage(named: "flag_icon")
        newProjectmarker.draggable = false
        
        Project.createInManagedObjectContext(self.managedObjectContext!, title: newProjectTitle, lat:newProjectmarker.position.latitude, long: newProjectmarker.position.longitude)
        save()
        fetchProjects()
    }
    
    func saveNewProjectWithCurrentLocation(sender:UIButton!)
    {
        sender.removeFromSuperview()
        self.view.addSubview(addProjectButton)
        newProjectmarker.icon = UIImage(named: "flag_icon")
        newProjectmarker.draggable = false
        
        Project.createInManagedObjectContext(self.managedObjectContext!, title: newProjectTitle, lat:currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude)
        save()
        fetchProjects()
    }
    
    func saveEditProject()
    {
        saveEditProjectButton.removeFromSuperview()
        self.view.addSubview(addProjectButton)
        
        currentEditableMarker.icon = UIImage(named: "flag_icon")
        currentEditableMarker.draggable = false
        
        projectItems[editProjectAtIndex].longitude = currentEditableMarker.position.longitude
        projectItems[editProjectAtIndex].latitude = currentEditableMarker.position.latitude
        save()
    }
    
    func cancelNewProject()
    {
        newProjectView!.removeFromSuperview()
    }
    
    var setPositonForNewProject = false
    func setPositionNewProject()
    {
        newProjectView!.removeFromSuperview()
        addProjectButton.removeFromSuperview()
        
        var saveNewProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveNewProjectButton.setTitle("Save", forState: .Normal)
        saveNewProjectButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        saveNewProjectButton.addTarget(self, action: "saveNewProject:", forControlEvents: .TouchUpInside)
        self.view.addSubview(saveNewProjectButton)
        
        
        var titlePrompt = UIAlertController(title: "Enter",
            message: "Enter title of new project",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "title"
            textField.textAlignment = NSTextAlignment.Center
            textField.keyboardType = UIKeyboardType.Default
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                self.newProjectTitle = "\(titleTextField!.text)"
                
                var tapPrompt = UIAlertController(title: "Tap and drag on map",
                    message: "Tap on map to set position and drag for accuracy",
                    preferredStyle: .Alert)
                
                
                tapPrompt.addAction(UIAlertAction(title: "Ok",
                    style: .Default,
                    handler: { (action) -> Void in
                        self.setPositonForNewProject = true
                }))
                
                
                self.presentViewController(tapPrompt,
                    animated: true,
                    completion: nil)
        }))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
    }
    
    func setCurrentPositionNewProject()
    {
        newProjectView!.removeFromSuperview()
        addProjectButton.removeFromSuperview()
        
        newProjectTitle = self.localAddressText
        
        newProjectmarker = GMSMarker()
        newProjectmarker.title = newProjectTitle
        newProjectmarker.draggable = true
        newProjectmarker.position = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        newProjectmarker.appearAnimation = kGMSMarkerAnimationPop
        newProjectmarker.icon = UIImage(named: "red-pushpin")
        newProjectmarker.map = gmaps
        
        var saveNewProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveNewProjectButton.setTitle("Save", forState: .Normal)
        saveNewProjectButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        saveNewProjectButton.addTarget(self, action: "saveNewProjectWithCurrentLocation:", forControlEvents: .TouchUpInside)
        self.view.addSubview(saveNewProjectButton)
    }
    //MARK: CoreData
    
    func fetchProjects()
    {
        let fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            projectItems = fetchResults
        }
    }
    
    func printTestDatastructure()
    {
        for project in projectItems
        {
            println("project id \(project.objectID)")
            for imagefile in project.imagefiles
            {
                
                printTestImagefile(imagefile as Imagefile, depth:0)

            }
        }
    }
    
    func printTestImagefile(imagefile:Imagefile,depth:Int)
    {
        var depthstring = ""
        for var i = 0 ; i < depth ; i++
        {
            depthstring = depthstring + "-"
        }
        
        println("\(depthstring) imagefile id \(imagefile.objectID)")
        
        for filepoint in imagefile.filepoints
        {
            println("\(depthstring) filepoint id \(filepoint.objectID)")
            for imagefile in filepoint.imagefiles
            {
                printTestImagefile(imagefile as Imagefile,depth: depth + 1)
            }
            
        }
    }
    
    func fetchOverlays()
    {
        let fetchRequest = NSFetchRequest(entityName: "Overlay")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Overlay] {
            for overlay in fetchResults
            {
                if(overlay.active == 1 && overlay != overlayToSet)
                {
                    var sw = CLLocationCoordinate2DMake(overlay.latitudeSW,overlay.longitudeSW)
                    var ne = CLLocationCoordinate2DMake(overlay.latitudeNE,overlay.longitudeNE)

                    var overlayBounds = GMSCoordinateBounds(coordinate: sw, coordinate: ne)
                    var icon = UIImage(data: overlay.file)
                    
                    var overlayToSet = GMSGroundOverlay(bounds: overlayBounds, icon: icon)

                    overlayToSet.bearing = overlay.bearing
                    overlayToSet.map = gmaps

                    
                }
            }
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
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
            var newFileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title: "a filepoint title", file: imageData!, tags:nil, worktype:workType.info)
            // Update the array containing the table view row data
            project?.addImagefileToProject(newFileItem)

            save()
            self.fetchProjects()
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        var imageData =  UIImageJPEGRepresentation(image,1.0) as NSData

        var newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title: "a filepoint title", file: imageData, tags:nil, worktype:workType.info)
        project?.addImagefileToProject(newImagefileItem)
        
        save()
        
        self.fetchProjects()
        
        cameraView.removeFromSuperview()
    }

    
    //MARK: Storyboard and segue
    func test()
    {
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TestViewController") as TestViewController
        self.performSegueWithIdentifier("showTestViewController", sender: nil)
    }

    override func toMapView()
    {
        
    }
    
    override func toListView() {
        self.storyboard!.instantiateViewControllerWithIdentifier("ProjectListViewController") as ProjectListViewController
        self.performSegueWithIdentifier("showProjectList", sender: nil)
    }
    

    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepoint") {
            var svc = segue!.destinationViewController as FilepointViewController
            svc.project = project
            svc.oneLevelFromProject = true
        }
        else if (segue.identifier == "showTreeView") {
            var svc = segue!.destinationViewController as TreeViewController
            svc.pdfImages = self.pdfImages
        }
        else if (segue.identifier == "showFilepointList") {
            var svc = segue!.destinationViewController as FilepointListViewController
            svc.imagefile = project?.imagefiles.allObjects.first as Imagefile
        }
    }
    
}

