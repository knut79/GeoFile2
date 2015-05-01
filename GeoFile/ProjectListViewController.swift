//
//  ProjectListViewController.swift
//  GeoFile
//
//  Created by knut on 06/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData

class ProjectListViewController: CustomViewController,UITableViewDataSource  , UITableViewDelegate, EditProjectProtocol,TopNavigationViewProtocol {
    

    var project: Project?
    var addProjectButton:UIButton!
    var editProjectView:EditProjectView!
    //var topNavigationBar:TopNavigationView!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var projectsTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var projectItems = [Project]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topNavigationBar.showForViewtype(.list)
        
        projectsTableView.frame = CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2))
        self.view.addSubview(projectsTableView)
        projectsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        projectsTableView.delegate = self
        projectsTableView.dataSource = self
        
        self.fetchProjects()
        
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
        return projectItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell") as UITableViewCell
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let projectItem = projectItems[indexPath.row]
        
        cell.textLabel?.text = projectItem.title
        cell.showsReorderControl = true
        //cell.editing = false
        if(projectItem.filepoints.count > 0)
        {
            var imageData = (projectItem.filepoints.allObjects.first as Filepoint).file
            if let image = UIImage(data: imageData!)
            {
                cell.imageView?.image = image
            }
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let projectItem = projectItems[indexPath.row]
        project = projectItem
        if(project?.filepoints.count > 0)
        {
            let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as FilepointViewController
            self.performSegueWithIdentifier("showFilepoint", sender: nil)
        }
        else
        {
            var titlePrompt = UIAlertController(title: "Cant navigate",
                message: "No image set for project",
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
            let projectItem = projectItems[indexPath.row]
            
            var titlePrompt = UIAlertController(title: "Delete",
                message: "Sure you want to delete this project",
                preferredStyle: .Alert)
            
            titlePrompt.addAction(UIAlertAction(title: "Ok",
                style: .Default,
                handler: { (action) -> Void in
                    self.managedObjectContext!.deleteObject(projectItem)
                    
                    self.save()
                    
                    self.fetchProjects()
                    
                    self.projectsTableView.reloadData()
                    
            }))
            titlePrompt.addAction(UIAlertAction(title: "Cancel",
                style: .Default,
                handler: nil))
            
            
            self.presentViewController(titlePrompt,
                animated: true,
                completion: nil)
        }
    }
    

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (action, indexPath) -> Void in
            tableView.editing = false
            self.editProjectAtIndex(indexPath)
            //println("shareAction")
        }
        editAction.backgroundColor = UIColor.grayColor()
        
        /*
        var doneAction = UITableViewRowAction(style: .Default, title: "Done") { (action, indexPath) -> Void in
            tableView.editing = false
            println("readAction")
        }
        doneAction.backgroundColor = UIColor.greenColor()*/
        
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            tableView.editing = false
            self.deleteProjectAtIndex(indexPath)
            //println("deleteAction")
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
    
    
    func deleteProjectAtIndex(indexPath: NSIndexPath)
    {
        let projectItemToDelete = projectItems[indexPath.row]
        managedObjectContext?.deleteObject(projectItemToDelete)
        self.fetchProjects()
        projectsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        save()
    }
    
    var currentProjectItemIndex:Int = 0
    func editProjectAtIndex(indexPath: NSIndexPath)
    {
        currentProjectItemIndex = indexPath.row
        let projectItem = projectItems[indexPath.row]
        editProjectView = EditProjectView(frame: self.view.frame)
        editProjectView.titleTextBox.text = projectItem.title
        editProjectView!.delegate = self
        self.view.addSubview(editProjectView!)
        
    }
    
    var editPosition = false
    func editProjectPosition()
    {
        let projectItem = projectItems[currentProjectItemIndex]
        projectItem.title = editProjectView.titleTextBox.text
        save()
        
        editPosition = true
        let mapViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapOverviewViewController") as MapOverviewViewController
        self.performSegueWithIdentifier("showProjectInMap", sender: nil)
        editPosition = false
    }
    
    func cancelEditProject()
    {
        editProjectView.removeFromSuperview()
    }
    
    func saveEditProject()
    {
        let projectItem = projectItems[currentProjectItemIndex]
        projectItem.title = editProjectView.titleTextBox.text
        save()
        projectsTableView.reloadData()
        editProjectView.removeFromSuperview()
    }
    
    
    func fetchProjects() {
        projectItems = []
        let fetchRequest = NSFetchRequest(entityName: "Project")

        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            
            for item in fetchResults
            {
                //if(item.filepoints.count > 0)
                //{
                    projectItems.append(item)
                //}
            }
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    func toMapView()
    {
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapOverviewViewController") as MapOverviewViewController
        self.performSegueWithIdentifier("showProjectInMap", sender: nil)
    }

    func toTreeView()
    {
        let treeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TreeViewController") as TreeViewController
        self.performSegueWithIdentifier("showTreeView", sender: nil)
    }
    */
    
    override func toListView()
    {
    }
    

    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showProjectInMap") {
            var svc = segue!.destinationViewController as MapOverviewViewController
            svc.editProjectAtIndex = currentProjectItemIndex
            svc.editProject = editPosition
        }
        else if (segue.identifier == "showFilepoint") {
            var svc = segue!.destinationViewController as FilepointViewController
            svc.project = project
            svc.oneLevelFromProject = true
        }
        else if (segue.identifier == "showTreeView") {
            var svc = segue!.destinationViewController as TreeViewController
            svc.pdfImages = self.pdfImages
            
        }
    }
    
}