//
//  NoteEditorView.swift
//  NotIM
//
//  Created by 임준협 on 2023/04/02.
//

import SwiftUI
import LocalAuthentication
import UniformTypeIdentifiers
import Combine

struct NoteEditorView: View {
    enum FocusedField {
            case firstName, lastName
    }
    @Binding var fileArray: [String]
    @State var title: String
    @State private var jsonData = Data()

    @State private var noteBody: String = ""
    @State private var noteTitle: String = ""
    @State private var showSettings: Bool = false
    @State private var noteAuthor: String = ""
    @Binding var userIsAuthorized: Bool
    @Binding var MoveHere: Bool
    @State var noteIsLocked: Bool = false
    @State var shareNote: Bool = false
    @Binding var noteList: [String]
    @State private var NoteTitleWithoutDotJson: String = ""
    @State private var NoteIsLockedAndIsNotUnlocked: Bool = false
    @Environment(\.presentationMode) private var PresentationMode
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        ZStack {
            VStack{
                TextField(text: $noteTitle){
                    Text("Title")
                        .foregroundColor(.secondary)
                }
                .disabled(NoteIsLockedAndIsNotUnlocked)
                .onReceive(Just(noteTitle)) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        if NoteIsLockedAndIsNotUnlocked{
                        } else {
                            saveJsonData(data: newNote(title: noteTitle, date: Date(), data: noteBody, author: noteAuthor, locked: noteIsLocked), title: title)
                        }
                    })
                }
                .font(.system(size: 30, weight: .semibold))
                ZStack{
                    TextEditor(text: $noteBody)
                        .disabled(NoteIsLockedAndIsNotUnlocked)
                        .onReceive(Just(noteBody)) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.01, execute: {
                                if NoteIsLockedAndIsNotUnlocked{
                                } else {
                                    saveJsonData(data: newNote(title: noteTitle, date: Date(), data: noteBody, author: noteAuthor, locked: noteIsLocked), title: title)
                                }
                            })
                        }
                        .font(.body)
                        .zIndex(0)
                    if noteBody.isEmpty {
                        VStack{
                            HStack{
                                Text("Body")
                                    .foregroundColor(.secondary)
                                    .zIndex(1)
                                    .padding(.top, 10)
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
//                NoteIsLockedAndIsNotUnlocked = true
                noteIsLocked = loadJsonFile(title: title)!.locked
                print(noteIsLocked)
                if noteIsLocked{
                    if userIsAuthorized{
                        let noteJson = loadJsonFile(title: title)
                        noteTitle = noteJson!.title
                        noteBody = noteJson!.data
                        noteAuthor = noteJson!.author
                        GetNoteTitle()
                    } else {
                        NoteIsLockedAndIsNotUnlocked = true
                        let context = LAContext()
                        var error: NSError?
                        // check whether biometric authentication is possible
                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                            // it's possible, so go ahead and use it
                            let reason = "Face ID (or Touch ID) will be used to lock/ unlock your note"
                            
                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                                // authentication has now completed
                                if success {
                                    print("Auth Success")
                                    let noteJson = loadJsonFile(title: title)
                                    noteTitle = noteJson!.title
                                    noteBody = noteJson!.data
                                    noteAuthor = noteJson!.author
                                    GetNoteTitle()
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                        NoteIsLockedAndIsNotUnlocked = false
                                    })
                                    userIsAuthorized = true
                                } else {
                                    print("Auth Not Success")
                                }
                            }
                            
                        }
                        else {
                            // no biometrics
                        }
                    }
                } else {
                    let noteJson = loadJsonFile(title: title)
                    noteTitle = noteJson!.title
                    noteBody = noteJson!.data
                    noteAuthor = noteJson!.author
                    GetNoteTitle()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        NoteIsLockedAndIsNotUnlocked = false
                    })
                    GetNoteTitle()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//
//                    Button(action: {
//                        deleteJsonData(title: title)
//                        let fileManager = FileManager()
//                        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//                        let fileURL = path.appendingPathComponent("NotIM")
//
//                        do {
//                            let contents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
//                            cprint(contents)
//                            noteList = contents
//                        } catch let error as NSError {
//                            print("Error access directory: \(error)")
//                        }
//                    }, label: {
//                        Image(systemName: "trash")
//                    })
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        cprint("Share")
                        shareNote = true
                        self.exportJSON()

                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                }
            }
            .zIndex(0)
            .padding(10)
            .navigationTitle("\(NoteTitleWithoutDotJson)")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $NoteIsLockedAndIsNotUnlocked) {
                NavigationView {
                    VStack{
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                        Text("This note is locked.")
                            .fontWeight(.bold)
                            .font(.title)
                        Button(action: {
                            NoteIsLockedAndIsNotUnlocked = true
                            let context = LAContext()
                            var error: NSError?
                            // check whether biometric authentication is possible
                            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                                // it's possible, so go ahead and use it
                                let reason = "Face ID (or Touch ID) will be used to lock/ unlock your note"
                                
                                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                                    // authentication has now completed
                                    if success {
                                        print("Auth Success")
                                        let noteJson = loadJsonFile(title: title)
                                        noteTitle = noteJson!.title
                                        noteBody = noteJson!.data
                                        noteAuthor = noteJson!.author
                                        GetNoteTitle()
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                            NoteIsLockedAndIsNotUnlocked = false
                                        })
                                        userIsAuthorized = true
                                    } else {
                                        print("Auth Not Success")
                                    }
                                }
                                
                            }
                        }, label: {
                            Text("View This Note")
                                .font(.title3)
                        })
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                MoveHere = false
                                NoteIsLockedAndIsNotUnlocked = false
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                                //                                .foregroundColor(.primary)
                            })
                        }
                    }
                }
                
            }
            .sheet(isPresented: Binding<Bool>(
                            get: { return self.jsonData.count > 0 },
                            set: { _ in })) {
                        ShareSheet(activityItems: [self.jsonData])
                    }
            .sheet(isPresented: $showSettings) {
                VStack {
                    List() {
                        Section("About"){
                            Button(action: {
                                
                            }, label: {
                                Text("Change")
                            })
                        }
                    }
                }
            }
        }
    }
    func GetNoteTitle() {
        let tc = title.count
        let titleWithoutDotJson = title.prefix(tc - 5)
        NoteTitleWithoutDotJson = String(titleWithoutDotJson)
    }
    private func exportJSON() {
        let jsongDecoder = JSONDecoder()
        var data: Data
        do {
            let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    //            let path = Bundle.main.resourcePath!
    //            let documentDirectoryUrl = URL(string: path)
            let fileURL = documentDirectoryUrl!.appendingPathComponent("NotIM/\(title)")
            print(fileURL)
            let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            self.jsonData = jsonData
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Show share sheet
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        catch {
            print(error)
            
        }

        
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
