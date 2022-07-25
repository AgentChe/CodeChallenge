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
            VStack {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .onTapGesture {
                            onSelect(option)
                        }
                        .background(Color.red)
                }
            }
        }
    }
}

struct AutocompleteDropdownView_Previews: PreviewProvider {
    static var previews: some View {
        AutocompleteDropdownView(options: [""], onSelect: { _ in })
    }
}
