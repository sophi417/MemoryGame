//
//  ContentView.swift
//  Memory App
//
//  Created by Sophia Sartor on 10/4/26.
//

import SwiftUI

// one card in the game
struct Card: Identifiable {
    let id = UUID()
    let emoji: String
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
    let allEmojis = ["🐶", "🐱", "🦊", "🐸", "🐵", "🐼", "🐨", "🦁", "🐷", "🐙", "🦄", "🐢"]
    let pairOptions = [2, 4, 6, 8, 10]

    @State private var cards: [Card] = []
    @State private var firstIndex: Int? = nil
    // index of the first card flipped
    @State private var numberOfPairs = 6
    @State private var isChecking = false
    // blocks taps while 2 cards are showing

    // 3 columns for the grid
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            // background
            LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Memory Game")
                    .font(.largeTitle)
                    .bold()

                // pick how many pairs to play with
                Picker("Pairs", selection: $numberOfPairs) {
                    ForEach(pairOptions, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // show when all cards are matched
                if !cards.isEmpty && cards.allSatisfy({ $0.isMatched }) {
                    Text("You won! 🎉")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }

                // scroll view so extra cards fit
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(cards) { card in
                            CardView(card: card)
                                .onTapGesture {
                                    tap(card)
                                }
                        }
                    }
                    .padding()
                }

                Button("New Game") {
                    newGame()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            newGame()
        }
        .onChange(of: numberOfPairs) {
            newGame()
        }
    }

    // makes a new shuffled set of cards
    func newGame() {
        let picked = allEmojis.shuffled().prefix(numberOfPairs)
        var newCards: [Card] = []
        for emoji in picked {
            newCards.append(Card(emoji: emoji))
            newCards.append(Card(emoji: emoji))
        }
        cards = newCards.shuffled()
        firstIndex = nil
        isChecking = false
    }

    // handles tapping a card
    func tap(_ card: Card) {
        if isChecking { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        if cards[index].isFaceUp || cards[index].isMatched { return }

        withAnimation {
            cards[index].isFaceUp = true
        }

        if let first = firstIndex {
            // second card heck for a match
            firstIndex = nil
            isChecking = true

            let firstID = cards[first].id
            let secondID = cards[index].id
            let isMatch = cards[first].emoji == cards[index].emoji

            // wait so the user can see both cards
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // cards could be gone if new game was pressed
                guard let a = cards.firstIndex(where: { $0.id == firstID }),
                      let b = cards.firstIndex(where: { $0.id == secondID }) else { return }

                withAnimation {
                    if isMatch {
                        cards[a].isMatched = true
                        cards[b].isMatched = true
                    } else {
                        cards[a].isFaceUp = false
                        cards[b].isFaceUp = false
                    }
                }
                isChecking = false
            }
        } else {
            // this is the first card
            firstIndex = index
        }
    }
}

// how a single card looks


struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp ? Color.white : Color.blue)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 3)

            if card.isFaceUp {
                Text(card.emoji)
                    .font(.system(size: 40))
            } else {
                Text("?")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .scaleEffect(x: -1) // undo the mirror from the flip
            }
        }
      
        
    .frame(height: 100)
        .rotation3DEffect(.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .opacity(card.isMatched ? 0 : 1) // matched cards disappear
    }
}

#Preview {
    ContentView()
}
