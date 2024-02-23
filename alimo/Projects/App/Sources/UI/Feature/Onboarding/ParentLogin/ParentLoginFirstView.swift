//
//  ParentLoginFirstView.swift
//  App
//
//  Created by dgsw8th36 on 1/11/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import SwiftUI

struct ParentLoginFirstView: View {
    
    @ObservedObject var vm = ParentLoginViewModel()
    
    @EnvironmentObject var tm: TokenManager
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("학부모님 안녕하세요!")
                    .font(.subtitle)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .padding(.leading, 24)
                Spacer()
            }
            
            AlimoTextField("아이디를 입력하세요", text: $vm.email)
            
            AlimoTextField("비밀번호를 입력하세요", text: $vm.pw, textFieldType: .password)
            
            NavigationLink {
                ParentFindPWFirstView()
            } label: {
                HStack {
                    Spacer()
                    Text("비밀번호 찾기")
                        .font(.caption)
                        .foregroundStyle(Color.gray500)
                        .padding(.top, 5)
                        .padding(.trailing, 24)
                }
            }
            
            Spacer()
            
            HStack {
                Text("아직 계정이 없으시다면?")
                    .font(.caption)
                    .foregroundStyle(Color.gray500)
                NavigationLink {
                    ParentJoinFirstView()
                } label: {
                    Text("회원가입")
                        .font(.caption)
                        .foregroundStyle(Color.main500)
                        .underline()
                }
            }
            .padding(.bottom, 5)
            
            let isCompleted = vm.email != "" && vm.pw != ""
            let isCorrectPw = Regex.validateInput(vm.pw)
            let isOk = isCompleted && isCorrectPw
            
            let buttonType: AlimoButtonType = isOk ? .yellow : .none
            
            AlimoButton("로그인", buttonType: buttonType) {
                Task {
                    await vm.signIn { accessToken, refreshToken in
                        tm.accessToken = accessToken
                        tm.refreshToken = refreshToken
                    }
                }
            }
            .disabled(!isOk)
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true)
        .alimoToolbar("로그인") {
            dismiss()
        }
    }
}