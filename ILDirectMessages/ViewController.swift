//
//  ViewController.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-14.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: ILDirectMessagesCollectionView!
    @IBOutlet weak var inputContainerView: ILDirectMessagesInputContainerView!
    
    @IBOutlet weak var inputContainerViewHeightConstraint: NSLayoutConstraint!
    var messages: [ILMessage] = []

    @IBOutlet weak var inputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ILIncomingMessageCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "ILIncomingMessageCollectionViewCell")
        let nib2 = UINib(nibName: "ILOutgoingMessageCollectionViewCell", bundle: nil)
        self.collectionView.register(nib2, forCellWithReuseIdentifier: "ILOutgoingMessageCollectionViewCell")
        
        self.inputContainerView.delegate = self
        
        self.messages = self.prepareDemoMessages()
        self.collectionView.messages = self.messages
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func prepareDemoMessages() -> [ILMessage] {
        var messages: [ILMessage] = []
        for i in 0...15 {
            let message = ILMessage()
            message.date = Date(timeIntervalSinceNow: 0)
            
            if i % 2 == 0 {
                message.isIncoming = true
                message.senderName = "Tim Cook"
            message.body = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
            } else if i % 3 == 0 {
                message.isIncoming = true
                message.senderName = "Tim Cook"
                message.body = "Why do we use it?"
            } else {
                message.isIncoming = false
                message.senderName = "Steve Jobs"
                message.body = "It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."
            }
            message.isMediaMessage = false
            
            messages.append(message)
        }
        
        return messages
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.item]
        var cell: ILDirectMessageCollectionViewCell!
        
        if !message.isIncoming {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ILOutgoingMessageCollectionViewCell", for: indexPath) as! ILOutgoingMessageCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ILIncomingMessageCollectionViewCell", for: indexPath) as! ILIncomingMessageCollectionViewCell
        }
        
        cell.configure(text: message.body)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.collectionView.collectionViewLayout as! ILDirectMessagesCollectionViewFlowLayout).sizeForItem(at: indexPath)
        
        print("\(size) for \(indexPath.item)")
        return size
    }
}

extension ViewController {
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("Show")
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let options = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.init(rawValue: options), animations: {
                let bottom = self.collectionView.frame.maxY - self.inputContainerView.frame.minY
                
                let insets = UIEdgeInsets(top: self.topLayoutGuide.length + keyboardFrame.size.height, left: 0.0, bottom: bottom + keyboardFrame.size.height, right: 0.0)
                
                self.collectionView.setContentOffset(CGPoint(x: 0.0, y: self.collectionView.contentOffset.y + insets.bottom), animated: true)
                self.inputContainerViewBottomConstraint.constant = insets.bottom
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                
            })
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("Hide")
            
            self.collectionView.contentInset = UIEdgeInsets.zero
            self.collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.inputContainerViewBottomConstraint.constant = 0.0
        }
    }
}

extension ViewController: ILDirectMessagesInputContainerDelegate {
    func sizeForInputContainerView(size: CGSize) {
        self.inputContainerViewHeightConstraint.constant = size.height
    }
}

