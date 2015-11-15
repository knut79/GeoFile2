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


class MapOverviewViewController: CustomViewController, GMSMapViewDelegate, NewMapPointProtocol, UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate, CameraProtocol,UIGestureRecognizerDelegate, SetOverlayButtonsProtocol, TagCheckViewProtocol{
    

    var gmaps: GMSMapView?
    var mappoint: MapPoint?
    //var topNavigationBar:TopNavigationView!
    var addProjectButton:CustomButton!
    var saveEditProjectButton:CustomButton!
    var newMapPointView:NewMapPointView?
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var projectItems = [MapPoint]()
    
    var editProject = false
    var editProjectAtIndex:Int = -1

    var locationManager:CLLocationManager!
    var geocoder:CLGeocoder!
    var placemark:CLPlacemark!
    
    var localAddressText:String!
    var localAddressSet:Bool = false
    
    var newMapPointTitle:String!
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
    
    var tagsScrollView:TagCheckScrollView!
    var tagsScrollViewOpenButton:UIButton!
    
    var marks:[MarkerItem]!

    override func viewDidLoad() {
        super.viewDidLoad()

        initPickerView()

        initialTarget = mappoint != nil ? CLLocationCoordinate2D(latitude: mappoint!.latitude, longitude: mappoint!.longitude) : nil
        let target: CLLocationCoordinate2D = initialTarget ?? CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75)
        let camera = GMSCameraPosition(target: target, zoom: 10, bearing: 0, viewingAngle: 0)
        
        
        self.view.backgroundColor = UIColor.whiteColor()

        topNavigationBar.showForViewtype(.map)
        
        addProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        //addProjectButton.setTitle("Add project", forState: .Normal)
        addProjectButton.setTitle("Opprett nytt arbeid", forState: .Normal)
        addProjectButton.addTarget(self, action: "addNewMapPoint", forControlEvents: .TouchUpInside)
        self.view.addSubview(addProjectButton)

        saveEditProjectButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveEditProjectButton.setTitle("Save", forState: .Normal)
        saveEditProjectButton.addTarget(self, action: "saveEditProject", forControlEvents: .TouchUpInside)

        gmaps = GMSMapView(frame: CGRectMake(0, buttonBarHeight , self.view.bounds.width,
            self.view.bounds.height - (buttonBarHeight*2)))
        
        if let map = gmaps {
            map.myLocationEnabled = true
            map.camera = camera
            map.delegate = self
            
            self.view.addSubview(gmaps!)
        }
        
        tagsScrollViewOpenButton = UIButton(frame: CGRectMake(buttonIconSideSmall * 0.75, gmaps!.frame.minY + (buttonIconSideSmall * 0.75), buttonIconSideSmall, buttonIconSideSmall))
        let funnelIcon = UIImage(named: "funnel.png")
        tagsScrollViewOpenButton.setImage(funnelIcon, forState: UIControlState.Normal)
        tagsScrollViewOpenButton.addTarget(self, action: "showTagsScrollView", forControlEvents: UIControlEvents.TouchUpInside)
        tagsScrollViewOpenButton.layer.borderWidth = 2
        tagsScrollViewOpenButton.layer.borderColor = UIColor.blackColor().CGColor
        self.view.addSubview(tagsScrollViewOpenButton)
        
        tagsScrollView = TagCheckScrollView(frame: CGRectMake(elementMargin,elementMargin + buttonBarHeight,self.view.frame.width * 0.5, self.view.frame.height * 0.5))
        tagsScrollView.delegate = self
        tagsScrollView.alpha = 0

        self.view.addSubview(tagsScrollView!)
        
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
        
        initMarkers(editProject,atIndex: editProjectAtIndex)
        setupMarkers(nil)
    }
    
    func setNewOverlay(overlay:Overlay)
    {
        let image = UIImage(data: overlay.file)
        //var scaleFactor = image!.size.width / UIScreen.mainScreen().bounds.size.width
        //newOverlayToSet = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, image!.size.height / scaleFactor))
        newOverlayToSet = UIImageView(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
        
        print("sizes should match \(image!.size.width) \(image!.size.height) and \(newOverlayToSet.frame.width) \(newOverlayToSet.frame.height)")
        newOverlayToSet.center = gmaps!.center
        newOverlayToSet.alpha = 0.5
        newOverlayToSet.image = image
        newOverlayToSet.userInteractionEnabled = true
        newOverlayToSet.multipleTouchEnabled = true
        newOverlayToSet.contentMode = UIViewContentMode.ScaleToFill
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "scaleImage:")
        pinchRecognizer.delegate = self
        newOverlayToSet.addGestureRecognizer(pinchRecognizer)
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateImage:")
        rotationRecognizer.delegate = self
        newOverlayToSet.addGestureRecognizer(rotationRecognizer)
        
        gmaps?.settings.scrollGestures = false
        gmaps?.settings.zoomGestures = false
        gmaps?.settings.rotateGestures = false

        
        gmaps?.addSubview(newOverlayToSet)
        
        overlayButtons = SetOverlayButtons(view: gmaps!, overlay:newOverlayToSet)
        overlayButtons.delegate = self
        
        
        setOverlayButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight  ,UIScreen.mainScreen().bounds.size.width / 2, buttonBarHeight))
        setOverlayButton.setTitle("Set overlay", forState: .Normal)
        setOverlayButton.addTarget(self, action: "setOverlay", forControlEvents: .TouchUpInside)
        self.view.addSubview(setOverlayButton)
        
        cancelOverlayButton = CustomButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height - buttonBarHeight  ,UIScreen.mainScreen().bounds.size.width / 2, buttonBarHeight))
        cancelOverlayButton.setTitle("Cancel", forState: .Normal)
        cancelOverlayButton.addTarget(self, action: "cancelOverlay", forControlEvents: .TouchUpInside)
        self.view.addSubview(cancelOverlayButton)
    }
    
    func showTagsScrollView()
    {
        let rightLocation = tagsScrollView.center
        tagsScrollView.transform = CGAffineTransformScale(tagsScrollView.transform, 0.1, 0.1)
        self.tagsScrollView.alpha = 1
        tagsScrollView.center = tagsScrollViewOpenButton.center
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.tagsScrollView.transform = CGAffineTransformIdentity
            
            self.tagsScrollView.center = rightLocation
            }, completion: { (value: Bool) in
                self.tagsScrollView.transform = CGAffineTransformIdentity
                self.tagsScrollView.alpha = 1
                self.tagsScrollView.center = rightLocation
        })
        
    }
    
    //MARK: 
    func closeTagCheckView()
    {
        let rightLocation = tagsScrollView.center
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.tagsScrollView.transform = CGAffineTransformScale(self.tagsScrollView.transform, 0.1, 0.1)

            self.tagsScrollView.center = self.tagsScrollViewOpenButton.center
            }, completion: { (value: Bool) in
                self.tagsScrollView.transform = CGAffineTransformScale(self.tagsScrollView.transform, 0.1, 0.1)
                self.tagsScrollView.alpha = 0
                self.tagsScrollView.center = rightLocation
                
        })
    }
    
    func reloadMarks(tags:[String])
    {
        setupMarkers(tags)
    }
    
    var touchLocationFromCenterInOverlay:CGPoint!
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        //var theImageView = touch?.view
        if let ovview = newOverlayToSet
        {
            touchLocationFromCenterInOverlay = touch!.locationInView(ovview)
            touchLocationFromCenterInOverlay = CGPointMake(touchLocationFromCenterInOverlay.x - (ovview.frame.width / 2) , touchLocationFromCenterInOverlay.y - (ovview.frame.height / 2))
            print("sizes \(newOverlayToSet.frame.width) \(newOverlayToSet.frame.height) and positions \(touchLocationFromCenterInOverlay.x) \(touchLocationFromCenterInOverlay.y)")
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        
        let touch = touches.first
        //var theImageView = touch?.view
        if let view = newOverlayToSet
        {
            let touchLocation = touch!.locationInView(self.gmaps)
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
        
        let northEast = gmaps!.projection.coordinateForPoint(CGPointMake(newOverlayToSet.frame.minX, newOverlayToSet.frame.minY))
        let southWest = gmaps!.projection.coordinateForPoint(CGPointMake(newOverlayToSet.frame.maxX, newOverlayToSet.frame.maxY))

        //let degrees = CGFloat(gmaps!.camera.bearing) * (180 / CGFloat(M_PI) )
        
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)

        if let newOverlayOnMap = overlayToSet
        {
            var icon = UIImage(data: newOverlayOnMap.file)
            icon = imageResize(icon!, sizeChange: newOverlayToSet.frame.size)
            
            let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
            //var overlay = GMSGroundOverlay(position: southWest, icon: icon, zoomLevel: 0)
            
            //gmaps!.clear()
            overlay.bearing = CLLocationDirection(degrees) //360.0 - gmaps!.camera.bearing  //CLLocationDirection(degrees)
            overlay.map = gmaps
            
            newOverlayOnMap.active = true
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
            let view = r.view;
            let touch0 = r.locationOfTouch(0, inView: view) //[r locationOfTouch:0 inView:view];
            let touch1 = r.locationOfTouch(1, inView: view)
            let tangent = fabsf( Float(touch1.y - touch0.y) / Float(touch1.x - touch0.x) )
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
            //let degrees = radians * (180 / CGFloat(M_PI) )
            newOverlayToSet!.transform = CGAffineTransformRotate(newOverlayToSet!.transform, radians * -1)
            
            let view = sender.view
            let axis = pinchGestureRecognizerAxis(sender)
            switch(axis)
            {
            case .PinchAxisHorizontal:
                let center = view!.center
                view!.frame.size = CGSizeMake(view!.frame.size.width * sender.scale, view!.frame.size.height)//.width = view!.frame.width * sender.scale
                view!.center = center
                //view!.transform = CGAffineTransformScale(view!.transform, sender.scale, 1)
                break
            case .PinchAxisVertical:
                let center = view!.center
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
            let rotation = 0.0 - (_lastRotation - sender.rotation)
            
            let view = sender.view
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
            print("transition to wide")
        }
        else
        {
            print("transition to portrait")
        }

        topNavigationBar.frame = CGRectMake(topNavigationBar.frame.size.width , 0 , size.width * 0.33, buttonBarHeight)
        addProjectButton.frame = CGRectMake(0, size.height - buttonBarHeight ,size.width, buttonBarHeight)
        saveEditProjectButton.frame = CGRectMake(0, size.height - buttonBarHeight ,size.width, buttonBarHeight)

        gmaps!.frame = CGRectMake(0, buttonBarHeight , size.width,
            size.height - (buttonBarHeight*2))
    }
    //MARK: Locationmanager
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error \(error.description)")
        
    }

    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            if let map = gmaps {
                map.myLocationEnabled = true
                map.settings.myLocationButton = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first
        {
            if let map = gmaps {
            
                let target = initialTarget ?? location.coordinate
                map.camera = GMSCameraPosition(target: target, zoom: 15, bearing: 0, viewingAngle: 0)
                print("location is  \(location.coordinate.latitude) \(location.coordinate.longitude)")
                locationManager.stopUpdatingLocation()
                
                // Reverse Geocoding
                geocoder.reverseGeocodeLocation(location, completionHandler: {(stuff, error)->Void in
                    
                    if (error != nil) {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                        return
                    }
                    
                    if stuff!.count > 0 {
                        
                        self.currentLocation = location
                        self.localAddressSet = true
                        
                        //_? swift 2 convertion: self.placemark = CLPlacemark(placemark: stuff[0] as! CLPlacemark)
                        self.placemark = CLPlacemark(placemark: stuff!.first! )
                        
                        print("\(self.placemark.country)")
                        print("\(self.placemark.administrativeArea)")
                        print("\(self.placemark.locality)")
                        print("\(self.placemark.postalCode)")
                        print("\(self.placemark.thoroughfare)")
                        print("\(self.placemark.subThoroughfare)")

                        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
                        self.localAddressText = ("\(self.placemark.thoroughfare) \(self.placemark.locality) \(timestamp)")

                    }
                    else {
                        print("No Placemarks!")
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

    
    func initMarkers(edit:Bool,atIndex:Int)
    {
        marks = []
        var index = 0
        for item in projectItems
        {
            let marker = GMSMarker()
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
            
            //marker.map = gmaps
            marks.append(MarkerItem(gmsmarker: marker, tagsString: item.tags, statusTODO: ""))
            index++
        }
    }
    
    func setupMarkers(filters:[String]?)
    {
        for item in marks
        {
            if filters == nil
            {
                item.gmsmarker.map = gmaps
            }
            else
            {
                var foundValue = false
                for filter in filters!
                {
                    if item.tags.rangeOfString(filter) != nil
                    {
                        foundValue = true
                        item.gmsmarker.map = gmaps
                    }
                }
                if !foundValue
                {
                    item.gmsmarker.map = nil
                }
            }
            
        }
    }

    func getProjectOnTitle(title:String) -> MapPoint?
    {
        print("searching for project \(title)")
        for item in projectItems
        {
            print("project with title \(item.title)")
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
        
        print("tapped at coordinate \(coordinate.latitude) \(coordinate.longitude)")
        if(setPositonForNewProject)
        {
            setPositonForNewProject = false
            
            newProjectmarker = GMSMarker()
            newProjectmarker.title = newMapPointTitle
            newProjectmarker.draggable = true
            newProjectmarker.position = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude)
            newProjectmarker.appearAnimation = kGMSMarkerAnimationPop
            newProjectmarker.icon = UIImage(named: "red-pushpin")
            newProjectmarker.map = gmaps
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        print("marker title \(marker.title)")
        
        mappoint = self.getProjectOnTitle(marker.title)
        
        print("number of files in project \(mappoint?.imagefiles.count)")
        
        
        //TODO: maby show info worktype at first
        /*if(project?.imagefiles.count > 1)
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("FilepointListViewController") as FilepointListViewController
            self.performSegueWithIdentifier("showFilepointList", sender: nil)
        }
        else*/
        if(mappoint?.imagefiles.count > 0)
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as! FilepointViewController
            self.performSegueWithIdentifier("showFilepoint", sender: nil)
        }
        else
        {
            cameraView = CameraView(frame: self.view.frame, image:nil, worktype:workType.arbeid)
            cameraView.delegate = self
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
    
    //var newMapPointTitleTextBox:UITextField!
    func addNewMapPoint()
    {
        newMapPointView = NewMapPointView(frame: self.view.frame)
        newMapPointView!.delegate = self
        
        if(localAddressSet)
        {
            newMapPointView!.newMapPointTitle.text = localAddressText
        }
        else
        {
            newMapPointView!.setCurrentPositionButton.alpha = 0.5
            newMapPointView!.setCurrentPositionButton.enabled = false
            newMapPointView!.newMapPointTitle.text = "Could not recieve current address"
            newMapPointView!.setPositionButton.setTitle("Set position", forState: .Normal)
         }

        self.view.addSubview(newMapPointView!)
    }
    
    func saveNewMapPoint(sender:UIButton!)
    {
        sender.removeFromSuperview()
        self.view.addSubview(addProjectButton)
        newProjectmarker.icon = UIImage(named: "flag_icon")
        newProjectmarker.draggable = false
        
        let tags = newMapPointView!.getTags()
        MapPoint.createInManagedObjectContext(self.managedObjectContext!, title: newMapPointTitle, lat:newProjectmarker.position.latitude, long: newProjectmarker.position.longitude, tags: tags)
        save()
        fetchProjects()
    }
    
    func saveNewMapPointWithCurrentLocation(sender:UIButton!)
    {
        sender.removeFromSuperview()
        self.view.addSubview(addProjectButton)
        newProjectmarker.icon = UIImage(named: "flag_icon")
        newProjectmarker.draggable = false
        
        let tags = newMapPointView!.getTags()
        MapPoint.createInManagedObjectContext(self.managedObjectContext!, title: newMapPointTitle, lat:currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude, tags: tags)
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
    
    func cancelNewMapPoint()
    {
        newMapPointView!.removeFromSuperview()
    }
    
    var setPositonForNewProject = false
    func setPositionNewMapPoint()
    {
        newMapPointView!.removeFromSuperview()
        addProjectButton.removeFromSuperview()
        
        let saveNewMapPointButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveNewMapPointButton.setTitle("Save", forState: .Normal)
        saveNewMapPointButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        saveNewMapPointButton.addTarget(self, action: "saveNewMapPoint:", forControlEvents: .TouchUpInside)
        self.view.addSubview(saveNewMapPointButton)
        
        
        let titlePrompt = UIAlertController(title: "Enter",
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
                self.newMapPointTitle = "\(titleTextField!.text)"
                
                let tapPrompt = UIAlertController(title: "Tap and drag on map",
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
    
    func setCurrentPositionNewMapPoint()
    {
        newMapPointView!.removeFromSuperview()
        addProjectButton.removeFromSuperview()
        
        newMapPointTitle = self.localAddressText
        
        newProjectmarker = GMSMarker()
        newProjectmarker.title = newMapPointTitle
        newProjectmarker.draggable = true
        newProjectmarker.position = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        newProjectmarker.appearAnimation = kGMSMarkerAnimationPop
        newProjectmarker.icon = UIImage(named: "red-pushpin")
        newProjectmarker.map = gmaps
        
        let saveNewMapPointButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveNewMapPointButton.setTitle("Save", forState: .Normal)
        saveNewMapPointButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        saveNewMapPointButton.addTarget(self, action: "saveNewMapPointWithCurrentLocation:", forControlEvents: .TouchUpInside)
        self.view.addSubview(saveNewMapPointButton)
    }
    //MARK: CoreData
    
    func fetchProjects()
    {
        let fetchRequest = NSFetchRequest(entityName: "MapPoint")
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MapPoint] {
            projectItems = fetchResults
        }
    }
    
    func printTestDatastructure()
    {
        for project in projectItems
        {
            print("project id \(project.objectID)")
            for imagefile in project.imagefiles
            {
                
                printTestImagefile(imagefile as! Imagefile, depth:0)

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
        
        print("\(depthstring) imagefile id \(imagefile.objectID)")
        
        for filepoint in imagefile.filepoints
        {
            print("\(depthstring) filepoint id \(filepoint.objectID)")
            for imagefile in filepoint.imagefiles
            {
                printTestImagefile(imagefile as! Imagefile,depth: depth + 1)
            }
            
        }
    }
    
    func fetchOverlays()
    {
        let fetchRequest = NSFetchRequest(entityName: "Overlay")
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Overlay] {
            for overlay in fetchResults
            {
                if(overlay.active == true && overlay != overlayToSet)
                {
                    let sw = CLLocationCoordinate2DMake(overlay.latitudeSW,overlay.longitudeSW)
                    let ne = CLLocationCoordinate2DMake(overlay.latitudeNE,overlay.longitudeNE)

                    let overlayBounds = GMSCoordinateBounds(coordinate: sw, coordinate: ne)
                    let icon = UIImage(data: overlay.file)
                    
                    let overlayToSet = GMSGroundOverlay(bounds: overlayBounds, icon: icon)

                    overlayToSet.bearing = overlay.bearing
                    overlayToSet.map = gmaps

                    
                }
            }
        }
    }
    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
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
    
    func savePictureFromCamera(imageData:NSData?,saveAsNewInstance:Bool,worktype:workType)
    {
        if(imageData != nil)
        {
            print("imagedata is not")
            let newFileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title: "a filepoint title", file: imageData!, tags:nil, worktype:worktype)
            // Update the array containing the table view row data
            let sort = mappoint?.getSort()
            newFileItem.setNewSort(sort!)
            mappoint?.addImagefile(newFileItem)

            save()
            self.fetchProjects()
        }
        else
        {
            print("imagedata is nil")
        }
        cameraView.removeFromSuperview()
    }
    
    var worktypeFromCameraView:workType!
    func chooseImageFromPhotoLibrary(saveAsNewInstance:Bool,worktype:workType)
    {
        worktypeFromCameraView = worktype
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        cameraView.removeFromSuperview()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        let imageData =  UIImageJPEGRepresentation(image,1.0)

        let newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title: "a filepoint title", file: imageData!, tags:nil, worktype:worktypeFromCameraView)
        
        let sort = mappoint!.getSort()
        newImagefileItem.setNewSort(sort)
        mappoint?.addImagefile(newImagefileItem)
        
        save()
        
        self.fetchProjects()
        
        cameraView.removeFromSuperview()
    }

    
    //MARK: Storyboard and segue
    func test()
    {
        self.storyboard!.instantiateViewControllerWithIdentifier("TestViewController") as! TestViewController
        self.performSegueWithIdentifier("showTestViewController", sender: nil)
    }

    override func toMapView()
    {
        
    }
    
    override func toListView() {
        self.storyboard!.instantiateViewControllerWithIdentifier("ProjectListViewController") as! MapPointListViewController
        self.performSegueWithIdentifier("showProjectList", sender: nil)
    }
    

    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepoint") {
            let svc = segue!.destinationViewController as! FilepointViewController
            svc.mappoint = mappoint
            svc.oneLevelFromMapPoint = true
        }
        else if (segue.identifier == "showTreeView") {
            let svc = segue!.destinationViewController as! TreeViewController
            svc.pdfImages = self.pdfImages
        }
        else if (segue.identifier == "showFilepointList") {
            let svc = segue!.destinationViewController as! FilepointListViewController
            svc.imagefile = mappoint?.firstImagefile
        }
    }
    
}

