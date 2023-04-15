//
//  NewMemoView.swift
//  NotIM
//
//  Created by 임준협 on 2023/04/01.
//

import SwiftUI

struct NewMemoView: View {
    @AppStorage("userName") var userName = ""
    @Binding var createNote: Bool
    @Binding var fileArray: [String]
    @State var title: String = ""
    @State var author: String = ""
    @State var showDoneBtn: Bool = false
    @State var showExistErr: Bool = false
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                Image(systemName: "square.and.pencil.circle.fill")
                    .font(.system(size: 120))
                Text("New Note")
                    .font(.system(size: 40, weight: .bold))
                ZStack {
                    TextField("Title", text: $title)
                        .padding(20)
                        .zIndex(1)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.background)
                        .padding(10)
                        .frame(height: 70)
                        .shadow(color: .secondary, radius: 10)
                        .zIndex(0)
                }
                ZStack{
                    TextField("Author (Default: \(userName))", text: $author)
                        .padding(20)
                        .zIndex(1)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.background)
                        .padding(10)
                        .frame(height: 70)
                        .shadow(color: .secondary, radius: 10)
                        .zIndex(0)
                }
                Spacer()
                if !title.isEmpty {
                    Text("")
                        .onAppear{
                            withAnimation {
                                showDoneBtn = true
                            }
                        }
                }
                if title.isEmpty{
                    Text("")
                        .onAppear{
                            withAnimation {
                                showDoneBtn = false
                            }
                        }
                }
                if showDoneBtn {
                    Button(action: {
                        let fileManager = FileManager()
                        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                        let fileURL = path.appendingPathComponent("NotIM")

                        do {
                            let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                            if contents.contains("\(title).json") {
                                showExistErr = true
                            } else {
                                var authorName = ""
                                if author.isEmpty {
                                    authorName = userName
                                } else {
                                    authorName = author
                                }
                                saveJsonData(data: newNote(title: title, date: Date(), data: "", author: authorName, locked: false), title: "\(title).json")
                                cprint("created file \(title).json")
                                createNote = false
                                let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                                fileArray = contents
                            }
                        } catch let error as NSError {
                            print("Error access directory: \(error)")
                        }
                        
                        
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.orange)
                                .frame(width: 280, height: 70)
                            HStack{
                                Text("Create")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }.foregroundColor(Color("notColorMode"))
                            
                        }
                    })
                    .padding(.bottom, 10)
                    .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        createNote = false
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
            .alert("Memo with this title already exists.", isPresented: $showExistErr, actions: {})
        }
    }
}
