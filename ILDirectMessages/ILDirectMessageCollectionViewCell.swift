//
//  ILDirectMessageCollectionViewCell.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-16.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var messageBubbleBackgroundImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var messageContainerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelHeightConstraint: NSLayoutConstraint!
    
    var profileImageViewSize: CGSize! = CGSize(width: 30.0, height: 30.0)
    
    var textViewFrameInsets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: self.textViewTopConstraint.constant,
                                left: self.textViewLeadingConstraint.constant,
                                bottom: self.textViewBottomConstraint.constant,
                                right: self.textViewTrailingConstraint.constant)
        }
        
        set(newTextViewFrameInsets) {
            self.textViewTopConstraint.constant = newTextViewFrameInsets.top
            self.textViewLeadingConstraint.constant = newTextViewFrameInsets.left
            self.textViewBottomConstraint.constant = newTextViewFrameInsets.bottom
            self.textViewTrailingConstraint.constant = newTextViewFrameInsets.right
        }
    }
    
    var nib: UINib!
    var cellReuseIdentifier: String!
    var mediaCellReuseIdentifier: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textView.textContainer.lineBreakMode = .byWordWrapping
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.topLabel.text = nil
        self.bottomLabel.text = nil
        
        self.profileImageView.image = nil
        
        self.messageBubbleBackgroundImageView.image = nil
        
        self.textView.text = nil
    }
    
    func configure(text: String) {
        self.textView.text = text
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let customLayoutAttributes = layoutAttributes as? ILDirectMessagesCollectionViewLayoutAttributes else { return }
        
        if (!UIEdgeInsetsEqualToEdgeInsets(customLayoutAttributes.textViewTextContainerInsets, self.textView.textContainerInset)) {
            self.textView.textContainerInset = customLayoutAttributes.textViewTextContainerInsets
        }
        
        if (!UIEdgeInsetsEqualToEdgeInsets(customLayoutAttributes.textViewFrameInsets, self.textViewFrameInsets)) {
            self.textViewTopConstraint.constant = customLayoutAttributes.textViewFrameInsets.top
            self.textViewBottomConstraint.constant = customLayoutAttributes.textViewFrameInsets.bottom
            self.textViewLeadingConstraint.constant = customLayoutAttributes.textViewFrameInsets.left
            self.textViewLeadingConstraint.constant = customLayoutAttributes.textViewFrameInsets.right
        }
        
        if (customLayoutAttributes.messageContainerViewWidth != self.messageContainerWidthConstraint.constant) {
            self.messageContainerWidthConstraint.constant = customLayoutAttributes.messageContainerViewWidth
        }
        
        if (customLayoutAttributes.topLabelHeight != self.topLabelHeightConstraint.constant) {
            self.topLabelHeightConstraint.constant = customLayoutAttributes.topLabelHeight
        }

        if (customLayoutAttributes.bottomLabelHeight != self.bottomLabelHeightConstraint.constant) {
            self.bottomLabelHeightConstraint.constant = customLayoutAttributes.bottomLabelHeight
        }
        
        if self.isKind(of: ILIncomingMessageCollectionViewCell.self) {
            if (__CGSizeEqualToSize(self.profileImageViewSize, customLayoutAttributes.incomingProfileImageViewSize)) {
                self.profileImageViewSize = customLayoutAttributes.incomingProfileImageViewSize
            }
        } else {
            if (__CGSizeEqualToSize(self.profileImageViewSize, customLayoutAttributes.outgoingProfileImageViewSize)) {
                self.profileImageViewSize = customLayoutAttributes.outgoingProfileImageViewSize
            }
        }
        
    }
}
