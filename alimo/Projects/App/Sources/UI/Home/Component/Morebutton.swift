//
//  Morebutton.swift
//  App
//
//  Created by dgsw8th61 on 1/7/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation
import SwiftUI

struct Morebutton : View {
    @State private var isShowingDetail = false
    var body: some View {
        NavigationView{
            NavigationLink(destination: DetailPostView()) {
                Text("...더보기")
                    .font(.cute)
                    .foregroundColor(.gray500)
                    .padding(.top, 3)
                
            }
        }
    }
}

//        NavigationView {
//            VStack {
//                Button(action: {
//                    isShowingDetail = true
//                }) {
//                    Text("...더보기")
//                        .font(.cute)
//                        .foregroundColor(.gray500)
//                        .padding(.top, 3)
//                }
//                .fullScreenCover(isPresented: $isShowingDetail) {
//                    DetailPostView()
//                }
//            }
//        }
//    }
//}


#Preview {
    Morebutton()
}
