//
//  TermsAndConditionsView.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import SwiftUI

struct TermsAndConditionsView: View {
    private let termsText: String = {
        guard let url = Bundle.main.url(
            forResource: Copy.terms.fileName,
            withExtension: Copy.terms.fileExtension
        ) else {
            return Copy.terms.loadFailure
        }

        return (try? String(contentsOf: url)) ?? Copy.terms.loadFailure
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.m) {
                Text(Copy.terms.title)
                    .font(.title)
                    .bold()

                Text(Copy.terms.lastUpdated)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(termsText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationTitle(Copy.terms.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsAndConditionsView()
    }
}
