//
//  HomeView.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var tm: TokenManager
    @State var reader: ScrollViewProxy?
    
    @State private var scrollViewOffset: CGFloat = 0 {
        didSet {
            if isSelectorReached != (scrollViewOffset >= 84) {
                isSelectorReached = scrollViewOffset >= 84
            }
        }
    }
    @State private var isSelectorReached = false
    
    @ViewBuilder
    private var categorySelector: some View {
        let category = vm.category
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                AlimoSmallButton("전체", buttonType: vm.selectedIndex == -1 ? .yellow : .none) {
                    vm.selectedIndex = -1
                    withAnimation {
                        reader?.scrollTo("top")
                    }
                }
                ForEach(0..<category.count, id: \.self) { index in
                    AlimoSmallButton(category[index], buttonType: vm.selectedIndex == index ? .yellow : .none) {
                        vm.selectedIndex = index
                        withAnimation {
                            reader?.scrollTo("top")
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
        .showShadow(show: isSelectorReached)
    }
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    AlimoLogoBar()
                        .id("top")
                    if let loudSpeaker = vm.loudSpeaker {
                        Notice( notificationspeaketitle: Text(loudSpeaker.title), memberID: Text(loudSpeaker.name), notificationId: loudSpeaker.notificationId)
                    }
                    
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section(header: categorySelector) {
                            switch vm.flow {
                            case .fetching:
                                LazyVStack(spacing: 0) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        NotificationCellShimmer()
                                    }
                                }
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
                                        .task {
                                            guard let index = vm.notificationList.firstIndex(where: { $0.notificationId == notification.notificationId }) else { return }
                                            
                                            if index % pagingInterval == (pagingInterval - 1) && index / pagingInterval == (vm.notificationList.count - 1) / pagingInterval {
                                                await vm.fetchNotifications(isNew: false)
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            case .failure:
                                Image(.noNotice)
                                    .padding(.top, 115)
                                Text("공지를 불러올 수 없어요")
                                    .font(.subtitle)
                                    .foregroundStyle(Color.gray500)
                                    .padding(.top, 32)
                            }
                        }
                    }
                    .shimmer(vm.flow == .fetching)
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
                .onAppear {
                    self.reader = reader
                }
            }
            .coordinateSpace(name: "scroll")
            .refreshable {
                Task {
                    vm.flow = .fetching
                    await vm.fetchNotifications(isNew: true)
                }
            }
            .task {
                vm.flow = .fetching
                await vm.fetchCategoryList()
                await vm.fetchLoudSpeaker()
                await vm.fetchNotifications(isNew: true)
            }
        }
        .onChange(of: vm.refreshFailure) {
            if $0 {
                tm.accessToken = ""
                tm.refreshToken = ""
            }
        }
    }
}
