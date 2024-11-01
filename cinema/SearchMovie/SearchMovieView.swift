//
//  SearchMovieView.swift
//  cinema
//
//  Created by NSFuntik on 22.06.2023.
//

import SwiftUI

final class SearchMovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    let client = Service()
    @Published var searchText: String = ""

    init() { }
    
    func searchMovies(with searchText: String) async {
        DispatchQueue.main.async {
            Task {
                self.movies = try await self.client.fetchMovie(with: searchText) ?? []
            }
        }
    }
}

struct SearchMovieView: View {
    @StateObject var searchVM = SearchMovieViewModel()
    var body: some View {
        VStack {
            HStack(alignment: .bottom ) {
                Text("Search movie")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                Spacer()
                
            }.padding([.top, .horizontal], 10).frame(height: 80)
            SearchBar(text: $searchVM.searchText)
                .onChange(of: searchVM.searchText) { newValue in
                    Task {
                        await searchVM.searchMovies(with: newValue)
                    }
                }
            List($searchVM.movies, id: \.id) { $movie in
                if let posterPath = movie.poster_path {
                    NavigationLink {
                        TVPageDetailView(detailVM: TVPageDetailViewModel(client: searchVM.client, movie: movie))
                    } label: {
                        HStack(alignment: .top, spacing: 5) {
                           CachedAsyncImage(url: URL(string: ImageKeys.IMAGE_BASE_URL)!
                                .appendingPathComponent(ImageKeys.PosterSizes.ORIGINAL_POSTER)
                                .appendingPathComponent(posterPath)) {
                                $0.resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 100, alignment: .center)
                            } placeholder: {
                                LoaderView(tintColor: Color("AccentColor"))
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(movie.title ?? movie.name ?? "")")
                                    .font(.system(size: 17, weight: .semibold, design: .serif))
                                Text("\(movie.release_date?.convertDateString() ?? "")")
                                    .font(.system(size: 14, weight: .light, design: .rounded))
                            }
                        }
                    }
                }
            }.listStyle(.inset)
        }
    }
    
    private struct SearchBar: View {
        @Binding var text: String
        @State private var isEditing = false
        
        var body: some View {
            HStack {
                TextField("Search ...", text: $text)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if isEditing {
                                Button(action: {
                                    self.text = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        self.isEditing = true
                    }
                
                if isEditing {
                    Button(action: {
                        self.isEditing = false
                        self.text = ""
                        
                        // Dismiss the keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default, value: isEditing)
                }
            }
        }
    }
}


