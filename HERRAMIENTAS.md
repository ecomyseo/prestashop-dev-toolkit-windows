# Herramientas de desarrollo y revisión de código (Windows)

Stack necesario para revisar, programar y que **Antigravity** verifique y compruebe
todo el código del repositorio `C:\z\modulos ps mios finalizados y ok`.

El repositorio es mayoritariamente **PHP / PrestaShop**, con frontend (JS/CSS),
plantillas **Smarty (.tpl)** y **Twig**, **Python** (Odoo + skills IA), SQL, XML y YAML.

> Instalación automática: ejecuta `instalar-herramientas.ps1`.
> Para incluir versiones de PrestaShop: `instalar-herramientas.ps1 -DownloadPrestaShop`.

---

## Resumen de tu equipo (detectado)

| Herramienta | Estado | Ruta |
|---|---|---|
| Python 3.14 | ✅ Instalado | `…\Programs\Python\Python314\python.exe` |
| Node.js (nvm4w) | ✅ Instalado | `C:\nvm4w\nodejs\node.exe` |
| npm | ✅ Instalado | `C:\nvm4w\nodejs\npm.ps1` |
| Git | ✅ Instalado | `C:\Program Files\Git\cmd\git.exe` |
| winget | ✅ Instalado | `…\WindowsApps\winget.exe` |
| VS Code | ✅ Instalado | `…\Microsoft VS Code\bin\code.cmd` |
| **PHP** | ❌ **Falta** | lo instala el script |
| **Composer** | ❌ **Falta** | lo instala el script |

---

## 1. Núcleo PHP / PrestaShop (lo principal)

| Herramienta | Para qué sirve | Comando |
|---|---|---|
| **PHP 7.4** | Compatibilidad PrestaShop 1.6 / 1.7.x | `php74 -v` |
| **PHP 8.1** | PrestaShop 8.0 / 8.1 | `php81 -v` |
| **PHP 8.2** | PrestaShop 8.2 | `php82 -v` |
| **PHP 8.3** | PrestaShop 8.x / 9.x | `php83 -v` |
| **PHP 8.4** | PrestaShop 9.x / principal | `php84 -v` / `php -v` |
| **Composer** | Gestor de dependencias PHP | `composer` |

> Se instalan **5 versiones de PHP en paralelo** para poder probar el mismo módulo
> contra cada versión (regla del proyecto: compatibilidad PHP 7.4 y 8.x).

---

## 2. Análisis estático y estándares PHP

| Herramienta | Para qué sirve | Comando |
|---|---|---|
| **PHP_CodeSniffer** | Detecta y corrige violaciones de estilo | `phpcs` / `phpcbf` |
| **PHPCompatibility** | Comprueba compatibilidad entre versiones PHP | `phpcs --standard=PHPCompatibility --runtime-set testVersion 7.4-8.3` |
| **prestashop/php-dev-tools** | Ruleset oficial PrestaShop + `header-stamp` (cabeceras de licencia) | `phpcs --standard=PrestaShop` |
| **PHPStan** | Análisis estático / detección de bugs por niveles | `phpstan analyse -l 5` |
| **Psalm** | Análisis estático avanzado (tipos, dead code) | `psalm` |
| **PHPMD** | Mess detector (complejidad, código no usado) | `phpmd` |
| **PHP-CS-Fixer** | Formateo automático PSR | `php-cs-fixer fix` |
| **Rector** | Migraciones automáticas / upgrades de versión PHP | `rector process` |

---

## 3. Frontend (JS / CSS / plantillas)

| Herramienta | Para qué sirve | Comando |
|---|---|---|
| **ESLint** | Linter JavaScript | `eslint` |
| **JSHint** | Linter JS ligero | `jshint` |
| **Prettier** | Formateo JS/CSS/JSON/MD | `prettier` |
| **@prettier/plugin-php** | Formatear PHP con Prettier | (plugin) |
| **Stylelint** | Linter CSS | `stylelint` |

> Smarty (`.tpl`) y Twig se revisan con resaltado/validación en VS Code
> (extensiones del punto 6). `twigcs` se puede añadir vía Composer si hace falta.

---

## 4. Python (Odoo + scripts IA)

| Herramienta | Para qué sirve | Comando |
|---|---|---|
| **Ruff** | Linter + formateo ultrarrápido | `ruff check` |
| **Black** | Formateador estándar | `black` |
| **Pylint** | Análisis profundo | `pylint` |
| **Flake8** | Linter clásico | `flake8` |
| **mypy** | Comprobación de tipos | `mypy` |
| **Bandit** | Seguridad en código Python | `bandit -r` |

---

## 5. Control de versiones y utilidades

| Herramienta | Para qué sirve |
|---|---|
| **Git** | Control de versiones (ya instalado) |
| **winget** | Gestor de paquetes Windows (ya instalado) |

---

## 6. Extensiones de VS Code / Antigravity

| Extensión | Lenguaje / función |
|---|---|
| `bmewburn.vscode-intelephense-client` | PHP IntelliSense |
| `xdebug.php-debug` | Depuración PHP (Xdebug) |
| `valeryanm.vscode-phpsab` | phpcs/phpcbf integrado en el editor |
| `SanderRonde.php-intellisense` | Autocompletado PHP |
| `neilbrayfield.php-docblocker` | Generación de DocBlocks |
| `smarty-templates.vscode-smarty` | Plantillas Smarty `.tpl` |
| `mblode.twig-language-2` | Plantillas Twig |
| `ms-python.python` + `charliermarsh.ruff` | Python + Ruff |
| `dbaeumer.vscode-eslint` | ESLint |
| `esbenp.prettier-vscode` | Prettier |
| `stylelint.vscode-stylelint` | Stylelint CSS |
| `redhat.vscode-yaml` | YAML |
| `mtxr.sqltools` | SQL |

---

## 7. PrestaShop para test de compatibilidad (opcional)

Con `-DownloadPrestaShop` se descargan en `C:\dev-tools\prestashop\<version>\`:

| Versión | PHP recomendado | Fuente |
|---|---|---|
| 1.6.1.24 | PHP 5.6 – 7.1 | instalador |
| 1.7.8.11 | PHP 7.1 – 7.4 | instalador |
| 8.1.7 | PHP 7.2.5 – 8.1 | instalador |
| 8.2.7 | PHP 8.1 – 8.2 | instalador |
| 9.1.1 | PHP 8.1 – 8.4 | código fuente (GitHub)* |

\* La release 9.1.1 en GitHub solo publica el código fuente (no el instalador empaquetado);
el script lo descarga igualmente como `archive/refs/tags/9.1.1.zip`, válido para revisión
de código y comprobación de compatibilidad contra el core de PrestaShop 9.

Sirven para levantar una instalación real y comprobar que el módulo instala/funciona
en cada versión antes de entregarlo.

---

## Rutas de instalación

| Elemento | Ruta |
|---|---|
| Raíz | `C:\dev-tools` |
| Binarios (en PATH) | `C:\dev-tools\bin` |
| Versiones PHP | `C:\dev-tools\php\php-7.4`, `php-8.1`, `php-8.2`, `php-8.3` |
| Composer | `C:\dev-tools\tools\composer.phar` |
| Tools globales PHP | `C:\dev-tools\composer-global\vendor\bin` |
| PrestaShop | `C:\dev-tools\prestashop\` |
| Log | `instalacion.log` (junto al script) |

---

## Comandos rápidos de revisión

```powershell
# Estilo + estándar PrestaShop
phpcs --standard=PrestaShop .\ruta_modulo

# Corregir automáticamente lo corregible
phpcbf --standard=PrestaShop .\ruta_modulo

# Compatibilidad PHP 7.4 -> 8.3
phpcs -p .\ruta_modulo --standard=PHPCompatibility --runtime-set testVersion 7.4-8.3

# Análisis estático
phpstan analyse .\ruta_modulo --level 5

# Cabeceras de licencia PrestaShop (Ecom Experts / AFL-3.0)
header-stamp --target=.\ruta_modulo --license=.\assets\afl.txt

# Python
ruff check .\ruta_py
bandit -r .\ruta_py
```
