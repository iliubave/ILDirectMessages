//
//  ILDirectMessagesCellSizeCalculator.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-15.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import Foundation
import UIKit

class ILDirectMessagesCellSizeCalculator: NSObject {
    
    var minimumItemWidth: Float!
    var cache: [Int: CGSize] = [:]

    func cellContainerSizeForItem(at indexPath: IndexPath, message: ILMessage, layout: ILDirectMessagesCollectionViewFlowLayout) -> CGSize {
        if let cachedSize = self.cache[message.hash] {
            return cachedSize
        }
        
        let horizontalContainerInsets = layout.messageTextViewTextContainerInsets.left + layout.messageTextViewTextContainerInsets.right
        let horizontalFrameInsets = layout.messageTextViewFrameInsets.left + layout.messageTextViewFrameInsets.right
        
        let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
        let width = layout.collectionView!.bounds.width - horizontalInsets
        let height = layout.collectionView!.bounds.height - horizontalInsets
        let layoutWidthForFixedWidthBubbles = min(width, height)
        
        
        // Check the message type
        if let message = message as? ILMediaMessage {
            var finalWidth: CGFloat = 0.0
            var finalHeight: CGFloat = 0.0
            
            guard let image = message.image else { return CGSize.zero }
            let aspectRatio = image.size.width / image.size.height
            
            // Landscape format
            if image.size.width > image.size.height {
                finalWidth = width / 1.5
                finalHeight = finalWidth / aspectRatio
            } else {
                // Portrait format
                finalWidth = width / 1.5
                finalHeight = finalWidth / aspectRatio
            }
            
            let finalSize = CGSize(width: finalWidth, height: finalHeight)
            self.cache[message.hash] = finalSize
            return finalSize
        }
        
        let horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + 30.0 + 3 * 8.0
        let maximumTextWidth = layoutWidthForFixedWidthBubbles - horizontalInsetsTotal
        
        let textViewSize = self.boundingRect(for: message.body, withConstrainedWidth: maximumTextWidth, font: layout.messageFont, textViewFrameInsets: layout.messageTextViewFrameInsets)
        
        let verticalContainerInsets = layout.messageTextViewTextContainerInsets.top + layout.messageTextViewTextContainerInsets.bottom
        let verticalFrameInsets = layout.messageTextViewFrameInsets.top + layout.messageTextViewFrameInsets.bottom + layout.topLabelHeight + layout.bottomLabelHeight
        
        let verticalInsets = verticalContainerInsets + verticalFrameInsets + layout.topLabelHeight + layout.bottomLabelHeight
        
        let finalWidth = textViewSize.width + 2.0
        let finalHeight = max(textViewSize.height + verticalInsets, 30.0) + 2.0
        
        let finalSize = CGSize(width: finalWidth, height: finalHeight)
        self.cache[message.hash] = finalSize
        
        return finalSize
    }
}

extension ILDirectMessagesCellSizeCalculator {
    func boundingRect(for text: String?, withConstrainedWidth width: CGFloat, font: UIFont, textViewFrameInsets: UIEdgeInsets) -> CGSize {
        guard let text = text else { return .zero }
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        // Dummy textview
        let frame = CGRect(origin: CGPoint.zero, size: constraintSize)
        let textView = UITextView(frame: frame)
        textView.font = font
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.text = text
        textView.textContainerInset = textViewFrameInsets
        
        return textView.sizeThatFits(constraintSize)
    }
}
