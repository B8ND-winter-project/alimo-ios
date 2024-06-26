//
//  Notice.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI


struct Notice: View {
    var notificationspeaketitle: Text
    var memberID: Text
    var notificationId: Int

    var body : some View {
        NavigationLink {
            NotificationDetailView(vm: NotificationDetailViewModel(notificationId: notificationId))
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.main100)
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .cornerRadius(5)
                HStack {
                    Image(Asset.loudSpeaker)
                        .renderingMode(.template)
                        .foregroundStyle(Color.main300)
                    
                    notificationspeaketitle
                        .font(.label)
                        .foregroundColor(.main900)
                    
                    memberID
                        .font(.label)
                        .foregroundColor(.gray500)
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 6)
        }
    }
}
