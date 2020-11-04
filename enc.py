import os, sys, time

if len(sys.argv) == 2:
	inp = sys.argv[1]
else:
	inp = input('[?] Enter Filename or Path: ')	

out = inp + '_enc'

if os.path.exists(out) == False:
	pass
elif input('[?] Enter to overwrite: ') == '':
	pass
else:
	print('[!] Exitting...')
	time.sleep(0.5)
	sys.exit()

try:
	with open(inp, 'r') as file:
		raw = file.read().encode()

except FileNotFoundError:
	print('[!] File does not exist: ')
	sys.exit()

with open(out, 'w') as file:
	file.write(str(raw).replace('b', '', 1).replace('"', r'\"'))
	print('[#] Successfully Converted...')

time.sleep(0.5)