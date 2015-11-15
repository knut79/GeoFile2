//
//  ProjectListViewController.swift
//  GeoFile
//
//  Created by knut on 06/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData

class MapPointListViewController: CustomViewController,UITableViewDataSource  , UITableViewDelegate, EditMapPointProtocol {
    

    var mappoint: MapPoint?
    var addMapPointButton:UIButton!
    var editMapPointView:EditMapPointView!
    //var topNavigationBar:TopNavigationView!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var mapPointTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var mapPointItems = [MapPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topNavigationBar.showForViewtype(.list)
        
        mapPointTableView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2))
        self.view.addSubview(mapPointTableView)
        mapPointTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        mapPointTableView.delegate = self
        mapPointTableView.dataSource = self
        
        self.fetchMapPoints()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapPointItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell")
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let mapPointItem = mapPointItems[indexPath.row]
        
        cell!.textLabel?.text = mapPointItem.title
        cell!.showsReorderControl = true
        //cell.editing = false
        if(mapPointItem.imagefiles.count > 0)
        {
            if let imageData = (mapPointItem.firstImagefile)?.file
            {
                if let image = UIImage(data: imageData)
                {
                    cell!.imageView?.image = image
                }
            }
        }
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapPointItem = mapPointItems[indexPath.row]
        mappoint = mapPointItem
        if(mappoint?.imagefiles.count > 0)
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as! FilepointViewController
            self.performSegueWithIdentifier("showFilepoint", sender: nil)
        }
        else
        {
            let titlePrompt = UIAlertController(title: "Cant navigate",
                message: "No image set for map point",
                preferredStyle: .Alert)
            titlePrompt.addAction(UIAlertAction(title: "OK",
                    style: .Default,
                    handler: nil))
            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            let mapPointItem = mapPointItems[indexPath.row]
            
            let titlePrompt = UIAlertController(title: "Delete",
                message: "Sure you want to delete this map point",
                preferredStyle: .Alert)
            
            titlePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    self.managedObjectContext!.deleteObject(mapPointItem)
                    
                    self.save()
                    
                    self.fetchMapPoints()
                    
                    self.mapPointTableView.reloadData()
                    
            }))
            titlePrompt.addAction(UIAlertAction(title: "Cancel",
                style: .Default,
                handler: nil))
            
            
            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)
        }
    }
    

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (action, indexPath) -> Void in
            tableView.editing = false
            self.editMapPointAtIndex(indexPath)
            //println("shareAction")
        }
        editAction.backgroundColor = UIColor.grayColor()
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            tableView.editing = false
            self.deleteMapPointAtIndex(indexPath)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if ( indexPath.row == 0 )
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    
    
    func deleteMapPointAtIndex(indexPath: NSIndexPath)
    {
        let mapPointItemToDelete = mapPointItems[indexPath.row]
        managedObjectContext?.deleteObject(mapPointItemToDelete)
        self.fetchMapPoints()
        mapPointTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        save()
    }
    
    var currentMapPointItemIndex:Int = 0
    func editMapPointAtIndex(indexPath: NSIndexPath)
    {
        currentMapPointItemIndex = indexPath.row
        let mapPointItem = mapPointItems[indexPath.row]
        editMapPointView = EditMapPointView(frame: self.view.frame)
        editMapPointView.titleTextBox.text = mapPointItem.title
        editMapPointView!.delegate = self
        self.view.addSubview(editMapPointView!)
        
    }
    
    var editPosition = false
    func editMapPointPosition()
    {
        let mapPointItem = mapPointItems[currentMapPointItemIndex]
        mapPointItem.title = editMapPointView.titleTextBox.text!
        save()
        
        editPosition = true
        self.storyboard!.instantiateViewControllerWithIdentifier("MapOverviewViewController") as! MapOverviewViewController
        self.performSegueWithIdentifier("showProjectInMap", sender: nil)
        editPosition = false
    }
    
    func cancelEditMapPoint()
    {
        editMapPointView.removeFromSuperview()
    }
    
    func saveEditMapPoint()
    {
        let mapPointItem = mapPointItems[currentMapPointItemIndex]
        mapPointItem.title = editMapPointView.titleTextBox.text!
        save()
        mapPointTableView.reloadData()
        editMapPointView.removeFromSuperview()
    }
    
    
    func fetchMapPoints() {
        mapPointItems = []
        let fetchRequest = NSFetchRequest(entityName: "MapPoint")

        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MapPoint] {
            
            for item in fetchResults
            {

                mapPointItems.append(item)

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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func toListView()
    {
    }
    

    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showProjectInMap") {
            let svc = segue!.destinationViewController as! MapOverviewViewController
            svc.editMapPointAtIndex = currentMapPointItemIndex
            svc.editMapPoint = editPosition
        }
        else if (segue.identifier == "showFilepoint") {
            let svc = segue!.destinationViewController as! FilepointViewController
            svc.mappoint = mappoint
            svc.oneLevelFromMapPoint = true
        }
        else if (segue.identifier == "showTreeView") {
            let svc = segue!.destinationViewController as! TreeViewController
            svc.pdfImages = self.pdfImages
            
        }
    }
    
}