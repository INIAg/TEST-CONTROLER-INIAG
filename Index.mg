<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>X Technology's | Laboratorio de Diagnóstico de Mandos</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-dark: #070b14;
      --panel-bg: rgba(15, 23, 42, 0.85);
      --border-glow: rgba(56, 189, 248, 0.25);
    }
    body {
      background-color: var(--bg-dark);
      background-image: 
        radial-gradient(circle at 15% 15%, rgba(37, 99, 235, 0.12), transparent 35%),
        radial-gradient(circle at 85% 80%, rgba(16, 185, 129, 0.08), transparent 35%),
        linear-gradient(to bottom, #070b14, #090e1a);
      color: #f1f5f9;
      font-family: 'Inter', sans-serif;
      overflow-x: hidden;
    }
    .mono { font-family: 'JetBrains Mono', monospace; }
    .glass-panel {
      background: var(--panel-bg);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(148, 163, 184, 0.14);
      box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.6);
    }
    /* Animaciones e iluminación de botones en los SVG */
    .svg-btn {
      transition: all 0.06s cubic-bezier(0.4, 0, 0.2, 1);
      transform-origin: center;
      transform-box: fill-box;
    }
    .svg-btn.pressed {
      fill: #38bdf8 !important;
      stroke: #bae6fd !important;
      filter: drop-shadow(0 0 10px rgba(56, 189, 248, 0.95));
      transform: scale(0.93);
    }
    .svg-btn.faulty {
      stroke: #ef4444 !important;
      stroke-width: 2.5px !important;
      filter: drop-shadow(0 0 8px rgba(239, 68, 68, 0.9));
    }
    .svg-stick {
      transition: transform 0.02s linear;
    }
    .touchpad-surface {
      cursor: crosshair;
    }
    /* Scrollbar estética */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: #090d16; }
    ::-webkit-scrollbar-thumb { background: #334155; border-radius: 3px; }
    ::-webkit-scrollbar-thumb:hover { background: #475569; }
  </style>
</head>
<body class="min-h-screen flex flex-col selection:bg-sky-500 selection:text-white">

  <!-- BARRA SUPERIOR -->
  <header class="border-b border-slate-800/80 bg-slate-950/80 backdrop-blur-md sticky top-0 z-40">
    <div class="max-w-[1600px] mx-auto px-4 py-3 flex flex-wrap items-center justify-between gap-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-sky-500 to-blue-700 flex items-center justify-center shadow-lg shadow-sky-500/20 font-black text-xl tracking-tighter text-white">
          XT
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h1 class="font-extrabold text-lg tracking-tight text-white">X TECHNOLOGY'S</h1>
            <span class="text-[11px] mono uppercase px-2 py-0.5 rounded-full bg-sky-500/15 text-sky-400 border border-sky-500/30 font-semibold">Lab v4.9</span>
          </div>
          <p class="text-xs text-slate-400">Sistema de Diagnóstico de Drift, Membranas Flexibles, Microswitches y Touchpad</p>
        </div>
      </div>

      <!-- Estado de Conexión -->
      <div class="flex flex-wrap items-center gap-2.5">
        <div id="connectionBadge" class="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-amber-500/10 border border-amber-500/30 text-amber-300 text-xs font-medium">
          <span id="connDot" class="w-2.5 h-2.5 rounded-full bg-amber-400 animate-pulse"></span>
          <span id="connText">Esperando mando (Presiona cualquier botón)...</span>
        </div>

        <button id="btnWebHID" onclick="connectWebHIDTouchpad()" class="px-3.5 py-1.5 rounded-lg bg-indigo-600/25 hover:bg-indigo-600/40 border border-indigo-400/40 text-indigo-200 text-xs font-semibold flex items-center gap-2 transition">
          <svg class="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 11.5V14m0-2.5v-6a1.5 1.5 0 113 0m-3 6a1.5 1.5 0 00-3 0v2a7.5 7.5 0 0015 0v-5a1.5 1.5 0 00-3 0m-6-3V11m0-5.5v-1a1.5 1.5 0 013 0v1m0 0V11m0-5.5a1.5 1.5 0 013 0v3m0 0V11"/>
          </svg>
          <span>Conectar Touchpad (WebHID)</span>
        </button>

        <button onclick="vibrateController()" class="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-200 text-xs font-semibold transition">
          Probar Vibración
        </button>

        <button onclick="resetDiagnostics()" class="px-3 py-1.5 rounded-lg bg-rose-500/15 hover:bg-rose-500/25 border border-rose-500/30 text-rose-300 text-xs font-semibold transition">
          Reiniciar Test
        </button>
      </div>
    </div>
  </header>

  <!-- CONTENIDO PRINCIPAL -->
  <main class="max-w-[1600px] w-full mx-auto p-4 grid grid-cols-1 lg:grid-cols-12 gap-4 flex-1">

    <!-- COLUMNA IZQUIERDA: SELECTOR DE MANDO Y RADARES DE STICKS (3 COLS) -->
    <section class="lg:col-span-3 flex flex-col gap-4">
      
      <!-- Selector Manual / Automático de Mando -->
      <div class="glass-panel rounded-2xl p-4">
        <div class="flex items-center justify-between mb-2.5">
          <h2 class="text-xs font-bold uppercase tracking-wider text-slate-400">Modelo Detectado / Vista</h2>
          <span id="boardRevisionBadge" class="text-[11px] mono px-2 py-0.5 rounded bg-slate-800 text-sky-400 border border-slate-700">BDM-010/020/030/040</span>
        </div>
        <div class="grid grid-cols-2 gap-2">
          <button onclick="setControllerProfile('ps5')" id="tab-ps5" class="profile-tab px-3 py-2 rounded-xl border text-xs font-bold flex items-center gap-2 transition bg-sky-500/20 border-sky-400 text-white">
            <span class="w-2 h-2 rounded-full bg-sky-400"></span> PS5 DualSense
          </button>
          <button onclick="setControllerProfile('ps4')" id="tab-ps4" class="profile-tab px-3 py-2 rounded-xl border border-slate-800 bg-slate-900/60 text-slate-400 hover:text-white text-xs font-bold flex items-center gap-2 transition">
            <span class="w-2 h-2 rounded-full bg-indigo-400"></span> PS4 DualShock 4
          </button>
          <button onclick="setControllerProfile('xbox')" id="tab-xbox" class="profile-tab px-3 py-2 rounded-xl border border-slate-800 bg-slate-900/60 text-slate-400 hover:text-white text-xs font-bold flex items-center gap-2 transition">
            <span class="w-2 h-2 rounded-full bg-emerald-400"></span> Xbox One / Series
          </button>
          <button onclick="setControllerProfile('switch')" id="tab-switch" class="profile-tab px-3 py-2 rounded-xl border border-slate-800 bg-slate-900/60 text-slate-400 hover:text-white text-xs font-bold flex items-center gap-2 transition">
            <span class="w-2 h-2 rounded-full bg-rose-400"></span> Switch Joy-Con
          </button>
        </div>
        <p id="controllerIdString" class="mt-2.5 text-[11px] mono text-slate-400 truncate">ID: Modo interactivo / Esperando entrada USB o Bluetooth</p>
      </div>

      <!-- Telemetría de Joysticks + Circularidad (Drift) -->
      <div class="glass-panel rounded-2xl p-4 flex-1 flex flex-col justify-between">
        <div>
          <div class="flex items-center justify-between mb-3">
            <h2 class="text-xs font-bold uppercase tracking-wider text-slate-400">Telemetría de Joysticks & Drift</h2>
            <label class="flex items-center gap-1.5 text-[11px] text-slate-300 cursor-pointer">
              <input type="checkbox" id="traceToggle" checked class="accent-sky-400 rounded">
              <span>Trazar circularidad</span>
            </label>
          </div>

          <!-- Radares L3 y R3 -->
          <div class="grid grid-cols-2 gap-3">
            <!-- Stick Izquierdo -->
            <div class="bg-slate-950/80 border border-slate-800/80 rounded-xl p-2.5 flex flex-col items-center">
              <div class="w-full flex justify-between items-center mb-1">
                <span class="text-xs font-bold text-slate-300">Stick Izq (LX/LY)</span>
                <span id="leftDriftStatus" class="text-[10px] mono px-1.5 py-0.5 rounded bg-emerald-500/15 text-emerald-400">OK</span>
              </div>
              <canvas id="canvasLeftStick" width="130" height="130" class="rounded-lg bg-slate-900/90 border border-slate-800 my-1"></canvas>
              <div class="w-full text-[11px] mono text-slate-400 mt-1 space-y-0.5">
                <div class="flex justify-between"><span>X:</span><span id="lxVal" class="text-slate-200">0.000</span></div>
                <div class="flex justify-between"><span>Y:</span><span id="lyVal" class="text-slate-200">0.000</span></div>
                <div class="flex justify-between"><span>Ruido/Drift:</span><span id="lDriftPct" class="text-sky-400">0.0%</span></div>
              </div>
            </div>

            <!-- Stick Derecho -->
            <div class="bg-slate-950/80 border border-slate-800/80 rounded-xl p-2.5 flex flex-col items-center">
              <div class="w-full flex justify-between items-center mb-1">
                <span class="text-xs font-bold text-slate-300">Stick Der (RX/RY)</span>
                <span id="rightDriftStatus" class="text-[10px] mono px-1.5 py-0.5 rounded bg-emerald-500/15 text-emerald-400">OK</span>
              </div>
              <canvas id="canvasRightStick" width="130" height="130" class="rounded-lg bg-slate-900/90 border border-slate-800 my-1"></canvas>
              <div class="w-full text-[11px] mono text-slate-400 mt-1 space-y-0.5">
                <div class="flex justify-between"><span>X:</span><span id="rxVal" class="text-slate-200">0.000</span></div>
                <div class="flex justify-between"><span>Y:</span><span id="ryVal" class="text-slate-200">0.000</span></div>
                <div class="flex justify-between"><span>Ruido/Drift:</span><span id="rDriftPct" class="text-sky-400">0.0%</span></div>
              </div>
            </div>
          </div>

          <!-- Medidores de Gatillos Analógicos L2 / R2 -->
          <div class="mt-4 space-y-2.5">
            <div>
              <div class="flex justify-between text-xs mono mb-1">
                <span class="text-slate-400" id="lblL2">Gatillo L2 / LT / ZL</span>
                <span id="valL2" class="text-sky-400 font-semibold">0% (0.00)</span>
              </div>
              <div class="w-full h-2.5 bg-slate-900 rounded-full overflow-hidden border border-slate-800">
                <div id="barL2" class="h-full bg-gradient-to-r from-sky-500 to-cyan-300 transition-all duration-75" style="width: 0%"></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between text-xs mono mb-1">
                <span class="text-slate-400" id="lblR2">Gatillo R2 / RT / ZR</span>
                <span id="valR2" class="text-sky-400 font-semibold">0% (0.00)</span>
              </div>
              <div class="w-full h-2.5 bg-slate-900 rounded-full overflow-hidden border border-slate-800">
                <div id="barR2" class="h-full bg-gradient-to-r from-sky-500 to-cyan-300 transition-all duration-75" style="width: 0%"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Simulador de Fallas de Taller -->
        <div class="mt-4 pt-3 border-t border-slate-800/80">
          <div class="flex items-center justify-between mb-2">
            <span class="text-[11px] font-bold uppercase tracking-wider text-amber-400">Simulador de Fallas (Demo Taller)</span>
            <button onclick="clearSimulatedFaults()" class="text-[11px] text-slate-400 hover:text-white underline">Limpiar</button>
          </div>
          <div class="grid grid-cols-2 gap-1.5">
            <button onclick="simulateFault('drift_left')" class="px-2.5 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 border border-slate-700/80 text-[11px] text-slate-300 text-left transition">
              + Drift Stick Izq.
            </button>
            <button onclick="simulateFault('membrane_dpad')" class="px-2.5 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 border border-slate-700/80 text-[11px] text-slate-300 text-left transition">
              + Falla Membrana/Goma
            </button>
            <button onclick="simulateFault('chatter_x')" class="px-2.5 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 border border-slate-700/80 text-[11px] text-slate-300 text-left transition">
              + Rebote Botón / Switch
            </button>
            <button onclick="simulateFault('trigger_pot')" class="px-2.5 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 border border-slate-700/80 text-[11px] text-slate-300 text-left transition">
              + Falla Gatillo R2/ZR
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- COLUMNA CENTRAL: VISUALIZADOR REALISTA DEL MANDO + TOUCHPAD DUALSENSE (5 COLS) -->
    <section class="lg:col-span-5 flex flex-col gap-4">
      <div class="glass-panel rounded-2xl p-5 flex-1 flex flex-col justify-between relative overflow-hidden">
        
        <!-- Encabezado del Visualizador -->
        <div class="flex flex-wrap items-center justify-between gap-2 z-10">
          <div>
            <h2 id="ControllerTitle" class="text-base font-extrabold text-white tracking-tight">Sony DualSense (PS5 Original)</h2>
            <p id="ControllerSubtitle" class="text-xs text-slate-400">Animación en tiempo real + Sensor Touchpad Capacitivo (1920×1080)</p>
          </div>
          <div class="flex items-center gap-2">
            <span id="touchStatusPill" class="text-[11px] mono px-2.5 py-1 rounded-full bg-sky-500/15 border border-sky-500/30 text-sky-300">
              Touchpad: Activo (Pasa el dedo o ratón)
            </span>
          </div>
        </div>

        <!-- CONTENEDOR DEL MANDO SVG -->
        <div class="my-auto py-2 flex items-center justify-center relative select-none">

          <!-- =====================================================
               1. SVG ORIGINAL PS5 DUALSENSE (BLANCO/NEGRO BICOLOR)
               ===================================================== -->
          <svg id="svg-ps5" viewBox="0 0 600 410" class="w-full max-w-[540px] drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)]">
            <defs>
              <linearGradient id="ps5WhiteShell" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#f8fafc"/>
                <stop offset="65%" stop-color="#e2e8f0"/>
                <stop offset="100%" stop-color="#cbd5e1"/>
              </linearGradient>
              <linearGradient id="ps5BlackCore" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#1e293b"/>
                <stop offset="100%" stop-color="#090d16"/>
              </linearGradient>
              <filter id="blueGlow" x="-20%" y="-20%" width="140%" height="140%">
                <feGaussianBlur stdDeviation="4" result="blur"/>
                <feComposite in="SourceGraphic" in2="blur" operator="over"/>
              </filter>
            </defs>

            <!-- Gatillos L2 / R2 y Botones L1 / R1 -->
            <path id="ps5-b6" class="svg-btn" d="M 135 55 Q 165 25 215 42 L 215 68 L 135 72 Z" fill="#1e293b" stroke="#475569" stroke-width="2"/>
            <text x="165" y="54" fill="#94a3b8" font-size="11" font-weight="bold">L2</text>
            <path id="ps5-b4" class="svg-btn" d="M 128 74 Q 170 58 220 68 L 220 88 L 125 92 Z" fill="#0f172a" stroke="#64748b" stroke-width="2"/>
            <text x="165" y="81" fill="#cbd5e1" font-size="10" font-weight="bold">L1</text>

            <path id="ps5-b7" class="svg-btn" d="M 465 55 Q 435 25 385 42 L 385 68 L 465 72 Z" fill="#1e293b" stroke="#475569" stroke-width="2"/>
            <text x="420" y="54" fill="#94a3b8" font-size="11" font-weight="bold">R2</text>
            <path id="ps5-b5" class="svg-btn" d="M 472 74 Q 430 58 380 68 L 380 88 L 475 92 Z" fill="#0f172a" stroke="#64748b" stroke-width="2"/>
            <text x="420" y="81" fill="#cbd5e1" font-size="10" font-weight="bold">R1</text>

            <!-- Núcleo Inferior Negro DualSense -->
            <path d="M 155 230 Q 300 260 445 230 L 470 330 Q 445 365 420 325 L 382 268 Q 300 272 218 268 L 180 325 Q 155 365 130 330 Z" fill="url(#ps5BlackCore)" stroke="#334155" stroke-width="1.5"/>

            <!-- Carcasa Blanca Original DualSense -->
            <path d="M 125 85 Q 92 140 82 245 Q 72 345 112 372 Q 148 392 175 330 L 212 255 Q 245 190 202 85 Z" fill="url(#ps5WhiteShell)" stroke="#94a3b8" stroke-width="2"/>
            <path d="M 475 85 Q 508 140 518 245 Q 528 345 488 372 Q 452 392 425 330 L 388 255 Q 355 190 398 85 Z" fill="url(#ps5WhiteShell)" stroke="#94a3b8" stroke-width="2"/>
            <!-- Puente Superior Blanco/Gris -->
            <path d="M 125 85 Q 300 68 475 85 L 448 232 Q 300 250 152 232 Z" fill="url(#ps5WhiteShell)" stroke="#cbd5e1" stroke-width="1.5"/>

            <!-- Tiras LED Azules a los lados del Touchpad -->
            <path d="M 205 78 L 222 178" stroke="#0ea5e9" stroke-width="5" stroke-linecap="round" filter="url(#blueGlow)"/>
            <path d="M 395 78 L 378 178" stroke="#0ea5e9" stroke-width="5" stroke-linecap="round" filter="url(#blueGlow)"/>

            <!-- TOUCHPAD INTERACTIVO DUALSENSE (Blanco Mate Trapezoidal) -->
            <g id="ps5-touchpad-group" class="touchpad-surface">
              <polygon id="ps5-b17" class="svg-btn" points="210,75 390,75 373,174 227,174" fill="#f1f5f9" stroke="#64748b" stroke-width="2"/>
              <line x1="220" y1="124" x2="380" y2="124" stroke="#cbd5e1" stroke-dasharray="3,3" stroke-width="1"/>
              <line x1="300" y1="80" x2="300" y2="170" stroke="#cbd5e1" stroke-dasharray="3,3" stroke-width="1"/>
              <text x="300" y="165" text-anchor="middle" fill="#64748b" font-size="9" font-family="JetBrains Mono">TOUCHPAD CAPACITIVO (DESLIZA AQUÍ)</text>
              <!-- Rastro y Puntos de Dedos -->
              <polyline id="ps5TouchTrail" points="" fill="none" stroke="#0284c7" stroke-width="2.5" stroke-linecap="round" opacity="0.7"/>
              <circle id="ps5Finger1" cx="300" cy="124" r="9" fill="#0ea5e9" stroke="#ffffff" stroke-width="2.5" class="hidden" filter="url(#blueGlow)"/>
              <text id="ps5Finger1Text" x="300" y="108" text-anchor="middle" fill="#0369a1" font-size="9" font-weight="bold" font-family="JetBrains Mono" class="hidden">X:0 Y:0</text>
              <circle id="ps5Finger2" cx="320" cy="124" r="8" fill="#ec4899" stroke="#ffffff" stroke-width="2" class="hidden"/>
            </g>

            <!-- Botones Create (8) y Options (9) -->
            <rect id="ps5-b8" class="svg-btn" x="188" y="92" width="12" height="22" rx="6" transform="rotate(-18 194 103)" fill="#cbd5e1" stroke="#475569" stroke-width="1.5"/>
            <rect id="ps5-b9" class="svg-btn" x="400" y="92" width="12" height="22" rx="6" transform="rotate(18 406 103)" fill="#cbd5e1" stroke="#475569" stroke-width="1.5"/>

            <!-- Cruceta (D-Pad Cristal Translúcido) -->
            <g transform="translate(158, 158)">
              <circle cx="0" cy="0" r="42" fill="#e2e8f0" stroke="#cbd5e1" stroke-width="1"/>
              <path id="ps5-b12" class="svg-btn" d="M -11 -35 L 11 -35 L 11 -12 L 0 -4 L -11 -12 Z" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
              <path id="ps5-b13" class="svg-btn" d="M -11 35 L 11 35 L 11 12 L 0 4 L -11 12 Z" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
              <path id="ps5-b14" class="svg-btn" d="M -35 -11 L -35 11 L -12 11 L -4 0 L -12 -11 Z" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
              <path id="ps5-b15" class="svg-btn" d="M 35 -11 L 35 11 L 12 11 L 4 0 L 12 -11 Z" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
            </g>

            <!-- Botones de Acción PS5 (Cristal Blanco con Símbolos Grises) -->
            <g transform="translate(442, 158)">
              <circle cx="0" cy="0" r="44" fill="#e2e8f0" stroke="#cbd5e1" stroke-width="1"/>
              <!-- Triángulo (b3) -->
              <g id="ps5-b3" class="svg-btn">
                <circle cx="0" cy="-27" r="13" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
                <polygon points="0,-34 -7,-22 7,-22" fill="none" stroke="#475569" stroke-width="2"/>
              </g>
              <!-- Cruz (b0) -->
              <g id="ps5-b0" class="svg-btn">
                <circle cx="0" cy="27" r="13" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
                <path d="M -5 22 L 5 32 M 5 22 L -5 32" stroke="#475569" stroke-width="2.2"/>
              </g>
              <!-- Cuadrado (b2) -->
              <g id="ps5-b2" class="svg-btn">
                <circle cx="-27" cy="0" r="13" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
                <rect x="-32" y="-5" width="10" height="10" fill="none" stroke="#475569" stroke-width="2"/>
              </g>
              <!-- Círculo (b1) -->
              <g id="ps5-b1" class="svg-btn">
                <circle cx="27" cy="0" r="13" fill="#f8fafc" stroke="#64748b" stroke-width="1.8"/>
                <circle cx="27" cy="0" r="5.5" fill="none" stroke="#475569" stroke-width="2"/>
              </g>
            </g>

            <!-- Altavoz Central + Botón PS (b16) + Botón Mute Mic -->
            <g transform="translate(300, 200)">
              <circle cx="-12" cy="-8" r="1.5" fill="#334155"/><circle cx="-4" cy="-8" r="1.5" fill="#334155"/><circle cx="4" cy="-8" r="1.5" fill="#334155"/><circle cx="12" cy="-8" r="1.5" fill="#334155"/>
              <circle cx="-8" cy="-3" r="1.5" fill="#334155"/><circle cx="0" cy="-3" r="1.5" fill="#334155"/><circle cx="8" cy="-3" r="1.5" fill="#334155"/>
              <!-- Botón PS -->
              <rect id="ps5-b16" class="svg-btn" x="-14" y="8" width="28" height="16" rx="8" fill="#0f172a" stroke="#64748b" stroke-width="1.8"/>
              <text x="0" y="19" text-anchor="middle" fill="#f8fafc" font-size="9" font-weight="bold">PS</text>
              <!-- Mute LED -->
              <rect x="-8" y="30" width="16" height="6" rx="3" fill="#f59e0b"/>
            </g>

            <!-- Stick Analógico Izquierdo (L3 - b10) -->
            <g transform="translate(232, 224)">
              <circle cx="0" cy="0" r="34" fill="#090d16" stroke="#475569" stroke-width="2"/>
              <g id="ps5-stick-left" class="svg-stick">
                <circle id="ps5-b10" class="svg-btn" cx="0" cy="0" r="24" fill="#1e293b" stroke="#64748b" stroke-width="3"/>
                <circle cx="0" cy="0" r="16" fill="#0f172a" stroke="#334155" stroke-width="1" stroke-dasharray="2,2"/>
                <text x="0" y="4" text-anchor="middle" fill="#94a3b8" font-size="10" font-weight="bold">L3</text>
              </g>
            </g>

            <!-- Stick Analógico Derecho (R3 - b11) -->
            <g transform="translate(368, 224)">
              <circle cx="0" cy="0" r="34" fill="#090d16" stroke="#475569" stroke-width="2"/>
              <g id="ps5-stick-right" class="svg-stick">
                <circle id="ps5-b11" class="svg-btn" cx="0" cy="0" r="24" fill="#1e293b" stroke="#64748b" stroke-width="3"/>
                <circle cx="0" cy="0" r="16" fill="#0f172a" stroke="#334155" stroke-width="1" stroke-dasharray="2,2"/>
                <text x="0" y="4" text-anchor="middle" fill="#94a3b8" font-size="10" font-weight="bold">R3</text>
              </g>
            </g>
          </svg>

          <!-- =====================================================
               2. SVG ORIGINAL PS4 DUALSHOCK 4 V2 (JET BLACK)
               ===================================================== -->
          <svg id="svg-ps4" viewBox="0 0 600 410" class="w-full max-w-[540px] hidden drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)]">
            <defs>
              <linearGradient id="ps4JetBlack" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#27272a"/>
                <stop offset="60%" stop-color="#18181b"/>
                <stop offset="100%" stop-color="#09090b"/>
              </linearGradient>
            </defs>

            <!-- Gatillos L2/R2 y L1/R1 -->
            <path id="ps4-b6" class="svg-btn" d="M 140 55 Q 170 30 215 45 L 215 68 L 140 72 Z" fill="#18181b" stroke="#52525b" stroke-width="2"/>
            <text x="168" y="55" fill="#a1a1aa" font-size="10" font-weight="bold">L2</text>
            <path id="ps4-b4" class="svg-btn" d="M 135 72 Q 175 60 220 68 L 220 88 L 135 90 Z" fill="#27272a" stroke="#71717a" stroke-width="2"/>
            <text x="168" y="81" fill="#e4e4e7" font-size="10" font-weight="bold">L1</text>

            <path id="ps4-b7" class="svg-btn" d="M 460 55 Q 430 30 385 45 L 385 68 L 460 72 Z" fill="#18181b" stroke="#52525b" stroke-width="2"/>
            <text x="418" y="55" fill="#a1a1aa" font-size="10" font-weight="bold">R2</text>
            <path id="ps4-b5" class="svg-btn" d="M 465 72 Q 425 60 380 68 L 380 88 L 465 90 Z" fill="#27272a" stroke="#71717a" stroke-width="2"/>
            <text x="418" y="81" fill="#e4e4e7" font-size="10" font-weight="bold">R1</text>

            <!-- Cuerpo Principal DualShock 4 Jet Black -->
            <path d="M 130 85 Q 85 140 82 250 Q 80 355 125 368 Q 168 378 192 310 L 220 255 L 380 255 L 408 310 Q 432 378 475 368 Q 520 355 518 250 Q 515 140 470 85 Q 300 72 130 85 Z" fill="url(#ps4JetBlack)" stroke="#3f3f46" stroke-width="2.5"/>

            <!-- Touchpad Negro con Lightbar Azul Superior V2 -->
            <g id="ps4-touchpad-group" class="touchpad-surface">
              <rect id="ps4-b17" class="svg-btn" x="215" y="78" width="170" height="94" rx="8" fill="#18181b" stroke="#52525b" stroke-width="2"/>
              <!-- Lightbar V2 -->
              <line x1="230" y1="84" x2="370" y2="84" stroke="#38bdf8" stroke-width="4" stroke-linecap="round"/>
              <text x="300" y="160" text-anchor="middle" fill="#71717a" font-size="9" font-family="JetBrains Mono">TOUCHPAD DS4 (DESLIZA AQUÍ)</text>
              <polyline id="ps4TouchTrail" points="" fill="none" stroke="#38bdf8" stroke-width="2.5" stroke-linecap="round"/>
              <circle id="ps4Finger1" cx="300" cy="125" r="8" fill="#38bdf8" stroke="#ffffff" stroke-width="2" class="hidden"/>
              <text id="ps4Finger1Text" x="300" y="110" text-anchor="middle" fill="#bae6fd" font-size="9" font-family="JetBrains Mono" class="hidden">X:0 Y:0</text>
              <circle id="ps4Finger2" cx="320" cy="125" r="7" fill="#f472b6" stroke="#ffffff" stroke-width="2" class="hidden"/>
            </g>

            <!-- Botones SHARE (8) y OPTIONS (9) -->
            <rect id="ps4-b8" class="svg-btn" x="192" y="88" width="12" height="22" rx="6" fill="#3f3f46" stroke="#71717a" stroke-width="1.5"/>
            <text x="198" y="82" text-anchor="middle" fill="#a1a1aa" font-size="7" font-weight="bold">SHARE</text>
            <rect id="ps4-b9" class="svg-btn" x="396" y="88" width="12" height="22" rx="6" fill="#3f3f46" stroke="#71717a" stroke-width="1.5"/>
            <text x="402" y="82" text-anchor="middle" fill="#a1a1aa" font-size="7" font-weight="bold">OPTIONS</text>

            <!-- Cruceta Clásica DualShock 4 -->
            <g transform="translate(158, 160)">
              <circle cx="0" cy="0" r="42" fill="#18181b" stroke="#27272a" stroke-width="1.5"/>
              <path id="ps4-b12" class="svg-btn" d="M -11 -35 L 11 -35 L 11 -11 L 0 -3 L -11 -11 Z" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
              <path id="ps4-b13" class="svg-btn" d="M -11 35 L 11 35 L 11 11 L 0 3 L -11 11 Z" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
              <path id="ps4-b14" class="svg-btn" d="M -35 -11 L -35 11 L -11 11 L -3 0 L -11 -11 Z" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
              <path id="ps4-b15" class="svg-btn" d="M 35 -11 L 35 11 L 11 11 L 3 0 L 11 -11 Z" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
            </g>

            <!-- Botones de Acción PS4 Originales con Símbolos a Color -->
            <g transform="translate(442, 160)">
              <circle cx="0" cy="0" r="44" fill="#18181b" stroke="#27272a" stroke-width="1.5"/>
              <!-- Triángulo Verde -->
              <g id="ps4-b3" class="svg-btn">
                <circle cx="0" cy="-27" r="13" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
                <polygon points="0,-34 -7,-22 7,-22" fill="none" stroke="#34d399" stroke-width="2.2"/>
              </g>
              <!-- Cruz Azul -->
              <g id="ps4-b0" class="svg-btn">
                <circle cx="0" cy="27" r="13" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
                <path d="M -5 22 L 5 32 M 5 22 L -5 32" stroke="#60a5fa" stroke-width="2.4"/>
              </g>
              <!-- Cuadrado Rosa -->
              <g id="ps4-b2" class="svg-btn">
                <circle cx="-27" cy="0" r="13" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
                <rect x="-32" y="-5" width="10" height="10" fill="none" stroke="#f472b6" stroke-width="2.2"/>
              </g>
              <!-- Círculo Rojo -->
              <g id="ps4-b1" class="svg-btn">
                <circle cx="27" cy="0" r="13" fill="#27272a" stroke="#52525b" stroke-width="1.8"/>
                <circle cx="27" cy="0" r="5.5" fill="none" stroke="#f87171" stroke-width="2.2"/>
              </g>
            </g>

            <!-- Botón PS Central (b16) -->
            <circle id="ps4-b16" class="svg-btn" cx="300" cy="224" r="12" fill="#18181b" stroke="#52525b" stroke-width="2"/>
            <text x="300" y="227" text-anchor="middle" fill="#e4e4e7" font-size="8" font-weight="bold">PS</text>

            <!-- Sticks Izquierdo y Derecho -->
            <g transform="translate(232, 224)">
              <circle cx="0" cy="0" r="33" fill="#09090b" stroke="#3f3f46" stroke-width="2"/>
              <g id="ps4-stick-left" class="svg-stick">
                <circle id="ps4-b10" class="svg-btn" cx="0" cy="0" r="24" fill="#27272a" stroke="#52525b" stroke-width="3"/>
                <text x="0" y="4" text-anchor="middle" fill="#a1a1aa" font-size="10" font-weight="bold">L3</text>
              </g>
            </g>
            <g transform="translate(368, 224)">
              <circle cx="0" cy="0" r="33" fill="#09090b" stroke="#3f3f46" stroke-width="2"/>
              <g id="ps4-stick-right" class="svg-stick">
                <circle id="ps4-b11" class="svg-btn" cx="0" cy="0" r="24" fill="#27272a" stroke="#52525b" stroke-width="3"/>
                <text x="0" y="4" text-anchor="middle" fill="#a1a1aa" font-size="10" font-weight="bold">R3</text>
              </g>
            </g>
          </svg>

          <!-- =====================================================
               3. SVG ORIGINAL XBOX SERIES X|S / ONE (CARBON BLACK)
               ===================================================== -->
          <svg id="svg-xbox" viewBox="0 0 600 410" class="w-full max-w-[540px] hidden drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)]">
            <defs>
              <linearGradient id="xboxCarbon" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#262626"/>
                <stop offset="100%" stop-color="#111111"/>
              </linearGradient>
            </defs>

            <!-- LT / RT y LB / RB -->
            <path id="xbox-b6" class="svg-btn" d="M 145 45 Q 175 22 220 40 L 220 65 L 145 68 Z" fill="#171717" stroke="#525252" stroke-width="2"/>
            <text x="175" y="52" fill="#a3a3a3" font-size="10" font-weight="bold">LT</text>
            <path id="xbox-b4" class="svg-btn" d="M 130 66 Q 180 52 235 64 L 235 86 L 130 88 Z" fill="#262626" stroke="#737373" stroke-width="2"/>
            <text x="175" y="79" fill="#e5e5e5" font-size="10" font-weight="bold">LB</text>

            <path id="xbox-b7" class="svg-btn" d="M 455 45 Q 425 22 380 40 L 380 65 L 455 68 Z" fill="#171717" stroke="#525252" stroke-width="2"/>
            <text x="412" y="52" fill="#a3a3a3" font-size="10" font-weight="bold">RT</text>
            <path id="xbox-b5" class="svg-btn" d="M 470 66 Q 420 52 365 64 L 365 86 L 470 88 Z" fill="#262626" stroke="#737373" stroke-width="2"/>
            <text x="412" y="79" fill="#e5e5e5" font-size="10" font-weight="bold">RB</text>

            <!-- Carcasa Carbon Black Xbox Series -->
            <path d="M 125 82 Q 80 140 75 260 Q 72 360 125 375 Q 168 385 205 305 L 235 265 L 365 265 L 395 305 Q 432 385 475 375 Q 528 360 525 260 Q 520 140 475 82 Q 300 58 125 82 Z" fill="url(#xboxCarbon)" stroke="#404040" stroke-width="2.5"/>

            <!-- Botón Guia Xbox (b16) -->
            <circle id="xbox-b16" class="svg-btn" cx="300" cy="102" r="18" fill="#f5f5f5" stroke="#a3a3a3" stroke-width="2"/>
            <path d="M 291 94 L 309 110 M 309 94 L 291 110" stroke="#171717" stroke-width="3" stroke-linecap="round"/>

            <!-- Botones View (b8), Share (b17) y Menu (b9) -->
            <circle id="xbox-b8" class="svg-btn" cx="260" cy="145" r="10" fill="#262626" stroke="#737373" stroke-width="1.8"/>
            <circle id="xbox-b9" class="svg-btn" cx="340" cy="145" r="10" fill="#262626" stroke="#737373" stroke-width="1.8"/>
            <rect id="xbox-b17" class="svg-btn" x="291" y="162" width="18" height="10" rx="5" fill="#262626" stroke="#737373" stroke-width="1.5"/>

            <!-- Stick Izquierdo Superior (Asimétrico Xbox - b10) -->
            <g transform="translate(175, 148)">
              <circle cx="0" cy="0" r="35" fill="#0a0a0a" stroke="#404040" stroke-width="2"/>
              <g id="xbox-stick-left" class="svg-stick">
                <circle id="xbox-b10" class="svg-btn" cx="0" cy="0" r="24" fill="#262626" stroke="#737373" stroke-width="3"/>
                <text x="0" y="4" text-anchor="middle" fill="#d4d4d4" font-size="10" font-weight="bold">LS</text>
              </g>
            </g>

            <!-- Cruceta Facetada Circular Xbox Series -->
            <g transform="translate(232, 228)">
              <circle cx="0" cy="0" r="36" fill="#141414" stroke="#404040" stroke-width="2"/>
              <path id="xbox-b12" class="svg-btn" d="M -10 -32 L 10 -32 L 10 -10 L -10 -10 Z" fill="#262626" stroke="#525252" stroke-width="1.5"/>
              <path id="xbox-b13" class="svg-btn" d="M -10 10 L 10 10 L 10 32 L -10 32 Z" fill="#262626" stroke="#525252" stroke-width="1.5"/>
              <path id="xbox-b14" class="svg-btn" d="M -32 -10 L -10 -10 L -10 10 L -32 10 Z" fill="#262626" stroke="#525252" stroke-width="1.5"/>
              <path id="xbox-b15" class="svg-btn" d="M 10 -10 L 32 -10 L 32 10 L 10 10 Z" fill="#262626" stroke="#525252" stroke-width="1.5"/>
            </g>

            <!-- Stick Derecho Inferior (b11) -->
            <g transform="translate(368, 228)">
              <circle cx="0" cy="0" r="35" fill="#0a0a0a" stroke="#404040" stroke-width="2"/>
              <g id="xbox-stick-right" class="svg-stick">
                <circle id="xbox-b11" class="svg-btn" cx="0" cy="0" r="24" fill="#262626" stroke="#737373" stroke-width="3"/>
                <text x="0" y="4" text-anchor="middle" fill="#d4d4d4" font-size="10" font-weight="bold">RS</text>
              </g>
            </g>

            <!-- Botones ABXY Originales Xbox -->
            <g transform="translate(432, 148)">
              <!-- Y Amarillo -->
              <g id="xbox-b3" class="svg-btn">
                <circle cx="0" cy="-27" r="14" fill="#171717" stroke="#facc15" stroke-width="2"/>
                <text x="0" y="-22" text-anchor="middle" fill="#facc15" font-size="13" font-weight="bold">Y</text>
              </g>
              <!-- A Verde -->
              <g id="xbox-b0" class="svg-btn">
                <circle cx="0" cy="27" r="14" fill="#171717" stroke="#4ade80" stroke-width="2"/>
                <text x="0" y="32" text-anchor="middle" fill="#4ade80" font-size="13" font-weight="bold">A</text>
              </g>
              <!-- X Azul -->
              <g id="xbox-b2" class="svg-btn">
                <circle cx="-27" cy="0" r="14" fill="#171717" stroke="#38bdf8" stroke-width="2"/>
                <text x="-27" y="5" text-anchor="middle" fill="#38bdf8" font-size="13" font-weight="bold">X</text>
              </g>
              <!-- B Rojo -->
              <g id="xbox-b1" class="svg-btn">
                <circle cx="27" cy="0" r="14" fill="#171717" stroke="#f87171" stroke-width="2"/>
                <text x="27" y="5" text-anchor="middle" fill="#f87171" font-size="13" font-weight="bold">B</text>
              </g>
            </g>
          </svg>

          <!-- =====================================================
               4. SVG ORIGINAL NINTENDO SWITCH JOY-CON (AZUL / ROJO NEÓN EN GRIP)
               ===================================================== -->
          <svg id="svg-switch" viewBox="0 0 600 410" class="w-full max-w-[540px] hidden drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)]">
            <defs>
              <linearGradient id="neonBlue" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#00c3e3"/>
                <stop offset="100%" stop-color="#0284c7"/>
              </linearGradient>
              <linearGradient id="neonRed" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stop-color="#ff4554"/>
                <stop offset="100%" stop-color="#e11d48"/>
              </linearGradient>
            </defs>

            <!-- Empuñaduras Traseras del Joy-Con Grip Negro -->
            <path d="M 155 190 Q 95 245 95 340 Q 98 380 135 375 Q 175 365 205 295 Z" fill="#18181b" stroke="#3f3f46" stroke-width="2"/>
            <path d="M 445 190 Q 505 245 505 340 Q 502 380 465 375 Q 425 365 395 295 Z" fill="#18181b" stroke="#3f3f46" stroke-width="2"/>

            <!-- Puente Central Negro del Joy-Con Grip -->
            <rect x="242" y="68" width="116" height="238" rx="10" fill="#18181b" stroke="#3f3f46" stroke-width="2"/>
            <!-- LEDs de Jugador -->
            <circle cx="282" cy="145" r="3" fill="#4ade80"/><circle cx="282" cy="158" r="3" fill="#27272a"/><circle cx="282" cy="171" r="3" fill="#27272a"/><circle cx="282" cy="184" r="3" fill="#27272a"/>
            <circle cx="318" cy="145" r="3" fill="#4ade80"/><circle cx="318" cy="158" r="3" fill="#27272a"/><circle cx="318" cy="171" r="3" fill="#27272a"/><circle cx="318" cy="184" r="3" fill="#27272a"/>
            <text x="300" y="120" text-anchor="middle" fill="#71717a" font-size="9" font-weight="bold">JOY-CON GRIP</text>

            <!-- Gatillos Superiores ZL / L y ZR / R -->
            <path id="switch-b6" class="svg-btn" d="M 162 42 Q 195 24 240 42 L 240 62 L 162 62 Z" fill="#18181b" stroke="#52525b" stroke-width="2"/>
            <text x="195" y="52" fill="#cbd5e1" font-size="10" font-weight="bold">ZL</text>
            <path id="switch-b4" class="svg-btn" d="M 155 58 Q 195 48 242 58 L 242 75 L 155 75 Z" fill="#27272a" stroke="#71717a" stroke-width="2"/>
            <text x="195" y="70" fill="#f8fafc" font-size="10" font-weight="bold">L</text>

            <path id="switch-b7" class="svg-btn" d="M 438 42 Q 405 24 360 42 L 360 62 L 438 62 Z" fill="#18181b" stroke="#52525b" stroke-width="2"/>
            <text x="392" y="52" fill="#cbd5e1" font-size="10" font-weight="bold">ZR</text>
            <path id="switch-b5" class="svg-btn" d="M 445 58 Q 405 48 358 58 L 358 75 L 445 75 Z" fill="#27272a" stroke="#71717a" stroke-width="2"/>
            <text x="392" y="70" fill="#f8fafc" font-size="10" font-weight="bold">R</text>

            <!-- JOY-CON IZQUIERDO (AZUL NEÓN HAC-015) -->
            <rect x="148" y="68" width="96" height="238" rx="46" fill="url(#neonBlue)" stroke="#bae6fd" stroke-width="2"/>
            <!-- Botón Menos (-) -->
            <rect id="switch-b8" class="svg-btn" x="216" y="86" width="16" height="6" rx="2" fill="#18181b" stroke="#3f3f46" stroke-width="1.5"/>
            <!-- Stick Izquierdo Joy-Con -->
            <g transform="translate(196, 134)">
              <circle cx="0" cy="0" r="28" fill="#0f172a" stroke="#334155" stroke-width="2"/>
              <g id="switch-stick-left" class="svg-stick">
                <circle id="switch-b10" class="svg-btn" cx="0" cy="0" r="21" fill="#1e293b" stroke="#64748b" stroke-width="2.5"/>
                <text x="0" y="4" text-anchor="middle" fill="#cbd5e1" font-size="9" font-weight="bold">LS</text>
              </g>
            </g>
            <!-- Botones Direccionales Separados Joy-Con Izquierdo -->
            <g transform="translate(196, 214)">
              <circle id="switch-b12" class="svg-btn" cx="0" cy="-22" r="11" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
              <polygon points="0,-26 -4,-19 4,-19" fill="#cbd5e1"/>
              <circle id="switch-b13" class="svg-btn" cx="0" cy="22" r="11" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
              <polygon points="0,26 -4,19 4,19" fill="#cbd5e1"/>
              <circle id="switch-b14" class="svg-btn" cx="-22" cy="0" r="11" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
              <polygon points="-26,0 -19,-4 -19,4" fill="#cbd5e1"/>
              <circle id="switch-b15" class="svg-btn" cx="22" cy="0" r="11" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
              <polygon points="26,0 19,-4 19,4" fill="#cbd5e1"/>
            </g>
            <!-- Botón Captura Cuadrado (b17) -->
            <rect id="switch-b17" class="svg-btn" x="208" y="262" width="16" height="16" rx="3" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
            <circle cx="216" cy="270" r="4" fill="#0f172a"/>

            <!-- JOY-CON DERECHO (ROJO NEÓN HAC-016) -->
            <rect x="356" y="68" width="96" height="238" rx="46" fill="url(#neonRed)" stroke="#fecdd3" stroke-width="2"/>
            <!-- Botón Más (+) -->
            <g id="switch-b9" class="svg-btn">
              <rect x="368" y="86" width="16" height="5" rx="1.5" fill="#18181b"/>
              <rect x="373.5" y="80.5" width="5" height="16" rx="1.5" fill="#18181b"/>
            </g>
            <!-- Botones X / Y / A / B Switch -->
            <g transform="translate(404, 134)">
              <!-- X Arriba (b3) -->
              <g id="switch-b3" class="svg-btn">
                <circle cx="0" cy="-23" r="11.5" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
                <text x="0" y="-19" text-anchor="middle" fill="#f8fafc" font-size="10" font-weight="bold">X</text>
              </g>
              <!-- B Abajo (b0) -->
              <g id="switch-b0" class="svg-btn">
                <circle cx="0" cy="23" r="11.5" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
                <text x="0" y="27" text-anchor="middle" fill="#f8fafc" font-size="10" font-weight="bold">B</text>
              </g>
              <!-- Y Izquierda (b2) -->
              <g id="switch-b2" class="svg-btn">
                <circle cx="-23" cy="0" r="11.5" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
                <text x="-23" y="4" text-anchor="middle" fill="#f8fafc" font-size="10" font-weight="bold">Y</text>
              </g>
              <!-- A Derecha (b1) -->
              <g id="switch-b1" class="svg-btn">
                <circle cx="23" cy="0" r="11.5" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
                <text x="23" y="4" text-anchor="middle" fill="#f8fafc" font-size="10" font-weight="bold">A</text>
              </g>
            </g>
            <!-- Stick Derecho Joy-Con -->
            <g transform="translate(404, 214)">
              <circle cx="0" cy="0" r="28" fill="#0f172a" stroke="#334155" stroke-width="2"/>
              <g id="switch-stick-right" class="svg-stick">
                <circle id="switch-b11" class="svg-btn" cx="0" cy="0" r="21" fill="#1e293b" stroke="#64748b" stroke-width="2.5"/>
                <text x="0" y="4" text-anchor="middle" fill="#cbd5e1" font-size="9" font-weight="bold">RS</text>
              </g>
            </g>
            <!-- Botón Home Redondo (b16) -->
            <circle id="switch-b16" class="svg-btn" cx="382" cy="270" r="9" fill="#1e293b" stroke="#94a3b8" stroke-width="2"/>
          </svg>

        </div>

        <!-- Barra Inferior de Coordenadas Touchpad y Matriz de 18 Botones -->
        <div class="space-y-3 z-10">
          <!-- Coordenadas Touchpad DualSense / DS4 -->
          <div class="bg-slate-950/90 border border-slate-800/90 rounded-xl p-2.5 flex flex-wrap items-center justify-between gap-2 text-xs mono">
            <div class="flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-sky-400"></span>
              <span class="text-slate-400">DEDO 1:</span>
              <span id="touchCoord1" class="text-sky-300 font-bold">Inactivo (Pasa el dedo por el Touchpad)</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-pink-400"></span>
              <span class="text-slate-400">DEDO 2:</span>
              <span id="touchCoord2" class="text-pink-300 font-bold">Inactivo</span>
            </div>
          </div>

          <!-- Matriz Rápida de Botones B0 - B17 -->
          <div id="buttonMatrix" class="grid grid-cols-6 sm:grid-cols-9 gap-1.5">
            <!-- Generado dinámicamente por JS -->
          </div>
        </div>

      </div>
    </section>

    <!-- COLUMNA DERECHA: DIAGNÓSTICO DE REPARACIÓN (MEMBRANAS, DRIFT, MICROSWITCHES) (4 COLS) -->
    <section class="lg:col-span-4 flex flex-col gap-4">
      
      <!-- Diagnóstico Automático de Fallas -->
      <div class="glass-panel rounded-2xl p-4 flex-1 flex flex-col justify-between">
        <div>
          <div class="flex items-center justify-between mb-3">
            <div>
              <h2 class="text-xs font-bold uppercase tracking-wider text-sky-400">Diagnóstico Inteligente de Taller</h2>
              <p class="text-[11px] text-slate-400">Detección de Drift, Membrana Conductora, Carboncillos y Switches</p>
            </div>
            <span id="healthScoreBadge" class="px-2.5 py-1 rounded-lg bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-xs font-extrabold mono">
              SALUD: 100%
            </span>
          </div>

          <!-- Lista Dinámica de Diagnósticos -->
          <div id="diagnosticList" class="space-y-2.5 max-h-[340px] overflow-y-auto pr-1">
            <!-- Renderizado por JS -->
          </div>
        </div>

        <!-- Guía Técnica Específica según el Mando Conectado -->
        <div class="mt-4 pt-3 border-t border-slate-800/90">
          <h3 class="text-xs font-bold uppercase tracking-wider text-slate-300 mb-2">Guía de Refacciones del Modelo Actual</h3>
          <div id="repairPartsGuide" class="bg-slate-950/80 border border-slate-800 rounded-xl p-3 text-xs text-slate-300 space-y-1.5">
            <!-- Se actualiza según PS5 / PS4 / Xbox / Switch Joy-Con -->
          </div>

          <!-- Botón para Copiar Orden de Servicio WhatsApp -->
          <div class="mt-3 flex gap-2">
            <button onclick="copyRepairReport()" class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-sky-500 to-blue-600 hover:from-sky-400 hover:to-blue-500 text-white font-bold text-xs shadow-lg shadow-sky-500/20 flex items-center justify-center gap-2 transition">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"/>
              </svg>
              <span id="copyBtnText">Copiar Reporte de Diagnóstico (WhatsApp / Orden)</span>
            </button>
          </div>
        </div>
      </div>

    </section>

  </main>

  <script>
    // =========================================================================
    // ESTADO GLOBAL DEL LABORATORIO DE MANDOS
    // =========================================================================
    let currentProfile = 'ps5'; // 'ps5' | 'ps4' | 'xbox' | 'switch'
    let activeGamepadIndex = null;
    let leftTrail = [];
    let rightTrail = [];
    let touchTrailPoints = [];
    let hidDevice = null;

    // Estadísticas por botón para detectar rebote (chatter) o membrana gastada
    const buttonStats = Array.from({ length: 18 }, () => ({
      pressed: false,
      pressCount: 0,
      lastPressTime: 0,
      chatterEvents: 0,
      maxAnalogVal: 0
    }));

    // Fallas simuladas o detectadas
    const simulatedFaults = {
      drift_left: false,
      membrane_dpad: false,
      chatter_x: false,
      trigger_pot: false
    };

    // Nombres de botones según plataforma
    const PROFILE_DATA = {
      ps5: {
        title: "Sony DualSense (PS5 Original)",
        subtitle: "Animación en tiempo real + Sensor Touchpad Capacitivo (1920×1080)",
        revision: "Placa BDM-010 / BDM-020 / BDM-030 / BDM-040",
        labels: ["Cruz (✕)", "Círculo (○)", "Cuadrado (□)", "Triángulo (△)", "L1", "R1", "L2", "R2", "Create", "Options", "L3", "R3", "Arriba", "Abajo", "Izquierda", "Derecha", "Botón PS", "Touchpad"],
        partsGuide: `
          <p><strong class="text-sky-400">• Joysticks (Drift):</strong> Potenciómetros ALPS de 2.3KΩ o actualización a <span class="text-emerald-400 font-semibold">Sensores Hall Effect / TMR</span> (requiere desoldar 14 pines).</p>
          <p><strong class="text-sky-400">• Botones / Cruceta:</strong> Si hay que presionar muy fuerte, revisar <span class="text-amber-300 font-semibold">Membrana Flexible (FPC 18 pines según BDM-010/020/030)</span> y limpiar o cambiar gomas conductoras de carbón.</p>
          <p><strong class="text-sky-400">• Gatillos L2/R2:</strong> Revisar cinta flex de gatillo adaptativo y resorte de torsión.</p>
        `
      },
      ps4: {
        title: "Sony DualShock 4 V2 (PS4 Original)",
        subtitle: "Lightbar V2 Frontal + Diagnóstico de Membrana Conductora JDM",
        revision: "Placa JDM-001 / JDM-011 / JDM-030 / JDM-040 / JDM-050 / JDM-055",
        labels: ["Cruz (✕)", "Círculo (○)", "Cuadrado (□)", "Triángulo (△)", "L1", "R1", "L2", "R2", "Share", "Options", "L3", "R3", "Arriba", "Abajo", "Izquierda", "Derecha", "Botón PS", "Touchpad"],
        partsGuide: `
          <p><strong class="text-sky-400">• Membrana Conductora:</strong> Falla muy común en cruceta o botones R2/L2. Reemplazar <span class="text-amber-300 font-semibold">Membrana Flexible según modelo exacto (JDM-040 / JDM-055)</span>.</p>
          <p><strong class="text-sky-400">• Gomas de Silicona:</strong> Si el botón no regresa o requiere mucha presión, cambiar pad de goma conductora.</p>
          <p><strong class="text-sky-400">• Drift L3/R3:</strong> Cambio de trimpots verdes/naranjas de 10KΩ o módulo completo ALPS/Hall.</p>
        `
      },
      xbox: {
        title: "Xbox Series X|S / Xbox One (Carbon Black)",
        subtitle: "Diagnóstico de Microswitches LB/RB, Domos Metálicos y Sensores Hall en Gatillos",
        revision: "Placa Modelo 1914 (Series X|S) / Modelo 1708 (One S)",
        labels: ["A", "B", "X", "Y", "LB", "RB", "LT", "RT", "View", "Menu", "LS", "RS", "Arriba", "Abajo", "Izquierda", "Derecha", "Guía Xbox", "Share"],
        partsGuide: `
          <p><strong class="text-emerald-400">• Botones LB / RB:</strong> No usan membrana; si fallan o dan doble clic, desoldar y reemplazar <span class="text-amber-300 font-semibold">Microswitch táctil lateral Omron</span> o revisar pestaña plástica del bumper.</p>
          <p><strong class="text-emerald-400">• Cruceta y ABXY:</strong> Usan placa con domos metálicos (snap domes) y gomas conductoras.</p>
          <p><strong class="text-emerald-400">• Gatillos LT/RT:</strong> Funcionan por imán y sensor Hall Effect (si fallan, verificar imán suelto).</p>
        `
      },
      switch: {
        title: "Nintendo Switch Joy-Con (HAC-015 Azul / HAC-016 Rojo)",
        subtitle: "Diagnóstico de Sticks Planos ZIF y Cintas Flexibles SL/SR/ZL/ZR",
        revision: "Joy-Con L (HAC-015) & Joy-Con R (HAC-016)",
        labels: ["B", "A", "Y", "X", "L", "R", "ZL", "ZR", "Menos (-)", "Más (+)", "Stick L", "Stick R", "Arriba", "Abajo", "Izquierda", "Derecha", "Home", "Captura"],
        partsGuide: `
          <p><strong class="text-rose-400">• Drift en Joy-Con:</strong> El módulo de joystick es plano con conector <span class="text-emerald-400 font-semibold">ZIF sin soldadura</span> (reemplazo directo por módulo original o Hall Effect para Joy-Con).</p>
          <p><strong class="text-rose-400">• Botones L / R:</strong> Microswitch SMD soldado en placa principal (suele desprenderse en caídas).</p>
          <p><strong class="text-rose-400">• Botones ZL / ZR y SL / SR:</strong> Usan <span class="text-amber-300 font-semibold">Cinta Flex independiente</span> que se fatiga por el doblez interno.</p>
        `
      }
    };

    // =========================================================================
    // INICIALIZACIÓN
    // =========================================================================
    window.addEventListener('DOMContentLoaded', () => {
      setControllerProfile('ps5');
      initInteractiveTouchpadSurface();
      requestAnimationFrame(updateLoop);
    });

    // Eventos de conexión Gamepad API
    window.addEventListener('gamepadconnected', (e) => {
      activeGamepadIndex = e.gamepad.index;
      autoDetectControllerType(e.gamepad.id);
      updateConnectionBanner(true, e.gamepad.id);
    });

    window.addEventListener('gamepaddisconnected', (e) => {
      if (activeGamepadIndex === e.gamepad.index) {
        activeGamepadIndex = null;
        updateConnectionBanner(false, "");
      }
    });

    function autoDetectControllerType(idStr) {
      const id = idStr.toLowerCase();
      if (id.includes('054c') && (id.includes('0ce6') || id.includes('dualsense') || id.includes('wireless controller'))) {
        if (id.includes('05c4') || id.includes('09cc') || id.includes('dualshock')) {
          setControllerProfile('ps4');
        } else {
          setControllerProfile('ps5');
        }
      } else if (id.includes('dualshock') || id.includes('05c4') || id.includes('09cc') || id.includes('ps4')) {
        setControllerProfile('ps4');
      } else if (id.includes('057e') || id.includes('joy-con') || id.includes('pro controller') || id.includes('nintendo') || id.includes('switch')) {
        setControllerProfile('switch');
      } else if (id.includes('xbox') || id.includes('045e') || id.includes('xinput')) {
        setControllerProfile('xbox');
      }
    }

    function updateConnectionBanner(connected, idStr) {
      const badge = document.getElementById('connectionBadge');
      const dot = document.getElementById('connDot');
      const text = document.getElementById('connText');
      const idLabel = document.getElementById('controllerIdString');

      if (connected) {
        badge.className = "flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/15 border border-emerald-500/40 text-emerald-300 text-xs font-semibold";
        dot.className = "w-2.5 h-2.5 rounded-full bg-emerald-400";
        text.textContent = "Mando Conectado en Tiempo Real";
        idLabel.textContent = `ID: ${idStr}`;
      } else {
        badge.className = "flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-amber-500/10 border border-amber-500/30 text-amber-300 text-xs font-medium";
        dot.className = "w-2.5 h-2.5 rounded-full bg-amber-400 animate-pulse";
        text.textContent = "Esperando mando (Presiona cualquier botón)...";
        idLabel.textContent = "ID: Modo interactivo / Esperando entrada USB o Bluetooth";
      }
    }

    // =========================================================================
    // CAMBIO DE PERFIL VISUAL (PS5 / PS4 / XBOX / SWITCH JOY-CON)
    // =========================================================================
    function setControllerProfile(profile) {
      currentProfile = profile;
      ['ps5', 'ps4', 'xbox', 'switch'].forEach(p => {
        const svgEl = document.getElementById(`svg-${p}`);
        const tabEl = document.getElementById(`tab-${p}`);
        if (p === profile) {
          svgEl.classList.remove('hidden');
          tabEl.className = "profile-tab px-3 py-2 rounded-xl border text-xs font-bold flex items-center gap-2 transition bg-sky-500/20 border-sky-400 text-white";
        } else {
          svgEl.classList.add('hidden');
          tabEl.className = "profile-tab px-3 py-2 rounded-xl border border-slate-800 bg-slate-900/60 text-slate-400 hover:text-white text-xs font-bold flex items-center gap-2 transition";
        }
      });

      const info = PROFILE_DATA[profile];
      document.getElementById('ControllerTitle').textContent = info.title;
      document.getElementById('ControllerSubtitle').textContent = info.subtitle;
      document.getElementById('boardRevisionBadge').textContent = info.revision;
      document.getElementById('repairPartsGuide').innerHTML = info.partsGuide;

      // Renderizar matriz de botones inferior
      const matrix = document.getElementById('buttonMatrix');
      matrix.innerHTML = info.labels.map((label, idx) => `
        <div id="matrix-b${idx}" class="px-2 py-1.5 rounded-lg bg-slate-900/90 border border-slate-800 text-center transition">
          <div class="text-[10px] mono text-slate-400 truncate">${label}</div>
          <div id="matrix-count-b${idx}" class="text-[11px] mono font-bold text-slate-500">0</div>
        </div>
      `).join('');
    }

    // =========================================================================
    // TOUCHPAD DUALSENSE / DS4: WEBHID REAL + SUPERFICIE TÁCTIL INTERACTIVA
    // =========================================================================
    async function connectWebHIDTouchpad() {
      if (!('hid' in navigator)) {
        alert("Tu navegador no soporta WebHID. Usa Chrome o Edge en PC por cable USB, o desliza el dedo directamente sobre el Touchpad en pantalla.");
        return;
      }
      try {
        const devices = await navigator.hid.requestDevice({
          filters: [
            { vendorId: 0x054c, productId: 0x0ce6 }, // DualSense
            { vendorId: 0x054c, productId: 0x0df2 }, // DualSense Edge
            { vendorId: 0x054c, productId: 0x05c4 }, // DualShock 4 V1
            { vendorId: 0x054c, productId: 0x09cc }  // DualShock 4 V2
          ]
        });
        if (!devices.length) return;
        hidDevice = devices[0];
        if (!hidDevice.opened) await hidDevice.open();

        document.getElementById('touchStatusPill').textContent = `WebHID Activo: ${hidDevice.productName}`;
        document.getElementById('touchStatusPill').className = "text-[11px] mono px-2.5 py-1 rounded-full bg-emerald-500/20 border border-emerald-400/40 text-emerald-300";

        hidDevice.addEventListener('inputreport', (event) => {
          const data = new Uint8Array(event.data.buffer);
          // Parseo de coordenadas de Touchpad de DualSense (Report ID 0x01 por USB)
          // Bytes 32..35 (Dedo 1) y 36..39 (Dedo 2) en DualSense USB
          if (data.length >= 40) {
            const f1Active = (data[32] & 0x80) === 0;
            const x1 = ((data[34] & 0x0f) << 8) | data[33];
            const y1 = (data[35] << 4) | ((data[34] & 0xf0) >> 4);

            const f2Active = (data[36] & 0x80) === 0;
            const x2 = ((data[38] & 0x0f) << 8) | data[37];
            const y2 = (data[39] << 4) | ((data[38] & 0xf0) >> 4);

            renderTouchpadFinger(1, f1Active, x1, y1);
            renderTouchpadFinger(2, f2Active, x2, y2);
          }
        });
      } catch (err) {
        console.warn("WebHID cancelado o no disponible:", err);
      }
    }

    // Superficie interactiva para probar el Touchpad pasando el dedo o mouse
    function initInteractiveTouchpadSurface() {
      ['ps5', 'ps4'].forEach(prefix => {
        const padGroup = document.getElementById(`${prefix}-touchpad-group`);
        if (!padGroup) return;

        const handlePointer = (e) => {
          const rect = padGroup.getBoundingClientRect();
          const normX = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
          const normY = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));
          const rawX = Math.round(normX * 1920);
          const rawY = Math.round(normY * 1080);
          renderTouchpadFinger(1, true, rawX, rawY);
        };

        padGroup.addEventListener('pointermove', handlePointer);
        padGroup.addEventListener('pointerdown', (e) => {
          handlePointer(e);
          // Simular clic del touchpad (b17)
          buttonStats[17].pressed = true;
        });
        padGroup.addEventListener('pointerup', () => {
          buttonStats[17].pressed = false;
        });
        padGroup.addEventListener('pointerleave', () => {
          buttonStats[17].pressed = false;
          renderTouchpadFinger(1, false, 0, 0);
        });
      });
    }

    function renderTouchpadFinger(fingerIdx, active, rawX, rawY) {
      const prefix = currentProfile === 'ps4' ? 'ps4' : 'ps5';
      const fingerCircle = document.getElementById(`${prefix}Finger${fingerIdx}`);
      const fingerText = document.getElementById(`${prefix}Finger1Text`);
      const trailEl = document.getElementById(`${prefix}TouchTrail`);
      const coordLabel = document.getElementById(`touchCoord${fingerIdx}`);

      if (!active) {
        if (fingerCircle) fingerCircle.classList.add('hidden');
        if (fingerIdx === 1 && fingerText) fingerText.classList.add('hidden');
        if (coordLabel) coordLabel.textContent = "Inactivo";
        if (fingerIdx === 1) touchTrailPoints = [];
        return;
      }

      // Mapear 1920x1080 al área del touchpad en el SVG
      const svgX = 225 + (rawX / 1920) * 150;
      const svgY = 82 + (rawY / 1080) * 86;

      if (fingerCircle) {
        fingerCircle.setAttribute('cx', svgX.toFixed(1));
        fingerCircle.setAttribute('cy', svgY.toFixed(1));
        fingerCircle.classList.remove('hidden');
      }
      if (fingerIdx === 1 && fingerText) {
        fingerText.setAttribute('x', svgX.toFixed(1));
        fingerText.setAttribute('y', (svgY - 12).toFixed(1));
        fingerText.textContent = `${rawX},${rawY}`;
        fingerText.classList.remove('hidden');

        touchTrailPoints.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);
        if (touchTrailPoints.length > 28) touchTrailPoints.shift();
        if (trailEl) trailEl.setAttribute('points', touchTrailPoints.join(' '));
      }

      if (coordLabel) {
        coordLabel.textContent = `X: ${rawX} px | Y: ${rawY} px`;
      }
    }

    // =========================================================================
    // BUCLE PRINCIPAL DE LECTURA Y TELEMETRÍA (60 FPS)
    // =========================================================================
    function updateLoop() {
      const gamepads = navigator.getGamepads ? navigator.getGamepads() : [];
      let gp = null;

      if (activeGamepadIndex !== null && gamepads[activeGamepadIndex]) {
        gp = gamepads[activeGamepadIndex];
      } else {
        for (let i = 0; i < gamepads.length; i++) {
          if (gamepads[i]) {
            gp = gamepads[i];
            activeGamepadIndex = i;
            autoDetectControllerType(gp.id);
            updateConnectionBanner(true, gp.id);
            break;
          }
        }
      }

      // Coordenadas de Joysticks
      let lx = gp ? (gp.axes[0] || 0) : 0;
      let ly = gp ? (gp.axes[1] || 0) : 0;
      let rx = gp ? (gp.axes[2] || 0) : 0;
      let ry = gp ? (gp.axes[3] || 0) : 0;

      // Aplicar simulación de Drift si está activa
      if (simulatedFaults.drift_left) {
        lx = 0.24 + Math.sin(Date.now() / 160) * 0.04;
        ly = -0.19 + Math.cos(Date.now() / 210) * 0.03;
      }

      // Actualizar Stiks en el SVG activo
      const leftStickEl = document.getElementById(`${currentProfile}-stick-left`);
      const rightStickEl = document.getElementById(`${currentProfile}-stick-right`);
      if (leftStickEl) leftStickEl.style.transform = `translate(${(lx * 14).toFixed(1)}px, ${(ly * 14).toFixed(1)}px)`;
      if (rightStickEl) rightStickEl.style.transform = `translate(${(rx * 14).toFixed(1)}px, ${(ry * 14).toFixed(1)}px)`;

      // Actualizar Radares de Circularidad
      drawStickRadar('canvasLeftStick', lx, ly, leftTrail);
      drawStickRadar('canvasRightStick', rx, ry, rightTrail);

      // Valores numéricos de Drift
      const lMag = Math.hypot(lx, ly);
      const rMag = Math.hypot(rx, ry);
      document.getElementById('lxVal').textContent = lx.toFixed(3);
      document.getElementById('lyVal').textContent = ly.toFixed(3);
      document.getElementById('lDriftPct').textContent = `${(lMag * 100).toFixed(1)}%`;

      document.getElementById('rxVal').textContent = rx.toFixed(3);
      document.getElementById('ryVal').textContent = ry.toFixed(3);
      document.getElementById('rDriftPct').textContent = `${(rMag * 100).toFixed(1)}%`;

      // Estado visual de Drift Izquierdo / Derecho
      updateDriftPill('leftDriftStatus', lMag);
      updateDriftPill('rightDriftStatus', rMag);

      // Procesar los 18 botones estándar
      const now = performance.now();
      for (let i = 0; i < 18; i++) {
        let isPressed = false;
        let val = 0;

        if (gp && gp.buttons[i]) {
          isPressed = gp.buttons[i].pressed;
          val = gp.buttons[i].value || (isPressed ? 1 : 0);
        }

        // Si es el botón 17 (Touchpad) presionado con el ratón
        if (i === 17 && buttonStats[17].pressed && !gp) {
          isPressed = true;
          val = 1;
        }

        // Simulación de falla de gatillo R2/ZR (no llega al 100%)
        if (i === 7 && simulatedFaults.trigger_pot && val > 0.62) {
          val = 0.62;
        }

        // Detectar flanco de subida y posible rebote (chatter)
        if (isPressed && !buttonStats[i].pressed) {
          const delta = now - buttonStats[i].lastPressTime;
          if (delta > 0 && delta < 48) {
            buttonStats[i].chatterEvents++;
          }
          buttonStats[i].pressCount++;
          buttonStats[i].lastPressTime = now;
        }
        buttonStats[i].pressed = isPressed;
        if (val > buttonStats[i].maxAnalogVal) buttonStats[i].maxAnalogVal = val;

        // Iluminar botón en el SVG actual
        const svgBtn = document.getElementById(`${currentProfile}-b${i}`);
        if (svgBtn) {
          svgBtn.classList.toggle('pressed', isPressed);
          const isFaultyBtn = (i === 13 && simulatedFaults.membrane_dpad) || (i === 0 && simulatedFaults.chatter_x) || (i === 7 && simulatedFaults.trigger_pot);
          svgBtn.classList.toggle('faulty', isFaultyBtn);
        }

        // Actualizar Matriz Inferior
        const matrixCell = document.getElementById(`matrix-b${i}`);
        const matrixCount = document.getElementById(`matrix-count-b${i}`);
        if (matrixCell && matrixCount) {
          matrixCount.textContent = buttonStats[i].pressCount;
          if (isPressed) {
            matrixCell.className = "px-2 py-1.5 rounded-lg bg-sky-500/30 border border-sky-400 text-center transition scale-95";
            matrixCount.className = "text-[11px] mono font-bold text-white";
          } else if (buttonStats[i].pressCount > 0) {
            matrixCell.className = "px-2 py-1.5 rounded-lg bg-emerald-500/10 border border-emerald-500/30 text-center transition";
            matrixCount.className = "text-[11px] mono font-bold text-emerald-400";
          }
        }

        // Actualizar barras de gatillos L2 (b6) y R2 (b7)
        if (i === 6) {
          document.getElementById('valL2').textContent = `${Math.round(val * 100)}% (${val.toFixed(2)})`;
          document.getElementById('barL2').style.width = `${val * 100}%`;
        }
        if (i === 7) {
          document.getElementById('valR2').textContent = `${Math.round(val * 100)}% (${val.toFixed(2)})`;
          document.getElementById('barR2').style.width = `${val * 100}%`;
        }
      }

      // Ejecutar motor de diagnóstico técnico
      evaluateDiagnostics(lMag, rMag);

      requestAnimationFrame(updateLoop);
    }

    function updateDriftPill(elId, mag) {
      const el = document.getElementById(elId);
      if (mag > 0.12) {
        el.textContent = "DRIFT";
        el.className = "text-[10px] mono px-1.5 py-0.5 rounded bg-rose-500/20 text-rose-400 border border-rose-500/40 font-bold";
      } else if (mag > 0.06) {
        el.textContent = "LEVE";
        el.className = "text-[10px] mono px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300";
      } else {
        el.textContent = "OK";
        el.className = "text-[10px] mono px-1.5 py-0.5 rounded bg-emerald-500/15 text-emerald-400";
      }
    }

    // =========================================================================
    // RADAR DE CIRCULARIDAD Y TRAZADO DE STICKS
    // =========================================================================
    function drawStickRadar(canvasId, x, y, trailArr) {
      const canvas = document.getElementById(canvasId);
      if (!canvas) return;
      const ctx = canvas.getContext('2d');
      const w = canvas.width;
      const h = canvas.height;
      const cx = w / 2;
      const cy = h / 2;
      const r = w * 0.42;

      ctx.clearRect(0, 0, w, h);

      // Círculo exterior y zona muerta (10%)
      ctx.strokeStyle = '#334155';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.arc(cx, cy, r, 0, Math.PI * 2);
      ctx.stroke();

      ctx.strokeStyle = 'rgba(239, 68, 68, 0.35)';
      ctx.beginPath();
      ctx.arc(cx, cy, r * 0.12, 0, Math.PI * 2);
      ctx.stroke();

      // Ejes centrales
      ctx.strokeStyle = '#1e293b';
      ctx.beginPath();
      ctx.moveTo(cx - r, cy); ctx.lineTo(cx + r, cy);
      ctx.moveTo(cx, cy - r); ctx.lineTo(cx, cy + r);
      ctx.stroke();

      // Guardar e imprimir trazo de circularidad
      const traceEnabled = document.getElementById('traceToggle').checked;
      if (traceEnabled && Math.hypot(x, y) > 0.03) {
        trailArr.push({ x: cx + x * r, y: cy + y * r });
        if (trailArr.length > 90) trailArr.shift();
      } else if (!traceEnabled) {
        trailArr.length = 0;
      }

      if (trailArr.length > 1) {
        ctx.strokeStyle = 'rgba(56, 189, 248, 0.45)';
        ctx.lineWidth = 2;
        ctx.beginPath();
        trailArr.forEach((pt, idx) => {
          if (idx === 0) ctx.moveTo(pt.x, pt.y);
          else ctx.lineTo(pt.x, pt.y);
        });
        ctx.stroke();
      }

      // Posición actual del stick
      const px = cx + x * r;
      const py = cy + y * r;
      const isDrifting = Math.hypot(x, y) > 0.12;
      ctx.fillStyle = isDrifting ? '#f43f5e' : '#38bdf8';
      ctx.beginPath();
      ctx.arc(px, py, 5, 0, Math.PI * 2);
      ctx.fill();
    }

    // =========================================================================
    // MOTOR INTELIGENTE DE DIAGNÓSTICO DE REPARACIÓN
    // =========================================================================
    function evaluateDiagnostics(lMag, rMag) {
      const issues = [];
      let health = 100;

      // 1. Diagnóstico de Drift en Stick Izquierdo / Derecho
      if (lMag > 0.12 || simulatedFaults.drift_left) {
        health -= 35;
        let partRecommendation = "Reemplazar potenciómetros ALPS o instalar sticks magnéticos Hall Effect / TMR.";
        if (currentProfile === 'switch') {
          partRecommendation = "Reemplazar módulo de Joystick plano Joy-Con (conector ZIF sin soldadura) por repuesto nuevo o Hall Effect.";
        }
        issues.push({
          severity: "CRÍTICO",
          color: "rose",
          title: "Drift Detectado en Joystick Izquierdo (LX/LY)",
          desc: `Desviación en reposo del ${(lMag * 100).toFixed(1)}% (fuera del umbral del 10%). ${partRecommendation}`
        });
      }

      if (rMag > 0.12) {
        health -= 35;
        issues.push({
          severity: "CRÍTICO",
          color: "rose",
          title: "Drift Detectado en Joystick Derecho (RX/RY)",
          desc: `Desviación en reposo del ${(rMag * 100).toFixed(1)}%. Limpieza con alcohol isopropílico o cambio de potenciómetro/módulo completo.`
        });
      }

      // 2. Diagnóstico de Membrana Conductora / Gomas (Especial PlayStation vs Xbox/Switch)
      if (simulatedFaults.membrane_dpad) {
        health -= 25;
        if (currentProfile === 'ps5' || currentProfile === 'ps4') {
          issues.push({
            severity: "REEMPLAZO",
            color: "amber",
            title: "Falla en Membrana Conductora / Pad de Goma (Cruceta Abajo)",
            desc: `El circuito de contacto presenta circuito abierto o desgaste de carbón. En ${currentProfile.toUpperCase()} se requiere reemplazo de la Membrana Flexible (FPC) o cambio de gomas conductoras de silicona.`
          });
        } else if (currentProfile === 'xbox') {
          issues.push({
            severity: "REEMPLAZO",
            color: "amber",
            title: "Falla en Domo Metálico de Cruceta (D-Pad Abajo)",
            desc: "Limpiar contacto debajo de la lámina adhesiva de domos metálicos en la placa frontal o reemplazar lámina snap-dome."
          });
        } else {
          issues.push({
            severity: "REEMPLAZO",
            color: "amber",
            title: "Falla en Botón Direccional de Joy-Con Izquierdo",
            desc: "Revisar contacto de goma conductora o humedad en los pads dorados de la placa HAC-015."
          });
        }
      }

      // 3. Diagnóstico de Rebote / Microswitch (Chatter)
      const hasChatter = buttonStats.some(b => b.chatterEvents > 1) || simulatedFaults.chatter_x;
      if (hasChatter) {
        health -= 20;
        const btnName = PROFILE_DATA[currentProfile].labels[0];
        issues.push({
          severity: "SERVICIO",
          color: "amber",
          title: `Falso Contacto / Rebote en Botón ${btnName}`,
          desc: currentProfile === 'xbox'
            ? "Detectadas pulsaciones intermitentes (<45ms). Limpiar pad de carbón o reemplazar microswitch táctil Omron si ocurre en LB/RB."
            : "Pulsaciones múltiples involuntarias. Limpiar pistas de carbón con alcohol isopropílico al 99% o sustituir goma conductora vencida."
        });
      }

      // 4. Diagnóstico de Gatillo Analógico L2/R2
      if (simulatedFaults.trigger_pot) {
        health -= 20;
        issues.push({
          severity: "AJUSTE",
          color: "sky",
          title: `Recorrido Incompleto en Gatillo (${PROFILE_DATA[currentProfile].labels[7]})`,
          desc: currentProfile === 'switch'
            ? "La cinta flex del botón ZR presenta fatiga mecánica. Reemplazar flex de gatillo ZR."
            : "El gatillo se estanca al 62% de presión. Revisar goma conductora cortada (PS4), potenciómetro de gatillo (PS5) o imán desplazado (Xbox)."
        });
      }

      // Renderizar estado de salud
      health = Math.max(10, health);
      const healthBadge = document.getElementById('healthScoreBadge');
      healthBadge.textContent = `SALUD: ${health}%`;
      healthBadge.className = health === 100
        ? "px-2.5 py-1 rounded-lg bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-xs font-extrabold mono"
        : "px-2.5 py-1 rounded-lg bg-rose-500/15 border border-rose-500/30 text-rose-300 text-xs font-extrabold mono";

      const listEl = document.getElementById('diagnosticList');
      if (issues.length === 0) {
        listEl.innerHTML = `
          <div class="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/25 flex items-start gap-3">
            <div class="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold shrink-0">✓</div>
            <div>
              <h4 class="text-xs font-bold text-emerald-300">Sin Anomalías Detectadas</h4>
              <p class="text-[11px] text-slate-300 mt-0.5">Centrado de joysticks dentro de tolerancia (<6%), respuesta de membranas/switches limpia y recorrido de gatillos al 100%.</p>
            </div>
          </div>
        `;
      } else {
        listEl.innerHTML = issues.map(item => `
          <div class="p-3 rounded-xl bg-${item.color}-500/10 border border-${item.color}-500/30 space-y-1">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-${item.color}-300">${item.title}</span>
              <span class="text-[10px] mono font-bold px-1.5 py-0.5 rounded bg-${item.color}-500/20 text-${item.color}-300">${item.severity}</span>
            </div>
            <p class="text-[11px] text-slate-300 leading-relaxed">${item.desc}</p>
          </div>
        `).join('');
      }
    }

    // =========================================================================
    // FUNCIONES DE UTILIDAD (SIMULADOR, VIBRACIÓN, RESET Y REPORTE)
    // =========================================================================
    function simulateFault(faultKey) {
      simulatedFaults[faultKey] = !simulatedFaults[faultKey];
    }

    function clearSimulatedFaults() {
      Object.keys(simulatedFaults).forEach(k => simulatedFaults[k] = false);
    }

    function resetDiagnostics() {
      clearSimulatedFaults();
      leftTrail = [];
      rightTrail = [];
      touchTrailPoints = [];
      buttonStats.forEach(b => {
        b.pressCount = 0;
        b.chatterEvents = 0;
        b.maxAnalogVal = 0;
      });
      setControllerProfile(currentProfile);
    }

    function vibrateController() {
      const gamepads = navigator.getGamepads ? navigator.getGamepads() : [];
      const gp = activeGamepadIndex !== null ? gamepads[activeGamepadIndex] : gamepads[0];
      if (gp && gp.vibrationActuator) {
        gp.vibrationActuator.playEffect("dual-rumble", {
          startDelay: 0,
          duration: 450,
          weakMagnitude: 0.85,
          strongMagnitude: 1.0
        });
      } else {
        alert("Conecta un mando compatible por USB/Bluetooth y presiona un botón para activar los motores de vibración.");
      }
    }

    function copyRepairReport() {
      const info = PROFILE_DATA[currentProfile];
      const lx = document.getElementById('lxVal').textContent;
      const ly = document.getElementById('lyVal').textContent;
      const rx = document.getElementById('rxVal').textContent;
      const ry = document.getElementById('ryVal').textContent;
      const health = document.getElementById('healthScoreBadge').textContent;

      const report = [
        `*X TECHNOLOGY'S - REPORTE TÉCNICO DE MANDO*`,
        `• Modelo: ${info.title}`,
        `• Revisión: ${info.revision}`,
        `• Estado General: ${health}`,
        `• Telemetría Stick Izq: X=${lx}, Y=${ly}`,
        `• Telemetría Stick Der: X=${rx}, Y=${ry}`,
        `• Diagnóstico: ${document.getElementById('diagnosticList').innerText.replace(/\n+/g, ' | ')}`
      ].join('\n');

      navigator.clipboard.writeText(report).then(() => {
        const btnText = document.getElementById('copyBtnText');
        btnText.textContent = "¡Reporte Copiado al Portapapeles!";
        setTimeout(() => {
          btnText.textContent = "Copiar Reporte de Diagnóstico (WhatsApp / Orden)";
        }, 2200);
      });
    }
  </script>
</body>
</html>
