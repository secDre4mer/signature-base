
rule MAL_RANSOM_SH_ESXi_Attacks_Feb23_1 {
   meta:
      description = "Detects script used in ransomware attacks exploiting and encrypting ESXi servers - file encrypt.sh"
      author = "Florian Roth"
      reference = "https://www.bleepingcomputer.com/forums/t/782193/esxi-ransomware-help-and-support-topic-esxiargs-args-extension/page-14"
      date = "2023-02-04"
      score = 85
      hash1 = "10c3b6b03a9bf105d264a8e7f30dcab0a6c59a414529b0af0a6bd9f1d2984459"
   strings:
      $x1 = "/bin/find / -name *.log -exec /bin/rm -rf {} \\;" ascii fullword
      $x2 = "/bin/touch -r /etc/vmware/rhttpproxy/config.xml /bin/hostd-probe.sh" ascii fullword
      $x3 = "grep encrypt | /bin/grep -v grep | /bin/wc -l)" ascii fullword

      $s1 = "## ENCRYPT" ascii fullword
      $s2 = "/bin/find / -name *.log -exec /bin" ascii fullword
   condition:
      uint16(0) == 0x2123 and
      filesize < 10KB and (
         1 of ($x*)
         or 2 of them
      ) or 3 of them
}

rule MAL_RANSOM_ELF_ESXi_Attacks_Feb23_1 {
   meta:
      description = "Detects ransomware exploiting and encrypting ESXi servers"
      author = "Florian Roth"
      reference = "https://www.bleepingcomputer.com/forums/t/782193/esxi-ransomware-help-and-support-topic-esxiargs-args-extension/page-14"
      date = "2023-02-04"
      score = 85
      hash1 = "11b1b2375d9d840912cfd1f0d0d04d93ed0cddb0ae4ddb550a5b62cd044d6b66"
   strings:
      $x1 = "usage: encrypt <public_key> <file_to_encrypt> [<enc_step>] [<enc_size>] [<file_size>]" ascii fullword
      $x2 = "[ %s ] - FAIL { Errno: %d }" ascii fullword

      $s1 = "lPEM_read_bio_RSAPrivateKey" ascii fullword
      $s2 = "lERR_get_error" ascii fullword
      $s3 = "get_pk_data: key file is empty!" ascii fullword

      $op1 = { 8b 45 a8 03 45 d0 89 45 d4 8b 45 a4 69 c0 07 53 65 54 89 45 a8 8b 45 a8 c1 c8 19 }
      $op2 = { 48 89 95 40 fd ff ff 48 83 bd 40 fd ff ff 00 0f 85 2e 01 00 00 48 8b 9d 50 ff ff ff 48 89 9d 30 fd ff ff 48 83 bd 30 fd ff ff 00 78 13 f2 48 0f 2a 85 30 fd ff ff }
      $op3 = { 31 55 b4 f7 55 b8 8b 4d ac 09 4d b8 8b 45 b8 31 45 bc c1 4d bc 13 c1 4d b4 1d }
   condition:
      uint16(0) == 0x457f and
      filesize < 200KB and (
         1 of ($x*)
         or 3 of them
      ) or 4 of them
}
