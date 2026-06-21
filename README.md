# PrestaShop Dev Toolkit · Windows

Instalador en **PowerShell** que deja un equipo Windows listo para **programar, revisar,
verificar y comprobar** código **PHP / PrestaShop** (y también Python, JavaScript, CSS,
Smarty, Twig, SQL y YAML) — pensado para trabajar con asistentes de IA como **Antigravity**,
Cursor o Claude Code.

Un solo script instala el stack completo: varias versiones de PHP en paralelo, Composer,
analizadores estáticos, estándares oficiales de PrestaShop, linters de frontend y Python,
extensiones de VS Code y, opcionalmente, copias de PrestaShop para pruebas de compatibilidad.

---

## ✨ Qué instala

| Categoría | Herramientas |
|---|---|
| **PHP (multi-versión)** | PHP 7.4, 8.1, 8.2, 8.3 y 8.4 (NTS x64), con alias `php74`…`php84` |
| **Dependencias** | Composer |
| **Análisis PHP** | PHP_CodeSniffer, PHPCompatibility, PHPStan, Psalm, PHPMD, PHP-CS-Fixer, Rector |
| **Estándares PrestaShop** | `prestashop/php-dev-tools` (ruleset + `header-stamp`) |
| **Frontend** | ESLint, JSHint, Prettier (+plugin PHP), Stylelint |
| **Python** | Ruff, Black, Pylint, Flake8, mypy, Bandit |
| **VS Code** | Intelephense, PHP Debug, phpsab, Smarty, Twig, ESLint, Prettier, Ruff, YAML, SQLTools… |
| **Skills PrestaShop** | 29 skills de [`ecomyseo/prestashop_skills`](https://github.com/ecomyseo/prestashop_skills) → Claude (`~/.claude/skills`) y Antigravity (`~/.gemini/antigravity/global_skills`) |
| **PrestaShop (opcional)** | 1.6.1.24, 1.7.8.11, 8.1.7, 8.2.7, 9.1.1 |

> Lista detallada con la función de cada herramienta en **[HERRAMIENTAS.md](HERRAMIENTAS.md)**.

---

## 🚀 Uso

```powershell
# Instalación base (PHP + Composer + analizadores + linters + extensiones)
pwsh -ExecutionPolicy Bypass -File .\instalar-herramientas.ps1

# Incluyendo descarga de versiones de PrestaShop para test de compatibilidad
pwsh -ExecutionPolicy Bypass -File .\instalar-herramientas.ps1 -DownloadPrestaShop
```

El script es **idempotente**: comprueba antes de instalar y puede re-ejecutarse sin duplicar nada.
**No reinicia el equipo.** Al terminar, abre una terminal nueva para refrescar el `PATH`.

### Parámetros

| Parámetro | Por defecto | Descripción |
|---|---|---|
| `-InstallRoot` | `C:\dev-tools` | Carpeta raíz de instalación |
| `-PhpVersions` | `7.4.33, 8.1.31, 8.2.27, 8.3.15, 8.4.2` | Versiones de PHP a instalar |
| `-DownloadPrestaShop` | *(off)* | Descarga copias de PrestaShop |
| `-PsVersions` | `1.6.1.24, 1.7.8.11, 8.1.7, 8.2.7, 9.1.1` | Versiones de PrestaShop |
| `-SkipVSCode` | *(off)* | No instala extensiones de VS Code |
| `-SkipPython` | *(off)* | No instala herramientas de Python |
| `-SkipNode` | *(off)* | No instala herramientas de Node |
| `-SkipSkills` | *(off)* | No instala los skills de PrestaShop |
| `-SkillsRepo` | `ecomyseo/prestashop_skills` | Repo Git de los skills |

---

## ✅ Comprobar la instalación

```powershell
php -v
php74 -v ; php81 -v ; php82 -v ; php83 -v ; php84 -v
composer --version
phpcs --version
phpstan --version
```

---

## 🔍 Revisar código (ejemplos)

```powershell
# Estilo + estándar PrestaShop
phpcs --standard=PrestaShop .\ruta_modulo
phpcbf --standard=PrestaShop .\ruta_modulo      # autocorrección

# Compatibilidad de PHP 7.4 -> 8.4
phpcs -p .\ruta_modulo --standard=PHPCompatibility --runtime-set testVersion 7.4-8.4

# Análisis estático
phpstan analyse .\ruta_modulo --level 5

# Python
ruff check .\ruta_py
bandit -r .\ruta_py
```

---

## 📁 Estructura instalada

```
C:\dev-tools\
├─ bin\                  # php, php74…php84, composer, phpcs… (en PATH)
├─ php\php-7.4 … php-8.4 # binarios de cada versión de PHP
├─ tools\composer.phar
├─ composer-global\      # herramientas PHP globales
└─ prestashop\<version>\ # copias de PrestaShop (con -DownloadPrestaShop)
```

---

## 📝 Notas

- Las URLs de PHP en `windows.php.net` rotan al salir un nuevo patch; el script prueba
  `/releases/` y luego `/archives/`. Si una versión exacta falla, ajusta `-PhpVersions`.
- PrestaShop **9.1.1** solo publica el **código fuente** en GitHub (no el instalador
  empaquetado); el script lo descarga igualmente, válido para revisión y compatibilidad.

---

## 📄 Licencia

MIT.
