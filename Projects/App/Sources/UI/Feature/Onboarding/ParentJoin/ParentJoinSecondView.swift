//
//  ParentJoinSecondView.swift
//  App
//
//  Created by dgsw8th36 on 1/11/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import SwiftUI

struct ParentJoinSecondView: View {
    
    @EnvironmentObject var vm: ParentJoinViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var emailFocused: Bool
    @FocusState private var pwFocused: Bool
    @FocusState private var pwCheckFocused: Bool
    
    let childName: String?
    
    var body: some View {
        
        let isCompleted = !vm.email.isEmpty && !vm.pw.isEmpty && !vm.pwCheck.isEmpty
        let isSame: Bool = vm.pw == vm.pwCheck
        let isCorrectPw = Regex.validatePassword(vm.pw) && Regex.validatePassword(vm.pwCheck)
        
        VStack {
            HStack {
                Text("\(childName ?? "")\(childName != nil ? " " : "")학부모님 안녕하세요!")
                    .font(.subtitle)
                    .foregroundStyle(Color.main900)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .padding(.leading, 24)
                Spacer()
            }
            
            AlimoTextField("이메일", text: $vm.email)
                .focused($emailFocused)
                .keyboardType(.emailAddress)
                .onSubmit {
                    pwFocused = true
                }
            
            AlimoTextField("비밀번호", text: $vm.pw, type: .password)
                .focused($pwFocused)
                .onSubmit {
                    pwCheckFocused = true
                }
            
            AlimoTextField("비밀번호 재입력", text: $vm.pwCheck, type: .password)
                .focused($pwCheckFocused)
            
            HStack {
                Group {
                    if !isCorrectPw && (!vm.pw.isEmpty || !vm.pwCheck.isEmpty) {
                        Text("5~18자 영문, 숫자, 특수문자")
                    } else if vm.pw != vm.pwCheck {
                        Text("비밀번호가 일치하지 않습니다")
                    }
                }
                .font(.caption)
                .padding(.top, 4)
                .foregroundStyle(Color.red500)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            HStack {
                Text("이미 계정이 있으시다면?")
                    .font(.caption)
                    .foregroundStyle(Color.gray500)
                NavigationLink {
                    ParentLoginFirstView()
                } label: {
                    Text("로그인")
                        .font(.caption)
                        .foregroundStyle(Color.main500)
                        .underline()
                }
            }
            .padding(.bottom, 16)
            
            let isOk = isCompleted && isSame && isCorrectPw
            
            let buttonType: AlimoButtonType = isOk ? .yellow : .none
            
            NavigationLink(isActive: $vm.isCorrectSignUp) {
                ParentJoinThirdView()
                    .environmentObject(vm)
            } label: {
            }
            
            AlimoButton("다음", buttonType: buttonType, isLoading: vm.isFetching) {
                Task {
                    await vm.signUp()
                }
            }
            .disabled(!(isCompleted && isSame && isOk))
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden()
        .alimoToolbar("회원가입") {
            NavigationUtil.popToRootView()
        }
        .alert(isPresented: $vm.showDialog) {
            Alert(title: Text(vm.dialogMessage),
                  dismissButton: .default(Text("닫기")))
        }
    }
}
