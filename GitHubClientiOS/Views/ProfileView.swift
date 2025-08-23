//
//  ProfileView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var repositoryViewModel: RepositoryListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if profileViewModel.isLoading && profileViewModel.currentUser == nil {
                    ProgressView("加载个人资料...")
                }
                else if let user = profileViewModel.currentUser {
                    List {
                        // 用户信息
                        Section {
                            VStack(alignment: .center, spacing: 16) {
                                AsyncImageView(urlStr: user.avatarUrl,
                                avatarPlaceholder: "person.circle.fill")
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                
                                Text(user.login)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                /*
                                HStack(spacing: 24) {
                                    VStack {
                                        Text(String(user.followers))
                                            .font(.headline)
                                        Text("关注者")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text(String(user.following))
                                            .font(.headline)
                                        Text("关注中")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                 */
                            }
                            .padding(.vertical)
                        }
                        
                        // 生物识别设置
                        Section(header: Text("安全设置")) {
                            Toggle(isOn: $authViewModel.isBiometricEnabled) {
                                HStack {
                                    Image(systemName: authViewModel.biometricType == .faceID ? "faceid" : "touchid")
                                    Text(authViewModel.biometricType == .faceID ? "启用Face ID登录" : "启用Touch ID登录")
                                }
                            }
                            .onChange(of: authViewModel.isBiometricEnabled) { newValue in
                                authViewModel.toggleBiometricLogin(enabled: newValue)
                            }
                            .disabled(!authViewModel.isBiometricAvailable)
                        }
                        
                        // 我的仓库
                        Section(header: Text("我的仓库")) {
                            if repositoryViewModel.isLoading && repositoryViewModel.currentUserRepositories.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if !repositoryViewModel.currentUserRepositories.isEmpty {
                                ForEach(repositoryViewModel.currentUserRepositories) { repository in
                                    RepositoryRow(repository: repository)
                                }
                                
                                if repositoryViewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            } else {
                                Text("没有找到仓库")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 登出按钮
                        Section {
                            Button(action: {
                                profileViewModel.logout()
                            }) {
                                Text("退出登录")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationTitle("个人资料")
                    .onAppear {
                        if repositoryViewModel.currentUserRepositories.isEmpty {
                            repositoryViewModel.loadCurrentUserRepositories()
                        }
                    }
                } else {
                    Text("无法加载个人资料")
                        .foregroundColor(.secondary)
                        .navigationTitle("个人资料")
                }
            }
            .alert(item: $profileViewModel.errorMessage) { error in
                Alert(
                    title: Text("加载失败"),
                    message: Text(error.message),
                    primaryButton: .default(Text("取消")) {
                        profileViewModel.errorMessage = nil
                    },
                    secondaryButton: .default(Text("重试")) {
                        profileViewModel.loadCurrentUserProfile()
                    }
                )
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ProfileViewModel())
            .environmentObject(RepositoryListViewModel())
            .environmentObject(AuthViewModel())
    }
}

