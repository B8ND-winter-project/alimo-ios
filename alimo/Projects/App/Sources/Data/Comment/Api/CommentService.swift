//
//  CommentService.swift
//  App
//
//  Created by dgsw8th71 on 2/27/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation

fileprivate let client = AlimoHttpClient.live

final class CommentService {
    
    private let commentPath = "/comment"
    
    func createComment(notificationId: Int, request: CreateCommentRequest) async throws -> Response {
        try await client.request("\(commentPath)/create/\(notificationId)", Response.self, method: .post, parameters: request)
    }
    
    func deleteComment(commentId: Int) async throws -> Response {
        try await client.request("\(commentPath)/delete/\(commentId)", Response.self, method: .delete)
    }
    
    func deleteSubComment(commentId: Int) async throws -> Response {
        try await client.request("\(commentPath)/deleteSub/\(commentId)", Response.self, method: .delete)
    }
    
}

extension CommentService {
    static let live = CommentService()
}
