//
//  MessagesViewController.swift
//  Croissant
//
//  Created by Daryl Lu on 2/6/15.
//  Copyright (c) 2015 Daryl Lu. All rights reserved.
//

import UIKit

class MessagesViewController: JSQMessagesViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = NSMutableArray()
    var jsqMessage: JSQMessage!
    
    var sender: String!
    
    var avatarImages = Dictionary<String, UIImage>()
    
    var incomingBubble: JSQMessageBubbleImageDataSource!
    var outgoingBubble: JSQMessageBubbleImageDataSource!
    
    var incomingAvatar: JSQMessageAvatarImageDataSource!
    var outgoingAvatar: JSQMessageAvatarImageDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "DL"
        self.senderDisplayName = "Daryl Lu"
        
        self.incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        self.outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
//        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
//        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        self.messages.addObject(JSQMessage(senderId: "HK", displayName: "Honky", text: "Hello"))
        self.messages.addObject(JSQMessage(senderId: "DL", displayName: "D-Train", text: "Rabbit tiddly"))
        self.messages.addObject(JSQMessage(senderId: "HK", displayName: "Honky", text: "So here I am sitting in a Starbucks. How does this go?"))
    }

    override func didPressAccessoryButton(sender: UIButton!) {        
        UIActionSheet(title: "Media messages", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Pick from Gallery").showFromToolbar(self.inputToolbar)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        println("Send Pressed: \(text)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item] as JSQMessage
        
        if message.senderId == "DL" {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item] as JSQMessage
        
        if message.senderId == "DL" {
            return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("DL", backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(), font: UIFont(name: "MarkerFelt-Thin", size: 7), diameter: 15)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(message.senderId, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(), font: UIFont(name: "MarkerFelt-Thin", size: 7), diameter: 15)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData {
        let messageData = self.messages[indexPath.row] as JSQMessage
        
        return messageData
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item] as JSQMessage
        
        cell.textView.text = message.text
        
        return cell
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return
        }
        
        switch (buttonIndex) {
        case 1:
            self.selectFrom("camera")
        case 2:
            self.selectFrom("gallery")
        default:
            break
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
    }

    
    func selectFrom(option: String) {
        var imagePicker: UIImagePickerController = UIImagePickerController()
        
        if option == "camera" {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        var pickedImage: UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        var imageData = UIImagePNGRepresentation(pickedImage)
        imageData = self.resize(pickedImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var mediaMessageData: JSQPhotoMediaItem = JSQPhotoMediaItem(image: UIImage(data: imageData))
        self.messages.addObject(JSQMessage(senderId: "DL", displayName: "Daryl Lu", media: mediaMessageData))
        
        self.finishSendingMessageAnimated(true)
    }
    
    func resize(image: UIImage) -> NSData {
        var compression: CGFloat = 0.9 as CGFloat
        var maxCompression: CGFloat = 0.1 as CGFloat
        var maxFileSize: Int = 250*1024
        
        var imageData: NSData = UIImageJPEGRepresentation(image, compression)
        
        while (imageData.length > maxFileSize && compression > maxCompression) {
            compression -= 0.1
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        
        return imageData
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
