import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:markdown/markdown.dart' as markdown;
import 'package:flutter_math_fork/flutter_math.dart';

class MathMarkdownWidget extends StatelessWidget {
  final String text;

  const MathMarkdownWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return md.MarkdownBody(
      data: text,
      selectable: true,
      extensionSet: markdown.ExtensionSet(
        [
          ...markdown.ExtensionSet.gitHubFlavored.blockSyntaxes,
        ],
        [
          ...markdown.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          LatexSyntax(),
        ],
      ),
      styleSheet: md.MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.6,
        ),
        strong: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        listBullet: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        code: TextStyle(
          color: Colors.cyan.shade200,
          backgroundColor: Colors.black.withOpacity(0.4),
          fontSize: 14,
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
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        a: const TextStyle(
          color: Colors.lightBlueAccent,
          decoration: TextDecoration.underline,
        ),
      ),
      builders: {
        'code': _StyledCodeBuilder(),
        'latex': LatexElementBuilder(),
      },
    );
  }
}

class _StyledCodeBuilder extends md.MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;

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
          fontSize: 14,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}

class LatexSyntax extends markdown.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[\s\S]*?\$\$)|(\$[^$]+?\$)');

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final input = match.input;
    final matchStart = match.start;
    final matchEnd = match.end;
    final text = input.substring(matchStart, matchEnd);
    final isBlock = text.startsWith(r'$$');
    final content = isBlock
        ? text.substring(2, text.length - 2)
        : text.substring(1, text.length - 1);

    final element = markdown.Element.text('latex', content);
    element.attributes['style'] = isBlock ? 'block' : 'inline';
    parser.addNode(element);
    return true;
  }
}

class LatexElementBuilder extends md.MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    final content = element.textContent;
    final style = element.attributes['style'];

    if (style == 'block') {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Math.tex(
          content,
          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          onErrorFallback: (err) => Text(
            '\$$content\$',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Math.tex(
      content,
      textStyle: preferredStyle?.copyWith(color: Colors.white) ??
          const TextStyle(color: Colors.white),
      onErrorFallback: (err) => Text(
        '\$$content\$',
        style: preferredStyle?.copyWith(color: Colors.redAccent) ??
            const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
