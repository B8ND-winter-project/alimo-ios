//
//  Icons.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

struct IconCeil: View {
    
    var emoji: EmojiType?
    var isBookmarked: Bool
    var hasEmoji = true
    var onClickEmoji: (EmojiType) -> Void
    var onClickBookmark: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if hasEmoji {
                AlimoEmojiMenu {
                    onClickEmoji($0)
                } content: {
                    if let emoji = emoji {
                        Image(emoji.image)
                            .resizable()
                            .frame(width: 28, height: 28)
                    } else {
                        Image("AddImoji")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                }
            }
            
            Spacer()
            
            Button {
                onClickBookmark()
            } label: {
                if isBookmarked {
                    Image(AppAsset.Assets.clickedBookmark.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                } else {
                    Image(AppAsset.Assets.bookmark.name)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.gray500)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
}
