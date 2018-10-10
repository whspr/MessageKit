/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

/// A subclass of `MessageCollectionViewCell` used to display text, media, and location messages.
open class MessageContentCell: MessageCollectionViewCell {

    /// The image view displaying the avatar.
//    open var avatarView = AvatarView()

    /// The container used for styling and holding the message's content view.
    open var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()

    /// The top label of the cell.
    open var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The top label of the messageBubble.
    open var messageTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    /// The bottom label of the messageBubble.
    open var messageBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()
    
    open var messageDeliveryIndicator: UIImageView = {
        let view = UIImageView()
//        view.isHidden = true
        return view
    }()

    
    enum ForwardIndicatorDirection {
        case left(CGRect)
        case right(CGRect)
    }
    
    private let forwardIndicator = UIView()
    private let forwardbackground = UIView()
    
    open var isForwarded: Bool = false
    open var forwardIncome: Bool = false
    open var forwardFillColor: UIColor? = nil
    
    /// The `MessageCellDelegate` for the cell.
    open weak var delegate: MessageCellDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setupSubviews() {
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(messageDeliveryIndicator)
//        contentView.addSubview(avatarView)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        messageTopLabel.text = nil
        messageBottomLabel.text = nil
    }
    
    var bubble: Bool = false

    // MARK: - Configuration

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        layoutMessageContainerView(with: attributes)
        layoutBottomLabel(with: attributes)
        layoutCellTopLabel(with: attributes)
        layoutMessageTopLabel(with: attributes)
        layoutDeliveryIndicator(with: attributes)
//        layoutAvatarView(with: attributes)
    }

    /// Used to configure the cell.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` this cell displays.
    ///   - indexPath: The `IndexPath` for this cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell is contained.
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        delegate = messagesCollectionView.messageCellDelegate

        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
        let isSelected = displayDelegate.isSelected(for: message, at: indexPath, in: messagesCollectionView)
        let (isForwarded, forwardIncome) = displayDelegate.isForwarded(for: message, at: indexPath, in: messagesCollectionView)
        let forwardFillColor = displayDelegate.forwardedFillColor(for: message, at: indexPath, in: messagesCollectionView)
        let forwardBckgColor = displayDelegate.forwardedBackgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let deliveryIndicator = displayDelegate.deliveryIndicatorImage(for: message, at: indexPath, in: messagesCollectionView)
        let offsetRect = dataSource.forwardOffset(at: indexPath)
        let offset = offsetRect.width
        self.bubble = messageStyle.isBubble()

        messageContainerView.backgroundColor = messageColor
        messageContainerView.style = messageStyle
        messageContainerView.isSelected = isSelected
        messageContainerView.isForwarded = isForwarded
        messageContainerView.ForwardIncome = forwardIncome
        messageContainerView.forwardedOffset = offset
        self.isForwarded = isForwarded
        self.forwardIncome = forwardIncome
        self.forwardFillColor = forwardFillColor
        messageDeliveryIndicator.image = deliveryIndicator
        
        let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)

        cellTopLabel.attributedText = topCellLabelText
        messageTopLabel.attributedText = topMessageLabelText
        messageBottomLabel.attributedText = bottomText
        messageBottomLabel.superview?.bringSubviewToFront(messageBottomLabel)
        messageTopLabel.superview?.bringSubviewToFront(messageTopLabel)
        
        drawForwardIndicator(from: offsetRect, fillWith: forwardBckgColor)
        
        if messageContainerView.isSelected {
            self.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        } else {
            self.contentView.backgroundColor = .clear
        }
        
    }
    
    private func drawForwardIndicator(from offset: CGSize, fillWith color: UIColor) {
        
        if !isForwarded {
            self.forwardIndicator.isHidden = true
            self.forwardbackground.isHidden = true
            return
        }
        
        let rect = CGRect(x: offset.width + 2, y: 0, width: 3, height: frame.height)
        self.forwardIndicator.frame = rect
        self.forwardIndicator.backgroundColor = self.forwardFillColor
        self.forwardIndicator.isHidden = !self.isForwarded
        self.addSubview(forwardIndicator)
        
        self.forwardbackground.frame = CGRect(offset.width + 2, 0, offset.height == 0 ? frame.width - offset.width - 2: offset.height - 6
            , frame.height)
        self.forwardbackground.backgroundColor = color
        self.forwardbackground.isHidden = !self.isForwarded
        self.addSubview(forwardbackground)
        self.sendSubviewToBack(forwardbackground)

    }

    /// Handle tap gesture on contentView and its subviews.
    open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        var isTapHandled: Bool = false
        switch true {
        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            delegate?.didTapMessage(in: self)
            isTapHandled = true
//        case avatarView.frame.contains(touchLocation):
//            delegate?.didTapAvatar(in: self)
//        case cellTopLabel.frame.contains(touchLocation):
//            delegate?.didTapCellTopLabel(in: self)
//            isTapHandled = true
        case messageTopLabel.frame.contains(touchLocation):
            delegate?.didTapMessageTopLabel(in: self)
            isTapHandled = true
        case messageBottomLabel.frame.contains(touchLocation):
            delegate?.didTapMessageBottomLabel(in: self)
            isTapHandled = true
        default:
            break
        }
        if self.contentView.frame.contains(touchLocation) && !isTapHandled {
            delegate?.didTap(in: self)
        }
    }
    
    open func handleLongTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        var isTapHandled: Bool = false
        switch true {
        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            delegate?.didLongTapMessage(in: self)
            isTapHandled = true
        case cellTopLabel.frame.contains(touchLocation):
            delegate?.didLongTapCellTopLabel(in: self)
            isTapHandled = true
        case messageTopLabel.frame.contains(touchLocation):
            delegate?.didLongTapMessageTopLabel(in: self)
            isTapHandled = true
        case messageBottomLabel.frame.contains(touchLocation):
            delegate?.didLongTapMessageBottomLabel(in: self)
            isTapHandled = true
        default:
            break
        }
        if self.contentView.frame.contains(touchLocation) && !isTapHandled {
            delegate?.didLongTap(in: self)
        }
    }

    open func setSelected(_ color: UIColor) {
        messageContainerView.isSelected = !messageContainerView.isSelected
        if messageContainerView.isSelected {
            self.contentView.backgroundColor = color
        } else {
            self.contentView.backgroundColor = .clear
        }
    }
    
    open func isSelected() -> Bool {
        return messageContainerView.isSelected
    }
    
    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.frame.contains(touchPoint)
    }

    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }

    // MARK: - Origin Calculations

    open func layoutDeliveryIndicator(with attributes: MessagesCollectionViewLayoutAttributes) {
        let deliveryMarkerSize: CGFloat = 16
        if attributes.messageIsForwarded {
            self.messageDeliveryIndicator.isHidden = true
        } else {
            switch attributes.avatarPosition.horizontal {
            case .cellLeading:
                self.messageDeliveryIndicator.isHidden = true
                break
            case .cellTrailing:
                self.messageDeliveryIndicator.tintColor = UIColor(red:0.22, green:0.56, blue:0.24, alpha:1)
                self.messageDeliveryIndicator.isHidden = false
                var origin: CGPoint = .zero
                origin.y = self.messageBottomLabel.frame.maxY - deliveryMarkerSize
                if !attributes.messageForwardedIncome && attributes.messageIsForwarded {
                    origin.x = self.messageBottomLabel.frame.maxX - deliveryMarkerSize - 50
                } else {
                    origin.x = self.messageBottomLabel.frame.maxX - deliveryMarkerSize - 18
                }
                self.messageDeliveryIndicator.frame = CGRect(origin: origin, size: CGSize(width: deliveryMarkerSize, height: deliveryMarkerSize))
            case .natural:
                fatalError(MessageKitError.avatarPositionUnresolved)
            }
        }
    }
    /// Positions the cell's `AvatarView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero

        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            break
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }

//        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }

    /// Positions the cell's `MessageContainerView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.messageContainerPadding.top
        case .messageCenter:
            if attributes.avatarSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top
        }
        let offset = attributes.messageForwardOffset
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            if attributes.messageIsForwarded {
                origin.x = offset.width
            } else {
                origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left
            }
        case .cellTrailing:
            if attributes.messageIsForwarded {
                origin.x = offset.width + CGFloat(8)
            } else {
                origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right
            }
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }
        messageContainerView.frame = CGRect(origin: origin, size: attributes.messageContainerSize)
        
    }

    /// Positions the cell's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
    }
    
    /// Positions the message bubble's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageTopLabel.textAlignment = .left
        messageTopLabel.textInsets = UIEdgeInsets(left: attributes.messageForwardOffset.width + 16)
        
        let y = messageContainerView.frame.minY// - attributes.messageContainerPadding.top - attributes.messageTopLabelSize.height
        let origin = CGPoint(x: 0, y: y)
        
        messageTopLabel.frame = CGRect(origin: origin, size: CGSize(width: attributes.frame.width, height: 16))
//        messageTopLabel.frame = CGRect(origin: origin, size: attributes.messageTopLabelSize)
    }

    /// Positions the cell's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets
        
        // check is our bottom label from income message
        if messageBottomLabel.textAlignment == .left {
            // change text aligment to .right
            messageBottomLabel.textAlignment = .right
            // calc right offset for label + padding from right message edge
            if attributes.messageIsForwarded {
//                if attributes.messageForwardedIncome {
//                    messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.frame.width - attributes.messageContainerSize.width + 8)
//                } else {
//                    messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.frame.width - attributes.messageForwardOffset.width - attributes.messageContainerSize.width)
//                }
                messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.frame.width - attributes.messageForwardOffset.width - attributes.messageContainerSize.width + 8)
            } else {
                messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.frame.width - attributes.messageContainerSize.width + 8)
            }
        } else {
            if attributes.messageIsForwarded {
//                if attributes.messageForwardedIncome {
//                    messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.messageForwardOffset.height + 24)
//                } else {
//                    messageBottomLabel.textInsets = UIEdgeInsets(right: 42)
//                }
                messageBottomLabel.textInsets = UIEdgeInsets(right: attributes.frame.width - attributes.messageForwardOffset.width - attributes.messageContainerSize.width + 8)
            }
        }

        // put our bottom label into message via setting upper Y coord
        let y = messageContainerView.frame.maxY - 16
        let origin = CGPoint(x: 0, y: y)
        messageBottomLabel.frame = CGRect(origin: origin, size: attributes.messageBottomLabelSize)
    }
    
}
