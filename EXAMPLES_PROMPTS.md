# 🛠️ Antigravity — Prompts y herramientas para revisar código PrestaShop

Este documento es una **chuleta de prompts** y comandos para que **Antigravity** (o Claude Code) revise, audite, refactorice y modernice módulos PrestaShop usando las herramientas instaladas con `instalar-herramientas.ps1`.

---

## 📦 Qué tienes instalado

Tras ejecutar el instalador, dispones de:

| Tipo | Herramientas |
|---|---|
| **PHP multiversión** | PHP 7.4, 8.1, 8.2, 8.3, 8.4 (NTS x64) |
| **Aliases CLI** | `php74`, `php81`, `php82`, `php83`, `php84`, `php` (la más alta) |
| **Composer** | 2.10+ |
| **Análisis estático** | `phpstan`, `psalm`, `phpmd` |
| **Estilo / Estándares** | `phpcs`, `phpcbf`, `php-cs-fixer`, **PrestaShop ruleset** (`prestashop/php-dev-tools`) |
| **Compatibilidad cross-PHP** | `phpcs --standard=PHPCompatibility` |
| **Refactor automático** | `rector` |
| **Métricas / complejidad** | `pdepend` |
| **PrestaShops para test** | 1.6.1.24 · 1.7.8.11 · 8.1.7 · 8.2.7 · 9.1.1 en `C:\dev-tools\prestashop\` |
| **Skills Antigravity / Claude** | 29 skills PrestaShop en `~/.claude/skills/` y `~/.gemini/antigravity/global_skills/` |

> ✅ **Sin reiniciar el equipo**. Abre **una terminal nueva** (o reinicia Antigravity / VS Code) tras la instalación para que `php`, `phpcs`, `phpstan`, etc. estén disponibles en `PATH`.

---

## 🚀 Cómo usarlo en Antigravity

Antigravity puede ejecutar comandos PowerShell y leer su salida. Basta con que le pidas tareas concretas y el agente lanzará la herramienta adecuada. **Tres formas de pedirle algo:**

1. **Pregunta directa con ruta** — `"Revisa el módulo C:\... con phpcs estándar PrestaShop"`
2. **Pregunta abstracta** — `"¿Mi módulo X es compatible con PHP 8.3?"` (el agente elegirá la tool)
3. **Pegando un fichero / función** — `"Revisa este código y dime si tiene SQL injection"` (sin tool, solo razonamiento)

---

## 🎯 Ejemplos de prompts (copiar y pegar)

### 1️⃣ Auditoría rápida de un módulo

```text
Revisa el módulo en Z:\modulos ps mios\modulo_xxx con phpcs usando el estándar PrestaShop.
Pásame las violaciones agrupadas por severidad. Si hay menos de 30, dime cuáles arreglar con phpcbf.
```

```text
Lanza phpstan level 5 contra Z:\modulos ps mios\modulo_xxx y resume los 10 errores más críticos.
Para cada uno: fichero:línea, descripción simple, propuesta de fix.
```

```text
Quiero un informe COMPLETO del módulo en Z:\ruta\modulo:
1. phpcs con estándar PrestaShop (violaciones de estilo)
2. phpstan level 6 (bugs estáticos)
3. PHPCompatibility 7.4-8.4 (problemas cross-version)
4. Resumen ejecutivo con TODO por hacer ordenado por gravedad.
```

### 2️⃣ Comprobar compatibilidad con PrestaShop 9

```text
El cliente quiere subir su módulo a PrestaShop 9 (que necesita PHP 8.1+).
Revisa Z:\ruta\modulo con PHPCompatibility para target 8.1-8.4 y lista los breaking changes.
También revisa si usa APIs deprecated de PS 1.7 que ya no existen en PS 9.
```

```text
Compara el módulo Z:\ruta\modulo contra el código de PS 9.1.1 en C:\dev-tools\prestashop\9.1.1.
Busca:
- Hooks renombrados o eliminados
- Clases del Core movidas a Symfony
- Smarty/Twig no migrado
- Uso de `Tools::redirect` legacy en lugar de Symfony Response.
```

### 3️⃣ Refactor automático con Rector

```text
Aplica Rector sobre Z:\ruta\modulo para subirlo de PHP 7.4 a 8.2.
Usa el preset `php82` y muestra el diff ANTES de modificar nada.
Si los cambios son seguros, aplícalos. Si tocan lógica, pide confirmación.
```

```text
Mi módulo todavía usa array() en lugar de [], y métodos sin tipos.
Aplica php-cs-fixer con PSR-12 + short_array_syntax + return_type_declaration
y déjalo limpio.
```

### 4️⃣ Detectar vulnerabilidades

```text
Audita la seguridad del módulo Z:\ruta\modulo. Busca específicamente:
- SQL Injection (concatenaciones en `Db::getInstance()->executeS`, `getValue`, `getRow`)
- XSS (output sin `htmlspecialchars` o sin `|escape:'html':'UTF-8'` en .tpl)
- Path traversal (`file_get_contents`, `include`, `require` con input de usuario)
- Bypass de autenticación (controllers admin sin checkToken)
- Credenciales hardcoded.

Para cada hallazgo: severidad, fichero, línea, snippet y propuesta de fix.
```

```text
Aplica phpmd con regla `Design,UnusedCode,CleanCode` y dame los TOP 5 problemas.
```

### 5️⃣ Test contra varias versiones de PrestaShop

```text
Tengo el módulo Z:\ruta\modulo (versión actual). Quiero saber si funciona en:
- PS 1.7.8.11 (PHP 7.4) → ejecuta phpcs con --runtime-set testVersion 7.4
- PS 8.1.7 (PHP 8.1) → phpcs --runtime-set testVersion 8.1
- PS 8.2.7 (PHP 8.2) → phpcs --runtime-set testVersion 8.2
- PS 9.1.1 (PHP 8.4) → phpcs --runtime-set testVersion 8.4

Y para cada incompatibilidad, dime QUÉ FICHERO y CÓMO arreglarla.
```

### 6️⃣ Análisis con un PHP específico

```text
Mi módulo da error en PrestaShop 1.7 con PHP 7.4. Lanza php74 con el script
de instalación del módulo (`install` hook) y dime el stack trace exacto.
```

```text
Compara el output de:
   php74 -l módulo/clases/MiClase.php
   php84 -l módulo/clases/MiClase.php
y dime si hay sintaxis incompatible.
```

### 7️⃣ Crear / extender funcionalidades PrestaShop

> Para estas tareas Antigravity invoca automáticamente las **skills** instaladas.

```text
Quiero añadir un grid administrativo nuevo en PS 9 para gestionar reservas.
Crea el módulo desde cero con:
- Symfony Grid factory
- Controller admin con CRUD
- Doctrine entity + repository
- Form type con multistore
- Plantilla Twig

Usa la skill prestashop-admin-grid.
```

```text
Necesito añadir una columna personalizada al listado de pedidos en BO PrestaShop 8.
Usa la skill prestashop-admin-columns.
```

```text
Mi módulo necesita exponer endpoints a un agente IA externo.
Implementa MCP Server siguiendo la skill prestashop_psmcpserver.
```

```text
Implementa un override SEGURO de la clase Cart en PS 9 sin usar installOverrides().
Sigue la skill prestashop-safe-overrides.
```

### 8️⃣ Auditoría de hooks instalados

```text
Lista todos los hooks que tiene registrados el módulo Z:\ruta\modulo (busca en
install()/uninstall() y `registerHook`). Después dime cuáles están REALMENTE
implementados como método `hookXxxx()` en la clase principal.

Marca como "ZOMBIE" los hooks registrados pero no implementados.
```

### 9️⃣ Documentación automática

```text
Lee todo el código de Z:\ruta\modulo y genera 3 documentos:
1. DOC_TECNICO.md — arquitectura, clases, hooks, BD
2. DOC_DESARROLLADOR.md — cómo extender, dónde tocar para añadir X
3. GUIA_USUARIO.md — qué hace el módulo desde el back-office, paso a paso

Sin inventarte nada. Si algo no se entiende, márcalo con [REVISAR].
```

### 🔟 Generar tests

```text
Crea tests phpunit para la clase Z:\ruta\modulo\classes\Helper.php
cubriendo:
- Métodos públicos
- Casos límite (null, array vacío, string vacío)
- Excepciones esperadas

Output: en un fichero tests/HelperTest.php
```

---

## 🧪 Comandos directos (sin Antigravity)

Si prefieres ejecutar las herramientas TÚ:

```powershell
# Estilo PrestaShop
phpcs --standard="C:\dev-tools\composer-global\vendor\prestashop\php-dev-tools\PrestaShop\ruleset.xml" .\modulo

# Auto-fix de lo arreglable
phpcbf --standard="C:\dev-tools\composer-global\vendor\prestashop\php-dev-tools\PrestaShop\ruleset.xml" .\modulo

# Compatibilidad cross-PHP (target PS 9)
phpcs -p .\modulo --standard=PHPCompatibility --runtime-set testVersion 8.1-8.4

# Análisis estático
phpstan analyse .\modulo --level 5
psalm --root .\modulo
phpmd .\modulo text cleancode,codesize,design,naming,unusedcode

# Refactor automático (upgrade PHP)
rector process .\modulo --dry-run         # preview
rector process .\modulo                    # aplicar

# Formateo PSR-12
php-cs-fixer fix .\modulo --rules=@PSR12,short_array_syntax,return_type_declaration

# Métricas de complejidad
pdepend --summary-xml=metrics.xml .\modulo

# Validar versión PHP exacta
php74 -l .\modulo\modulo.php
php84 -l .\modulo\modulo.php
```

---

## 🧠 Skills PrestaShop disponibles para Antigravity

Al pedir tareas PrestaShop, Antigravity invoca automáticamente la skill correcta. Estas son las disponibles:

| Skill | Para qué sirve |
|---|---|
| `prestashop-admin-grid` | Crear listados modernos del back-office (Symfony Grid) en PS 8/9 |
| `prestashop-admin-columns` | Añadir columnas a listados existentes |
| `prestashop-controller-tabs` | Crear AdminControllers + tabs en PS 8/9 |
| `prestashop-doctrine-entities` | Persistencia moderna con Doctrine ORM |
| `prestashop-symfony-form` | Formularios de configuración Symfony |
| `prestashop-multistore-form` | Forms multi-tienda |
| `prestashop-product-form` | Modificar el form del producto V2 |
| `prestashop-front-product-tabs` | Pestañas extras en ficha producto FO |
| `prestashop_product_v2_hybrid_tabs` | Tabs hybrid Symfony + Legacy en BO producto |
| `prestashop-order-hooks` | Extender Admin Order View V2 |
| `prestashop-form-data-providers` | Modificar datos de formularios core con Data Providers |
| `prestashop-mail-themes` | Crear/extender temas de email |
| `prestashop-translations` | Sistema de traducciones moderno |
| `prestashop-template-overrides` | Override seguro de templates BO/FO |
| `prestashop-safe-overrides` | Override de clases sin installOverrides() |
| `prestashop-module-routes` | Rutas custom + Pretty URLs |
| `prestashop-api-module` | APIs (WebService legacy + API Platform en PS 9) |
| `prestashop-webservice-extend` | Añadir recursos al WebService XML legacy |
| `prestashop-console-commands` | Comandos CLI Symfony Console |
| `prestashop-js-routing` | Generar admin links dinámicos en JS |
| `prestashop_js_events` | Rastrear/interceptar eventos JS del Core |
| `prestashop_login` | Auth/login empleados y clientes desde código |
| `prestashop_psmcpserver` | Exponer lógica del módulo a agentes IA vía MCP |
| `prestashop_openrouter_integration` | Integrar OpenRouter en PrestaShop |
| `prestashop_omnimind_openrouter_adapter` | OpenRouter Adapter for OmniMind |
| `prestashop-intel-mcp` | Servidor MCP local con caché JSON de módulos |
| `prestashop-validator` | Versión local del PrestaShop Validator oficial |

Para invocar una skill, **menciona qué quieres hacer** — Antigravity la cargará sola. O directamente:

```text
Usa la skill prestashop-admin-grid para crear un listado de pedidos personalizado.
```

---

## ⚙️ Tips para usar Antigravity con PrestaShop

### Pasarle el contexto necesario

Antigravity es **mucho más preciso** si le das:
- ✅ **Ruta absoluta** del módulo (`Z:\ruta\completa\modulo`)
- ✅ **Versión de PrestaShop** target (1.7 / 8.1 / 8.2 / 9.x)
- ✅ **Versión de PHP** mínima y máxima soportada
- ✅ **Qué busca el cliente** (compatibilidad, refactor, nuevo feature, bug, seguridad)

### Plantilla de prompt completo

```text
PROYECTO: <nombre>
RUTA: Z:\modulos\<modulo>
PRESTASHOP TARGET: 8.1.7 (también compatible con 1.7.8.11)
PHP TARGET: 7.4 a 8.2
TAREA: <una frase clara>

CONTEXTO ADICIONAL:
- <lo que el cliente ya intentó>
- <restricciones conocidas>
- <cosas que NO se pueden tocar>

ENTREGABLES:
- <lista clara de qué quieres recibir>
```

### Lo que NO le pidas

- ❌ "Mira un módulo" — sin ruta no puede leer ficheros
- ❌ "¿Está bien?" — sin criterio no sabe qué revisar
- ❌ "Hazlo mejor" — sin objetivo no sabe qué mejorar
- ❌ Tareas multi-módulo sin prioridad — divide en pasos

### Lo que SÍ funciona muy bien

- ✅ "Audita el módulo X con phpstan level 6 y lista los TOP 5 errores"
- ✅ "Convierte el módulo X de PS 1.7 a PS 8 usando la skill prestashop-controller-tabs"
- ✅ "Genera tests phpunit para la clase X cubriendo casos límite"
- ✅ "Compara el código de mi módulo con el de PS 9.1.1 en C:\dev-tools\prestashop\9.1.1"

---

## 🗂️ Estructura de archivos relevante

```
C:\dev-tools\
├── bin\                          → wrappers php74/php81/php82/php83/php84/composer
├── php\
│   ├── php-7.4\php.exe           → para PS 1.6/1.7
│   ├── php-8.1\php.exe           → para PS 8.0
│   ├── php-8.2\php.exe           → para PS 8.1
│   ├── php-8.3\php.exe           → para PS 8.2
│   └── php-8.4\php.exe           → para PS 9.x (principal)
├── tools\
│   └── composer.phar
├── composer-global\
│   └── vendor\bin\               → phpcs, phpstan, psalm, rector, php-cs-fixer, phpmd, pdepend
└── prestashop\
    ├── 1.6.1.24\                 → para test compat legacy
    ├── 1.7.8.11\
    ├── 8.1.7\
    ├── 8.2.7\
    └── 9.1.1\                    → última estable

~\.claude\skills\                 → 29 skills PrestaShop
~\.gemini\antigravity\global_skills\  → 31 skills PrestaShop
```

---

## 🚨 Troubleshooting rápido

| Síntoma | Causa probable | Fix |
|---|---|---|
| `php` no encontrado | Terminal vieja con PATH antiguo | Abre una terminal NUEVA |
| `phpstan: Composer detected issues` | platform_check con PHP < 8.4 | Ya neutralizado en la instalación |
| `phpcs: Standard not found` | PrestaShop ruleset no registrado | `phpcs -i` para ver estándares |
| `Module mysqli is already loaded` | `php.ini` con duplicado | Ya arreglado por el instalador |
| Permisos en `C:\dev-tools` | Carpeta de admin | Ejecuta cmd como admin la primera vez |

Para verificar todo en una terminal nueva:

```powershell
php -v                # 8.4.2
php74 -v              # 7.4.33
composer --version    # 2.10.1+
phpcs --version
phpstan --version
psalm --version
phpcs -i              # debe listar "PEAR, PHPCompatibility, PSR1, PSR2, PSR12, Squiz, Zend"
```

---

## 📝 Licencia / Autor

```
@author    Ecom Experts <ecomyseo@gmail.com>
@copyright 2026 Ecom Experts
@license   AFL-3.0
```

---

> 💡 **Sugerencia final:** ten este `.md` abierto al lado de Antigravity y copia los prompts según necesites. La parte difícil es saber **qué pedir**; la herramienta y la skill correctas las elige el agente solo si tu petición es clara.
