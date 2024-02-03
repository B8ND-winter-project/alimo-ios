//
//  AlimoAvatar.swift
//  App
//
//  Created by dgsw8th71 on 2/3/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import SwiftUI

struct AlimoAvatar: View {
    
    var image: String
    var type: AlimoAvatarType
    
    init(_ image: String = AppAsset.Assets.profileImage.name,
         type: AlimoAvatarType = .medium
    ) {
        self.image = image
        self.type = type
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: type.size, height: type.size)
            .clipShape(Circle())
    }
}

#Preview {
    AlimoAvatar()
}
