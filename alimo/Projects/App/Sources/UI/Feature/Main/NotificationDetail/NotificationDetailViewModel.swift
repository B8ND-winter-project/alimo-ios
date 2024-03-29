//
//  NotificationDetailViewModel.swift
//  App
//
//  Created by dgsw8th71 on 2/27/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import UIKit

fileprivate let emojiService = EmojiService.live
fileprivate let notificationService = NotificationService.live
fileprivate let commentService = CommentService.live
fileprivate let memberService = MemberService.live
fileprivate let bookmarkService = BookmarkService.live

@MainActor
final class NotificationDetailViewModel: ObservableObject {
    
    let notificationId: Int
    
    @Published var emojies: [Emoji] = []
    @Published var notification: NotificationRead? = nil
    @Published var selectedEmoji: EmojiType? = nil
    @Published var contentText = ""
    private var isNotificationFetching = false
    @Published var selectedComment: Comment? = nil
    
    init(notificationId: Int) {
        self.notificationId = notificationId
    }
    
    func getIsFetching() -> Bool {
        return isNotificationFetching
    }
    
    func fetchEmojies() async {
        do {
            emojies = try await emojiService.loadEmoji(notificationId: notificationId)
            dump(emojies)
        } catch {
            debugPrint(error)
        }
    }
    
    func fetchNotification() async {
        do {
            let notification = try await notificationService.getNotification(id: notificationId)
            self.notification = notification
            selectedEmoji = notification.emoji
            dump(notification)
        } catch {
            debugPrint(error)
        }
    }
    
    func createComment() async {
        defer { contentText = "" }
        do {
            let parentId = selectedComment == nil ? nil : selectedComment!.commentId
            let request = CreateCommentRequest(content: contentText,
                                               parentId: parentId)
            _ = try await commentService.createComment(notificationId: notificationId, request: request)
            print("NotificationDetailVM - comment created")
        } catch {
            debugPrint(error)
        }
    }
    
    func patchBookmark() async {
        do {
            if var notification = notification {
                let res = try await bookmarkService.patchBookmark(notificationId: notification.notificationId)
                dump(res)
                notification.isBookMarked.toggle()
                self.notification = notification
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func patchEmoji(emoji: EmojiType) async {
        do {
            if var notification = notification {
                let request = PatchEmojiRequest(reaction: emoji.rawValue)
                let res = try await emojiService.patchEmoji(notificationId: notificationId, request: request)
                dump(res)
                await self.fetchEmojies()
                
                // handle notification emoji
                if notification.emoji == emoji {
                    notification.emoji = nil
                    selectedEmoji = nil
                } else {
                    notification.emoji = emoji
                    selectedEmoji = emoji
                }
                self.notification = notification
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func downloadImages(images: [ImageOrFile], callback: @escaping ([UIImage]) -> Void) async {
        var result: [UIImage] = []
        for image in images {
            await downloadImage(image: image) {
                result.append($0)
            }
        }
        callback(result)
    }
    
    func downloadImage(image: ImageOrFile, callback: @escaping (UIImage) -> Void) async {
        guard let url = URL(string: image.fileUrl) else {
            print("NotificationDetailVM - Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("NotificationDetailVM - Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let image = UIImage(data: data) {
                callback(image)
            } else {
                print("NotificationDetailVM - Invalid image data")
            }
        }.resume()
    }
    func downloadFile(file: ImageOrFile,
                      callback: @escaping (Data) -> Void) async {
        guard let url = URL(string: file.fileUrl) else {
            print("NotificationDetailVM - Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("NotificationDetailVM - Failed to download file: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            callback(data)
        }.resume()
    }
    
}
