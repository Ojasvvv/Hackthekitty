import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/widgets/living_cat_avatar.dart';
import '../../../shared/widgets/spring_pressable.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/mood_palette.dart';
import '../../mood_engine/mood_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../shared/widgets/paws_background.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Reactively change the cat's mood based on field focus
    void updateMood() {
      if (_passwordFocus.hasFocus || _emailFocus.hasFocus || _confirmPasswordFocus.hasFocus) {
        ref.read(moodTierProvider.notifier).setMood(MoodTier.good);
      } else {
        ref.read(moodTierProvider.notifier).setMood(MoodTier.neutral);
      }
    }
    
    _emailFocus.addListener(updateMood);
    _passwordFocus.addListener(updateMood);
    _confirmPasswordFocus.addListener(updateMood);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    // Auto-dismiss error after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          if (_errorMessage == message) _errorMessage = null;
        });
      }
    });
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Email address cannot be empty');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return false;
    }

    if (password.isEmpty) {
      _showError('Password cannot be empty');
      return false;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }

    if (_isSignUp) {
      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword != password) {
        _showError('Passwords do not match');
        return false;
      }
    }

    return true;
  }

  Future<void> _handleEmailAuth() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Authentication failed';
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      _showError(msg);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static bool _isGoogleInit = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_isGoogleInit) {
        await GoogleSignIn.instance.initialize(
          serverClientId: '661393559239-b3ofste9f8i2l8kdkuqhbkrd86bu8gjn.apps.googleusercontent.com',
        );
        _isGoogleInit = true;
      }
      
      final googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User canceled
      } else {
        _showError('Google Sign-In failed: ${e.description ?? e.code.name}');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Firebase Google Sign-In failed');
    } catch (e) {
      _showError(
        'Google Sign-In failed. Make sure SHA-1 & Firebase config are correct.\n'
        'For local testing, you can use "Continue as Guest".',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const PawsBackground(),
          SafeArea(
            child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: LivingCatAvatar(size: 160),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Purrist',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Create your mirror profile.' : 'Your honest reflection awaits.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Error Toast Message
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _errorMessage != null
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade200, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    hintText: 'Email address',
                    icon: Icons.alternate_email_rounded,
                    colorScheme: colorScheme,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    hintText: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    colorScheme: colorScheme,
                  ),
                  
                  // Confirm Password Field (only shown during Sign Up)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isSignUp
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              hintText: 'Confirm Password',
                              icon: Icons.lock_reset_rounded,
                              obscureText: true,
                              colorScheme: colorScheme,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 32),

                  SpringPressable(
                    onTap: _isLoading ? () {} : _handleEmailAuth,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD66B44), // AppColors.marmaladeDeep
                        border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFB55431), // AppColors.marmalade deeper
                            offset: Offset(4, 5),
                          )
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFDF9)),
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFFFFFDF9), // AppColors.white
                                ),
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Toggle Sign In / Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                        style: AppTypography.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'Sign In' : 'Sign Up',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  SpringPressable(
                    onTap: _isLoading ? () {} : _handleGoogleSignIn,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF9), // AppColors.white
                        border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFDCD0BC), // AppColors.line
                            offset: Offset(4, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF3A3532), // AppColors.ink
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required ColorScheme colorScheme,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // AppColors.white
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFF3A3532), // AppColors.ink
          width: 2,
        ),
        boxShadow: focusNode.hasFocus
            ? const [
                BoxShadow(
                  color: Color(0xFFEFC94C), // AppColors.butter
                  offset: Offset(4, 5),
                )
              ]
            : const [
                BoxShadow(
                  color: Color(0xFFDCD0BC), // AppColors.line
                  offset: Offset(4, 5),
                )
              ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: focusNode.hasFocus ? const Color(0xFFD66B44) : const Color(0xFF6B625B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF3A3532),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF6B625B), // AppColors.inkSoft
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
