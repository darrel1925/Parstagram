//
//  FeedViewController.swift
//  ParseChat
//
//  Created by Kay Lab on 5/6/19.
//  Copyright © 2019 Darrel Muonekwu. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var window: UIWindow?
    var posts = [PFObject]()
    var queryLimit = 20
    var showCommentBar = false
    var selectedPost: PFObject!
    
    
    let myRefreshControl = UIRefreshControl()
    let commentBar = MessageInputBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        // allows you to dismiss keyboard by dragging finger downwards
        tableView.keyboardDismissMode = .interactive
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        
        tableView.refreshControl = myRefreshControl
        
        commentBar.inputTextView.placeholder = "Add a comment"
        commentBar.sendButton.title = "Post"
        // everytime an action happes witht hte comment bar you can have callback functions that will fire
        commentBar.delegate = self
        // the thing the brodcasts all of the notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPosts()
    }
    
                         /************************ TableView Function ************************/
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // n number of comments + 1 post + 1 'AddCommentCell
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.PostCell) as! PostCell
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.commentLabel1.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url
            let url = URL(string: urlString!)
            cell.photoView?.af_setImage(withURL: url!)
            
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.CommentCell) as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String ?? "Error, no comment"
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.AddCommentCell)!
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        print("row \(indexPath.row) : section \(indexPath.section) : comment count \(comments.count + 1)")
            func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                //        if editingStyle == UITableViewCell.EditingStyle.delete {
                //
                //        }
                
            }
        
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            // raises the keyboard
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
    }
    


//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row + 1 == posts.count {
//            loadMorePosts()
//        }
//    }
    
                       /************************ Server Call Function ************************/
    
    @objc func loadPosts() {
        let query = PFQuery(className:"Posts")
        /* ~~~~~~~~~~~~  SUPER IMPORTANT  ~~~~~~~~~~~~~~~~~~~ */
        // if you dnt have this you will festch the pointer and not the object
        // this gives yout the actual object for you to use NOT the pointer that are stored in Parse
        query.includeKeys(["author","comments", "comments.author"])
        // says that you want the last 20 items
        query.limit = queryLimit
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.posts = posts
                // load post from newest to oldest
                //self.posts.reverse()
                self.tableView.reloadData()
            } else {
                print("Error loading posts: \(error!.localizedDescription)")
            }
        }
        self.myRefreshControl.endRefreshing()
    }
    
    func loadMorePosts(){
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = queryLimit + 1
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.posts = posts
                // load post from newest to oldest
                self.posts.reverse()
                self.tableView.reloadData()
            } else {
                print("Error loading posts: \(error!.localizedDescription)")
            }
        }
        self.myRefreshControl.endRefreshing()
    }
    
    @IBAction func onLogOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let LogInVC = main.instantiateViewController(withIdentifier: Controllers.LogInViewController)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = LogInVC
        
    }
    
                         /************************ KeyBoard Function ************************/
    
    @objc func keyBoardWillBeHidden() {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create comment
        let comment = PFObject(className: "comments")
        comment["text"]  = text
        comment["posts"] = selectedPost
        comment["author"] = PFUser.current()
        
        // creates an array of comment for every post
        selectedPost.add(comment, forKey: "comments")
        
        
        selectedPost.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("comment saved")
            } else {
                print("error saving comment")
            }
        }
        // *you can reload data with different animations
        tableView.reloadData()
        // Clear and dismiss
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        // returns whether or not to show the keyboard
        return showCommentBar
    }
    
}
