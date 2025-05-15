//
//  ContentView.swift
//  ScriptItSwiftUITest
//
//  Created by santhosh thalil on 13/05/25.
//

import SwiftUI

struct ContentView: View {
    
    struct Item: Equatable, Hashable {
        let name: String
        let description: String
    }
    
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollPercentage: CGFloat = 0
    
    @State private var showSearchBar = false
    
    @State private var selectedImageIndex = 0
    @State private var searchText = ""
    @State private var showStatsSheet = false
    
    let images = [
        "https://picsum.photos/id/237/400/200",
        "https://picsum.photos/id/238/400/200",
        "https://picsum.photos/id/239/400/200"
    ]
    
    let allItems: [[Item]] = [
        (1...20).map { Item(name: "Apple \($0)", description: "A sweet fruit \($0)") },
        (1...20).map { Item(name: "Banana \($0)", description: "A yellow fruit \($0)") },
        (1...20).map { Item(name: "Cherry \($0)", description: "A red fruit \($0)") }
    ]
    
    var filteredItems: [Item] {
        let items = allItems[selectedImageIndex]
        return searchText.isEmpty ? items : items.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if showSearchBar {
                    SearchBarView(text: $searchText)
                        .background(Color.white)
                        .zIndex(1)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Image Carousel
                        TabView(selection: $selectedImageIndex) {
                            ForEach(images.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: images[index])) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(height: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                    case .failure:
                                        Color.red.frame(height: 200)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .frame(height: 200)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        
                        // Search Bar
                        SearchBarView(text: $searchText)
                        
                        // List with square image
                        LazyVStack(spacing: 15) {
                            ForEach(filteredItems, id: \.self) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    AsyncImage(url: URL(string: "https://picsum.photos/seed/\(item.name)/60")) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text(item.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.teal.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Track scroll position
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self,
                                            value: geo.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = -value
                    let totalScrollableHeight: CGFloat = 50 * 100 - UIScreen.main.bounds.height
                    let percentage = min(max(scrollOffset / totalScrollableHeight, 0), 1)
                    scrollPercentage = percentage
                    
                    withAnimation {
                        //showSearchBar = value <= 2010
                        showSearchBar = value <= 1900
                    }
                }
            }
            
            //Floating Action Button
            Button(action: {
                showStatsSheet.toggle()
            }) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 24))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(20) // Padding from bottom and trailing
            .sheet(isPresented: $showStatsSheet) {
                StatsSheetView(items: allItems[selectedImageIndex])
            }
        }
    }
}

    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    struct StatsSheetView: View {
    let items: [ContentView.Item]
    
    var characterStats: [(char: Character, count: Int)] {
        let names = items.map { $0.name.lowercased() }.joined()
        let letters = names.filter { $0.isLetter }
        let frequency = Dictionary(letters.map { ($0, 1) }, uniquingKeysWith: +)
        return frequency.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("List \(items.count) items")
                .font(.headline)
                .padding(.top)
            
            ForEach(characterStats, id: \.char) { stat in
                HStack {
                    
                    Text("\(stat.char) =")
                    Spacer()
                    Text("\(stat.count)")
                }
                .font(.title2)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.3), .medium])
    }
}

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 0)
        .frame(width: UIScreen.main.bounds.width)
        .padding(.bottom, 10)
    }
}

