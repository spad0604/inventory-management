import 'package:flutter/material.dart';

Widget takePhotoButton({required Function takePhoto}) {
  return GestureDetector(
    onTap: () {
      takePhoto();
    },
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.5),
        border: Border.all(
          color: Colors.white,
          width: 6,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.01),
        ),
      ),
    ),
  );
}

class CustomLargeTextField extends StatelessWidget {
  const CustomLargeTextField(
      {super.key,
      required this.textFieldName,
      required this.hintText,
      required this.isConstrain,
      required this.textEditingController,
      required this.readOnly});

  final String textFieldName;
  final String hintText;
  final bool isConstrain;
  final TextEditingController textEditingController;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 10, left: 10, bottom: 5, right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: textFieldName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        children: [
                          if (isConstrain == true)
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextField(
                      readOnly: readOnly,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: Color(0xFFA6A6B0),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
