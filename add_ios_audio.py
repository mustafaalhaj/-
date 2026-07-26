import shutil
import os

# 1. Copy adhan audio file to ios/Runner/
src = 'android/app/src/main/res/raw/adhan.mp3'
for fname in ['adhan.mp3', 'adhan.aiff', 'adhan.caf', 'adhan.wav']:
    dst = os.path.join('ios', 'Runner', fname)
    shutil.copy(src, dst)
    print(f"Copied {src} to {dst}")

# 2. Update ios/Runner.xcodeproj/project.pbxproj
pbx_path = 'ios/Runner.xcodeproj/project.pbxproj'
with open(pbx_path, 'r', encoding='utf-8') as f:
    content = f.read()

files_to_add = ['adhan.caf', 'adhan.aiff', 'adhan.wav', 'adhan.mp3']
build_files = ''
file_refs = ''
resources = ''
group_refs = ''

for i, fname in enumerate(files_to_add):
    bf_id = f'74858F{i:02X}1ED2DC5600515810'
    fr_id = f'74858E{i:02X}1ED2DC5600515810'
    if fr_id not in content:
        build_files += f'\t\t{bf_id} /* {fname} in Resources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {fname} */; }};\n'
        file_refs += f'\t\t{fr_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = audio; path = {fname}; sourceTree = "<group>"; }};\n'
        resources += f'\t\t\t\t{bf_id} /* {fname} in Resources */,\n'
        group_refs += f'\t\t\t\t{fr_id} /* {fname} */,\n'

if build_files:
    content = content.replace('/* Begin PBXBuildFile section */\n', '/* Begin PBXBuildFile section */\n' + build_files)
    content = content.replace('/* Begin PBXFileReference section */\n', '/* Begin PBXFileReference section */\n' + file_refs)
    
    pos = content.find('/* Runner */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n')
    if pos != -1:
        insert_pos = pos + len('/* Runner */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n')
        content = content[:insert_pos] + group_refs + content[insert_pos:]
    
    pos_res = content.find('/* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n')
    if pos_res != -1:
        insert_res = pos_res + len('/* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n')
        content = content[:insert_res] + resources + content[insert_res:]

    with open(pbx_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print('pbxproj updated successfully!')
else:
    print('Already up to date.')
