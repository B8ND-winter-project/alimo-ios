//
//  ProfileView.swift
//  App
//
//  Created by dgsw8th36 on 1/11/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    enum Dialog {
        case childCode, error, deleteMember
    }
    
    @ObservedObject var vm: ProfileViewModel
    
    @EnvironmentObject var tm: TokenManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State var showDialog: Bool = false
    @State var dialog = Dialog.childCode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                AlimoLogoBar()
                AlimoAsyncAvatar(appState.member?.image, type: .large)
                    .padding(.top, 46)
                
                Text(appState.member?.name ?? "")
                    .font(Font.body)
                    .padding(.top, 24)
                Button {
                    if appState.member?.childCode == nil {
                        dialog = .error
                    } else {
                        dialog = .childCode
                    }
                    showDialog = true
                } label: {
                    Text("학생코드")
                        .font(.caption)
                        .foregroundStyle(Color.gray500)
                        .underline()
                        .padding(.top, 8)
                }
                
                AlimoFlowLayout(mode: .scrollable, items: vm.categoryList) {
                    AlimoSmallButton($0, buttonType: .none) {}.disabled(true)
                }
                .padding(.top, 36)
                .padding(.horizontal, 12)
                
                SettingCeil("알림 설정") {
                    AlimoToggle(isOn: $appState.isAlarmOn)
                }
                .padding(.top, 28)
                Color.gray100
                    .frame(height: 10)
                    .frame(maxWidth: .infinity)
                
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    SettingCeil("개인정보 이용 약관")
                }
                
                NavigationLink {
                    ServicePolicyView()
                } label: {
                    SettingCeil("서비스 정책")
                }
                
                SettingCeil("버전") {
                    Text("v\(version ?? " -")")
                        .font(.bodyLight)
                        .foregroundStyle(Color.gray500)
                }
                
                Color.gray100
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                
                Button {
                    withAnimation {
                        tm.accessToken = ""
                        tm.refreshToken = ""
                    }
                } label: {
                    SettingCeil("로그아웃", foregroundColor: .red500)
                }
                
                Button {
                    dialog = .deleteMember
                    showDialog = true
                } label: {
                    SettingCeil("회원탈퇴", foregroundColor: .red500)
                }
            }
            .background(Color.white)
            Color.gray100
                .frame(height: 100)
        }
        .alert(isPresented: $showDialog) {
            switch dialog {
            case .childCode:
                Alert(title: Text(appState.member?.childCode ?? ""),
                      message: Text("부모님께만 알려주세요"),
                      primaryButton: .cancel(Text("닫기")),
                      secondaryButton: .default(Text("복사")) {
                    guard let memberInfo = appState.member else { return }
                    UIPasteboard.general.string = memberInfo.childCode
                })
            case .error:
                Alert(title: Text("알 수 없는 에러"),
                      message: Text("다시 시도해 주세요"),
                      dismissButton: .default(Text("닫기")))
            case .deleteMember:
                Alert(title: Text("정말 탈퇴하시겠습니까?"),
                      primaryButton: .cancel(Text("아니요")),
                      secondaryButton: .destructive(Text("탈퇴")) {
                    Task {
                        await vm.byebye {
                            tm.accessToken = ""
                        }
                    }
                })
            }
        }
        .task {
            appState.fetchMember()
            await vm.fetchCategoryList()
        }
    }
}
