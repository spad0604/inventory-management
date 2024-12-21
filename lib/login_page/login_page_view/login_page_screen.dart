import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/login_page/login_page_controller/login_page_controller.dart';

class LoginPageScreen extends GetView<LoginPageController> {
  const LoginPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/png/icon_app.png',
                width: 200,
                height: 200,
              ),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    CustomTextFieldWidget(
                      hintText: 'Account',
                      isPassword: false,
                      textEditingController: controller.account,
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset('assets/images/png/account_ic.png',
                            width: 10, color: Colors.lightBlue),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Obx(
                      () => CustomTextFieldWidget(
                        showPassword: controller.isShowPassword.value,
                        showPasswordPressed: () {
                          controller.isShowPassword.value = !controller.isShowPassword.value;
                        },
                        hintText: 'Password',
                        isPassword: true,
                        textEditingController: controller.password,
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset('assets/images/png/lock_ic.png',
                              width: 10, color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80,),
                    
                    GestureDetector(
                      onTap: () {
                        controller.onPressedButton();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.lightBlue
                        ),
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextFieldWidget extends StatelessWidget {
  const CustomTextFieldWidget(
      {super.key,
      this.textEditingController,
      this.hintText,
      this.prefixIcon,
      this.isPassword = false,
      this.showPassword,
      this.showPasswordPressed,
      this.onChanged,
      this.readOnly,
      this.autofillHints});

  final TextEditingController? textEditingController;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final bool? showPassword;
  final Function()? showPasswordPressed;
  final Function(String)? onChanged;
  final bool? readOnly;
  final Iterable<String>? autofillHints;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B90A7), width: 1),
      ),
      child: TextField(
        autofillHints: autofillHints,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        readOnly: readOnly ?? false,
        controller: textEditingController,
        obscureText: showPassword ?? false,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF8B90A7),
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword == false
                        ? Icons.visibility_off_outlined
                        : Icons.remove_red_eye_outlined,
                    color: const Color(0xFF8B90A7),
                  ),
                  onPressed: () {
                    showPasswordPressed!();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
