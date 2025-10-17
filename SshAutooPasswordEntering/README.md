Скопировать `ssh_auto_ps.ps1`
Скопировать путь на `ssh_auto_ps.ps1`
Вставить путь после `-File` и дописать имя файла после `\`
создать ярлык и вписать туда получившуюся строку 


`powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\user\Desktop\ssh_auto_ps.ps1 -SSHHost "sshhost" -SSHUser "sshusername" -SSHPass "sshpassword"`
