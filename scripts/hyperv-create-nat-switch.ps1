# See: https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
    exit
}


# See: https://www.petri.com/using-nat-virtual-switch-hyper-v

If ("CBDCSwitch" -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $FALSE) {
    'Creating Internal-only switch named "CBDCSwitch" on Windows Hyper-V host...'

    New-VMSwitch -SwitchName "CBDCSwitch" -SwitchType Internal
}
else {
    '"CBDCSwitch" for static IP configuration already exists; skipping'
}

If ("192.168.99.1" -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $FALSE) {
    'Registering new IP address 192.168.99.1 on Windows Hyper-V host...'

    New-NetIPAddress -IPAddress 192.168.99.1 -PrefixLength 24 -InterfaceAlias "vEthernet (CBDCSwitch)"
}
else {
    '"192.168.99.1" for static IP configuration already registered; skipping'
}

If ("192.168.99.0/24" -in (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix) -eq $FALSE) {
    'Registering new NAT adapter for 192.168.99.0/24 on Windows Hyper-V host...'

    New-NetNAT -Name "CBDCNetwork" -InternalIPInterfaceAddressPrefix 192.168.99.0/24
}
else {
    '"192.168.99.0/24" for static IP configuration already registered; skipping'
}

{
    'Enabling Forwarding on CBDC switch'
    Set-NetIPInterface -InterfaceAlias "vEthernet (CBDCSwitch)" -Forwarding Enabled
}

If ("WSL" -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $FALSE) {
    'Enabling Forwarding on WSL switch'
    Set-NetIPInterface -InterfaceAlias "vEthernet (WSL)" -Forwarding Enabled
}

# Remove-NetNat -Name CBDCNetwork
# Remove-NetIPAddress -IPAddress 192.168.99.1
# Remove-VMSwitch -SwitchName CBDCSwitch
