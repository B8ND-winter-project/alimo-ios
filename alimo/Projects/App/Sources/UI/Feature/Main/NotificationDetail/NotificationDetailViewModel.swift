//
//  NotificationDetailViewModel.swift
//  App
//
//  Created by dgsw8th71 on 2/27/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation

fileprivate let emojiService = EmojiService.live
fileprivate let notificationService = NotificationService.live

@MainActor
final class NotificationDetailViewModel: ObservableObject {
    
    let notificationId: Int
    
    @Published var emojies: [Emoji] = []
    @Published var notification: NotificationRead? = nil
    @Published var selectedEmoji: Emoji? = nil {
        didSet {
            Task {
                if let emojiType = selectedEmoji?.emojiType {
                    await patchEmoji(emoji: emojiType)
                    await fetchEmojies()
                }
            }
        }
    }
    
    init(notificationId: Int) {
        self.notificationId = notificationId
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
            notification = try await notificationService.getNotification(id: notificationId)
            dump(notification)
        } catch {
            debugPrint(error)
        }
    }
    
    func patchEmoji(emoji: EmojiType) async {
        do {
            let request = PatchEmojiRequest(reaction: emoji.rawValue)
            _ = try await emojiService.patchEmoji(notificationId: notificationId, request: request)
            print("NotificationDetailVM - fetching to patch emoji success")
        } catch {
            debugPrint(error)
        }
    }
}