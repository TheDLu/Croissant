//
//  ViewController.swift
//  Croissant
//
//  Created by Daryl Lu on 2/6/15.
//  Copyright (c) 2015 Daryl Lu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView()
    var isRunning = false
    var partner: PFUser!
    
    @IBOutlet var userTextField: UITextField!
    @IBOutlet var partnerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.view.addSubview(activityIndicator)
        self.activityIndicator.center = CGPointMake(240,160)
        
        self.partnerButton.setImage(UIImage(named: "checkmark-64.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        if self.partner == nil {
            self.partnerButton.tintColor = UIColor.lightGrayColor()
        } else {
            self.partnerButton.tintColor = UIColor.blueColor()
        }
        self.partnerButton.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func activateIndicator(sender: AnyObject) {
        var userString = self.userTextField.text as NSString
        
        if userString == "" {
            UIAlertView(title: "Missing Information", message: "Enter a username to search", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        var userSearchQuery = PFQuery(className: "User")
        userSearchQuery.whereKey("Username", equalTo: userString)
        userSearchQuery.getFirstObjectInBackgroundWithBlock {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                if object == nil {
                    UIAlertView(title: "No One Found", message: "There was no user with that name. Please check if the username you're looking for was entered correctly.", delegate: nil, cancelButtonTitle: "Okay").show()
                } else {
                    self.partner = object as PFUser
                    self.partnerButton.tintColor = UIColor.blueColor()
                }
            }
        }
        
        
//        if isRunning {
//            self.activityIndicator.stopAnimating()
//            self.isRunning = false
//        } else {
//            self.activityIndicator.startAnimating()
//            self.isRunning = true
//        }
    }

    @IBAction func showChatButton(sender: UIButton) {
        if self.partner != nil {
            self.performSegueWithIdentifier("showChatSegue", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var messagesViewController: MessagesViewController = segue.destinationViewController as MessagesViewController
        messagesViewController.messages.removeAllObjects()
        
        var chatQuery = PFQuery(className: "Conversation")
        chatQuery.whereKey("participants", containsAllObjectsInArray: [self.partner, PFUser.currentUser()])
        
        var messagesQuery = PFQuery(className: "Message")
        messagesQuery.whereKey("conversation", matchesQuery: chatQuery)
        messagesQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    var obj = object as PFObject
                    var mediaObject = obj["media"] as PFFile
                    mediaObject.getDataInBackgroundWithBlock {
                        (imageData: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            messagesViewController.pictureObjects.addObject(UIImage(data: imageData)!)
                        }
                    }
                    messagesViewController.messageObjects.addObject(obj)
                }
            } else {
                println(error)
            }
        }
    }
}

