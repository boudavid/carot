//
//  Texts.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI

struct Text14: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
        .font(.system(size: 14))
    }
}

struct Text16: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
        .font(.system(size: 16))
    }
}

struct Text50: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
        .font(.system(size: 50))
    }
}
