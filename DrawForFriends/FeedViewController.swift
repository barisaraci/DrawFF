//
//  FeedViewController.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/30/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts : [Post] = []
    var userId : String = ""
    var refreshDate : Int64 = 0
    var lastPostDate : Int64 = 0
    var isLoading : Bool = true
    
    var refreshControl = UIRefreshControl()
    var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        userId = (tabBarController as! HomeViewController).userId
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
        
        loadPosts(type: 0)
    }
    
    func refresh() {
        loadPosts(type: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostIdentifier", for: indexPath) as! FeedViewCell
        
        let post : Post = posts[indexPath.row]
        var timeText : String = ""
        
        if (post.date > 7 * 24 * 60) { timeText = "\(post.date / (7 * 24 * 60)) w"; } // week
        else if (post.date > 24 * 60) { timeText = "\(post.date / (24 * 60)) d"; } // day
        else if (post.date > 60) { timeText = "\(post.date / 60) h"; } // hour
        else if (post.date >= 0){ timeText = "\(post.date) m"; } // minute
        
        cell.labelInfo.text = "@\(post.username) posted an image \(timeText) ago"
        cell.viewImage.downloadedFrom(link: "http://barisaraci.com/drawff/drawffimages/\(post.userId)_\(post.imageId).jpg")
        
        cell.isUserInteractionEnabled = false
        
        if indexPath.row == self.posts.count - 1 && !isLoading && self.posts.count >= 10 {
            loadPosts(type: 2)
            self.isLoading = true
        }
        
        return cell
    }

    func loadPosts(type: Int) {
        var postDate : Int64 = 0
        
        if(type == 0) {
            postDate = 0
        } else if(type == 1) {
            postDate = refreshDate
        } else if(type == 2) {
            postDate = lastPostDate
        }
        
        let json: [String: Any] = ["userId": userId, "postDate": postDate, "type": type, "isProfile": 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://www.barisaraci.com/drawff/query.php?action=getPosts")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    self.showToast(message: "There is a problem connecting to server")
                    if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                    self.isLoading = false
                    self.activityIndicatorView.stopAnimating()
                }
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                self.processResponse(result: responseJSON, type: type)
            }
        }
        
        task.resume()
    }
    
    func processResponse(result: [String: Any], type: Int) {
        let info = result["info"] as! [String:Any]
        let posts = result["posts"] as! [[String: Any]]
        
        let refreshDate = info["refreshDate"] as! Int64
        let lastPostDate = Int64(info["lastPostDate"] as! String)!
        
        if (posts.count == 0) {
            DispatchQueue.main.async {
                self.showToast(message: "There is no new post")
                if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                self.isLoading = false
                self.activityIndicatorView.stopAnimating()
            }
        } else {
            if (type == 0) {
                self.refreshDate = refreshDate
                self.lastPostDate = lastPostDate
            } else if (type == 1) {
                self.refreshDate = refreshDate
            } else if (type == 2) {
                self.lastPostDate = lastPostDate
            }
            
            for i in 0..<posts.count {
                let post = Post(postId: posts[i]["post_id"] as! String, userId: posts[i]["post_user_id"] as! String, imageId: posts[i]["post_image_id"] as! String, username: posts[i]["username"] as! String, date: (refreshDate - Int64(posts[i]["post_date"] as! String)!) / 60)
                
                if (type == 1) {
                    self.posts.insert(post, at: 0)
                } else {
                    self.posts.append(post)
                }
            }
            
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                self.tableView.reloadData()
                self.isLoading = false
            }
        }
    }

}
