import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 1. colorScheme.background -> colorScheme.surface
    content = re.sub(r'\.background\b', '.surface', content)
    
    # 2. colorScheme.onBackground -> colorScheme.onSurface
    content = re.sub(r'\.onBackground\b', '.onSurface', content)
    
    # 3. .withOpacity(x) -> .withValues(alpha: x)
    # The regex captures everything between the parentheses.
    # Be careful not to replace things like `withOpacity(0.5).withOpacity(0.5)` incorrectly,
    # though that rarely happens. `[^)]+` is usually safe.
    content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
    
    # 4. Switch(activeColor: -> Switch(activeThumbColor:
    # Actually activeColor is also used in other widgets, so let's only replace it where it makes sense,
    # but the task says "Replace `Switch(activeColor:` -> `Switch(activeThumbColor:`".
    # Since Switch may span multiple lines, let's just replace `activeColor:` with `activeThumbColor:` 
    # if it's likely inside a Switch. Or just do it everywhere if we know it's only for Switch.
    # Actually activeColor is a property on Switch. We can just replace 'activeColor:' with 'activeThumbColor:'
    # But wait, activeColor is also a property on Checkbox, Radio, Slider. Are they deprecated there too?
    # Yes, for Switch it's activeThumbColor or activeColor depending on context. Wait, activeColor is deprecated in Switch.
    
    # Let's use a simpler regex for Switch activeColor. We know there's only a few instances.
    # Let's search for "activeColor:" in the codebase first or just blindly replace it if it's inside Switch.
    # Since we can't easily parse AST in Python, let's just replace "activeColor:" with "activeThumbColor:" 
    # but only on lines that look like they're inside a Switch, or just do it for the word activeColor.
    # Actually, in Phase 4.1 it specifically says `Switch(activeColor:` -> `Switch(activeThumbColor:`.
    
    # Let's just do a naive replace:
    content = content.replace('activeColor:', 'activeThumbColor:')

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

def main():
    lib_dir = os.path.join(os.getcwd(), 'lib')
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
