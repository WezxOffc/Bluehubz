#!/bin/bash
# BLUEHUBZ.PROTECT — Uninstaller

set -e
PANEL="/var/www/pterodactyl"

echo "🧹 BLUEHUBZ.PROTECT Uninstaller"
[ "$EUID" -ne 0 ] && echo "❌ Harus root" && exit 1
[ ! -d "$PANEL" ] && echo "❌ Panel gak ketemu" && exit 1
cd "$PANEL"

# 1. Hapus banner include + anchor
echo "[1/6] Remove banner includes..."
find resources/views -name "*.blade.php" -type f | while read f; do
  python3 - "$f" << 'PYEOF'
import sys, re
p = sys.argv[1]
try:
    h = open(p).read()
    orig = h
    h = re.sub(r"@include\('bluehubz::banner'[^\)]*\)\s*", "", h)
    h = re.sub(r"\{\{--\s*BLUEHUBZ_ANCHOR_\w+\s*--\}\}\s*", "", h)
    if h != orig:
        open(p, 'w').write(h)
except: pass
PYEOF
done

# 2. Hapus sidebar Protect Manager
python3 - resources/views/layouts/admin.blade.php << 'PYEOF' 2>/dev/null || true
import sys, re
p = sys.argv[1]
try:
    h = open(p).read()
    h = re.sub(r'<li[^>]*>\s*<a[^>]*admin/protect-manager[^>]*>.*?</li>', '', h, flags=re.DOTALL)
    open(p, 'w').write(h)
except: pass
PYEOF

# 3. Hapus files
rm -rf resources/views/bluehubz
rm -rf resources/views/admin/protect
rm -rf app/Bluehubz
rm -f app/Http/Controllers/Admin/ProtectManagerController.php
echo "[2/6] ✅ Files removed"

# 4. Unregister middleware
KERNEL="app/Http/Kernel.php"
[ -f "$KERNEL" ] && sed -i "/'bluehubz' =>/d" "$KERNEL"
sed -i "s/Route::middleware(\['auth', 'admin', 'bluehubz'\])/Route::middleware(['auth', 'admin'])/g" routes/admin.php 2>/dev/null || true
echo "[3/6] ✅ Middleware unregistered"

# 5. Hapus route
python3 - routes/admin.php << 'PYEOF' 2>/dev/null || true
import sys, re
p = sys.argv[1]
h = open(p).read()
h = re.sub(r"Route::(get|post)\('/protect-manager[^;]*;\s*", "", h)
open(p, 'w').write(h)
PYEOF
echo "[4/6] ✅ Routes removed"

# 6. Unregister observer
python3 - app/Providers/AppServiceProvider.php << 'PYEOF' 2>/dev/null || true
import sys, re
p = sys.argv[1]
h = open(p).read()
h = re.sub(r"\s*// BLUEHUBZ\.PROTECT Observer.*?abort\(403[^;]*;\s*\}\);\s*", "\n", h, flags=re.DOTALL)
open(p, 'w').write(h)
PYEOF
echo "[5/6] ✅ Observer removed"

# 7. Drop table
php artisan tinker --execute="\Schema::dropIfExists('protect_settings');" 2>/dev/null || true
rm -f database/migrations/*create_protect_settings.php
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan cache:clear
echo "[6/6] ✅ Cache cleared"

echo ""
echo "✅ Uninstall selesai. Panel kembali normal."
