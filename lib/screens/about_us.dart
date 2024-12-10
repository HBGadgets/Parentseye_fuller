import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: const DecorationImage(
                    image: AssetImage('assets/parentseye_logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to ParensEye App',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'At ParentsEye, we understand the paramount importance of ensuring a secure and efficient transportation system for your child’s journey to and from school. Our state-of-the-art bus tracking application is designed to provide real-time insights into the location and movement of our school buses, offering parents and guardians peace of mind. With a user-friendly interface, our application allows you to effortlessly track your child’s bus, receive timely notifications, and stay informed about any updates related to the transportation schedule. At ParentsEye, we are committed to leveraging technology to enhance the overall educational experience, and our bus tracking application stands as a testament to our dedication to safety, transparency, and the well-being of our students.',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Column(
                children: [
                  buildMenuButton('Our Website', () {
                    launchUrl(Uri.parse('https://www.parentseye.in/'));
                  }),
                  buildMenuButton('Our Instagram', () {
                    launchUrl(Uri.parse(
                        'https://www.instagram.com/parents_eye?igsh=NDdoZDZvOHlkeW4w'));
                  }),
                  buildMenuButton('Feedback', () {
                    launchUrl(Uri.parse('https://www.parentseye.in/feedback'));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuButton(String text, Function() onPressed) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onPressed,
    );
  }
}
