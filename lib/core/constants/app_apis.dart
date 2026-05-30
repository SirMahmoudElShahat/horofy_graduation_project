class AppApis {
  // Base URL
  static const String baseUrl = 'https://deslexia-desgraphia-production-1e86.up.railway.app';

  // ==========================================
  // Authentication
  // ==========================================
  static const String login = '$baseUrl/auth/login'; // POST: User login
  static const String register = '$baseUrl/auth/register'; // POST: User registration
  static const String changePassword = '$baseUrl/auth/password'; // PATCH: Change current user password
  static const String forgotPassword = '$baseUrl/auth/forgot-password'; // POST: Request password reset OTP
  static const String resetPassword = '$baseUrl/auth/reset-password'; // POST: Reset password using OTP
  static const String verifyOtp = '$baseUrl/auth/verify-otp'; // POST: Verify email OTP
  static const String requestChangePasswordOtp = '$baseUrl/auth/request-change-password-otp'; // POST: Send OTP to confirm password change
  static const String changePasswordWithOtp = '$baseUrl/auth/change-password-with-otp'; // PATCH: Change password after OTP verification
  static const String deleteAccount = '$baseUrl/auth/delete-account'; // DELETE: Delete user account permanently

  // ==========================================
  // Users
  // ==========================================
  static const String createUser = '$baseUrl/users'; // POST: Create a new user (Admin only)
  static const String getAllUsers = '$baseUrl/users'; // GET: Get all users (Admin only)
  static const String getProfile = '$baseUrl/users/profile'; // GET: Get current user profile
  static const String updateProfile = '$baseUrl/users/profile'; // PATCH: Update current user profile
  static String getUserById(String id) => '$baseUrl/users/$id'; // GET: Get user by ID (Admin only)
  static String updateUserById(String id) => '$baseUrl/users/$id'; // PATCH: Update user by ID (Admin only)
  static String deleteUserById(String id) => '$baseUrl/users/$id'; // DELETE: Delete user (Admin only)
  static const String verifyUserOtp = '$baseUrl/users/verify-otp'; // POST

  // ==========================================
  // Chat
  // ==========================================
  static const String createConversation = '$baseUrl/chat/conversations'; // POST: Create a new conversation
  static const String getUserConversations = '$baseUrl/chat/conversations'; // GET: Get user conversations
  static String getConversationById(String id) => '$baseUrl/chat/conversations/$id'; // GET: Get conversation by ID
  static String updateConversation(String id) => '$baseUrl/chat/conversations/$id'; // PATCH: Update conversation
  static String deleteConversation(String id) => '$baseUrl/chat/conversations/$id'; // DELETE: Delete a conversation
  static String getMessages(String id) => '$baseUrl/chat/conversations/$id/messages'; // GET: Get messages from a conversation
  static String sendMessage(String id) => '$baseUrl/chat/conversations/$id/messages'; // POST: Send a message and get AI analysis
  static String markMessageAsRead(String id) => '$baseUrl/chat/messages/$id/read'; // POST: Mark message as read
  static const String getUnreadCount = '$baseUrl/chat/unread-count'; // GET: Get unread count
  static String deleteMessage(String id) => '$baseUrl/chat/messages/$id'; // DELETE: Delete a message

  // ==========================================
  // Upload
  // ==========================================
  static const String uploadFile = '$baseUrl/upload/file'; // POST: Upload a single file
  static const String uploadFiles = '$baseUrl/upload/files'; // POST: Upload multiple files (max 10)
  static const String uploadAvatar = '$baseUrl/upload/avatar'; // POST: Upload user avatar
  static const String uploadStoreLogo = '$baseUrl/upload/store-logo'; // POST: Upload store logo
  static const String uploadStoreCover = '$baseUrl/upload/store-cover'; // POST: Upload store cover image
  static const String uploadChatAttachment = '$baseUrl/upload/chat-attachment'; // POST: Upload chat message attachment

  // ==========================================
  // Children
  // ==========================================
  static const String createChild = '$baseUrl/api/children'; // POST: Create child
  static const String getChildren = '$baseUrl/api/children'; // GET: Get all children for the logged-in parent
  static String getChildById(String id) => '$baseUrl/api/children/$id'; // GET: Get a specific child by ID
  static String updateChild(String id) => '$baseUrl/api/children/$id'; // PUT: Update child information
  static String deleteChild(String id) => '$baseUrl/api/children/$id'; // DELETE: Delete a child

  // ==========================================
  // Submissions
  // ==========================================
  static const String submitExercise = '$baseUrl/submissions'; // POST: Submit exercise result (from Mobile/Web)
  static String getChildSubmissions(String childId) => '$baseUrl/submissions/child/$childId'; // GET: Get all submissions for a specific child

  // ==========================================
  // Exercises
  // ==========================================
  static const String getExercises = '$baseUrl/exercises'; // GET
  static String getExerciseById(String id) => '$baseUrl/exercises/$id'; // GET
  static String updateExercise(String id) => '$baseUrl/exercises/$id'; // PATCH: Update an exercise (Admin only)
  static String deleteExercise(String id) => '$baseUrl/exercises/$id'; // DELETE: Delete an exercise (Admin only)
}
