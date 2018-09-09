//
//  ViewController.swift
//  tumblr
//
//  Created by Kristy Caster on 10/31/16.
//  Copyright © 2016 kristeaac. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var posts = [NSDictionary]()
    @IBOutlet weak var tumblrTableView: UITableView!
    var blogTitle = "humansofnewyork.tumblr.com"
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFeed()
    }
    
    func initializeFeed() {
        loadBlogTitle()
        self.refreshControl.addTarget(self, action: #selector(refreshTumblrFeed), for: UIControlEvents.valueChanged)
        tumblrTableView.insertSubview(self.refreshControl, at: posts.count)
        loadTumblrFeed()
        tumblrTableView.rowHeight = 640
        initializeLoadingIndicator()
    }
    
    func refreshTumblrFeed() {
        posts = [NSDictionary]()
        tumblrTableView.reloadData()
        loadTumblrFeed()
    }
    
    func loadTumblrFeed() {
        let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)&offset=\(posts.count)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
    
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    let r = responseDictionary.object(forKey: "response") as! NSDictionary
                    self.posts.append(contentsOf: r.object(forKey: "posts") as! [NSDictionary])
                    self.tumblrTableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.isMoreDataLoading = false
                    self.loadingMoreView!.stopAnimating()
                }
            } else {
                NSLog("uh oh")
            }
        });
        task.resume()
    }
    
    func initializeLoadingIndicator() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tumblrTableView.contentSize.height), size: CGSize(width: tumblrTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tumblrTableView.addSubview(loadingMoreView!)
        
        var insets = tumblrTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tumblrTableView.contentInset = insets
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        loadImageFromUrl(url: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar", view: profileView)
        headerView.addSubview(profileView)
        
        let label = UILabel(frame: CGRect(x: 50, y: 10, width: 300, height: 30))
        label.text = blogTitle
        label.textColor = UIColor(red: 0/255, green: 102/255, blue: 204/255, alpha: 1.0)
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath[0]
        if (index == posts.count - 1) {
            if (!isMoreDataLoading) {
                isMoreDataLoading = true
                animateLoadingIndicator()
                loadTumblrFeed()
            }
        }
        return loadPost(tableView: tableView, index: index)
    }
    
    func animateLoadingIndicator() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tumblrTableView.contentSize.height), size: CGSize(width: tumblrTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
    }
    
    func loadPost(tableView: UITableView, index: Int) -> UITableViewCell {
        let url = getPhotoUrl(index: index)
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.kristeaac.tumblr.cell") as! TumblrCell
        loadImageFromUrl(url: url, view: cell.tumblrImageView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func roundedImage(view: UIImageView) {
        view.layer.cornerRadius = view.frame.size.width / 2;
        view.clipsToBounds = true
    }
    
    func imageBorder(view: UIImageView) {
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1.0).cgColor;
    }
    
    func loadImageFromUrl(url: String, view: UIImageView){
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                //print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                view.image = image
            })
            
        }).resume()
    }
    
    func loadBlogTitle(){
        let url = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/info?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                //print(error)
                return
            }
            if let responseDictionary = try! JSONSerialization.jsonObject(with: data!, options:[]) as? NSDictionary {
                let r = responseDictionary.object(forKey: "response") as! NSDictionary
                let blog = r.object(forKey: "blog") as! NSDictionary
                self.blogTitle = blog.object(forKey: "title") as! String
            }
            
        }).resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! PhotoDetailsViewController
        destinationViewController.photoImage = (sender! as! TumblrCell).tumblrImageView.image
    }
    
    func getPhotoUrl(index: Int) -> String {
        let photos = posts[index].object(forKey: "photos") as! NSArray
        let originalSize = (photos[0] as! NSDictionary).object(forKey: "original_size") as! NSDictionary
        return originalSize.object(forKey: "url") as! String
    }


}

