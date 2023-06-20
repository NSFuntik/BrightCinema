//
//  TVPageView.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import SwiftUI
import Combine

final class TVPageViewModel: ObservableObject {
    @Published var shows: [Movie] = []
    let client = Service()
    var cancelRequest: Bool = false
    
    init() {
        loadLatestTvData()
    }
    
    private func loadLatestTvData(onPage page: Int = 1) {
        guard !cancelRequest else { return }
        let _ = client.taskForGETMethod(Methods.TRENDING_TV, parameters: [ParameterKeys.TOTAL_RESULTS: page as AnyObject]) { (data, error) in
            if error == nil, let jsonData = data {
                
                let result = MovieResults.decode(jsonData: jsonData)
                if let movieResults = result?.results {
                    DispatchQueue.main.async {
                        self.shows += movieResults
                    }
                }
                if let totalPages = result?.total_pages, totalPages < 10 {
                    guard !self.cancelRequest else {
                        print("Cancel Request Failed")
                        return
                        
                    }
                    self.loadLatestTvData(onPage: page + 1)
                }
            } else if let error = error, let retry = error.userInfo["Retry-After"] as? Int {
                print("Retry after: \(retry) seconds")
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: Double(retry), repeats: false, block: { (_) in
                        print("Retrying...")
                        guard !self.cancelRequest else { return }
                        self.loadLatestTvData(onPage: page)
                        return
                    })
                }
            } else {
                print("Error code: \(String(describing: error?.code))")
                print("There was an error: \(String(describing: error?.userInfo))")
            }
        }
    }
}

struct TVPageView: View {
    @ObservedObject var tvPageVM = TVPageViewModel()
    
    @ViewBuilder
    var body: some View {
        
        VStack {
            GeometryReader { proxy in
                TabView {
                    ForEach($tvPageVM.shows, id: \.id) { $show in
                        if let posterPath = show.poster_path {
                            NavigationLink {
                                TVPageDetailView(detailVM: TVPageDetailViewModel(client: tvPageVM.client, movie: show, isTV: true))
                            } label: {
                                
                                AsyncImage(
                                    url: URL(string: ImageKeys.IMAGE_BASE_URL)!.appendingPathComponent(ImageKeys.PosterSizes.ORIGINAL_POSTER).appendingPathComponent(posterPath),
                                    content: { $0.resizable() }, placeholder: { LoaderView(tintColor: Color("AccentColor")) }
                                )
                                .scaledToFill()
                                .cornerRadius(10)
                            }

                            
                        }
                    }
                    .rotationEffect(.degrees(-90)) // Rotate content
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                }
                .frame(
                    width: proxy.size.height, // Height & width swap
                    height: proxy.size.width
                )
                .rotationEffect(.degrees(90), anchor: .topLeading) // Rotate TabView
                .offset(x: proxy.size.width) // Offset back into screens bounds
                .tabViewStyle(
                    PageTabViewStyle(indexDisplayMode: .always)
                )
            }
        }.frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        ).ignoresSafeArea(.all)
        
    }
}

struct TVPageView_Previews: PreviewProvider {
    static var previews: some View {
        TVPageView()
    }
}
