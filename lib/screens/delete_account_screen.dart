import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/delete_account_provider.dart';
import 'package:parentseye_parent/screens/parent_login_screen.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  // ignore: unused_field
  bool _isAuthenticating = false;
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<bool> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to delete your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      print(e);
    }

    setState(() {
      _isAuthenticating = false;
    });

    return authenticated;
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_countdown > 0) {
                setState(() {
                  _countdown--;
                });
              } else {
                timer.cancel();
              }
            });

            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 26, 25, 25),
              title: Text(
                'Confirm Account Deletion',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              content: Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    _countdown > 0 ? 'OK ($_countdown)' : 'OK',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onPressed: _countdown > 0
                      ? null
                      : () {
                          _timer?.cancel();
                          Navigator.of(context).pop(true);
                        },
                ),
              ],
            );
          },
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteAccount();
      }
    });
  }

  void _deleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deleteAccountProvider =
        Provider.of<DeleteAccountProvider>(context, listen: false);

    final error =
        await deleteAccountProvider.deleteAccount(authProvider.token!);

    if (error == null) {
      // Account deleted successfully
      authProvider.logout(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ParentalLogin()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 26, 25, 25),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Are you sure you want to delete your account?',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                'Delete Account',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              onPressed: () async {
                if (_canCheckBiometrics) {
                  bool authenticated = await _authenticate();
                  if (authenticated) {
                    _showDeleteConfirmationDialog();
                  }
                } else {
                  _showDeleteConfirmationDialog();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
