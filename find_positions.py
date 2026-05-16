import pdfplumber
import sys
sys.stdout.reconfigure(encoding='utf-8')

with pdfplumber.open(r'D:\小米云盘\文件\黑龙江科技大学\Zrrd\简历.pdf') as pdf:
    # Page 1 - find positions
    page1 = pdf.pages[0]
    chars = page1.chars
    
    print("=== Page 1 - Finding 前端技术 ===")
    for i, c in enumerate(chars):
        text = c.get('text', '')
        if text == '前':
            # Check if next chars form 前端技术
            if i+3 < len(chars):
                combined = chars[i]['text'] + chars[i+1]['text'] + chars[i+2]['text'] + chars[i+3]['text']
                if combined == '前端技术':
                    print(f'Found "前端技术" at x={chars[i]["x0"]:.1f}, y={chars[i]["top"]:.1f}')
                    print(f'  Last char bottom: {chars[i+3]["bottom"]:.1f}')
                    print(f'  Font: {chars[i]["fontname"]}, Size: {chars[i]["size"]}')
    
    print()
    print("=== Page 1 - Finding 全栈能力 ===")
    for i, c in enumerate(chars):
        text = c.get('text', '')
        if text == '全':
            if i+4 < len(chars):
                combined = chars[i]['text'] + chars[i+1]['text'] + chars[i+2]['text'] + chars[i+3]['text'] + chars[i+4]['text']
                if combined == '全栈能力':
                    print(f'Found "全栈能力" at x={chars[i]["x0"]:.1f}, y={chars[i]["top"]:.1f}')
                    print(f'  Last char bottom: {chars[i+4]["bottom"]:.1f}')
    
    print()
    print("=== Page 2 - Finding 自我评价 ===")
    page2 = pdf.pages[1]
    chars2 = page2.chars
    for i, c in enumerate(chars2):
        text = c.get('text', '')
        if text == '自':
            if i+3 < len(chars2):
                combined = chars2[i]['text'] + chars2[i+1]['text'] + chars2[i+2]['text'] + chars2[i+3]['text']
                if combined == '自我评价':
                    print(f'Found "自我评价" at x={chars2[i]["x0"]:.1f}, y={chars2[i]["top"]:.1f}')
                    print(f'  Font: {chars2[i]["fontname"]}, Size: {chars2[i]["size"]}')
    
    print()
    print("=== Page 2 - Finding last project Gitee link ===")
    for i, c in enumerate(chars2):
        text = c.get('text', '')
        if text == 'y':
            if i+10 < len(chars2):
                combined = ''.join(chars2[i+j]['text'] for j in range(11))
                if combined == 'yuewu_parent':
                    print(f'Found "yuewu_parent" at x={chars2[i]["x0"]:.1f}, y={chars2[i]["top"]:.1f}')
                    print(f'  Bottom: {chars2[i]["bottom"]:.1f}')
