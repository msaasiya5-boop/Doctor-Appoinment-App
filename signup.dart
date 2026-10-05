// import 'package:flutter/material.dart';
// import 'package:medicare_connect/provider/provider_auth.dart';
// import 'package:provider/provider.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen>
//     with SingleTickerProviderStateMixin {
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();

//   bool isLoading = false;
//   bool obscurePassword = true;
//   bool obscureConfirmPassword = true;
//   String selectedRole = "Patient";
//   AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

//   late final AnimationController _animController;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
//     );
//     _animController.forward();
//   }

//   Future<void> register() async {
//     if (!_formKey.currentState!.validate()) {
//       setState(() {
//         _autovalidateMode = AutovalidateMode.onUserInteraction;
//       });
//       _showSnack("Please fix the highlighted fields", isError: true);
//       return;
//     }

//     if (passwordController.text != confirmPasswordController.text) {
//       setState(() {
//         _autovalidateMode = AutovalidateMode.onUserInteraction;
//       });
//       _showSnack("Passwords do not match", isError: true);
//       return;
//     }

//     setState(() => isLoading = true);

//     final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

//     final result = await authProvider.register(
//       name: nameController.text.trim(),
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//       role: selectedRole,
//     );
//     setState(() => isLoading = false);

//     if (!mounted) return;

//     if (result == null) {
//       _showSnack("Registration Successful");
//       Navigator.pop(context);
//     } else {
//       _showSnack(result, isError: true);
//     }
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   InputDecoration _fieldDecoration({
//     required String label,
//     required IconData icon,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.grey.shade700),
//       prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
//       ),
//       errorStyle: TextStyle(
//         color: Colors.red.shade600,
//         fontSize: 12.5,
//         fontWeight: FontWeight.w600,
//       ),
//       errorMaxLines: 2,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Gradient background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF1D4ED8),
//                   Color(0xFF3B82F6),
//                   Color(0xFF60A5FA)
//                 ],
//               ),
//             ),
//           ),

//           // Decorative soft circles
//           Positioned(
//             top: -60,
//             right: -40,
//             child: _blurCircle(180, Colors.white.withOpacity(0.08)),
//           ),
//           Positioned(
//             bottom: -80,
//             left: -60,
//             child: _blurCircle(220, Colors.white.withOpacity(0.10)),
//           ),

//           // Back button
//           SafeArea(
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8, top: 4),
//                 child: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: screenHeight - 96),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     FadeTransition(
//                       opacity: _fadeAnim,
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(18),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.4),
//                                 width: 1.2,
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.person_add_alt_1_rounded,
//                               size: 54,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             "Create Account",
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "Join Medicare Connect today",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white.withOpacity(0.85),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     SlideTransition(
//                       position: _slideAnim,
//                       child: FadeTransition(
//                         opacity: _fadeAnim,
//                         child: Container(
//                           padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(24),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 24,
//                                 offset: const Offset(0, 12),
//                               ),
//                             ],
//                           ),
//                           child: Form(
//                             key: _formKey,
//                             autovalidateMode: _autovalidateMode,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Sign up",
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w700,
//                                     color: Color(0xFF111827),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "Fill in your details to get started",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 TextFormField(
//                                   controller: nameController,
//                                   decoration: _fieldDecoration(
//                                     label: "Full Name",
//                                     icon: Icons.person_outline,
//                                   ),
//                                   validator: (value) =>
//                                       value!.isEmpty ? "Enter name" : null,
//                                 ),
//                                 const SizedBox(height: 18),
//                                 TextFormField(
//                                   controller: emailController,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: _fieldDecoration(
//                                     label: "Email",
//                                     icon: Icons.email_outlined,
//                                   ),
//                                   validator: (value) =>
//                                       value!.isEmpty ? "Enter email" : null,
//                                 ),
//                                 const SizedBox(height: 18),
//                                 TextFormField(
//                                   controller: passwordController,
//                                   obscureText: obscurePassword,
//                                   decoration: _fieldDecoration(
//                                     label: "Password",
//                                     icon: Icons.lock_outline,
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         obscurePassword
//                                             ? Icons.visibility_outlined
//                                             : Icons.visibility_off_outlined,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           obscurePassword = !obscurePassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.length < 6) {
//                                       return "Minimum 6 characters";
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 const SizedBox(height: 18),
//                                 TextFormField(
//                                   controller: confirmPasswordController,
//                                   obscureText: obscureConfirmPassword,
//                                   decoration: _fieldDecoration(
//                                     label: "Confirm Password",
//                                     icon: Icons.lock_outline,
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         obscureConfirmPassword
//                                             ? Icons.visibility_outlined
//                                             : Icons.visibility_off_outlined,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           obscureConfirmPassword =
//                                               !obscureConfirmPassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "Confirm password";
//                                     }
//                                     if (value != passwordController.text) {
//                                       return "Passwords do not match";
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 const SizedBox(height: 18),
//                                 DropdownButtonFormField<String>(
//                                   value: selectedRole,
//                                   decoration: _fieldDecoration(
//                                     label: "Select Role",
//                                     icon: Icons.badge_outlined,
//                                   ),
//                                   items: const [
//                                     DropdownMenuItem(
//                                       value: "Patient",
//                                       child: Text("Patient"),
//                                     ),
//                                     DropdownMenuItem(
//                                       value: "Doctor",
//                                       child: Text("Doctor"),
//                                     ),
//                                   ],
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedRole = value!;
//                                     });
//                                   },
//                                 ),
//                                 const SizedBox(height: 28),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   height: 52,
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF2563EB),
//                                       foregroundColor: Colors.white,
//                                       elevation: isLoading ? 0 : 4,
//                                       shadowColor: const Color(0xFF2563EB)
//                                           .withOpacity(0.4),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                     ),
//                                     onPressed: isLoading ? null : register,
//                                     child: isLoading
//                                         ? const SizedBox(
//                                             height: 22,
//                                             width: 22,
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2.4,
//                                             ),
//                                           )
//                                         : const Text(
//                                             "Sign Up",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Center(
//                                   child: TextButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     style: TextButton.styleFrom(
//                                       foregroundColor: const Color(0xFF2563EB),
//                                     ),
//                                     child: RichText(
//                                       text: TextSpan(
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                         children: const [
//                                           TextSpan(
//                                               text:
//                                                   "Already have an account? "),
//                                           TextSpan(
//                                             text: "Login",
//                                             style: TextStyle(
//                                               color: Color(0xFF2563EB),
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _blurCircle(double size, Color color) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medicare_connect/provider/provider_auth.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String selectedRole = "Patient";
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _showSnack("Please fix the highlighted fields", isError: true);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _showSnack("Passwords do not match", isError: true);
      return;
    }

    setState(() => isLoading = true);

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    final result = await authProvider.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole,
    );
    setState(() => isLoading = false);

    if (!mounted) return;

    if (result == null) {
      _showSnack("Registration Successful");
      Navigator.pop(context);
    } else {
      _showSnack(result, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1D4ED8),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA)
                ],
              ),
            ),
          ),

          // Decorative soft circles
          Positioned(
            top: -60,
            right: -40,
            child: _blurCircle(180, Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _blurCircle(220, Colors.white.withOpacity(0.10)),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight - 96),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Join Medicare Connect today",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autovalidateMode,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Fill in your details to get started",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: nameController,
                                  decoration: _fieldDecoration(
                                    label: "Full Name",
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? "Enter name" : null,
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _fieldDecoration(
                                    label: "Email",
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? "Enter email" : null,
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  decoration: _fieldDecoration(
                                    label: "Password",
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return "Minimum 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: obscureConfirmPassword,
                                  decoration: _fieldDecoration(
                                    label: "Confirm Password",
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscureConfirmPassword =
                                              !obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Confirm password";
                                    }
                                    if (value != passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                                // NOTE: Doctor accounts are created only by
                                // the Admin (see Add Doctor screen), so this
                                // signup form now only registers Patients.
                                // selectedRole stays fixed to "Patient".
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      elevation: isLoading ? 0 : 4,
                                      shadowColor: const Color(0xFF2563EB)
                                          .withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : register,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.4,
                                            ),
                                          )
                                        : const Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2563EB),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        children: const [
                                          TextSpan(
                                              text:
                                                  "Already have an account? "),
                                          TextSpan(
                                            text: "Login",
                                            style: TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
