import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../services/telegram_account_service.dart';
import '../utils/models/telegram_account.dart';

/// Screen for linking/managing Telegram accounts with bot-driven flow
class TelegramLinkingScreen extends StatefulWidget {
  const TelegramLinkingScreen({super.key});

  @override
  State<TelegramLinkingScreen> createState() => _TelegramLinkingScreenState();
}

class _TelegramLinkingScreenState extends State<TelegramLinkingScreen> {
  final TelegramAccountService _telegramService = TelegramAccountService();
  final TextEditingController _chatIdController = TextEditingController();
  
  TelegramAccount? _linkedAccount;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription? _telegramStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadLinkedAccount();
  }

  @override
  void dispose() {
    _telegramStreamSubscription?.cancel();
    _chatIdController.dispose();
    super.dispose();
  }

  /// Load currently linked Telegram account
  Future<void> _loadLinkedAccount() async {
    setState(() => _isLoading = true);
    try {
      final account = await _telegramService.getTelegramAccount();
      setState(() {
        _linkedAccount = account;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load account: $e';
      });
    }
  }

  /// Show instructions to manually get chat ID from bot
  void _showGetChatIdInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Your Chat ID'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step 1: Open Telegram',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('Search for and open: NurtriSeeSmart_bot'),
              SizedBox(height: 16),
              Text(
                'Step 2: Send /start',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('Send the command /start to the bot'),
              SizedBox(height: 16),
              Text(
                'Step 3: Copy Your Chat ID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('The bot will send you a message with your Chat ID. Copy it.'),
              SizedBox(height: 16),
              Text(
                'Step 4: Paste in App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('Paste the Chat ID in the field below.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Link Telegram account using manually entered chat ID
  Future<void> _linkTelegramWithChatId() async {
    final chatId = _chatIdController.text.trim();

    if (chatId.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Telegram Chat ID');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await _telegramService.linkTelegramAccount(
        telegramUserId: chatId,
        telegramUsername: 'telegram_user',
      );

      setState(() {
        _linkedAccount = account;
        _isLoading = false;
        _successMessage = '✅ Telegram account linked successfully!';
        _errorMessage = null;
        _chatIdController.clear();
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _successMessage = null);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to link account: $e';
      });
    }
  }

  /// Open Telegram bot link
  Future<void> _openTelegramBot() async {
    const botUsername = 'NurtriSeeSmart_bot';
    
    try {
      final uri = Uri.parse('https://t.me/$botUsername');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        // Copy link to clipboard as fallback
        await Clipboard.setData(
          ClipboardData(text: 'https://t.me/$botUsername'),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bot link copied to clipboard!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
  }

  /// Unlink current Telegram account
  Future<void> _unlinkTelegram() async {
    if (_linkedAccount == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Telegram?'),
        content: Text(
          'Are you sure you want to unlink @${_linkedAccount!.telegramUsername} from your account? '
          'You won\'t receive meal recommendations via Telegram.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _telegramService.unlinkTelegramAccount(_linkedAccount!.telegramUserId);
      setState(() {
        _linkedAccount = null;
        _isLoading = false;
        _successMessage = 'Telegram account unlinked successfully!';
      });

      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _successMessage = null);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to unlink account: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Bot Setup'),
        elevation: 0,
      ),
      body: _isLoading && _linkedAccount == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Message
                  if (_successMessage != null)
                    _buildSuccessMessage(_successMessage!),

                  // Error Message
                  if (_errorMessage != null) _buildErrorMessage(_errorMessage!),

                  // Header
                  const SizedBox(height: 8),
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Linked Account or Link Instructions
                  if (_linkedAccount != null)
                    _buildLinkedAccountCard()
                  else
                    _buildLinkingInstructions(),

                  const SizedBox(height: 32),

                  // Additional Info
                  if (_linkedAccount != null)
                    _buildInfoSection(),
                ],
              ),
            ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link Your Telegram Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Receive personalized meal recommendations directly in Telegram. '
          'Just send /breakfast, /lunch, /dinner to get started!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Build linked account card
  Widget _buildLinkedAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  'Account Linked',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Chat ID', _linkedAccount!.telegramUserId),
            _buildInfoRow('Username', '@${_linkedAccount!.telegramUsername}'),
            if (_linkedAccount!.fullName.isNotEmpty)
              _buildInfoRow('Name', _linkedAccount!.fullName),
            _buildInfoRow(
              'Linked Since',
              _formatDate(_linkedAccount!.linkedAt),
            ),
            if (_linkedAccount!.lastUsedAt != null)
              _buildInfoRow(
                'Last Used',
                _formatDate(_linkedAccount!.lastUsedAt!),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _openTelegramBot,
                    icon: const Icon(Icons.chat),
                    label: const Text('Open Telegram'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _unlinkTelegram,
                  icon: const Icon(Icons.delete),
                  label: const Text('Unlink'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build linking instructions with manual chat ID input
  Widget _buildLinkingInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to Get Your Chat ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1️⃣ Open Telegram and search for: NurtriSeeSmart_bot',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2️⃣ Send /start to the bot',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  '3️⃣ Copy your Chat ID from the bot message',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openTelegramBot,
                    icon: const Icon(Icons.telegram),
                    label: const Text('Open Telegram Bot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _showGetChatIdInstructions,
                  child: const Text('Show Detailed Instructions'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter Your Chat ID',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _chatIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Telegram Chat ID',
            hintText: 'e.g., 987654321',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.badge),
            helperText: 'Paste the Chat ID that the bot sends you',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _linkTelegramWithChatId,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Link Account'),
          ),
        ),
      ],
    );
  }

  /// Build command tile
  Widget _buildCommandTile(String command, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              command,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info section with features
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'After Linking - Available Commands',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCommandTile(
          '/breakfast',
          'Get breakfast recommendations',
        ),
        _buildCommandTile(
          '/lunch',
          'Get lunch recommendations',
        ),
        _buildCommandTile(
          '/dinner',
          'Get dinner recommendations',
        ),
        _buildCommandTile(
          '/snack',
          'Get snack recommendations',
        ),
        _buildCommandTile(
          '/help',
          'Show all available commands',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your recommendations are based on your profile, nutrition targets, and liked/disliked recipes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build success message
  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green[900]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[900]),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
