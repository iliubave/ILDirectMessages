//
//  ILDirectMessagesInputContainerView.swift
//  ILDirectMessagesTextView
//
//  Created by Igar Liubavetskiy on 2017-07-03.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

protocol ILDirectMessagesInputContainerDelegate: class {
    func didChangeSize(inputContainerView: ILDirectMessagesInputContainerView, size: CGSize)
    func didTapSendButton(inputContainerView: ILDirectMessagesInputContainerView)
}

class ILDirectMessagesInputContainerView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: ILDirectTextView!
    @IBOutlet weak var leftAccessoryButton: UIButton!
    @IBOutlet weak var rightAccessoryButton: UIButton!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sendBarButtonItem: UIBarButtonItem!
    
    var minimumContainerHeight: CGFloat?
    var maximumContainerHeight: CGFloat?
    
    weak var delegate: ILDirectMessagesInputContainerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonPrepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonPrepare()
    }
    
    func commonPrepare() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        
        // Toolbar
        self.toolbar.clipsToBounds = true
        let font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        self.sendBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        
        self.addSubview(self.contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
        
        self.layoutTextView(with: self.textView.text)
    }
    
    
    @IBAction func sendBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.delegate?.didTapSendButton(inputContainerView: self)
    }
}

extension ILDirectMessagesInputContainerView {
    func layoutTextView(with text: String) {
        let originalText = self.textView.text
        let inputContainerViewBounds = self.bounds
        let constraintWidth = inputContainerViewBounds.size.width - 2 * 10.0
        let constraintSize = CGSize(width: constraintWidth, height: .greatestFiniteMagnitude)
        
        self.textView.isScrollEnabled = false
        let newTextViewSize = self.textView.sizeThatFits(constraintSize)
        let adjustedTextViewContainerViewHeight = 10.0 + 15.0 + self.toolbar.bounds.size.height + 1.0 + newTextViewSize.height
        let newSize = CGSize(width: 2 * 10.0 + newTextViewSize.width, height: adjustedTextViewContainerViewHeight)
        
        // Update constraints
        self.textViewHeightConstraint.constant = newTextViewSize.height
        self.delegate?.didChangeSize(inputContainerView: self, size: newSize)
    
        // Reset the textview
        self.textView.text = originalText
        self.textView.setContentOffset(CGPoint.zero, animated: true)
        self.textView.isScrollEnabled = true
    }
}

extension ILDirectMessagesInputContainerView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.layoutTextView(with: textView.text)
    }
}
