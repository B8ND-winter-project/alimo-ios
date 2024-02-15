//
//  MemberInfoResponse.swift
//  App
//
//  Created by dgsw8th36 on 2/15/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation

struct MemberInfoResponse: Decodable {
    
    let email: String
    let grade: Int
    let room: Int
    let number: Int
    let name: String
    let image: String
    let childCode: String
    
}
