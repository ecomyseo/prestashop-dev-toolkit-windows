<#
/**
 * Instalador de herramientas de desarrollo y revision de codigo (Windows)
 *
 * Objetivo: dejar el equipo listo para que Antigravity (y tu) podais revisar,
 * verificar y comprobar codigo PHP / PrestaShop, ademas de Python, JS, CSS,
 * Smarty (.tpl), Twig, SQL, YAML, etc.
 *
 * @author    Ecom Experts <ecomyseo@gmail.com>
 * @copyright 2026 Ecom Experts
 * @license   AFL-3.0
 *
 * USO:
 *   pwsh -ExecutionPolicy Bypass -File .\instalar-herramientas.ps1
 *
 *   # Incluyendo descarga de versiones de PrestaShop para test de compatibilidad:
 *   pwsh -ExecutionPolicy Bypass -File .\instalar-herramientas.ps1 -DownloadPrestaShop
 *
 *   # Saltando extensiones de VS Code:
 *   pwsh -ExecutionPolicy Bypass -File .\instalar-herramientas.ps1 -SkipVSCode
 *
 * El script es idempotente: comprueba antes de instalar y se puede re-ejecutar.
 */
#>

[CmdletBinding()]
param(
    # Carpeta raiz donde se instalan PHP, Composer, tools y PrestaShop.
    [string]   $InstallRoot       = 'C:\dev-tools',

    # Versiones de PHP a instalar (NTS x64). La mas alta sera la principal.
    # 7.4 -> PS1.6/1.7 | 8.1/8.2/8.3 -> PS8.x | 8.4 -> PS9.x
    [string[]] $PhpVersions       = @('7.4.33', '8.1.31', '8.2.27', '8.3.15', '8.4.2'),

    # Descargar copias de PrestaShop para pruebas de compatibilidad (opcional, pesado).
    [switch]   $DownloadPrestaShop,

    # Versiones de PrestaShop a descargar si se activa -DownloadPrestaShop.
    [string[]] $PsVersions        = @('1.6.1.24', '1.7.8.11', '8.1.7', '8.2.7', '9.1.1'),

    # No instalar extensiones de VS Code.
    [switch]   $SkipVSCode,

    # No instalar herramientas de Python (pip).
    [switch]   $SkipPython,

    # No instalar herramientas globales de Node (npm).
    [switch]   $SkipNode
)

$ErrorActionPreference = 'Stop'
$ProgressPreference     = 'SilentlyContinue'   # acelera Invoke-WebRequest

# ---------------------------------------------------------------------------
#  Utilidades
# ---------------------------------------------------------------------------
$script:LogFile = Join-Path $PSScriptRoot 'instalacion.log'

function Write-Step  { param($m) Write-Host "`n=== $m ===" -ForegroundColor Cyan;  "[$(Get-Date -Format o)] STEP $m" | Add-Content $script:LogFile }
function Write-Ok    { param($m) Write-Host "  [OK]   $m" -ForegroundColor Green;  "[$(Get-Date -Format o)] OK   $m" | Add-Content $script:LogFile }
function Write-Skip  { param($m) Write-Host "  [SKIP] $m" -ForegroundColor DarkGray }
function Write-Warn2 { param($m) Write-Host "  [WARN] $m" -ForegroundColor Yellow; "[$(Get-Date -Format o)] WARN $m" | Add-Content $script:LogFile }
function Write-Err2  { param($m) Write-Host "  [ERR]  $m" -ForegroundColor Red;    "[$(Get-Date -Format o)] ERR  $m" | Add-Content $script:LogFile }

function Test-Cmd { param($name) [bool](Get-Command $name -ErrorAction SilentlyContinue) }

function Add-UserPath {
    param([string]$Dir)
    if (-not (Test-Path $Dir)) { return }
    $cur = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($cur -split ';') -notcontains $Dir) {
        [Environment]::SetEnvironmentVariable('Path', "$cur;$Dir", 'User')
        Write-Ok "PATH usuario += $Dir"
    } else {
        Write-Skip "PATH ya contiene $Dir"
    }
    # Disponible tambien en esta sesion.
    if (($env:Path -split ';') -notcontains $Dir) { $env:Path += ";$Dir" }
}

function Get-File {
    param([string]$Url, [string]$Out)
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
}

# ---------------------------------------------------------------------------
#  0. Preparacion
# ---------------------------------------------------------------------------
Write-Step "Preparando carpetas en $InstallRoot"
$BinDir = Join-Path $InstallRoot 'bin'
foreach ($d in @($InstallRoot, $BinDir, (Join-Path $InstallRoot 'php'), (Join-Path $InstallRoot 'tools'))) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
Add-UserPath $BinDir
Write-Ok "Carpetas listas. Log en $script:LogFile"

if (-not (Test-Cmd winget)) {
    Write-Warn2 "winget no esta disponible. Algunas instalaciones de respaldo no funcionaran."
}

# ---------------------------------------------------------------------------
#  1. PHP (multiples versiones para test de compatibilidad)
# ---------------------------------------------------------------------------
Write-Step "Instalando PHP (NTS x64): $($PhpVersions -join ', ')"

function Get-PhpUrl {
    param([string]$Version)
    # vc15 para 7.x, vs16 para 8.0-8.3. Archivo NTS x64.
    $major = [int]($Version.Split('.')[0])
    $minor = [int]($Version.Split('.')[1])
    $vs    = if ($major -lt 8) { 'vc15' } elseif ($minor -ge 4) { 'vs17' } else { 'vs16' }
    $file  = "php-$Version-nts-Win32-$vs-x64.zip"
    # Las versiones viejas estan en /archives/, las recientes en /releases/.
    return @(
        "https://windows.php.net/downloads/releases/$file",
        "https://windows.php.net/downloads/releases/archives/$file"
    )
}

function Set-PhpIni {
    param([string]$PhpDir)
    $devIni = Join-Path $PhpDir 'php.ini-development'
    $ini    = Join-Path $PhpDir 'php.ini'
    if (-not (Test-Path $devIni)) { return }
    $c = Get-Content $devIni -Raw
    $c = $c -replace ';\s*extension_dir\s*=\s*"ext"', 'extension_dir = "ext"'
    foreach ($ext in 'openssl','curl','mbstring','fileinfo','gd','intl','zip','pdo_mysql','mysqli','sodium','exif','opcache','sqlite3','pdo_sqlite','soap','xsl') {
        $c = $c -replace "(?m)^;\s*extension\s*=\s*$ext\s*$", "extension=$ext"
    }
    Set-Content -Path $ini -Value $c -Encoding ASCII
}

$PrimaryPhp = $null
foreach ($v in ($PhpVersions | Sort-Object { [version]$_ })) {
    $short  = ($v.Split('.')[0..1] -join '.')      # 8.3
    $tag    = "php-$short"                          # php-8.3
    $phpDir = Join-Path $InstallRoot "php\$tag"
    $phpExe = Join-Path $phpDir 'php.exe'

    if (Test-Path $phpExe) { Write-Skip "PHP $short ya instalado en $phpDir"; }
    else {
        $ok = $false
        foreach ($url in (Get-PhpUrl $v)) {
            try {
                $zip = Join-Path $env:TEMP "php-$v.zip"
                Write-Host "  Descargando $url"
                Get-File -Url $url -Out $zip
                New-Item -ItemType Directory -Force -Path $phpDir | Out-Null
                Expand-Archive -Path $zip -DestinationPath $phpDir -Force
                Remove-Item $zip -Force -ErrorAction SilentlyContinue
                Set-PhpIni -PhpDir $phpDir
                Write-Ok "PHP $v instalado en $phpDir"
                $ok = $true
                break
            } catch {
                Write-Warn2 "Fallo $url ($($_.Exception.Message))"
            }
        }
        if (-not $ok) { Write-Err2 "No se pudo instalar PHP $v (revisa la version exacta en windows.php.net)"; continue }
    }

    # Wrapper phpXY.cmd (php74, php81, php82, php83) en bin.
    $alias = "php$($short.Replace('.',''))"
    $cmd   = Join-Path $BinDir "$alias.cmd"
    "@echo off`r`n`"$phpExe`" %*" | Set-Content -Path $cmd -Encoding ASCII
    Write-Ok "Alias '$alias' -> PHP $short"

    $PrimaryPhp = $phpExe   # la mas alta queda como principal por orden ascendente
}

if ($PrimaryPhp) {
    # 'php' generico apunta a la version mas alta.
    "@echo off`r`n`"$PrimaryPhp`" %*" | Set-Content -Path (Join-Path $BinDir 'php.cmd') -Encoding ASCII
    Write-Ok "Comando 'php' -> $PrimaryPhp"
} else {
    Write-Err2 "No hay PHP principal disponible. El resto de tools PHP no se instalaran."
}

# ---------------------------------------------------------------------------
#  2. Composer
# ---------------------------------------------------------------------------
Write-Step "Instalando Composer"
$composerPhar = Join-Path $InstallRoot 'tools\composer.phar'
if ($PrimaryPhp) {
    if (-not (Test-Path $composerPhar)) {
        try {
            Get-File -Url 'https://getcomposer.org/composer-stable.phar' -Out $composerPhar
            Write-Ok "composer.phar descargado"
        } catch { Write-Err2 "No se pudo descargar Composer: $($_.Exception.Message)" }
    } else { Write-Skip "composer.phar ya existe" }

    if (Test-Path $composerPhar) {
        "@echo off`r`n`"$PrimaryPhp`" `"$composerPhar`" %*" | Set-Content -Path (Join-Path $BinDir 'composer.cmd') -Encoding ASCII
        Write-Ok "Comando 'composer' creado"
    }
} else { Write-Skip "Composer omitido (sin PHP)" }

# ---------------------------------------------------------------------------
#  3. Herramientas PHP globales (analisis estatico + estandares PrestaShop)
# ---------------------------------------------------------------------------
Write-Step "Instalando herramientas de analisis PHP (Composer global)"
if ($PrimaryPhp -and (Test-Path $composerPhar)) {
    $composerHome = Join-Path $InstallRoot 'composer-global'
    New-Item -ItemType Directory -Force -Path $composerHome | Out-Null
    $env:COMPOSER_HOME = $composerHome

    $packages = @(
        'squizlabs/php_codesniffer',                  # phpcs / phpcbf
        'phpcompatibility/php-compatibility',         # estandar compatibilidad PHP cross-version
        'dealerdirect/phpcodesniffer-composer-installer', # registra estandares en phpcs
        'prestashop/php-dev-tools',                   # ruleset + header-stamp PrestaShop
        'phpstan/phpstan',                            # analisis estatico
        'phpmd/phpmd',                                # mess detector
        'friendsofphp/php-cs-fixer',                  # formateo / fixer PSR
        'rector/rector',                              # upgrades automaticos / compatibilidad
        'vimeo/psalm'                                 # analisis estatico avanzado
    )
    foreach ($p in $packages) {
        try {
            Write-Host "  composer global require $p"
            & $PrimaryPhp $composerPhar global require $p --no-interaction --quiet 2>&1 | Out-Null
            Write-Ok $p
        } catch { Write-Warn2 "Fallo instalando $p ($($_.Exception.Message))" }
    }

    # Exponer los binarios de composer global en bin.
    $vendorBin = Join-Path $composerHome 'vendor\bin'
    Add-UserPath $vendorBin

    # Registrar el estandar PHPCompatibility en phpcs.
    try {
        $phpcs = Join-Path $vendorBin 'phpcs.bat'
        if (Test-Path $phpcs) {
            & $phpcs --config-set installed_paths (Join-Path $composerHome 'vendor\phpcompatibility\php-compatibility') 2>&1 | Out-Null
            Write-Ok "Estandar PHPCompatibility registrado en phpcs"
        }
    } catch { Write-Warn2 "No se pudo registrar PHPCompatibility: $($_.Exception.Message)" }
} else {
    Write-Skip "Tools PHP omitidas (sin PHP/Composer)"
}

# ---------------------------------------------------------------------------
#  4. Herramientas Node (JS / CSS / formato)
# ---------------------------------------------------------------------------
if (-not $SkipNode -and (Test-Cmd npm)) {
    Write-Step "Instalando herramientas Node globales"
    $npmPkgs = @(
        'eslint',
        'prettier',
        '@prettier/plugin-php',          # formatear PHP con prettier
        'stylelint',
        'stylelint-config-standard',
        'jshint'
    )
    foreach ($p in $npmPkgs) {
        try {
            Write-Host "  npm i -g $p"
            npm install -g $p --silent 2>&1 | Out-Null
            Write-Ok $p
        } catch { Write-Warn2 "Fallo npm $p" }
    }
} else { Write-Skip "Herramientas Node omitidas" }

# ---------------------------------------------------------------------------
#  5. Herramientas Python (linters / formato)
# ---------------------------------------------------------------------------
if (-not $SkipPython -and (Test-Cmd python)) {
    Write-Step "Instalando herramientas Python (pip)"
    try { python -m pip install --upgrade pip --quiet 2>&1 | Out-Null } catch {}
    $pyPkgs = @('ruff', 'black', 'pylint', 'flake8', 'mypy', 'bandit')
    foreach ($p in $pyPkgs) {
        try {
            Write-Host "  pip install $p"
            python -m pip install --upgrade $p --quiet 2>&1 | Out-Null
            Write-Ok $p
        } catch { Write-Warn2 "Fallo pip $p" }
    }
} else { Write-Skip "Herramientas Python omitidas" }

# ---------------------------------------------------------------------------
#  6. Extensiones de VS Code (motor de revision de Antigravity)
# ---------------------------------------------------------------------------
if (-not $SkipVSCode -and (Test-Cmd code)) {
    Write-Step "Instalando extensiones de VS Code"
    $ext = @(
        'bmewburn.vscode-intelephense-client',  # PHP IntelliSense
        'xdebug.php-debug',                      # Debug PHP
        'valeryanm.vscode-phpsab',               # phpcs/phpcbf en el editor
        'SanderRonde.php-intellisense',          # autocompletado PHP
        'neilbrayfield.php-docblocker',          # docblocks
        'smarty-templates.vscode-smarty',        # Smarty .tpl
        'mblode.twig-language-2',                # Twig
        'ms-python.python',                      # Python
        'charliermarsh.ruff',                    # Ruff linter
        'dbaeumer.vscode-eslint',                # ESLint
        'esbenp.prettier-vscode',                # Prettier
        'stylelint.vscode-stylelint',            # Stylelint CSS
        'redhat.vscode-yaml',                    # YAML
        'mtxr.sqltools'                          # SQL
    )
    foreach ($e in $ext) {
        try {
            code --install-extension $e --force 2>&1 | Out-Null
            Write-Ok $e
        } catch { Write-Warn2 "Fallo extension $e" }
    }
} else { Write-Skip "Extensiones VS Code omitidas" }

# ---------------------------------------------------------------------------
#  7. PrestaShop para test de compatibilidad (opcional)
# ---------------------------------------------------------------------------
if ($DownloadPrestaShop) {
    Write-Step "Descargando PrestaShop: $($PsVersions -join ', ')"
    $psRoot = Join-Path $InstallRoot 'prestashop'
    New-Item -ItemType Directory -Force -Path $psRoot | Out-Null
    foreach ($v in $PsVersions) {
        $dest = Join-Path $psRoot $v
        if (Test-Path $dest) { Write-Skip "PrestaShop $v ya descargado"; continue }
        # 1) instalador oficial (release asset)  2) codigo fuente (fallback, p.ej. 9.1.1)
        $sources = @(
            @{ Url = "https://github.com/PrestaShop/PrestaShop/releases/download/$v/prestashop_$v.zip"; Tipo = 'instalador' },
            @{ Url = "https://github.com/PrestaShop/PrestaShop/archive/refs/tags/$v.zip";               Tipo = 'codigo-fuente' }
        )
        $done = $false
        foreach ($s in $sources) {
            try {
                $zip = Join-Path $env:TEMP "ps-$v.zip"
                Write-Host "  Descargando ($($s.Tipo)) $($s.Url)"
                Get-File -Url $s.Url -Out $zip
                New-Item -ItemType Directory -Force -Path $dest | Out-Null
                Expand-Archive -Path $zip -DestinationPath $dest -Force
                Remove-Item $zip -Force -ErrorAction SilentlyContinue
                Write-Ok "PrestaShop $v en $dest ($($s.Tipo))"
                $done = $true
                break
            } catch { Write-Warn2 "Fallo $($s.Tipo) PrestaShop $v ($($_.Exception.Message))" }
        }
        if (-not $done) { Write-Err2 "No se pudo descargar PrestaShop $v por ningun metodo" }
    }
} else {
    Write-Skip "Descarga de PrestaShop omitida (usa -DownloadPrestaShop para activarla)"
}

# ---------------------------------------------------------------------------
#  Resumen
# ---------------------------------------------------------------------------
Write-Step "Instalacion finalizada"
Write-Host @"
  Reinicia la terminal (o VS Code/Antigravity) para refrescar el PATH.

  Comprobaciones rapidas:
    php -v
    php74 -v   php81 -v   php82 -v   php83 -v
    composer --version
    phpcs --version
    phpstan --version

  Revisar un modulo PrestaShop (estandar PrestaShop):
    phpcs --standard="$InstallRoot\composer-global\vendor\prestashop\php-dev-tools\.../ruleset.xml" .\ruta_modulo

  Test de compatibilidad PHP 7.4 -> 8.3:
    phpcs -p .\ruta_modulo --standard=PHPCompatibility --runtime-set testVersion 7.4-8.3

  Analisis estatico:
    phpstan analyse .\ruta_modulo --level 5
"@ -ForegroundColor White
Write-Ok "Listo. Detalle en HERRAMIENTAS.md y log en $script:LogFile"
