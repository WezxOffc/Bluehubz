#!/bin/bash
# ═══════════════════════════════════════════════════════
#   BLUEHUBZ.PROTECT v1.0.0 — Full Installer
#   Guard: Hybrid | Mode: Non-Invasive | Auto-Connect
# ═══════════════════════════════════════════════════════

set -e
PANEL="/var/www/pterodactyl"
VERSION="1.0.0"

echo "╔══════════════════════════════════════════════╗"
echo "║   🔒 BLUEHUBZ.PROTECT v$VERSION              ║"
echo "║   Guard : Hybrid                             ║"
echo "║   Mode  : Non-Invasive                       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

[ "$EUID" -ne 0 ] && echo "❌ Harus root: sudo ./install.sh" && exit 1
[ ! -d "$PANEL" ] && echo "❌ Panel gak ketemu di $PANEL" && exit 1

cd "$PANEL"

# ─── 0. Backup ───
BACKUP="$PANEL/.bluehubz-backup-$(date +%s)"
mkdir -p "$BACKUP"
cp -r resources/views "$BACKUP/views" 2>/dev/null || true
cp -r app "$BACKUP/app" 2>/dev/null || true
cp routes/admin.php "$BACKUP/admin.php" 2>/dev/null || true
echo "✅ Backup: $BACKUP"

# ─── 1. Copy banner partial ───
mkdir -p resources/views/bluehubz
cp banner.blade.php resources/views/bluehubz/banner.blade.php
echo "✅ Banner partial installed"

# ─── 2. Copy guard ───
mkdir -p app/Bluehubz
cp guard.php app/Bluehubz/Guard.php
echo "✅ Guard installed"

# ─── 3. Copy ProtectManager Controller + Blade ───
mkdir -p app/Http/Controllers/Admin
cat > app/Http/Controllers/Admin/ProtectManagerController.php << 'PHPEOF'
<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Bluehubz\Guard;
use Illuminate\Http\Request;

class ProtectManagerController extends Controller
{
    public function index()
    {
        $features = [
            'protect1'   => ['label' => 'Anti Delete Server',                'desc' => 'Mencegah penghapusan server oleh admin selain ID 1'],
            'protect2'   => ['label' => 'Anti Hapus/Ubah User',              'desc' => 'Melindungi data user dari penghapusan dan modifikasi'],
            'protect3'   => ['label' => 'Anti Akses Location',               'desc' => 'Memblokir akses menu Location'],
            'protect4'   => ['label' => 'Anti Akses Nodes',                  'desc' => 'Memblokir akses menu Nodes'],
            'protect5a'  => ['label' => 'Sembunyikan & Block Menu Nests',    'desc' => 'Sembunyikan menu Nests dari sidebar'],
            'protect5b'  => ['label' => 'Branding Footer Panel',             'desc' => 'Pasang footer branding'],
            'protect5c'  => ['label' => 'Welcome Banner Client',             'desc' => 'Tampilkan welcome banner di dashboard client'],
            'protect6'   => ['label' => 'Anti Akses Settings',               'desc' => 'Memblokir akses Settings panel'],
            'protect7'   => ['label' => 'Anti Akses Server File',            'desc' => 'Proteksi file controller server'],
            'protect8'   => ['label' => 'Anti Akses Server Controller',      'desc' => 'Proteksi server controller'],
            'protect9'   => ['label' => 'Anti Modifikasi Server',            'desc' => 'Mencegah modifikasi detail server'],
            'protect10'  => ['label' => 'Anti Tautan Server (v1)',           'desc' => 'Mencegah perubahan tautan server'],
            'protect11'  => ['label' => 'Anti Tautan Server (v2)',           'desc' => 'Versi lanjutan proteksi tautan'],
            'protect12a' => ['label' => 'Proteksi Nodes (Sidebar + Akses)',  'desc' => 'Sembunyikan menu Nodes + blokir akses'],
            'protect12b' => ['label' => 'Proteksi Client Account API',       'desc' => 'Blokir ubah password/email admin ID 1'],
            'protect12c' => ['label' => 'Proteksi Application API User',     'desc' => 'Blokir akses/ubah data admin ID 1'],
            'protect12d' => ['label' => 'Proteksi API Key Admin',            'desc' => 'Blokir buat/lihat API key User ID 1'],
            'protect12e' => ['label' => 'Proteksi Locations (Sidebar)',      'desc' => 'Sembunyikan menu Locations'],
            'protect13a' => ['label' => 'Sembunyikan Menu Application API',  'desc' => 'Sembunyikan menu Application API'],
            'protect13b' => ['label' => 'Block Application API Controller',  'desc' => 'Blokir akses controller Application API'],
            'protect13c' => ['label' => 'Proteksi API Users root_admin',     'desc' => 'Cegah non-ID 1 ubah root_admin'],
            'protect14'  => ['label' => 'Anti Create/Delete Admin Panel',    'desc' => 'Selain ID 1 gabisa create/delete admin'],
        ];

        foreach ($features as $key => &$feat) {
            $feat['enabled'] = Guard::isEnabled($key);
        }

        $total  = count($features);
        $active = collect($features)->where('enabled', true)->count();
        $config = [
            'brand'     => Guard::get('brand', 'By WezxOffc'),
            'deskripsi' => Guard::get('deskripsi', 'Chat @wezxoffc jika membutuhkan bantuan & laporkan masalah'),
            'thanks'    => Guard::get('thanks', 'Thanks for using protect bluehubz'),
            'bot'       => Guard::get('bot', '@wezxpterodactyloffcbot'),
        ];

        return view('admin.protect.index', compact('features','total','active','config'));
    }

    public function apply(Request $request)
    {
        $selected = $request->features ?? [];
        \DB::table('protect_settings')
            ->whereNotIn('key', ['brand','deskripsi','thanks','bot'])
            ->update(['enabled' => false]);

        foreach ($selected as $key) {
            Guard::set($key, null, true);
        }
        return back()->with('success', 'Fitur proteksi diterapkan.');
    }

    public function save(Request $request)
    {
        foreach (['brand','deskripsi','thanks','bot'] as $k) {
            if ($request->has($k)) Guard::set($k, $request->$k);
        }
        return back()->with('success', 'Konfigurasi disimpan.');
    }
}
PHPEOF
echo "✅ ProtectManager Controller"

# ─── 4. Copy ProtectManager Blade ───
mkdir -p resources/views/admin/protect
cat > resources/views/admin/protect/index.blade.php << 'BLADE'
@extends('layouts.admin')
@section('title') Protect Manager @endsection
@section('content-header')
<h1>🛡️ Protect Manager<small>Kelola proteksi panel Anda</small></h1>
<ol class="breadcrumb"><li><a href="{{ route('admin.index') }}">Admin</a></li><li class="active">Protect Manager</li></ol>
@endsection
@section('content')
<div class="row"><div class="col-xs-12">
<div class="box box-primary">
    <div class="box-header with-border">
        <h3 class="box-title">🛡️ Protect Manager</h3>
        <p class="text-muted">Centang fitur proteksi yang ingin diaktifkan, lalu klik Terapkan.</p>
    </div>
    <div class="box-body">
        <div class="row text-center" style="margin-bottom:15px;">
            <div class="col-xs-4"><h2>{{ $total }}</h2><small>Total Fitur</small></div>
            <div class="col-xs-4"><h2 style="color:#00a65a;">{{ $active }}</h2><small>Aktif</small></div>
            <div class="col-xs-4"><h2 style="color:#dd4b39;">{{ $total - $active }}</h2><small>Nonaktif</small></div>
        </div>

        <ul class="nav nav-tabs">
            <li class="active"><a data-toggle="tab" href="#tab-protect">🔒 Proteksi</a></li>
            <li><a data-toggle="tab" href="#tab-config">⚙️ Konfigurasi</a></li>
        </ul>

        <div class="tab-content" style="margin-top:15px;">
            <div id="tab-protect" class="tab-pane fade in active">
                <form method="POST" action="{{ route('admin.protect.apply') }}">
                    @csrf
                    @foreach($features as $key => $feat)
                    <div style="display:flex;justify-content:space-between;align-items:center;padding:12px;border:1px solid #2a3a4a;border-radius:6px;margin-bottom:8px;">
                        <div>
                            <label style="font-weight:600;cursor:pointer;">
                                <input type="checkbox" name="features[]" value="{{ $key }}" {{ $feat['enabled'] ? 'checked' : '' }}>
                                {{ $feat['label'] }}
                            </label>
                            <div style="font-size:12px;color:#9ca3af;">{{ $feat['desc'] }}</div>
                            <span class="label {{ $feat['enabled'] ? 'label-success' : 'label-default' }}">
                                {{ $feat['enabled'] ? '● Aktif' : '○ Nonaktif' }}
                            </span>
                            <code>{{ $key }}</code>
                        </div>
                    </div>
                    @endforeach
                    <button type="submit" class="btn btn-primary">🚀 Terapkan</button>
                </form>
            </div>
            <div id="tab-config" class="tab-pane fade">
                <form method="POST" action="{{ route('admin.protect.save') }}">
                    @csrf
                    <div class="form-group"><label>Brand</label>
                        <input type="text" name="brand" class="form-control" value="{{ $config['brand'] }}"></div>
                    <div class="form-group"><label>Deskripsi</label>
                        <input type="text" name="deskripsi" class="form-control" value="{{ $config['deskripsi'] }}"></div>
                    <div class="form-group"><label>Thanks Message</label>
                        <input type="text" name="thanks" class="form-control" value="{{ $config['thanks'] }}"></div>
                    <div class="form-group"><label>Bot Telegram</label>
                        <input type="text" name="bot" class="form-control" value="{{ $config['bot'] }}"></div>
                    <button type="submit" class="btn btn-success">💾 Simpan</button>
                </form>
            </div>
        </div>
    </div>
    <div class="box-footer">Protect Version: 1.0.0 | System Guard: Hybrid</div>
</div>
</div></div>
@endsection
BLADE
echo "✅ ProtectManager Blade"

# ─── 5. Inject banner ke Login ───
LOGIN="resources/views/auth/login.blade.php"
if [ -f "$LOGIN" ] && ! grep -q "BLUEHUBZ_ANCHOR_LOGIN" "$LOGIN"; then
  python3 - "$LOGIN" << 'PYEOF'
import sys, re
p = sys.argv[1]
h = open(p).read()
anchor = "{{-- BLUEHUBZ_ANCHOR_LOGIN --}}"
inject = "@include('bluehubz::banner', ['mode' => 'login'])\n" + anchor
h = re.sub(r'(<form[^>]*>)', inject + r'\n\1', h, count=1, flags=re.IGNORECASE)
open(p, 'w').write(h)
PYEOF
  echo "✅ Login banner"
fi

# ─── 6. Dashboard client ───
DASH="resources/views/client/dashboard.blade.php"
if [ -f "$DASH" ] && ! grep -q "BLUEHUBZ_ANCHOR_DASH" "$DASH"; then
  python3 - "$DASH" << 'PYEOF'
import sys, re
p = sys.argv[1]
h = open(p).read()
anchor = "{{-- BLUEHUBZ_ANCHOR_DASH --}}"
inject = "@include('bluehubz::banner', ['mode' => 'dashboard'])\n" + anchor
h = re.sub(r'(<[^>]*>\s*Showing Your Servers)', inject + r'\n\1', h, count=1, flags=re.IGNORECASE)
open(p, 'w').write(h)
PYEOF
  echo "✅ Dashboard banner"
fi

# ─── 7. Console server ───
CONSOLE="resources/views/client/servers/console.blade.php"
if [ -f "$CONSOLE" ] && ! grep -q "BLUEHUBZ_ANCHOR_CONSOLE" "$CONSOLE"; then
  python3 - "$CONSOLE" << 'PYEOF'
import sys, re
p = sys.argv[1]
h = open(p).read()
anchor = "{{-- BLUEHUBZ_ANCHOR_CONSOLE --}}"
inject = "@include('bluehubz::banner', ['mode' => 'console'])\n" + anchor
h = re.sub(r'(<div[^>]*id="terminal")', inject + r'\n\1', h, count=1, flags=re.IGNORECASE)
open(p, 'w').write(h)
PYEOF
  echo "✅ Console banner"
fi

# ─── 8. Footer branding ───
LAYOUT="resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT" ] && ! grep -q "BLUEHUBZ_ANCHOR_FOOTER" "$LAYOUT"; then
  python3 - "$LAYOUT" << 'PYEOF'
import sys
p = sys.argv[1]
h = open(p).read()
inject = "@include('bluehubz::banner', ['mode' => 'footer'])\n{{-- BLUEHUBZ_ANCHOR_FOOTER --}}\n"
h = h.replace('</body>', inject + '</body>', 1)
open(p, 'w').write(h)
PYEOF
  echo "✅ Footer branding"
fi

# ─── 9. Sidebar Protect Manager ───
if [ -f "$LAYOUT" ] && ! grep -q "Protect Manager" "$LAYOUT"; then
  python3 - "$LAYOUT" << 'PYEOF'
import sys, re
p = sys.argv[1]
h = open(p).read()
sidebar = '''
<li class="{{ Route::is('admin.protect') ? 'active' : '' }}">
    <a href="{{ route('admin.protect') }}"><i class="fa fa-shield"></i> <span>Protect Manager</span></a>
</li>
'''
h = re.sub(r'(<li[^>]*>\s*<a[^>]*admin/settings[^>]*>.*?</li>)', r'\1' + sidebar, h, count=1, flags=re.DOTALL)
open(p, 'w').write(h)
PYEOF
  echo "✅ Sidebar Protect Manager"
fi

# ─── 10. Register route ───
if ! grep -q "admin.protect" routes/admin.php; then
  python3 - routes/admin.php << 'PYEOF'
import sys
p = sys.argv[1]
h = open(p).read()
routes = """
Route::get('/protect-manager', [\\App\\Http\\Controllers\\Admin\\ProtectManagerController::class, 'index'])->name('admin.protect');
Route::post('/protect-manager/apply', [\\App\\Http\\Controllers\\Admin\\ProtectManagerController::class, 'apply'])->name('admin.protect.apply');
Route::post('/protect-manager/save', [\\App\\Http\\Controllers\\Admin\\ProtectManagerController::class, 'save'])->name('admin.protect.save');
"""
import re
h = re.sub(r"(Route::get\('/', 'Admin\\\\AdminController@index'\)[^;]*;)", r"\1" + routes, h, count=1)
open(p, 'w').write(h)
PYEOF
  echo "✅ Route registered"
fi

# ─── 11. Register middleware di Kernel ───
KERNEL="app/Http/Kernel.php"
if [ -f "$KERNEL" ] && ! grep -q "Bluehubz" "$KERNEL"; then
  sed -i "/protected \$middleware = \[/a \\        'bluehubz' => \\\\App\\\\Bluehubz\\\\Guard::class," "$KERNEL"
  sed -i "s/Route::middleware(\['auth', 'admin'\])/Route::middleware(['auth', 'admin', 'bluehubz'])/g" routes/admin.php 2>/dev/null || true
  echo "✅ Middleware registered"
fi

# ─── 12. Migration ───
mkdir -p database/migrations
cat > database/migrations/2026_01_01_000000_create_protect_settings.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::create('protect_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->boolean('enabled')->default(false);
            $table->string('label')->nullable();
            $table->text('value')->nullable();
            $table->timestamps();
        });
    }
    public function down() { Schema::dropIfExists('protect_settings'); }
};
EOF

php artisan migrate --force
echo "✅ Migration"

# ─── 13. Seed default ───
php artisan tinker --execute="
\App\Bluehubz\Guard::set('brand','By WezxOffc');
\App\Bluehubz\Guard::set('deskripsi','Chat @wezxoffc jika membutuhkan bantuan & laporkan masalah');
\App\Bluehubz\Guard::set('thanks','Thanks for using protect bluehubz');
\App\Bluehubz\Guard::set('bot','@wezxpterodactyloffcbot');
foreach (['protect1','protect2','protect5a','protect5b','protect5c','protect6','protect7','protect8','protect9','protect10','protect11','protect12a','protect12b','protect12c','protect12d','protect12e','protect13a','protect13b','protect14'] as \$k) {
    \App\Bluehubz\Guard::set(\$k, null, true);
}
" 2>/dev/null
echo "✅ Seed done"

# ─── 14. Register observer di AppServiceProvider ───
PROVIDER="app/Providers/AppServiceProvider.php"
if [ -f "$PROVIDER" ] && ! grep -q "Bluehubz" "$PROVIDER"; then
  python3 - "$PROVIDER" << 'PYEOF'
import sys
p = sys.argv[1]
h = open(p).read()
inject = """
        // BLUEHUBZ.PROTECT Observer
        \\App\\Models\\User::updating(function ($user) {
            \\App\\Bluehubz\\Guard::observeUser($user);
        });
        \\App\\Models\\User::deleting(function ($user) {
            if ($user->id === 1) abort(403, 'Root account is immutable.');
        });
"""
# Insert di dalam method boot()
import re
h = re.sub(r'(public function boot\(\)[^{]*\{)', r'\1' + inject, h, count=1)
open(p, 'w').write(h)
PYEOF
  echo "✅ Observer registered"
fi

# ─── 15. Clear cache ───
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan cache:clear

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ BLUEHUBZ.PROTECT v$VERSION INSTALLED    ║"
echo "║   Guard : Hybrid                             ║"
echo "║   Mode  : Non-Invasive                       ║"
echo "║   Backup: $BACKUP"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "🌐 Login ke panel → Admin → Protect Manager"
echo "🧹 Revert: sudo ./uninstall.sh"
