//
//  Postimage.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

struct Postimage : View {
    var body: some View {
        Image(AppAsset.Assets.dummy.name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 320,height: 306)
            .cornerRadius(5)
    }
}

#Preview {
    Postimage()
}
