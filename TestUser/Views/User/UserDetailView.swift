//
//  UserDetailView.swift
//  TestUser
//
//  Created by owner on 03/07/2023.
//

import SwiftUI

struct UserDetailView: View {
    
    var dismiss: (() -> Void)?
    
    @EnvironmentObject var vm: HomeViewControllerViewModel
    @StateObject var userVM = UserDetailViewViewModel()
    @State private var noteText: String = "Enter notes..."
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                
                if userVM.image != nil {
                    Image(uiImage: userVM.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                } else {
                    Image("placeholder-image")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                }
                
                HStack (alignment: .center) {
                    Text("followers: \(userVM.followers)")
                        .frame(maxWidth: .infinity)
                    Text("following: \(userVM.following)")
                        .frame(maxWidth: .infinity)
                }
                .padding(10)
                
                VStack(alignment: .leading) {
                    Text("name: \(userVM.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("company: \(userVM.company)")
                    Text("blog: \(userVM.blog)")
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .border(.gray, width: 1)
                
                Text("Notes:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    
                    TextEditor(text:$userVM.notes)
                        .frame(height: 150)
                        .cornerRadius(10, antialiased: true)
                        .font(.body)
                        .padding()
                        .border(Color.gray, width: 1)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    
                    if self.userVM.notes.isEmpty {
                        TextEditor(text: $noteText)
                            .font(.body)
                            .foregroundColor(.gray)
                            .disabled(true)
                            .padding()
                    }
                }
                
                Button(action: {
                    userVM.saveNotes()
                    hideKeyboard()
                    dismiss?()
                }) {
                    Text("Save")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                        .background(
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        )
                        .padding()
                }
                Spacer()
            }
            
            .padding()
            .onAppear {
                userVM.fetchUserDetail(with: vm.selectedUser ?? "")
            }
        }
        .navigationTitle(vm.selectedUser ?? "")
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        UserDetailView().environmentObject({ () -> HomeViewControllerViewModel in
            let vm = HomeViewControllerViewModel()
            vm.selectedUser = "winter"
            return vm
        }())
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
