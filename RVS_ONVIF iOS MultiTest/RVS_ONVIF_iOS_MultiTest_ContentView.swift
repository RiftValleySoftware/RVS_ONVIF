/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

struct RVS_ONVIF_iOS_MultiTest_ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabbedView(selection: $selection) {
            Text("First View")
                .font(.title)
                .tabItemLabel(Image("first"))
                .tag(0)
            Text("Second View")
                .font(.title)
                .tabItemLabel(Image("second"))
                .tag(1)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RVS_ONVIF_iOS_MultiTest_ContentView()
    }
}
#endif
