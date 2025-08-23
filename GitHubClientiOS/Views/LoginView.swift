//
//  LoginView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("GitHubLogo") // 假设项目中有GitHub Logo图片
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("欢迎使用GitHub客户端")
                .font(.title)
                .fontWeight(.bold)
            
            Text("探索开源世界，发现优质项目")
                .foregroundColor(.secondary)
            
            Spacer()
            
            // GitHub登录按钮
            Button(action: {
                authViewModel.startAuthorization()
            }) {
                HStack {
                    Image(systemName: "github")
                        .font(.title)
                    Text("使用GitHub账号登录")
                        .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .accessibilityIdentifier("GitHubLoginButton")
            
            // 生物识别登录选项
            if authViewModel.isBiometricAvailable || authViewModel.isBiometricEnabled {
                Button(action: {
                    authViewModel.authenticateWithBiometrics()
                }) {
                    HStack {
                        Image(systemName: authViewModel.biometricType == .faceID ? "faceid" : "touchid")
                        Text(authViewModel.biometricType == .faceID ? "使用Face ID登录" : "使用Touch ID登录")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            // 继续浏览按钮 - 无需登录直接进入首页
            Button(action: {
                // 直接进入首页，不改变登录状态
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("继续浏览")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .onAppear {
            // 检查是否已登录，如果已登录则直接进入首页
            if authViewModel.isLoggedIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(item: $authViewModel.errorMessage) { error in
            Alert(
                title: Text("登录失败"),
                message: Text(error.message),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}

