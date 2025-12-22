import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          _buildSectionHeader(context, 'Frequently Asked Questions'),
          const SizedBox(height: 12),
          _buildFaqItem(
            context,
            question: 'How do I capture a screening image?',
            answer:
                'Go to the Capture tab, select your camera or gallery, position the cervical image clearly in frame, and tap the capture button. Ensure good lighting for best results.',
          ),
          _buildFaqItem(
            context,
            question: 'How long does AI analysis take?',
            answer:
                'AI analysis typically takes 2-5 seconds depending on network conditions. You\'ll see a "Processing" status while the analysis is running.',
          ),
          _buildFaqItem(
            context,
            question: 'What do the classification results mean?',
            answer:
                'Normal: No abnormalities detected\nAbnormal: Potential lesions or abnormalities found\nInconclusive: Image quality insufficient for reliable analysis',
          ),
          _buildFaqItem(
            context,
            question: 'How is patient data protected?',
            answer:
                'All data is encrypted in transit and at rest. Images are stored securely and accessible only to authorized medical professionals.',
          ),

          const SizedBox(height: 24),

          // Contact Section
          _buildSectionHeader(context, 'Contact Support'),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@serfix.com',
            onTap: () {
              // TODO: Launch email client
            },
          ),
          _buildContactItem(
            context,
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Available 9am - 5pm EST',
            onTap: () {
              // TODO: Open chat
            },
          ),
          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            onTap: () {
              // TODO: Launch phone dialer
            },
          ),

          const SizedBox(height: 24),

          // Resources Section
          _buildSectionHeader(context, 'Resources'),
          const SizedBox(height: 12),
          _buildResourceItem(
            context,
            icon: Icons.book_outlined,
            title: 'User Guide',
            onTap: () {
              // TODO: Open user guide
            },
          ),
          _buildResourceItem(
            context,
            icon: Icons.video_library_outlined,
            title: 'Video Tutorials',
            onTap: () {
              // TODO: Open tutorials
            },
          ),
          _buildResourceItem(
            context,
            icon: Icons.article_outlined,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Open terms
            },
          ),
          _buildResourceItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Open privacy policy
            },
          ),

          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Serfix',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI-Powered Cervical Cancer Screening',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
