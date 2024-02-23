//
//  ProfileView.swift
//  App
//
//  Created by dgsw8th36 on 1/11/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var vm = ProfileViewModel()
    
    @EnvironmentObject var tm: TokenManager
    
    @State var isCodeClicked: Bool = false
    @State var isAnimating: Bool = false
    
    @State var showDialog: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    HStack {
                        AlimoLogo(type: .gray)
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    
                    if let image = vm.memberInfo?.image {
                        AsyncImage(url: URL(string: image))
                        {
                            $0
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            Circle()
                                .foregroundStyle(Color.gray100)
                                .frame(width: 100, height: 100)
                        }
                    } else {
                        AlimoAvatar(type: .large)
                    }
                    
                    
                    Text(vm.memberInfo?.name ?? "")
                        .font(Font.body)
                        .padding(.top, 10)
                    
                    Button {
                        showDialog = true
                    } label: {
                        Text("학생코드")
                            .font(.caption)
                            .foregroundStyle(Color.gray500)
                            .underline()
                    }
                    
                    FlowLayout(mode: .scrollable,
                               items: vm.categoryList) {
                        Text($0)
                            .font(.caption)
                            .foregroundStyle(Color.gray500)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.gray100)
                            .clipShape(Capsule())
                    }
                               .padding()
                    
                    SettingCeil("알림 설정") {
                        AlimoToggle(isOn: $vm.isAlarmOn)
                    }
                }
                .background(Color.main50)
                
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        print("ProfileView - 개인정보 이용 약관")
                    } label: {
                        SettingCeil("개인정보 이용 약관")
                    }
                    
                    Button {
                        print("ProfileView - 개인정보 이용 약관")
                    } label: {
                        SettingCeil("서비스 정책")
                    }
                    
                    SettingCeil("버전") {
                        Text("v\(version ?? " -")")
                            .font(.bodyLight)
                            .foregroundStyle(Color.gray500)
                    }
                    
                    Divider()
                        .foregroundStyle(Color.gray100)
                        .padding(.horizontal, 12)
                    
                    Button {
                        tm.accessToken = ""
                    } label: {
                        SettingCeil("로그아웃", foregroundColor: .red500)
                    }
                }
            }
            .ignoresSafeArea()
            .background(Color.gray100)
            
            VStack {
                Spacer()
                
                RoundedCorner(radius: 4)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .shadow(radius: 0)
                    .overlay {
                        HStack {
                            Text("복사에 성공하였습니다!")
                                .font(.body)
                            
                            Spacer()
                            
                            Button {
                                isCodeClicked = false
                                isAnimating = false
                            } label: {
                                
                                Text("닫기")
                                    .font(Font.bodyLight)
                                    .foregroundStyle(Color.yellow)
                                
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .offset(y : isAnimating ? 0 : 100)
                    .animation(.bouncy(duration: 0.5), value: isAnimating)
                
            }
            
            if showDialog {
                
                Rectangle()
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.white)
                            .frame(width: 290, height: 160)
                            .overlay {
                                
                                VStack {
                                    
                                    HStack {
                                        Text("\(vm.memberInfo?.childCode ?? "")")
                                            .font(.subtitle)
                                        
                                        Button {
                                            
                                            UIPasteboard.general.string = vm.memberInfo?.childCode ?? ""
                                            showDialog = false
                                            isCodeClicked = true
                                            isAnimating = true
                                            
                                        } label: {
                                            Image(Asset.copy)
                                        }
                                        
                                    }
                                    .padding(.bottom, 5)
                                    
                                    Text("부모님께만 공유해주세요")
                                        .font(.bodyLight)
                                        .foregroundStyle(Color.gray500)
                                        .padding(.bottom, 5)
                                    
                                    HStack {
                                        
                                        Spacer()
                                        
                                        Button {
                                            showDialog = false
                                        } label: {
                                            
                                            Text("닫기")
                                                .foregroundStyle(Color.gray500)
                                                .frame(width: 50, height: 40)
                                                .background(Color.gray100)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.bottom, 5)
                                    
                                }
                            }
                            .padding(.bottom, 100)
                        
                    }
            }
        }
        
        .task {
            await vm.getInfo()
            print(vm.memberInfo?.name)
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
    }
}

public let flowLayoutDefaultItemSpacing: CGFloat = 4

public struct FlowLayout<RefreshBinding, Data, ItemView: View>: View {
    let mode: Mode
    @Binding var binding: RefreshBinding
    let items: [Data]
    let itemSpacing: CGFloat
    @ViewBuilder let viewMapping: (Data) -> ItemView
    
    @State private var totalHeight: CGFloat
    
    public init(mode: Mode,
                binding: Binding<RefreshBinding>,
                items: [Data],
                itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
                @ViewBuilder viewMapping: @escaping (Data) -> ItemView) {
        self.mode = mode
        _binding = binding
        self.items = items
        self.itemSpacing = itemSpacing
        self.viewMapping = viewMapping
        _totalHeight = State(initialValue: (mode == .scrollable) ? .zero : .infinity)
    }
    
    public var body: some View {
        let stack = VStack {
            GeometryReader { geometry in
                self.content(in: geometry)
            }
        }
        return Group {
            if mode == .scrollable {
                stack.frame(height: totalHeight)
            } else {
                stack.frame(maxHeight: totalHeight)
            }
        }
    }
    
    private func content(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lastHeight = CGFloat.zero
        let itemCount = items.count
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                viewMapping(item)
                    .padding([.horizontal, .vertical], itemSpacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = d.height
                        let result = width
                        if index == itemCount - 1 {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if index == itemCount - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(HeightReaderView(binding: $totalHeight))
    }
    
    public enum Mode {
        case scrollable, vstack
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
    static var defaultValue: CGFloat = 0
}

private struct HeightReaderView: View {
    @Binding var binding: CGFloat
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: geo.frame(in: .local).size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { h in
            binding = h
        }
    }
}


public extension FlowLayout where RefreshBinding == Never? {
    init(mode: Mode,
         items: [Data],
         itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
         @ViewBuilder viewMapping: @escaping (Data) -> ItemView) {
        self.init(mode: mode,
                  binding: .constant(nil),
                  items: items,
                  itemSpacing: itemSpacing,
                  viewMapping: viewMapping)
    }
}
