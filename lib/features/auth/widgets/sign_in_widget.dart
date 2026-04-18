import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/auth/domain/models/login_model.dart';
import 'package:mahakal/features/auth/screens/forget_password_screen.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/helper/velidate_check.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/features/auth/controllers/auth_controller.dart';
import 'package:mahakal/features/splash/controllers/splash_controller.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:mahakal/utill/images.dart';
import 'package:mahakal/common/basewidget/custom_button_widget.dart';
import 'package:mahakal/common/basewidget/custom_textfield_widget.dart';
import 'package:mahakal/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:mahakal/features/auth/screens/mobile_verify_screen.dart';
import 'package:mahakal/features/auth/widgets/social_login_widget.dart';
import 'package:provider/provider.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../screens/otp_verification_screen.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passNode = FocusNode();

  LoginModel loginBody = LoginModel();

  @override
  void initState() {
    super.initState();
    _emailController.text = Provider.of<AuthController>(context, listen: false).getUserEmail();
    _passwordController.text = Provider.of<AuthController>(context, listen: false).getUserPassword();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    if (_formKeyLogin.currentState!.validate()) {
      _formKeyLogin.currentState!.save();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      
      final authController = Provider.of<AuthController>(context, listen: false);
      
      if (!authController.isGuestIdExist()) {
        authController.getGuestIdUrl();
      }
      
      if (authController.isRemember!) {
        authController.saveUserEmail(email, password);
      } else {
        authController.clearUserEmailAndPassword();
      }
      
      loginBody.email = email;
      loginBody.password = password;
      loginBody.guestId = authController.getGuestToken() ?? '1';

      if (email.isEmpty) {
        showCustomSnackBar(getTranslated('user_name_is_required', context), context);
      } else if (password.isEmpty) {
        showCustomSnackBar(getTranslated('password_is_required', context), context);
      } else if (password.length < 8) {
        showCustomSnackBar(getTranslated('minimum_password_length', context), context);
      } else {
        await authController.login(loginBody, route);
      }
    }
  }

  void route(bool isRoute, String? token, String? temporaryToken, String? errorMessage) async {
    final splashController = Provider.of<SplashController>(context, listen: false);
    
    if (isRoute) {
      if (token == null || token.isEmpty) {
        if (splashController.configModel!.emailVerification!) {
          await Provider.of<AuthController>(context, listen: false)
              .sendOtpToEmail(_emailController.text, temporaryToken!)
              .then((value) async {
            if (value.response?.statusCode == 200) {
              Provider.of<AuthController>(context, listen: false).updateEmail(_emailController.text);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => VerificationScreen(temporaryToken!, '', _emailController.text),
                  ),
                  (route) => false,
                );
              }
            }
          });
        } else if (splashController.configModel!.phoneVerification!) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (_) => MobileVerificationScreen(temporaryToken!)),
              (route) => false,
            );
          }
        }
      } else {
        await Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
        if (context.mounted && Get.context != null) {
          Navigator.pushAndRemoveUntil(
            Get.context!,
            CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
            (route) => false,
          );
        }
      }
    } else {
      showCustomSnackBar(errorMessage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Form(
        key: _formKeyLogin,
        child: Column(
          children: [
            Hero(
              tag: 'user',
              child: CustomTextFieldWidget(
                hintText: getTranslated('enter_email_or_mobile', context),
                labelText: getTranslated('user_name', context),
                focusNode: _emailNode,
                nextFocus: _passNode,
                isRequiredFill: true,
                prefixIcon: Images.username,
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                showLabelText: true,
                required: true,
                validator: (value) => ValidateCheck.validateEmptyText(value, 'enter_email_or_mobile'),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomTextFieldWidget(
              showLabelText: true,
              required: true,
              labelText: getTranslated('password', context),
              hintText: getTranslated('enter_your_password', context),
              inputAction: TextInputAction.done,
              isPassword: true,
              prefixIcon: Images.pass,
              focusNode: _passNode,
              controller: _passwordController,
              validator: (value) => ValidateCheck.validateEmptyText(value, 'enter_your_password'),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Consumer<AuthController>(
                      builder: (context, authProvider, child) {
                        return InkWell(
                          onTap: () => authProvider.updateRemember(),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: .75),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                CupertinoIcons.checkmark_alt,
                                size: 15,
                                color: authProvider.isRemember!
                                    ? Theme.of(context).primaryColor.withValues(alpha: .75)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Text(
                        getTranslated('remember', context)!,
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const ForgetPasswordScreen()),
                  ),
                  child: Text(
                    getTranslated('forget_password', context)! + '?',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: ColorResources.getPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 30),
              child: Consumer<AuthController>(
                builder: (context, authController, child) {
                  return authController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Hero(
                          tag: 'onTap',
                          child: CustomButton(
                            onTap: loginUser,
                            buttonText: getTranslated('login', context),
                          ),
                        );
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            const SocialLoginWidget(),
            Consumer<AuthController>(
              builder: (context, authProvider, child) {
                return GestureDetector(
                  onTap: () {
                    if (!authProvider.isLoading) {
                      Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
                          (route) => false,
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated('continue_as', context)!,
                          style: titleRegular.copyWith(color: ColorResources.getHint(context)),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          getTranslated('guest', context)!,
                          style: titleHeader,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

