import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/login/routing.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginSection extends StatefulWidget {
  const SocialLoginSection({super.key});

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SpacingRow(
            spacing: 20,
            children: [
              Expanded(
                child: Container(
                  height: 0.3,
                  color: Color(0xFF787A7D),
                ),
              ),
              Text(
                R.string.hoac_dang_nhap_bang.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: Container(
                  height: 0.3,
                  color: Color(0xFF787A7D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Platform.isIOS)
                GestureDetector(
                  onTap: () {
                    loginApple();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(25)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(R.drawable.ic_login_apple,
                                  width: 26, height: 26),
                            ])),
                  ),
                )
              else
                const SizedBox(),
              GestureDetector(
                onTap: () {
                  loginGG();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(R.drawable.ic_google,
                                width: 26, height: 26),
                          ])),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16)
        ],
      ),
    );
  }

  loginApple() async {
    AuthorizationCredentialAppleID? credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.cactusoftware.diab.service', //'com.vbhc.diab',
          redirectUri: Uri.parse(
              'https://is.stg.diab.cptech.vn/External/Challenge?scheme=Apple' //'https://is.stg.diab.cptech.vn/signin-apple' //'https://is.diab.com.vn/callbacks/sign_in_with_apple', //
              ),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(credential.identityToken);

      BotToast.showLoading();

      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token": credential.identityToken ?? '',
        "provider": 'Apple'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        registerAccount(
            credential.userIdentifier,
            credential.identityToken,
            'Apple',
            credential.givenName ?? R.string.user_name_default.tr(),
            true,
            googleAccount: null,
            appleCredential: credential);
      } else {
       LoginRouting().navigateToHome(context);
      }
    } catch (error) {
      BotToast.closeAllLoading();
      if (error is Error && error.code == '5' && credential != null) {
        registerAccount(
            credential.userIdentifier,
            credential.identityToken,
            'Apple',
            credential.givenName ?? R.string.user_name_default.tr(),
            false,
            googleAccount: null,
            appleCredential: credential);
      } else if (error is PlatformException && error.code == 'network_error') {
        Message.showToastMessage(
            context, R.string.error_can_not_connect_to_server.tr());
      } else {
        // Message.showToastMessage(context, error.toString());
      }
    }
  }

  registerAccount(
    String? providerKey,
    String? externalToken,
    String provider,
    String userName,
    bool update, {
    GoogleSignInAccount? googleAccount,
    AuthorizationCredentialAppleID? appleCredential,
  }) async {
    try {
      Navigator.pushReplacementNamed(context, NavigatorName.update_info,
          arguments: {
            'type': provider.toLowerCase(),
            'googleAccount': googleAccount,
            'appleAccount': appleCredential,
          });
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, error.toString());
    }
  }

  loginGG() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        R.string.email.tr(),
        'profile',
      ],
    );
    GoogleSignInAccount? account;
    late GoogleSignInAuthentication authen;
    try {
      account = await _googleSignIn.signIn();
      if (account == null) return;
      authen = await account.authentication;
      print(authen.accessToken);
      BotToast.showLoading();

      await LoginClient().login({
        "client_id": Const.CLIENT_ID,
        "client_secret": Const.CLIENT_SECRET,
        "grant_type": "external",
        "external_token": authen.accessToken,
        "provider": 'Google'
      });
      final user = await UserClient().fetchUser();
      BotToast.closeAllLoading();
      if (user == null) {
        registerAccount(account.id, authen.accessToken, 'Google',
            account.displayName ?? R.string.user_name_default.tr(), true,
            googleAccount: account, appleCredential: null);
        // Navigator.pushReplacementNamed(context, NavigatorName.update_info,
        //     arguments: {'type': 'google', 'googleAccount': account});
      } else {
        LoginRouting().navigateToHome(context);
      }
    } catch (error) {
      if (error is Error && error.code == '5' && account != null) {
        registerAccount(account.id, authen.accessToken, 'Google',
            account.displayName ?? R.string.user_name_default.tr(), false,
            googleAccount: account, appleCredential: null);
      } else if (error is PlatformException && error.code == 'network_error') {
        Message.showToastMessage(
            context, R.string.error_can_not_connect_to_server.tr());
      } else {
        BotToast.closeAllLoading();
        Message.showToastMessage(context, error.toString());
      }
    }
  }
}
