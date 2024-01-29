//
//  ContentView.swift
//  Notes
//
//  Created by Aliia Satbakova  on 26.01.2024.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @ObservedObject private var viewModel = NoteViewModel()
    @State private var isAddingNote = false
    @State private var searchText = ""
    
    var filteredNotes: Results<NoteEntity> {
        if searchText.isEmpty {
            return viewModel.notes
        } else {
            return viewModel.notes.filter("text CONTAINS[c] %@", searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(/*viewModel.notes*/filteredNotes, id: \.id) { note in
                    NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(note.text)
                                .lineLimit(2)
                                .fontWeight(.semibold)
                            Text(formattedDate(note.timestamp))
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    addNoteButton
                        .padding(.trailing)
                }
            }
            .sheet(isPresented: $isAddingNote) {
                NavigationView {
                    NoteDetailView(note: viewModel.createNote(), viewModel: viewModel)
                        .navigationBarItems(
                            leading: Button("Add") {
                                isAddingNote.toggle()
                            })
                }
            }
            .onAppear {
                viewModel.loadNotes()
                if UserDefaults.standard.bool(forKey: "firstLaunch") == false {
                    viewModel.welcomeNote = viewModel.createWelcomeNote()
                    UserDefaults.standard.set(true, forKey: "firstLaunch")
                }
            }
        }
    }
}

extension ContentView {
    private var addNoteButton: some View {
        Button(action: {
            withAnimation {
                isAddingNote.toggle()
            }
        }) {
            Image(systemName: "square.and.pencil")
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            let validOffsets = offsets.filter { viewModel.isNoteValid(viewModel.notes[$0]) }
            validOffsets.forEach { index in
                let noteToDelete = viewModel.notes[index]
                viewModel.deleteNote(noteToDelete)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}
