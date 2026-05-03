import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geeta2/Home.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Color aiColor = Colors.yellowAccent;
  Color userColor = Colors.lightBlueAccent;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      aiColor =
          Color(prefs.getInt("ai_color") ?? Colors.yellowAccent.value);

      userColor =
          Color(prefs.getInt("user_color") ??
              Colors.lightBlueAccent.value);

      final path = prefs.getString("bg_path");

      if (path != null) {
        selectedImage = File(path);
      }
    });
  }

  Future<void> pickImage() async {

    final img =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {

      setState(() {
        selectedImage = File(img.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image selected ✔")),
      );
    }
  }

  Future<void> saveSettings() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("ai_color", aiColor.value);
    await prefs.setInt("user_color", userColor.value);

    if (selectedImage != null) {
      await prefs.setString("bg_path", selectedImage!.path);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
    );
  }

  Future<void> openLinkedIn() async {

    final url = Uri.parse(
        "https://www.linkedin.com/in/sidharth-kumar-059269294/");

    await launchUrl(url,
        mode: LaunchMode.externalApplication);
  }

  void pickColor(bool isAI) {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Select color",
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isAI ? aiColor : userColor,
            onColorChanged: (color) {

              setState(() {

                if (isAI) {
                  aiColor = color;
                } else {
                  userColor = color;
                }
              });
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Done"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget section({
    required String title,
    required Widget trailing,
    required Color borderColor
  }) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18),

      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.45),

        border: Border(
          left: BorderSide(
              color: borderColor,
              width: 5),
        ),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16),
          ),

          trailing
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// Background image
          Image.asset(
            "assets/media/setting.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          /// Black glass overlay
          Container(
              color: Colors.black.withOpacity(.65)
          ),

          SafeArea(
            child: Column(
              children: [

                /// Back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                  ],
                ),

                const Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.white),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18),

                    child: ListView(
                      children: [

                        /// Background image section
                        section(
                          title: "Background Image",
                          borderColor: Colors.white,
                          trailing: ElevatedButton(
                            onPressed: pickImage,
                            child: const Text("Upload"),
                          ),
                        ),

                        if (selectedImage != null)
                          const Padding(
                            padding:
                            EdgeInsets.only(left: 6),
                            child: Text(
                              "✔ Image selected",
                              style: TextStyle(
                                  color:
                                  Colors.greenAccent),
                            ),
                          ),

                        /// AI color
                        section(
                          title: "AI Border Color",
                          borderColor: aiColor,
                          trailing: GestureDetector(
                            onTap: () => pickColor(true),
                            child: CircleAvatar(
                              backgroundColor: aiColor,
                            ),
                          ),
                        ),

                        /// USER color
                        section(
                          title: "User Border Color",
                          borderColor: userColor,
                          trailing: GestureDetector(
                            onTap: () =>
                                pickColor(false),
                            child: CircleAvatar(
                              backgroundColor:
                              userColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        ElevatedButton(
                          onPressed: saveSettings,
                          child:
                          const Text("Save Settings"),
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: TextButton(
                            onPressed: openLinkedIn,
                            child: const Text(
                              "Contact Developer",
                              style: TextStyle(
                                  color:
                                  Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}