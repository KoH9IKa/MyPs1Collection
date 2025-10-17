param(
    [string]$SSHHost,
    [string]$SSHUser,
    [string]$SSHPass,
    [switch]$FirstTime
)

# Если пароль не передан через параметр, берем из окружения или запрашиваем
if (-not $SSHPass) { $SSHPass = $env:SSH_PASS }
if (-not $SSHPass) {
    $secure = Read-Host "Введите пароль" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $SSHPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

# Устанавливаем заголовок текущего окна PowerShell, чтобы его можно было активировать
$winTitle = "SSH-$SSHHost"
try {
    $host.UI.RawUI.WindowTitle = $winTitle
} catch {
    # В некоторых хостах PowerShell установка заголовка может выдать ошибку — игнорируем
}

Start-Sleep -Milliseconds 1000

# Формируем командную строку ssh
$sshCmd = "ssh $SSHUser@$SSHHost"

# Запускаем ssh в том же окне (NoNewWindow) и получаем объект процесса
# -PassThru возвращает System.Diagnostics.Process чтобы можно было при необходимости ждать/проверять
$proc = Start-Process -FilePath "ssh" -ArgumentList "$SSHUser@$SSHHost" -NoNewWindow -PassThru

# Даём процессу и окну время и активируем окно по заголовку
Start-Sleep -Milliseconds 400
$wshell = New-Object -ComObject WScript.Shell

# Попытаемся активировать окно по установлённому заголовку
$activated = $wshell.AppActivate($winTitle)

# Если по заголовку не активировалось, попробуем активировать по PID (альтернативно)
if (-not $activated) {
    try {
        # На некоторые системы AppActivate с PID не работает; пробуем имя процесса
        $wshell.AppActivate($proc.Id) | Out-Null
    } catch {
        # ничего — будем полагаться на то, что фокус уже в окне
    }
}

# Если это первый раз — ssh спросит про добавление хоста в known_hosts -> отправляем "yes"
if ($FirstTime) {
    Start-Sleep -Milliseconds 200
    $wshell.SendKeys("yes{ENTER}")
    Start-Sleep -Milliseconds 600
}

# Отправляем пароль (SendKeys) и Enter
Start-Sleep -Milliseconds 300
$wshell.SendKeys($SSHPass + "{ENTER}")

# По желанию можно дождаться завершения ssh-процесса (только если нужно)
# $proc.WaitForExit()
