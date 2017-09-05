//
//  HomeViewController.swift
//  OOG-iOS
//
//  Created by Nathan on 04/09/2017.
//  Copyright © 2017 Nathan. All rights reserved.
//

import UIKit
import SwiftyJSON
import DGElasticPullToRefresh

class HomeViewController: UIViewController,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
//        segmented.backgroundColor = UIColor.flatBlack
        
        // 设置delegate
        MovementsTableView.dataSource = self
        HotTableView.dataSource = self
        
        // Refresh stuff
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        MovementsTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            //logic here
            Cache.homeMovementsCache.homeMovementRequest {
                self?.loadCache()
            }
        }, loadingView: loadingView)
        
        // 设置左滑和右滑手势
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(gesture:)))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        
        scrollView.addGestureRecognizer(swipeLeft)
        scrollView.addGestureRecognizer(swipeRight)
        
//        Cache.homeMovementsCache.value = ""
        loadCache()
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var MovementsTableView: UITableView!
    @IBOutlet weak var HotTableView: UITableView!
    
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    
    //Mark: - Action
    var offset: CGFloat = 0.0 {
        didSet {
            UIView.animate(withDuration: 0.3) { () -> Void in
                self.scrollView.contentOffset = CGPoint(x: self.offset, y: 0.0)
            }
        }
    }
    
    func swipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // 向左滑时展示第二个tableview,同时设置选中的segmented item
            offset = self.view.frame.width
            segmented.selectedSegmentIndex = 1
        }
        else {
            offset = 0.0
            segmented.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func tabChanged(_ sender: Any) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
        // b. 设置scrollview的内容偏移量
        offset = CGFloat(index) * self.view.frame.width
    }
    
    //Mark : -Model
    var movements : [[Movement]] = []
    
    //Mark : -Logic
    private func loadCache(){
        if Cache.homeMovementsCache.isEmpty{
            refreshCache()
            return
        }
        
        var movementList : [Movement] = []
        movements.removeAll()
        let value = Cache.homeMovementsCache.value
        let json = JSON.parse(value)
        let movments = json["movements"].arrayValue
        for movementJSON in movments{
            //parse basic info
//            print(movementJSON)
            let movment_ID = movementJSON["movement_ID"].stringValue
            let content = movementJSON["content"].stringValue
            let created_at = movementJSON["created_at"].stringValue
            let likesNumber = movementJSON["likesNumber"].stringValue
            let repostsNumber = movementJSON["repostsNumber"].stringValue
            let commentsNumber = movementJSON["commentsNumber"].stringValue
            
            //parse imageUrl
            var imageNumber = 0
            let imageUrlsJSON = movementJSON["image_url"].arrayValue
            var imageUrls : [String] = []
            for imageUrl in imageUrlsJSON{
                imageUrls.append(imageUrl.stringValue)
                imageNumber += 1
            }
            let imageNumber_literal = String(imageNumber)
            
            //parse owner info
            let owner_avatar = movementJSON["owner"]["avatar_url"].stringValue
            let owner_userName = movementJSON["owner"]["username"].stringValue
            let owner_position = movementJSON["owner"]["position"].stringValue
            
            let movment_Model = Movement(movment_ID,
                                         content,
                                         imageNumber_literal,
                                         imageUrls,
                                         owner_avatar,
                                         owner_userName,
                                         owner_position,
                                         created_at,
                                         likesNumber,
                                         repostsNumber,
                                         commentsNumber)
            
            movementList.append(movment_Model)
        }
        movements.append(movementList)
        MovementsTableView.reloadData()
        HotTableView.reloadData()
        hideProgressDialog()
        MovementsTableView.dg_stopLoading()
    }
    
    private func refreshCache(){
        showProgressDialog()
        Cache.homeMovementsCache.homeMovementRequest {
            self.loadCache()
        }
    }
    
    
    //Mark : - tableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return movements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movements[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusedID: String!
        if tableView.tag == 101 {
            reusedID = "HomeMovement"
            let cell = tableView.dequeueReusableCell(withIdentifier: reusedID, for: indexPath) as! HomeMovementTableViewCell
            cell.movement = movements[indexPath.section][indexPath.row]
            return cell
        }
        else{
            reusedID = "HomeHot"
            let cell = tableView.dequeueReusableCell(withIdentifier: reusedID, for: indexPath)
            cell.textLabel!.text = "第二个TableView"
            return cell
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}