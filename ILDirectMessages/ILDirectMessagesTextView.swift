//
//  ILDirectMessagesTextView.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-07-02.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectTextView: UITextView {

    var height: CGFloat!
    
    var placeholder: String!
    var placeholderInsets: UIEdgeInsets!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonPrepare()
    }
    
    internal func commonPrepare() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 0.0
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        
        self.scrollIndicatorInsets = UIEdgeInsetsMake(self.layer.cornerRadius, 0.0, self.layer.cornerRadius, 0.0)
        
        self.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.textContainer.lineBreakMode = .byWordWrapping
        self.contentInset = UIEdgeInsets.zero
        
        self.isScrollEnabled = true
        self.scrollsToTop = false
        self.isUserInteractionEnabled = true
        
        self.font = UIFont.systemFont(ofSize: 17.0)
        self.textAlignment = .natural
        
        self.contentMode = .redraw
        self.keyboardAppearance = .default
        self.keyboardType = .default
        self.returnKeyType = .default
        
        self.text = "Type a message..."
        
        self.placeholder = nil
        self.placeholderInsets = self.textContainerInset
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
