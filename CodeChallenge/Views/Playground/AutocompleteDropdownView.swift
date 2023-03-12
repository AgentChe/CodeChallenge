//
//  AutocompleteDropdownView.swift
//  CC
//
//  Created by Tatevik Tovmasyan on 26/05/2022.
//

import SwiftUI

struct AutocompleteDropdownView: View {
    let options: [String]
    let onSelect: ((String) -> Void)

    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.bodyText)
                            .foregroundColor(.white)
                            .onTapGesture {
                                onSelect(option)
                            }
                            .frame(height: 26)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 8)

                Spacer()
            }
        }
        .background(.CodeChallenge.background)
        .cornerRadius(10)
    }
}

struct AutocompleteDropdownView_Previews: PreviewProvider {
    static var previews: some View {
        AutocompleteDropdownView(options: [""], onSelect: { _ in })
    }
}
