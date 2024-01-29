//
//  NoteDetailView.swift
//  Notes
//
//  Created by Aliia Satbakova  on 26.01.2024.
//

import SwiftUI
import PhotosUI
import RealmSwift

struct NoteDetailView: View {
    @ObservedObject var note: NoteEntity
    @ObservedObject var viewModel: NoteViewModel
    
    @State private var editedText: String
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    init(note: NoteEntity, viewModel: NoteViewModel) {
        self.note = note
        self.viewModel = viewModel
        _editedText = State(initialValue: note.text)
        _selectedPhotoData = State(initialValue: note.imageData)
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Write something...", text: $editedText, axis: .vertical)
                        .onAppear {
                            editedText = note.text
                        }
                        .onDisappear {
                            viewModel.updateNoteText(note: note, newText: editedText)
                            viewModel.updateNoteImage(note: note, image: selectedPhotoData)
                            viewModel.objectWillChange.send()
                        }
                }
                Section {
                    if let selectedPhotoData = selectedPhotoData,
                       let image = UIImage(data: selectedPhotoData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding()
                            .cornerRadius(8)
                            .frame(maxWidth: 350, maxHeight: 350, alignment: .center)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Edit")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker( selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo.badge.plus")
                }
                .onChange(of: selectedItem) { newItem, selectedItem in
                    guard let newItem = selectedItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                        }
                    }
                }
            }
        }
    }
}
