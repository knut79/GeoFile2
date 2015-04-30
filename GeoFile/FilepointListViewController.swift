//
//  FilepointListViewController.swift
//  GeoFile
//
//  Created by knut on 27/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


import UIKit
import CoreData

class FilepointListViewController: CustomViewController,UITableViewDataSource  , UITableViewDelegate ,TopNavigationViewProtocol {
    
    
    var filepoint:Filepoint?
    //project: only used for displaying multiple paralell files directly under project node
    var project:Project?
    var addFileButton:UIButton!
    //var topNavigationBar:TopNavigationView!
    var backButton:UIButton!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var filepointTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var filepointItems:[Filepoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topNavigationBar.showForViewtype(.list)
        
        backButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        backButton.setTitle("🔙", forState: .Normal)
        backButton.addTarget(self, action: "goBack", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        setDataSource()
        
        filepointTableView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2))
        self.view.addSubview(filepointTableView)
        filepointTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        filepointTableView.delegate = self
        filepointTableView.dataSource = self
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDataSource()
    {
        filepointItems = []
        if(filepoint != nil)
        {
            for item in filepoint!.filepoints
            {
                filepointItems.append(item as Filepoint)
            }
        }
        else if(project != nil) //show files from project
        {
            for item in project!.filepoints
            {
                filepointItems.append(item as Filepoint)
            }
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filepointItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell") as UITableViewCell
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let filepointItem = filepointItems[indexPath.row]
        
        cell.textLabel?.text = filepointItem.title
        cell.showsReorderControl = true
        //cell.editing = false
        if(filepointItem.filepoints.count > 0)
        {
            var imageData = filepointItem.file
            if let image = UIImage(data: imageData!)
            {
                cell.imageView?.image = image
            }
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filepointItem = filepointItems[indexPath.row]
        filepoint = filepointItem
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as FilepointViewController
        self.performSegueWithIdentifier("showFilepoint", sender: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            let filepointItem = filepointItems[indexPath.row]
            
            var titlePrompt = UIAlertController(title: "Delete",
                message: "Sure you want to delete this image",
                preferredStyle: .Alert)

            titlePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    self.managedObjectContext!.deleteObject(filepointItem)
                    
                    self.save()
                    
                    self.setDataSource()
                    
                    self.filepointTableView.reloadData()
                    
                    
            }))
            titlePrompt.addAction(UIAlertAction(title: "Cancel",
                style: .Default,
                handler: nil))
            

            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)

        }
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func goBack()
    {
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as FilepointViewController
        self.performSegueWithIdentifier("showFilepoint", sender: nil)
    }
    
    
    override func toListView()
    {
    }
    
    
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showProjectInMap") {
            var svc = segue!.destinationViewController as MapOverviewViewController
            svc.project = project ?? findProjectOfFilepoint(filepoint!)

        }
        else if (segue.identifier == "showFilepoint") {
            var svc = segue!.destinationViewController as FilepointViewController
            svc.currentFilepoint = filepoint
        }
        else if (segue.identifier == "showTreeView") {
            var svc = segue!.destinationViewController as TreeViewController
            svc.pdfImages = self.pdfImages
            svc.passingFilepoint = filepoint
            
        }

    }
    
}