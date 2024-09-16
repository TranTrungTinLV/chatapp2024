import 'dart:io';

import 'package:chatapps2024/widgets/image_user_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _isLogin = false;
  final _formKey = GlobalKey<FormState>();
  var _enterEmail = '';
  var _enterPassWord = '';
  var _enterName = '';
  File? _selectedImage;
  var _isUploading = false;
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _isLogin && _selectedImage == null) return;
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isUploading = true;
        });
        if (!_isLogin) {
          final userCredentials = await _firebase.signInWithEmailAndPassword(
              email: _enterEmail, password: _enterPassWord);
          print(userCredentials);
        } else {
          final userCredentials =
              await _firebase.createUserWithEmailAndPassword(
                  email: _enterEmail, password: _enterPassWord);

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user-image')
              .child('${userCredentials.user!.uid}.png');
          await storageRef.putFile(_selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .set({
            'username': _enterName,
            'email': _enterEmail,
            "images": imageUrl
          }); //createData
          print(imageUrl);
          print(userCredentials);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          //  ..
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Authentication failed. ')));
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Register Chatbox' : 'Login to Chatbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100),
          child: Column(
            children: [
              Container(
                width: 295,
                child: Text(
                  _isLogin
                      ? 'Get chatting with friends and family today by signing up for our chat app!'
                      : 'Welcome back! Sign in using your social account or email to continue us',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              _isLogin
                  ? ImageUserPicker(
                      onPickImage: (File pickedImage) {
                        _selectedImage = pickedImage;
                      },
                    )
                  : Container(),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'email không hợp lệ';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterEmail = value!;
                        },
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Your email',
                          contentPadding:
                              EdgeInsets.only(top: 30.0, bottom: 16),
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff24786D),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      _isLogin
                          ? TextFormField(
                              keyboardType: TextInputType.name,
                              onSaved: (value) {
                                _enterName = value!;
                              },
                              decoration: InputDecoration(
                                labelText: 'Your name',
                                contentPadding:
                                    EdgeInsets.only(top: 30.0, bottom: 16),
                                labelStyle: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xff24786D),
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Mật khẩu tối thiểu phải 6";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterPassWord = value!;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Your Password',
                          contentPadding:
                              EdgeInsets.only(top: 30.0, bottom: 16),
                          labelStyle: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff24786D),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 40),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              // color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0))),
                          child: _isUploading
                              ? Center(child: CircularProgressIndicator())
                              : TextButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff24786D)),
                                  child: Text(
                                    _isLogin ? 'Register' : 'Log in',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: Colors.white),
                                  )),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              height: 20,
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Center(
                              child: Row(
                                children: [
                                  Text('Hoặc'),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(
                                      _isLogin ? ' đăng nhập ' : ' đăng ký',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 20,
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
