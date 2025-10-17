# Check-Kernel41.ps1
# Block 1: List of recent Kernel-Power (ID 41) events (English only) / Block 2: Detailed description of the most recent event (English/Russian)

# --- Parameters / Параметры ---
$logName = 'System'
$provider = 'Microsoft-Windows-Kernel-Power'
$eventId = 41
$maxList = 10  # number of recent events to display / количество последних событий для списка

try {
    # --- Block 1: Recent events list (English only) ---
    Write-Output "=== LIST OF LAST $maxList Kernel-Power (ID 41) EVENTS ==="
    $eventsList = Get-WinEvent -FilterHashtable @{
        LogName = $logName
        ProviderName = $provider
        Id = $eventId
    } -MaxEvents $maxList -ErrorAction Stop

    if (-not $eventsList) {
        Write-Output "No Kernel-Power (ID 41) events found."
    }
    else {
        foreach ($evt in $eventsList) {
            Write-Output ("TimeCreated: {0} | RecordId: {1} | Level: {2}" -f $evt.TimeCreated, $evt.RecordId, $evt.LevelDisplayName)
        }
    }

    Write-Output "`n=== DETAILED DESCRIPTION OF THE MOST RECENT EVENT / ПОДРОБНОЕ ОПИСАНИЕ САМОГО НОВОГО СОБЫТИЯ ==="

    # --- Block 2: Detailed description of the most recent event ---
    $evt = $eventsList | Select-Object -First 1
    if (-not $evt) {
        Write-Output "No available event for detailed view / Нет доступного события для подробного просмотра."
    }
    else {
        Write-Output ("TimeCreated : {0}" -f $evt.TimeCreated)
        Write-Output ("RecordId    : {0}" -f $evt.RecordId)
        Write-Output ("Provider    : {0}" -f $evt.ProviderName)
        Write-Output ("Id          : {0}" -f $evt.Id)
        Write-Output ("Level       : {0}" -f $evt.LevelDisplayName)
        Write-Output ("MachineName : {0}" -f $evt.MachineName)
        Write-Output "-----------------------------------`n"

        Write-Output "FULL MESSAGE / ПОЛНОЕ СООБЩЕНИЕ:"
        Write-Output "-----------------------------------"
        Write-Output $evt.Message
        Write-Output "-----------------------------------`n"

        try {
            $xml = [xml]$evt.ToXml()
            $xmlFormatted = New-Object System.IO.StringWriter
            $xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
            $xmlWriterSettings.Indent = $true
            $xmlWriterSettings.IndentChars = "    "
            $xmlWriterSettings.OmitXmlDeclaration = $false

            $xmlWriter = [System.Xml.XmlWriter]::Create($xmlFormatted, $xmlWriterSettings)
            $xml.WriteTo($xmlWriter)
            $xmlWriter.Flush()
            $xmlWriter.Close()

            Write-Output "FULL XML (formatted) / ПОЛНЫЙ XML (отформатированный):"
            Write-Output "-----------------------------------"
            Write-Output $xmlFormatted.ToString()
            Write-Output "-----------------------------------`n"
        }
        catch {
            Write-Output "Failed to get XML / Не удалось получить XML: $_"
        }
    }
}
catch {
    Write-Output "An error occurred while accessing the event log / Произошла ошибка при работе с журналом событий: $_"
}
finally {
    # --- Pause at the end of the script / Пауза в конце скрипта ---
    Read-Host "`nPress Enter to exit / Нажмите Enter для выхода..."
}
