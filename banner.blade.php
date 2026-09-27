@php
    use App\Bluehubz\Guard;
    $mode     = $mode ?? 'dashboard';
    $brand    = Guard::get('brand', 'By WezxOffc') ?? 'By WezxOffc';
    $deskripsi= Guard::get('deskripsi', 'Chat @wezxoffc jika membutuhkan bantuan & laporkan masalah') ?? 'Chat @wezxoffc jika membutuhkan bantuan & laporkan masalah';
    $thanks   = Guard::get('thanks', 'Thanks for using protect bluehubz') ?? 'Thanks for using protect bluehubz';
    $version  = '1.0.0';
    // Auto-link @username
    $deskripsiLinked = preg_replace('/(@\w+)/', '<a href="https://t.me/$1" target="_blank" style="color:#38bdf8;font-weight:700;text-decoration:underline;">$1</a>', e($deskripsi));
@endphp

@if($mode === 'footer')
{{-- ═══ FOOTER BRANDING ═══ --}}
<div style="padding:16px;text-align:center;font-size:13px;color:#9ca3af;border-top:1px solid #1f2937;background:#0f172a;line-height:1.7;font-family:'Courier New',monospace;">
    <div>
        <span style="color:#38bdf8;font-weight:700;">● Panel By Wezx</span>
        &nbsp; Powered by <b style="color:#38bdf8;">Wezx Cloud</b>
        &nbsp; <span style="color:#38bdf8;">✈ @wezxoffc</span>
    </div>
    <div style="margin-top:4px;">
        Order panel via <a href="https://t.me/wezxoffc" style="color:#38bdf8;">@wezxoffc</a>
    </div>
    <div style="margin-top:6px;font-size:11px;opacity:.6;">
        Protect Version: {{ $version }} | System Guard: Hybrid
    </div>
</div>

@else
{{-- ═══ WELCOME BANNER ═══ --}}
<div style="border:2px solid #2563eb;border-radius:6px;overflow:hidden;background:#050a1a;font-family:'Courier New',monospace;box-shadow:0 0 24px rgba(37,99,235,.5);margin-bottom:16px;">
    <div style="background:repeating-linear-gradient(90deg,#38bdf8 0 12px,#050a1a 12px 24px);height:6px;"></div>

    <div style="padding:8px 14px;background:#0a1428;border-bottom:1px solid #2563eb;color:#38bdf8;font-size:12px;letter-spacing:1px;display:flex;align-items:center;gap:8px;">
        <span style="display:inline-block;width:12px;height:12px;background:#38bdf8;border:2px solid #2563eb;"></span>
        <span>// BLUEHUBZ.PROTECT</span>
    </div>

    <div style="padding:18px 16px;color:#f5f5f5;">
        @if($mode === 'login')
            <div style="font-size:18px;font-weight:700;color:#38bdf8;letter-spacing:1px;margin-bottom:8px;text-align:center;text-shadow:0 0 10px rgba(56,189,248,.7);">
                Welcome To Pterodactyl 👋🏻
            </div>
            <div style="text-align:center;font-size:12px;color:#9ca3af;letter-spacing:.5px;margin-bottom:14px;">
                Protected by <span style="color:#38bdf8;font-weight:700;">BLUEHUBZ</span>
            </div>
        @else
            <div style="font-size:16px;font-weight:700;color:#38bdf8;letter-spacing:1px;margin-bottom:12px;text-shadow:0 0 8px rgba(56,189,248,.6);">
                [ BLUEHUBZ.PROTECT ]
            </div>
        @endif

        <div style="font-size:13px;line-height:1.8;color:#e5e7eb;">
            <div style="margin-bottom:6px;">
                <span style="color:#2563eb;">&gt;</span> {!! $deskripsiLinked !!}
            </div>
            <div style="color:#9ca3af;font-style:italic;">
                <span style="color:#2563eb;">&gt;</span> {{ $thanks }}
            </div>
        </div>

        <div style="margin-top:12px;color:#38bdf8;font-size:14px;">
            <span style="animation:wezx-blink 1s steps(2) infinite;">█</span>
        </div>
    </div>
</div>

<style>@keyframes wezx-blink{0%,50%{opacity:1}51%,100%{opacity:0}}</style>
@endif
