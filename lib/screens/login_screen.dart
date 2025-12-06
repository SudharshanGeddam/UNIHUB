import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                BackButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(179, 63, 62, 62),
                    ),
                  ),
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        label: Text(
                          'Enter Your Email',
                          style: TextStyle(color: Colors.white),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        label: Text(
                          'Enter Your Password',
                          style: TextStyle(color: Colors.white),
                        ),
                        prefixIcon: Icon(Icons.visibility, color: Colors.white),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Radio(
                            value: 'Remember Me',
                            fillColor: WidgetStatePropertyAll(Colors.white),
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 100),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},

                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 6, 40, 229),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 10,
                    //   child: Divider(color: Colors.white),
                    // ),
                    const SizedBox(height: 10),
                    Text(
                      'or Continue with',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  const Color.fromARGB(115, 63, 62, 62),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/images/google.jpeg',
                                height: 20,
                              ),
                              label: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Google',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  const Color.fromARGB(115, 63, 62, 62),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/images/facebook.jpeg',
                                height: 20,
                              ),
                              label: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Facebook',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Don\'t have an account? Sign up ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
