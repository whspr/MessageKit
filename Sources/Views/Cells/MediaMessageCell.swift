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

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class MediaMessageCell: MessageContentCell {

    /// The play button view to display on video messages.
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    /// The image view display the media content.
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    open var collectionSubview: UIView = UIView()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        imageView.fillSuperview()
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
        collectionSubview.fillSuperview()
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(collectionSubview)
        messageContainerView.addSubview(playButtonView)
        setupConstraints()
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        collectionSubview.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        switch message.kind {
        case .photo(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = true
            break
        case .video(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = false
            break
        case .photos(let mediaItems):
            playButtonView.isHidden = true
            imageView.image = nil
            let halfPadding = CGFloat(2)
            let parentFrame = messageContainerView.bounds
            var rects: [CGRect] = []
            switch mediaItems.count < 7 ? mediaItems.count : 6 {
            case 2:
                rects.append(CGRect(x: 0, y: 0, width: parentFrame.width / 2 - halfPadding, height: parentFrame.height))
                rects.append(CGRect(x: parentFrame.width / 2 + halfPadding, y: 0, width: parentFrame.width / 2, height: parentFrame.height))
                break
            case 3:
                rects.append(CGRect(x: 0, y: 0, width: parentFrame.width / 2 - halfPadding, height: parentFrame.height))
                rects.append(CGRect(x: parentFrame.width / 2 + halfPadding, y: 0, width: parentFrame.width / 2, height: parentFrame.height / 2 - halfPadding))
                rects.append(CGRect(x: parentFrame.width / 2 + halfPadding, y: parentFrame.height / 2 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 2))
                break
            case 4:
                rects.append(CGRect(x: 0, y: 0, width: (parentFrame.width / 5) * 3 - halfPadding, height: parentFrame.height))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: 0, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: parentFrame.height / 3 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding * 2))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: (parentFrame.height / 3) * 2 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3))
                break
            case 5:
                rects.append(CGRect(x: 0, y: 0, width: (parentFrame.width / 5) * 3 - halfPadding, height: parentFrame.height / 2 - halfPadding))
                rects.append(CGRect(x: 0, y: parentFrame.height / 2 + halfPadding, width: (parentFrame.width / 5) * 3 - halfPadding, height: parentFrame.height / 2 - halfPadding))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: 0, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: parentFrame.height / 3 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding * 2))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: (parentFrame.height / 3) * 2 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3))
                break
            case 6:
                rects.append(CGRect(x: 0, y: 0, width: (parentFrame.width / 5) * 3 - halfPadding, height: (parentFrame.height / 3) * 2 - halfPadding))
                rects.append(CGRect(x: 0, y: (parentFrame.height / 3) * 2 + halfPadding, width: (parentFrame.width / 10) * 3 - halfPadding, height: parentFrame.height / 2 - halfPadding))
                rects.append(CGRect(x: (parentFrame.width / 10) * 3 + halfPadding, y: (parentFrame.height / 3) * 2 + halfPadding, width: (parentFrame.width / 10) * 3 - halfPadding * 2, height: parentFrame.height / 3))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: 0, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: parentFrame.height / 3 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3 - halfPadding * 2))
                rects.append(CGRect(x: (parentFrame.width / 5) * 3 + halfPadding, y: (parentFrame.height / 3) * 2 + halfPadding, width: parentFrame.width / 2, height: parentFrame.height / 3))
                break
            default:break
            }
            var mediaId: Int = 0
            rects.forEach { rect in
                let view = UIImageView(frame: rect)
                view.image = mediaItems[mediaId].image ?? mediaItems[mediaId].placeholderImage
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.layer.masksToBounds = true
                mediaId += 1
                if mediaId == 6 && mediaItems.count > 6 {
                    let toner = UIView(frame: view.bounds)
                    toner.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                    view.addSubview(toner)
                    let label = UILabel(frame: view.bounds)
                    label.text = "+\(mediaItems.count - 6)"
                    label.textAlignment = .center
                    label.textColor = .white
                    label.font = UIFont.boldSystemFont(ofSize: 30.0)
                    view.addSubview(label)
                }
                collectionSubview.addSubview(view)
            }
            
        default:
            break
        }

        displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
    }
}
