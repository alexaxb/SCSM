Import-Module 'C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.1\Microsoft.Exchange.WebServices.dll'

$EWS = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList( [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP2)
$EWS.Credentials = New-Object System.Net.NetworkCredential -ArgumentList 'username', 'password'
$EWS.Url = 'https://krimmail.kvv.se/EWS/Exchange.asmx'

$Folder = [Microsoft.Exchange.WebServices.Data.CalendarFolder]::Bind($EWS,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar)
$View = [Microsoft.Exchange.WebServices.Data.CalendarView]::new([datetime]::Now,[datetime]::Now.AddDays(3))
$Items = $Folder.FindAppointments($View)

$Appointment = New-Object Microsoft.Exchange.WebServices.Data.Appointment -ArgumentList $EWS
$Appointment.Subject = 'test'
$Appointment.Body = '123'
$Appointment.Start = Get-Date
$Appointment.End = (Get-Date).AddHours(1)
$Appointment.IsReminderSet = $false
$Appointment.Categories = 'Blå kategori'
$Appointment.Save([Microsoft.Exchange.WebServices.Data.SendInvitationsMode]::SendToNone) 
