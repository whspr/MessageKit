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

import Foundation

open class MediaMessageSizeCalculator: MessageSizeCalculator {

    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        let sizeForMediaItem = { (maxWidth: CGFloat, item: MediaItem) -> CGSize in
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        }
        
        let sizeForMediaItems = { (maxWidth: CGFloat, items: [MediaItem]) -> CGSize in
            if items.count == 0 {
                fatalError("cant calculate size for media items, array is empty")
            }
            if items.count > 1 {
                let rowHeight = (maxWidth / 2) * items[0].size.height / items[0].size.width
                let rowsCount = CGFloat((items.count + items.count % 2) / 2)
                return CGSize(width: maxWidth, height: rowHeight * rowsCount)
            }
            return sizeForMediaItem(maxWidth, items[0])
        }
        
        switch message.kind {
        case .photo(let item):
            return sizeForMediaItem(maxWidth, item)
        case .photos(let items):
            return sizeForMediaItems(maxWidth, items)
        case .video(let item):
            return sizeForMediaItem(maxWidth, item)
        case .videos(let items):
            return sizeForMediaItems(maxWidth, items)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}
