//
//  HomeView.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

struct BookmarkView: View {
    
    @StateObject var vm: BookmarkViewModel
    @EnvironmentObject var tm: TokenManager
    
    @State private var scrollViewOffset: CGFloat = 0 {
        didSet {
            if isSelectorReached != (scrollViewOffset >= 84) {
                isSelectorReached = scrollViewOffset >= 84
            }
        }
    }
    @State private var isSelectorReached = false
    var hasPost: Bool = true
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    AlimoLogoBar()
                    switch vm.flow {
                    case .fetching:
                        LazyVStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { _ in
                                NotificationCellShimmer()
                            }
                        }
                        .shimmer()
                    case .success:
                        LazyVStack(spacing: 0) {
                            ForEach(vm.notificationList, id: \.uuidString) { notification in
                                VStack(spacing: 0) {
                                    NotificationCeil(notification: notification, onClickEmoji: { emoji in
                                        Task {
                                            await vm.patchEmoji(emoji: emoji, notificationId: notification.notificationId)
                                        }
                                    }, onClickBookmark: {
                                        Task {
                                            await vm.patchBookmark(notificationId: notification.notificationId)
                                        }
                                    }, vm: NotificationDetailViewModel(notificationId: notification.notificationId))
                                    Divider()
                                        .foregroundStyle(Color.gray100)
                                }
                                .onAppear {
                                    guard let index = vm.notificationList.firstIndex(where: { $0.notificationId == notification.notificationId }) else { return }
                                    
                                    if index % pagingInterval == (pagingInterval - 1) && index / pagingInterval == (vm.notificationList.count - 1) / pagingInterval {
                                        Task {
                                            await vm.fetchNotifications(isNew: false)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    case .failure:
                        Image(.noNotice)
                            .padding(.top, 115)
                        Text("북마크를 불러올 수 없어요")
                            .font(.subtitle)
                            .foregroundStyle(Color.gray500)
                            .padding(.top, 32)
                        
                    }
                }
                
                .background(
                    GeometryReader {
                        Color.clear.preference(key: ViewOffsetKey.self,
                                               value: -$0.frame(in: .named("scroll")).origin.y)
                    }
                )
                .onPreferenceChange(ViewOffsetKey.self) {
                    scrollViewOffset = $0
                }
                .overlay {
                    if .success == vm.flow && vm.notificationList.isEmpty {
                        VStack(spacing: 32) {
                            Image(.noBookMark)
                                .resizable()
                                .frame(width: 117, height: 158)
                            Text("아직 북마크가 없어요")
                                .font(.subtitle)
                                .foregroundStyle(Color.gray500)
                        }
                        .padding(.top, geo.size.height / 1.5)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .refreshable {
                Task {
                    await vm.fetchNotifications(isNew: true)
                }
            }
        }
        .task {
            vm.flow = .fetching
            await vm.fetchNotifications(isNew: true)
        }
        .onChange(of: vm.refreshFailure) {
            if $0 {
                tm.accessToken = ""
                tm.refreshToken = ""
            }
        }
    }
}
