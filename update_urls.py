import os
import re

src_dir = r"c:\Users\harsh\Music\Harshul\Studies\sem 4\dbms\Minito_dbmsProject last version\frontend\src"

for root, dirs, files in os.walk(src_dir):
    for file in files:
        if file.endswith('.js') or file.endswith('.jsx'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. Replace double quotes "http://localhost:5000..." -> `http://${window.location.hostname}:5000...`
            content = re.sub(r'"http://localhost:5000(.*?)"', r'`http://${window.location.hostname}:5000\1`', content)
            
            # 2. Replace single quotes 'http://localhost:5000...' -> `http://${window.location.hostname}:5000...`
            content = re.sub(r"'http://localhost:5000(.*?)'", r'`http://${window.location.hostname}:5000\1`', content)
            
            # 3. Any remaining http://localhost:5000 inside backticks
            content = content.replace("http://localhost:5000", "http://${window.location.hostname}:5000")
            
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)

print("Updated API URLs successfully!")
