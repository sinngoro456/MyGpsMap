//
//  SignInView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/12.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        Button("ログイン", action: auth.signIn)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
