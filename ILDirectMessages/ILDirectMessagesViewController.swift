//
//  ILDirectMessagesViewController.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-14.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: ILDirectMessagesCollectionView!
    @IBOutlet weak var inputContainerView: ILDirectMessagesInputContainerView!
    
    @IBOutlet weak var inputContainerViewHeightConstraint: NSLayoutConstraint!
    var messages: [ILMessage] = []

    @IBOutlet weak var inputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerViewBottomConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ILIncomingMessageCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "ILIncomingMessageCollectionViewCell")
        let nib2 = UINib(nibName: "ILOutgoingMessageCollectionViewCell", bundle: nil)
        self.collectionView.register(nib2, forCellWithReuseIdentifier: "ILOutgoingMessageCollectionViewCell")
        
        self.inputContainerView.delegate = self
        
        self.messages = self.prepareDemoMessages()
        self.collectionView.messages = self.messages
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ILDirectMessagesViewController.keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ILDirectMessagesViewController.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            let context = ILDirectMessagesCollectionViewFlowLayoutInvalidationContext.context
            context.invalidateFlowLayoutCache = true
            (self.collectionView.collectionViewLayout as? ILDirectMessagesCollectionViewFlowLayout)?.invalidateLayout(with: context)
            self.scrollToLastItem(animated: false)
        }
    }
    
    func prepareDemoMessages() -> [ILMessage] {
        var messages: [ILMessage] = []
        for i in 0...20 {
            let message = ILMessage()
            message.date = Date(timeIntervalSinceNow: 0)
            
            if i % 2 == 0 {
                message.isIncoming = false
                message.senderName = "Tim Cook"
                message.body = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
            } else if i % 3 == 0 {
                message.isIncoming = true
                message.senderName = "Tim Cook"
                message.body = "Why do we use it?"
            } else {
                let message = ILMediaMessage()
                message.date = Date(timeIntervalSinceNow: 0)
                message.isIncoming = true
                message.senderName = "Steve Jobs"
                message.url = "https://cdn.vox-cdn.com/uploads/chorus_image/image/55102943/692626382.0.jpg"
                messages.append(message)
                continue
            }
            
            messages.append(message)
        }
        
        return messages
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.item]
        var cell: ILDirectMessagesCollectionViewCell!
        
        if !message.isIncoming {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ILOutgoingMessageCollectionViewCell", for: indexPath) as! ILOutgoingMessageCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ILIncomingMessageCollectionViewCell", for: indexPath) as! ILIncomingMessageCollectionViewCell
        }
        
        cell.configure(message: message)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.collectionView.collectionViewLayout as! ILDirectMessagesCollectionViewFlowLayout).sizeForItem(at: indexPath)
        return size
    }
}

extension ILDirectMessagesViewController {
    func scrollToLastItem(animated: Bool) {
        if self.collectionView.numberOfSections == 0 {
            return
        }
        
        let lastIndexPath = IndexPath(item: self.collectionView.numberOfItems(inSection: 0) - 1, section: 0)
        
        if self.collectionView.numberOfSections < lastIndexPath.section {
            return
        }
        
        let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight < self.collectionView.bounds.height {
            let visibleRect = CGRect(x: 0.0, y: contentHeight, width: 0.0, height: 0.0)
            self.collectionView.scrollRectToVisible(visibleRect, animated: animated)
            return
        }
        
        guard let collectionViewLayout = self.collectionView.collectionViewLayout as? ILDirectMessagesCollectionViewFlowLayout else { return }
        let cellSize = collectionViewLayout.sizeForItem(at: lastIndexPath)
        let boundsHeight = self.collectionView.bounds.height - self.inputContainerView.frame.height
        let position =  (cellSize.height > boundsHeight) ? UICollectionViewScrollPosition.bottom : UICollectionViewScrollPosition.top
        
        self.collectionView.scrollToItem(at:lastIndexPath, at: position, animated: animated)
    }

    func animateSending(animated: Bool, inputContainerView: ILDirectMessagesInputContainerView) {
        // Reset the textview
        guard let textView = inputContainerView.textView else { return }
        textView.text = nil
        inputContainerView.layoutTextView(with: textView.text)
        
        // Update the layout
        self.collectionView.reloadData()
        self.scrollToLastItem(animated: animated)
    }
}

extension ILDirectMessagesViewController {
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let options = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.init(rawValue: options), animations: {
                let bottom = self.collectionView.frame.maxY - self.inputContainerView.frame.minY
                
                let insets = UIEdgeInsets(top: self.topLayoutGuide.length + keyboardFrame.size.height, left: 0.0, bottom: bottom + keyboardFrame.size.height, right: 0.0)
                
                self.collectionView.setContentOffset(CGPoint(x: 0.0, y: self.collectionView.contentOffset.y + insets.bottom), animated: true)
                self.inputContainerViewBottomConstraint.constant = insets.bottom
            }, completion: { (success) in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let options = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.init(rawValue: options), animations: {
                let bottom = self.collectionView.frame.maxY - self.inputContainerView.frame.minY

                let insets = UIEdgeInsets(top: self.topLayoutGuide.length + keyboardFrame.size.height, left: 0.0, bottom: bottom - keyboardFrame.size.height, right: 0.0)
                
                self.collectionView.setContentOffset(CGPoint(x: 0.0, y: self.collectionView.contentOffset.y + insets.bottom), animated: true)
                
                self.collectionView.contentInset = UIEdgeInsets.zero
                self.collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
                self.inputContainerViewBottomConstraint.constant = 0.0
            }, completion: { (success) in
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension ILDirectMessagesViewController {
    func message(with body: String) -> ILMessage {
        let message = ILMessage()
        message.date = Date(timeIntervalSinceNow: 0)
        message.isIncoming = true
        message.senderName = "Me"
        message.body = body
    
        return message
    }
}

extension ILDirectMessagesViewController: ILDirectMessagesInputContainerDelegate {
    func didChangeSize(inputContainerView: ILDirectMessagesInputContainerView, size: CGSize) {
        self.inputContainerViewHeightConstraint.constant = size.height
        self.scrollToLastItem(animated: false)
    }
    
    func didTapSendButton(inputContainerView: ILDirectMessagesInputContainerView) {
        if inputContainerView.textView.text.isEmpty {
            return
        }
        
        let message = self.message(with: inputContainerView.textView.text)
        self.messages.append(message)
        self.collectionView.messages = self.messages
        
        self.animateSending(animated: true, inputContainerView: inputContainerView)
    }
}

