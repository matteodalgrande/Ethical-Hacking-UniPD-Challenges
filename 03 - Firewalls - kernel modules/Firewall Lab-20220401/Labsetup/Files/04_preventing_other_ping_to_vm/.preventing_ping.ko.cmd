cmd_/home/seed/Desktop/FirewallLab-20220401/Labsetup/Files/04_preventing_other_ping_to_vm/preventing_ping.ko := ld -r -m elf_x86_64  -z max-page-size=0x200000  --build-id  -T ./scripts/module-common.lds -o /home/seed/Desktop/FirewallLab-20220401/Labsetup/Files/04_preventing_other_ping_to_vm/preventing_ping.ko /home/seed/Desktop/FirewallLab-20220401/Labsetup/Files/04_preventing_other_ping_to_vm/preventing_ping.o /home/seed/Desktop/FirewallLab-20220401/Labsetup/Files/04_preventing_other_ping_to_vm/preventing_ping.mod.o;  true
