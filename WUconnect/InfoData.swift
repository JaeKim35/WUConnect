//
//  InfoData.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/5/26.
//

import SwiftUI

struct InfoData: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        InfoData(label: "Email", value: "test@gmail.com")
    }
}
