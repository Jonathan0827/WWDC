//
//  NotePreview.swift
//  NotIM
//
//  Created by 임준협 on 2023/04/02.
//

import SwiftUI
import Foundation
import LocalAuthentication

struct NoteListPreview: View {
    var title: String
    let df = DateFormatter()
    @Binding var noteList: [String]
    @Binding var userIsAuthorized: Bool
    @State var noteTitle: String = ""
    @State var noteDate: String = ""
    @State var noteAuthor: String = ""
    @State var noteLock: String = ""
    @State var buttonLock: String = ""
    @State var moveToEditor: Bool = false
    @State var noteIsLocked: Bool
    var body: some View {
        ZStack{
            ZStack(alignment: .leading){
                NavigationLink(destination: NoteEditorView(fileArray: $noteList, title: title, userIsAuthorized: $userIsAuthorized,MoveHere: $moveToEditor, noteList: $noteList), isActive: $moveToEditor){
                }
                .zIndex(1)
                VStack(alignment: .leading){
                    HStack{
                        Text(noteTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        if noteIsLocked {
                            if userIsAuthorized {
                                Image(systemName: "lock.open.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text("Updated by \(noteAuthor) on \(noteDate)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .fontWeight(.light)
                    
                }
                .zIndex(1)
                
                //            Button(action: {
                //                print("move")
                //            }, label: {
                //                VStack(alignment: .leading){
                //                    Text(noteTitle)
                //                        .font(.body)
                //                        .fontWeight(.semibold)
                //                        .foregroundColor(.primary)
                //                    Text("Updated by \(noteAuthor) on \(noteDate)")
                //                        .foregroundColor(.secondary)
                //                        .font(.caption)
                //                        .fontWeight(.light)
                //                }
                //            })
                
                 //            }
            }
            Rectangle()
                .fill(.bar)
                .opacity(0.0000000000000000000000000000000000000001)
        }
        .onAppear {
            cprint(title)
            cprint(noteIsLocked)
        }
        .swipeActions(allowsFullSwipe: false) {
//            Button(action: {
//                deleteJsonData(title: title)
//                let fileManager = FileManager()
//                guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//                let fileURL = path.appendingPathComponent("NotIM")
//
//                do {
//                    let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
//                    print(contents)
//                    noteList = contents
//                } catch let error as NSError {
//                    print("Error access directory: \(error)")
//                }
//            }, label: {
//                Image(systemName: "trash.fill")
//                    .renderingMode(.template)
//
//            })
//            .tint(.red)
//
//
            Button(action: {
                lockUnlockNote(title)
                let fileManager = FileManager()
                guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let fileURL = path.appendingPathComponent("NotIM")

                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                    print(contents)
                    noteList = contents
                } catch let error as NSError {
                    print("Error access directory: \(error)")
                }
            }, label: {
                Image(systemName: "lock.fill")
            })
            
        }
            .onTapGesture {
                moveToEditor = true
            }
        
        
        
        
        .contextMenu {
            Button(action: {
                lockUnlockNote(title)
                let fileManager = FileManager()
                guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let fileURL = path.appendingPathComponent("NotIM")
                
                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                    print(contents)
                    noteList = contents
                } catch let error as NSError {
                    print("Error access directory: \(error)")
                }
            }, label: {
                Label("\(buttonLock) this note", systemImage: noteLock)
            })
            .tint(.gray)
            Button(action: {
                deleteJsonData(title: title)
                let fileManager = FileManager()
                guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let fileURL = path.appendingPathComponent("NotIM")
                
                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                    print(contents)
                    noteList = contents
                } catch let error as NSError {
                    print("Error access directory: \(error)")
                }
            }, label: {
                Label("Delete this note", systemImage: "trash.fill")
                    .foregroundColor(.red)
                
            })
            .tint(.red)
        }
        .onAppear {
            makePreview()
        }
        
    }
    func makePreview() {
        let noteJson = loadJsonFile(title: title)
        let titleLeng = title.count-5
        let titleWithoutDotJson = title.prefix(titleLeng)
        noteTitle = String(titleWithoutDotJson)
        df.dateFormat = "yyyy/MM/dd"
        noteDate = df.string(from: Date())
        noteAuthor = noteJson!.author
        if noteJson!.locked {
            noteLock = "lock.slash.fill"
            buttonLock = "Unlock"
        } else {
            noteLock = "lock.fill"
            buttonLock = "Lock"
        }
    }
    func lockUnlockNote(_ title: String) {
        let jsonData = loadJsonFile(title: title)
        if jsonData!.locked {
            let context = LAContext()
            var error: NSError?
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                // it's possible, so go ahead and use it
                let reason = "Face ID (or Touch ID) will be used to lock/ unlock your note"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    if success {
                        saveJsonData(data: newNote(title: jsonData!.title, date: jsonData!.date, data: jsonData!.data, author: jsonData!.author, locked: false), title: title)
                        noteLock = "lock.fill"
                        buttonLock = "Lock"
                        noteIsLocked = false
                        cprint("note \(title) is unlocked")
                    } else {
                        cprint("Auth Not Success")
                    }
                }
            } else {
                // no biometrics
            }
        } else {
            let context = LAContext()
            var error: NSError?
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                // it's possible, so go ahead and use it
                let reason = "Face ID (or Touch ID) will be used to lock/ unlock your note"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    if success {
                        saveJsonData(data: newNote(title: jsonData!.title, date: jsonData!.date, data: jsonData!.data, author: jsonData!.author, locked: true), title: title)
                        noteLock = "lock.slash.fill"
                        buttonLock = "Unlock"
                        noteIsLocked = true
                        cprint("note \(title) is locked")
                    } else {
                        cprint("Auth Not Success")
                    }
                }
            } else {
                // no biometrics
            }
            
        }
    }
}
