//
//  NotificationloadRequest.swift
//  App
//
//  Created by dgsw8th61 on 2/14/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation

struct NotificationloadRequest : Encodable {
    let pageRequest : Page
//    let category : String
}


struct Page: Encodable {
    let page, size: Int
}
