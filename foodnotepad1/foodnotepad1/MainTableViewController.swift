//
//  MainTableViewController.swift
//  foodnotepad1
//
//  Created by iOS on 2019/10/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var allItems:[FoodItem] = [FoodItem]()
    var detailViewController:DetailViewController?
    //var activityIndicator:UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "美食迹"
        //从CoreData 数据表装入数据
        let items = self.loadDataFromCoreDataStore()
        //若有数据装入，则显示
        if items != nil{
            self.allItems = items!
            self.tableView.reloadData()
        }

        //若无数据装入，则从网络接口下载数据（暂不实现）
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.allItems[indexPath.row].name
        cell.detailTextLabel?.text = self.allItems[indexPath.row].store
        
        //let imgdata:ImageData = self.allImages[(indexPath as NSIndexPath).row]
        let imgdata = self.allItems[(indexPath as NSIndexPath).row].image1
        
        //resize the image to width=40,height=40
        let sacleSize:CGSize = CGSize(width:40,height:40)
        UIGraphicsBeginImageContextWithOptions(sacleSize,false,0.0)
        let img:UIImage = UIImage(data: imgdata! as Data)!
        img.draw(in: CGRect(x: 0,y: 0,width: sacleSize.width,height: sacleSize.height))
        let resizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        cell.imageView?.image = resizeImage
        
        return cell
    }
    

    func loadDataFromCoreDataStore() -> [FoodItem]? {
        var items:[FoodItem]?
        let context:NSManagedObjectContext = self.getContext()
        let request:NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        //无条件查询  predicate表示查询条件
        request.predicate = NSPredicate(value: true)
        //查询后按电话升序排序   ascending: true表示升序
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "telephone", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        var error:NSError?
        do{
            items = try context.fetch(request)
            print("items count=\(String(describing: items))")
            if items == nil{
                items = nil
            }
            else if items!.count == 0{
                print("No results returned:\(error.debugDescription)")
                items = nil
            }
        }catch let error1 as NSError{
            error = error1
            items = nil
            print("Error = \(String(describing: error?.description))")
        }
        return items
    }
    
    func operateDataInCoreDataStore(indexPath:Int, newItem:FoodItem) {
        var items:[FoodItem]?
        let context:NSManagedObjectContext = self.getContext()
        let request:NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        request.predicate = NSPredicate(value: true)
        
        var error:NSError?
        do{
            items = try context.fetch(request)
            items![indexPath] = newItem
            
        }catch let error1 as NSError{
            error = error1
            items = nil
            print("Error = \(String(describing: error?.description))")
        }
        
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    /*
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    */
    //UnwindSegue
    @IBAction func SaveAction(sender:UIStoryboardSegue){
        let vc = sender.source as! DetailViewController
        let indexPath:IndexPath? = self.tableView.indexPathForSelectedRow
        if indexPath != nil {
            let i = (indexPath! as NSIndexPath).row
            self.allItems[i].name = vc.nameField.text
            self.allItems[i].telephone = vc.telephoneField.text
            self.allItems[i].store = vc.storeField.text
            self.allItems[i].comment = vc.commentField.text
            self.allItems[i].image1 = vc.foodphoto.image!.jpegData(compressionQuality: 0.8)
            operateDataInCoreDataStore(indexPath: i, newItem: self.allItems[i])
            self.tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.automatic)
        }
        else {
            //let newFoodItem = FoodItem(context: self.getContext())
            self.allItems[allItems.count-1].name = vc.nameField.text
            self.allItems[allItems.count-1].telephone = vc.telephoneField.text
            self.allItems[allItems.count-1].store = vc.storeField.text
            self.allItems[allItems.count-1].comment = vc.commentField.text
            self.allItems[allItems.count-1].image1 = vc.foodphoto.image!.jpegData(compressionQuality: 0.8)
            //allItems.append(newFoodItem)
            
            //self.allItems.append(vc.foodItem!)
            operateDataInCoreDataStore(indexPath: allItems.count-1, newItem: self.allItems[allItems.count-1])
            self.tableView.reloadData()
        }
        
        self.dismiss(animated: true){
            
        }
    }
    @IBAction func CancelAction(sender:UIStoryboardSegue){
        self.dismiss(animated: true){
            
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.detailViewController = segue.destination as? DetailViewController
        let indexPath:IndexPath? = self.tableView.indexPathForSelectedRow
        if indexPath != nil {
            detailViewController?.foodItem = self.allItems[(indexPath! as NSIndexPath).row]
        }
        else {
            //添加新的一项
            let newFoodItem = FoodItem(context: self.getContext())
            allItems.append(newFoodItem)
            detailViewController?.foodItem = self.allItems[allItems.count-1]
            
        }
        
    }
    

}
