<?php
namespace App\Bluehubz;

use Closure;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Model;

/**
 * BLUEHUBZ.PROTECT — Hybrid Guard
 * Middleware + Helper + Observer dalam 1 file
 */
class Guard
{
    public function handle($request, Closure $next)
    {
        $user = Auth::user();

        // ── Bypass rules ──
        if (!$user) return $next($request);
        if ($user->id === 1) return $next($request);
        if (app()->runningInConsole()) return $next($request);
        if ($request->is('admin/protect-manager*')) return $next($request);

        // ── Route rules ──
        $rules = [
            'admin/nests*'         => 'protect5a',
            'admin/settings*'      => 'protect6',
            'admin/nodes*'         => 'protect12a',
            'admin/locations*'     => 'protect12e',
            'admin/api*'           => 'protect13b',
            'admin/users/*/edit'   => 'protect2',
            'admin/users/*/update' => 'protect2',
            'admin/users/*/delete' => 'protect2',
            'admin/servers/*/edit' => 'protect9',
            'admin/servers/*/delete'=> 'protect1',
            'api/application/users*' => 'protect12c',
            'api/client/account*'  => 'protect12b',
        ];

        foreach ($rules as $pattern => $key) {
            if ($request->is($pattern) && self::isEnabled($key)) {
                abort(403, 'Access Denied. Protected by BLUEHUBZ.');
            }
        }

        return $next($request);
    }

    public static function isEnabled(string $key): bool
    {
        try {
            if (!Schema::hasTable('protect_settings')) return false;
            $row = DB::table('protect_settings')->where('key', $key)->first();
            return $row && (bool) $row->enabled;
        } catch (\Throwable $e) { return false; }
    }

    public static function get(string $key, $default = null)
    {
        try {
            if (!Schema::hasTable('protect_settings')) return $default;
            $row = DB::table('protect_settings')->where('key', $key)->first();
            return $row->value ?? $default;
        } catch (\Throwable $e) { return $default; }
    }

    public static function set(string $key, $value, bool $enabled = null)
    {
        try {
            $data = ['value' => $value];
            if ($enabled !== null) $data['enabled'] = $enabled;
            DB::table('protect_settings')->updateOrInsert(['key' => $key], $data);
        } catch (\Throwable $e) {}
    }

    public static function observeUser(Model $user)
    {
        if ($user->id !== 1) return;
        foreach (['email','username','password','root_admin','name'] as $f) {
            if ($user->isDirty($f)) {
                $user->$f = $user->getOriginal($f);
            }
        }
    }
}
