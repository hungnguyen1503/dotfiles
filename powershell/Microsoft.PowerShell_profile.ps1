#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

# Loading this module adds about two seconds to every shell startup.  Keep the
# feature available, but load it only in sessions where its package-install
# suggestions are needed.
function Enable-WinGetCommandNotFound {
  Import-Module -Name Microsoft.WinGet.CommandNotFound
}
#f45873b3-b655-43a6-b217-97c00aa0db58

oh-my-posh init pwsh --config (Join-Path $HOME "dotfiles/oh-my-posh/M365Princess.omp.json") | Invoke-Expression

if ($IsWindows) {
  function bash {
    & "C:\Program Files\Git\bin\bash.exe" @args
  }
}

# Trust the corporate Netskope CA for Node-based tools (pi harness and its MCP
# endpoints) so they work without manually setting NODE_EXTRA_CA_CERTS.
$piCaPath = Join-Path $env:USERPROFILE '.pi\agent\certs\netskope-certadmin-root.pem'
if (-not $env:NODE_EXTRA_CA_CERTS -and (Test-Path -LiteralPath $piCaPath)) {
  $env:NODE_EXTRA_CA_CERTS = $piCaPath
}
