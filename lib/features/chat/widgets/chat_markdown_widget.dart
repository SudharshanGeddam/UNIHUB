import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter_math_fork/flutter_math.dart';

// Custom widget to render markdown with math support
class ChatMarkdownWidget extends StatelessWidget {
  final String text;

  const ChatMarkdownWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Process text to replace $...$ math expressions with code blocks that we can style
    final processedText = text.replaceAllMapped(
      RegExp(r'\$([^$]+)\$'),
      (match) {
        final mathContent = match.group(1) ?? '';
        // Use a special marker that we can detect in the code builder
        return '`MATH:${mathContent.trim()}`';
      },
    );

    return md.MarkdownBody(
      data: processedText,
      selectable: true,
      styleSheet: md.MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
        strong: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontStyle: FontStyle.italic,
        ),
        listBullet: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        code: TextStyle(
          color: Colors.cyan.shade200,
          backgroundColor: Colors.black.withOpacity(0.4),
          fontSize: 15,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.3),
            width: 1,
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontStyle: FontStyle.italic,
        ),
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        a: const TextStyle(
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
        ),
      ),
      builders: {
        'code': _MathCodeBuilder(),
      },
    );
  }
}

// Custom builder that detects and renders math expressions
class _MathCodeBuilder extends md.MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    final text = element.textContent.trim();

    // Check if it's a math expression (starts with MATH:)
    if (text.startsWith('MATH:')) {
      try {
        // Extract math content
        final mathContent = text.substring(5).trim();

        // Render using flutter_math_fork
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Math.tex(
            mathContent,
            mathStyle: MathStyle.text,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      } catch (e) {
        // If math parsing fails, show as styled code
        return _buildStyledCode(text.substring(5));
      }
    }

    // Regular code block - style it nicely
    return _buildStyledCode(text);
  }

  Widget _buildStyledCode(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.cyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          color: Colors.cyan.shade200,
          fontSize: 15,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}
