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
            VStack {
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
                
                List {
                    Section(header: SearchBarView(text: $searchText)) {
                        ForEach(filteredItems, id: \.self) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.teal.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 15)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 8)
            }
            
            // Floating Action Button
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
            .padding()
            .sheet(isPresented: $showStatsSheet) {
                StatsSheetView(items: allItems[selectedImageIndex])
            }
        }
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
        .padding(.bottom, 10)
        .frame(width: UIScreen.main.bounds.width)
        .padding(.bottom, 10)
    }
}

#Preview {
    ContentView()
}
