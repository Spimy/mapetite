<!-- 2A — Dine-In Feed -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Dine-In Feed - Urban Wellness</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#F0FDF4", /* Custom for this frame as requested, but overriding tailwind config bg to match request while keeping system integrity */
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        /* Hide scrollbar for horizontal scroll areas */
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }
        body {
            background-color: #F0FDF4; /* Requested background */
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="text-on-background min-h-screen pb-24 md:pb-0 font-body-1">
<!-- Top App Bar -->
<!-- Applying style commands from JSON where applicable conceptually for a custom nav -->
<header class="fixed top-0 w-full z-50 bg-white border-b border-border h-[56px] flex items-center px-margin-mobile transition-colors duration-200">
<div class="flex items-center justify-between w-full">
<button aria-label="Go back" class="p-2 -ml-2 text-primary hover:bg-grey-100 rounded-full transition-colors duration-200">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 0;">arrow_back</span>
</button>
<h1 class="font-headline-1 text-headline-1 text-on-surface absolute left-1/2 -translate-x-1/2">Dine-In</h1>
<div class="flex items-center gap-1 bg-primary-light text-primary-container px-3 py-1.5 rounded-full shadow-sm">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">location_on</span>
<span class="font-label text-label">Subang Jaya</span>
</div>
</div>
</header>
<!-- Main Content Canvas -->
<main class="pt-[72px] px-margin-mobile md:px-margin-tablet max-w-3xl mx-auto space-y-stack-lg pb-stack-lg">
<!-- Filter/Sort Pills -->
<div class="flex overflow-x-auto gap-stack-md pb-1 no-scrollbar w-full">
<button class="shrink-0 bg-primary-container text-white px-4 py-2 rounded-full font-label text-label flex items-center gap-1 shadow-sm transition-transform active:scale-95">
<span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">check</span>
                Best Match
            </button>
<button class="shrink-0 bg-white border border-border text-grey-600 px-4 py-2 rounded-full font-label text-label hover:bg-grey-100 transition-colors">
                Nearest
            </button>
<button class="shrink-0 bg-white border border-border text-grey-600 px-4 py-2 rounded-full font-label text-label hover:bg-grey-100 transition-colors">
                Budget
            </button>
<button class="shrink-0 bg-white border border-border text-grey-600 px-4 py-2 rounded-full font-label text-label hover:bg-grey-100 transition-colors flex items-center gap-1">
                Cuisine
                <span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 0;">expand_more</span>
</button>
</div>
<!-- Restaurant Cards Feed -->
<div class="space-y-stack-lg w-full">
<!-- Card 1 -->
<article class="bg-white border border-border rounded-[12px] overflow-hidden flex flex-col shadow-sm hover:shadow-md transition-shadow duration-200">
<div class="relative h-[160px] w-full bg-grey-100">
<img alt="Restaurant Interior" class="w-full h-full object-cover" data-alt="A bustling, warm-lit modern mamak restaurant interior filled with diverse patrons enjoying meals at clean wooden tables. The atmosphere is lively and inviting, bathed in a soft, high-key light that enhances the vibrant colors of the food and modern decor. The space feels energetic yet sophisticated, perfectly aligning with a sleek, health-conscious urban lifestyle app aesthetic. Deep greens and warm wood tones dominate the palette." src="https://lh3.googleusercontent.com/aida-public/AB6AXuB5uIXduuID-RNTb6MlL659ghLXqGFGMa69xBSuuN7GLipWAYn9rnUZjzJq1_rUCixm2rAWDK3TOmIOBftYSE7jXHjgG8-J6QfDdINDYsooFnvuAXsPHFTvw61EiYdcmIxuFQV7w5jPv7m82_dK053YCLf6RZ53bNv4fXBMjWKqSm5PbnOPBevR_h2wSUDqMqapaKNuXeEt0LE21Q8abc3WdCDiddH_eS1yCHkCyyQgam58J7dpD633T7eUHbtjuVSDJjrJHb2H6W8"/>
<!-- Overlay Tags Top -->
<div class="absolute top-3 left-3 flex gap-2">
<span class="bg-primary-container text-white px-2 py-1 rounded-[4px] font-label text-label shadow-sm">Halal</span>
</div>
<div class="absolute top-3 right-3">
<span class="bg-white/90 backdrop-blur-sm text-on-surface px-2 py-1 rounded-[4px] font-label text-label font-semibold shadow-sm border border-white/20">RM 5-10</span>
</div>
<!-- Gradient Footer Overlay -->
<div class="absolute bottom-0 left-0 w-full bg-gradient-to-t from-black/80 to-transparent p-4 flex justify-between items-end">
<h2 class="font-headline-2 text-headline-2 text-white drop-shadow-md">Restoran Nasi Kandar Ali</h2>
<span class="font-label text-label text-white/90 bg-black/40 px-2 py-1 rounded flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">directions_walk</span>
                            0.4km
                        </span>
</div>
</div>
<div class="p-4 space-y-stack-md">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<span class="bg-surface-variant text-on-surface px-2.5 py-1 rounded-full font-caption text-caption border border-border">Mamak</span>
<span class="font-caption text-caption text-grey-600 flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 0;">schedule</span>
                                5 min walk
                            </span>
</div>
<div class="flex items-center gap-1 text-warning font-label text-label">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
                            4.5 <span class="text-grey-400 font-caption text-caption">(128)</span>
</div>
</div>
<div class="bg-primary-light/30 rounded-lg p-3 border border-primary-light flex items-start gap-2">
<span class="material-symbols-outlined text-primary-container text-[18px] shrink-0 mt-0.5" style="font-variation-settings: 'FILL' 1;">thumb_up</span>
<p class="font-body-2 text-body-2 text-on-surface-variant">Matches Halal diet and RM 5-10 budget.</p>
</div>
</div>
</article>
<!-- Card 2 -->
<article class="bg-white border border-border rounded-[12px] overflow-hidden flex flex-col shadow-sm hover:shadow-md transition-shadow duration-200">
<div class="relative h-[160px] w-full bg-grey-100">
<img alt="Kopitiam Setting" class="w-full h-full object-cover" data-alt="A cozy, sunlit modern Kopitiam cafe featuring marble-top tables and classic wooden chairs, elegantly updated for a contemporary urban audience. Morning sunlight streams through large windows, casting soft shadows across cups of traditional coffee and toast. The scene exudes a comforting, reliable warmth, utilizing a bright, clean color palette with subtle earthy and deep green accents to fit seamlessly into a premium lifestyle application." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDZ_RigpOCsVx4hyw08GoRe9PMJQuurHCI8avcpzJBCw6NLi00lm_lWz2a0qmOyaG6btcqGKAmd-0NFs1lrGBMENzts083gscJcVCOhRXWkioaJ1JVF9xE1SOTGgxGKCaj4nCgm7BPyY53IZUAy-JQMEkSjxGVs9z77EG1mTHnZGLZ2kMO_u7iweqmIvR4lk49jKUBpbTyiLiTfHi739VGf3H2OtcA1LT5fJTQJpizgJmMI9tx9y-Wgvkzb9xaEQFX5nAwaGdi-Z2Q"/>
<!-- Overlay Tags Top -->
<div class="absolute top-3 left-3 flex gap-2">
<span class="bg-primary-container text-white px-2 py-1 rounded-[4px] font-label text-label shadow-sm">Halal</span>
</div>
<div class="absolute top-3 right-3">
<span class="bg-white/90 backdrop-blur-sm text-on-surface px-2 py-1 rounded-[4px] font-label text-label font-semibold shadow-sm border border-white/20">RM 10-20</span>
</div>
<!-- Gradient Footer Overlay -->
<div class="absolute bottom-0 left-0 w-full bg-gradient-to-t from-black/80 to-transparent p-4 flex justify-between items-end">
<h2 class="font-headline-2 text-headline-2 text-white drop-shadow-md">Kopitiam Old Town</h2>
<span class="font-label text-label text-white/90 bg-black/40 px-2 py-1 rounded flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">directions_walk</span>
                            0.7km
                        </span>
</div>
</div>
<div class="p-4 space-y-stack-md">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<span class="bg-surface-variant text-on-surface px-2.5 py-1 rounded-full font-caption text-caption border border-border">Kopitiam</span>
<span class="font-caption text-caption text-grey-600 flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 0;">schedule</span>
                                9 min walk
                            </span>
</div>
<div class="flex items-center gap-1 text-warning font-label text-label">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
                            4.2 <span class="text-grey-400 font-caption text-caption">(85)</span>
</div>
</div>
<div class="bg-surface-container rounded-lg p-3 border border-border flex items-start gap-2">
<span class="material-symbols-outlined text-secondary text-[18px] shrink-0 mt-0.5" style="font-variation-settings: 'FILL' 1;">restaurant</span>
<p class="font-body-2 text-body-2 text-on-surface-variant">Matches Halal diet and cuisine preference.</p>
</div>
</div>
</article>
<!-- Card 3 -->
<article class="bg-white border border-border rounded-[12px] overflow-hidden flex flex-col shadow-sm hover:shadow-md transition-shadow duration-200">
<div class="relative h-[160px] w-full bg-grey-100">
<img alt="Sushi Restaurant" class="w-full h-full object-cover" data-alt="An immaculate, minimalist Japanese sushi restaurant interior viewed from a slightly elevated angle. Sleek, light wood counters contrast beautifully with dark, slate-grey stone accents and subtle, warm pendant lighting. The space feels pristine, healthy, and highly ordered, perfectly capturing a modern, premium dining experience suitable for an upscale urban lifestyle app interface. The lighting is bright and evenly distributed." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDZIHBV7NYao73Q1gM7Y_95XCOqqkY01DJa_996Cxxk6laR88pzJvDIqWSBT0jiu5qwVmpj2uTcjkX4CHqlfEqWHP4Nf1AFjl-R3eLVL3QE0XPe_hq4Grkslyi5gZCWl2gxwe020o8b5Z-9tcXdeR3R5T0nJbiqOT6b1BYBBpCObtReZgvo1uI-moL86D3HzltXt3NiZE4DN8AGrPFSJI4GdhtcrkC5mPIDfqem6pARIX7YjWWIwM5bb3Bk6t3_NgdVgckn2Zs46YU"/>
<!-- Overlay Tags Top -->
<div class="absolute top-3 left-3 flex gap-2">
<!-- No Halal tag here as per prompt -->
</div>
<div class="absolute top-3 right-3">
<span class="bg-white/90 backdrop-blur-sm text-on-surface px-2 py-1 rounded-[4px] font-label text-label font-semibold shadow-sm border border-white/20">RM 10-20</span>
</div>
<!-- Gradient Footer Overlay -->
<div class="absolute bottom-0 left-0 w-full bg-gradient-to-t from-black/80 to-transparent p-4 flex justify-between items-end">
<h2 class="font-headline-2 text-headline-2 text-white drop-shadow-md">Sushi King Sunway Pyramid</h2>
<span class="font-label text-label text-white/90 bg-black/40 px-2 py-1 rounded flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">directions_walk</span>
                            1.2km
                        </span>
</div>
</div>
<div class="p-4 space-y-stack-md">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<span class="bg-surface-variant text-on-surface px-2.5 py-1 rounded-full font-caption text-caption border border-border">Japanese</span>
<span class="font-caption text-caption text-grey-600 flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 0;">schedule</span>
                                15 min walk
                            </span>
</div>
<div class="flex items-center gap-1 text-warning font-label text-label">
<span class="material-symbols-outlined text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
                            4.0 <span class="text-grey-400 font-caption text-caption">(210)</span>
</div>
</div>
<div class="bg-surface-container rounded-lg p-3 border border-border flex items-start gap-2">
<span class="material-symbols-outlined text-secondary text-[18px] shrink-0 mt-0.5" style="font-variation-settings: 'FILL' 1;">ramen_dining</span>
<p class="font-body-2 text-body-2 text-on-surface-variant">Matches Japanese cuisine preference.</p>
</div>
</div>
</article>
<div class="flex items-center justify-center py-4">
<p class="font-caption text-caption text-grey-400 flex items-center gap-1">
<span class="material-symbols-outlined text-[12px]" style="font-variation-settings: 'FILL' 0;">info</span>
                     Ratings are crowdsourced from local community
                 </p>
</div>
</div>
</main>
<!-- BottomNavBar generated from JSON with 'Home' active -->
<nav class="md:hidden fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe shadow-[0_-4px_12px_rgba(0,0,0,0.08)] bg-surface dark:bg-surface-container-lowest z-50">
<a class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-semibold hover:opacity-80 scale-95 transition-transform duration-150 group" href="#">
<span class="material-symbols-outlined group-hover:bg-grey-100 p-1 rounded-full transition-colors" style="font-variation-settings: 'FILL' 1;">home</span>
<span class="font-label text-label mt-1">Home</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 group" href="#">
<span class="material-symbols-outlined group-hover:bg-grey-100 p-1 rounded-full transition-colors" style="font-variation-settings: 'FILL' 0;">explore</span>
<span class="font-label text-label mt-1">Explore</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 group" href="#">
<span class="material-symbols-outlined group-hover:bg-grey-100 p-1 rounded-full transition-colors" style="font-variation-settings: 'FILL' 0;">payments</span>
<span class="font-label text-label mt-1">Budget</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 group" href="#">
<span class="material-symbols-outlined group-hover:bg-grey-100 p-1 rounded-full transition-colors" style="font-variation-settings: 'FILL' 0;">person</span>
<span class="font-label text-label mt-1">Profile</span>
</a>
</nav>
<!-- Web Navigation Cluster (Hidden on Mobile) -->
<nav class="hidden md:flex fixed top-0 right-0 h-[56px] items-center gap-6 px-margin-tablet z-[60]">
<a class="font-button text-button text-primary border-b-2 border-primary py-4" href="#">Home</a>
<a class="font-button text-button text-grey-600 hover:text-on-surface transition-colors py-4" href="#">Explore</a>
<a class="font-button text-button text-grey-600 hover:text-on-surface transition-colors py-4" href="#">Budget</a>
<a class="font-button text-button text-grey-600 hover:text-on-surface transition-colors py-4" href="#">Profile</a>
</nav>
</body></html>

<!-- 2B — Restaurant Detail -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Restaurant Detail</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background antialiased relative min-h-screen pb-[80px]">
<!-- Hero Area -->
<div class="relative w-full h-[220px] bg-primary-light flex items-center justify-center overflow-hidden">
<!-- Background Image with prompt -->
<div class="absolute inset-0 bg-cover bg-center opacity-80" data-alt="A vibrant, modern lifestyle photography shot of a bustling Mamak stall setting in Malaysia. The image features a delicious spread of Nasi Kandar, including aromatic rice, rich curries, and perfectly fried chicken, arranged aesthetically on a clean, light-colored table. The lighting is bright and natural, creating a welcoming and appetizing atmosphere that fits perfectly within a health-conscious, smart city app interface. The color palette emphasizes rich, warm food tones against a clean, modern background." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuDat_liS47HyTi2YI0gRzTTnykVWdQxHJCwfUU4PzYy5gbkEnBScCxj4rnLy65j7y0q9SJm21J159EyOPh3sl916JKaeZgtDJPKXp7Y08z_lYUQSvS-cijzmdTxakrbZKdAurFIn-yJTdXlxcnPhdDyEaDPvG9-1gweWPExfG8PeqfdlBaVaYcXaHUPfRINEep-enc2tHLoj6EYhVZOaVz2Ua1mRhUvWYbJn7sGjt-uVJedVE-dsorfwqo7pEPtgN9zULQjsJR1Y9U');"></div>
<div class="absolute inset-0 bg-black/20"></div>
<span class="material-symbols-outlined text-white z-10" style="font-size: 40px; font-variation-settings: 'FILL' 1;">restaurant</span>
<!-- Top Controls -->
<div class="absolute top-4 left-4 right-4 flex justify-between items-start z-20 pt-safe">
<button aria-label="Go back" class="w-10 h-10 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm">
<span class="material-symbols-outlined text-on-surface" data-icon="arrow_back">arrow_back</span>
</button>
<button aria-label="Share" class="w-10 h-10 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm">
<span class="material-symbols-outlined text-on-surface" data-icon="share">share</span>
</button>
</div>
</div>
<!-- Body Content -->
<div class="bg-white px-margin-mobile pt-stack-lg rounded-t-xl -mt-4 relative z-20">
<!-- Header Info -->
<div class="mb-stack-lg">
<h1 class="font-headline-1 text-headline-1 text-on-surface mb-stack-sm">Restoran Nasi Kandar Ali</h1>
<p class="font-body-2 text-body-2 text-grey-600 mb-stack-md">Mamak · Kopitiam</p>
<div class="flex items-center gap-2">
<span class="bg-primary-container text-white px-2 py-1 rounded font-label text-label inline-block">Halal</span>
<span class="bg-surface-container-high text-on-surface px-2 py-1 rounded font-label text-label inline-block">RM 5-10</span>
</div>
</div>
<!-- Info Rows -->
<div class="space-y-stack-md mb-stack-lg border-b border-border pb-stack-lg">
<div class="flex items-start gap-3">
<span class="material-symbols-outlined text-grey-600 mt-0.5 text-[20px]" data-icon="location_on">location_on</span>
<span class="font-body-1 text-body-1 text-on-surface">No. 12, Jalan SS15/4</span>
</div>
<div class="flex items-start gap-3">
<span class="material-symbols-outlined text-success mt-0.5 text-[20px]" data-icon="schedule">schedule</span>
<span class="font-body-1 text-body-1 text-success">Open</span>
</div>
<div class="flex items-start gap-3">
<span class="material-symbols-outlined text-grey-600 mt-0.5 text-[20px]" data-icon="phone">phone</span>
<span class="font-body-1 text-body-1 text-on-surface">+60 3-1234 5678</span>
</div>
</div>
<!-- Why we picked this card -->
<div class="bg-[#F0FDF4] border border-[#D1FAE5] rounded-lg p-4 mb-stack-lg">
<h3 class="font-headline-3 text-headline-3 text-on-surface mb-stack-md flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-[18px]" data-icon="thumb_up" style="font-variation-settings: 'FILL' 1;">thumb_up</span>
                Why we picked this
            </h3>
<div class="flex flex-wrap gap-2">
<span class="bg-white text-on-surface px-2 py-1 rounded border border-border font-caption text-caption flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" data-icon="near_me">near_me</span> Proximity
                </span>
<span class="bg-white text-on-surface px-2 py-1 rounded border border-border font-caption text-caption flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" data-icon="restaurant">restaurant</span> Diet Match
                </span>
<span class="bg-white text-on-surface px-2 py-1 rounded border border-border font-caption text-caption flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]" data-icon="payments">payments</span> Budget Fit
                </span>
</div>
</div>
<!-- Menu Section -->
<div>
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-stack-md">Menu</h2>
<!-- Tabs -->
<div class="flex overflow-x-auto no-scrollbar gap-2 mb-stack-lg pb-1">
<button class="bg-primary text-white px-4 py-2 rounded-full font-button text-button whitespace-nowrap">All</button>
<button class="bg-surface-variant text-on-surface px-4 py-2 rounded-full font-button text-button whitespace-nowrap">Mains</button>
<button class="bg-surface-variant text-on-surface px-4 py-2 rounded-full font-button text-button whitespace-nowrap">Sides</button>
<button class="bg-surface-variant text-on-surface px-4 py-2 rounded-full font-button text-button whitespace-nowrap">Beverages</button>
</div>
<!-- Menu Items -->
<div class="space-y-4">
<div class="flex justify-between items-center pb-4 border-b border-border">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Nasi Kandar Special</h4>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Mixed curries with fried chicken</p>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">RM 8.50</span>
</div>
<div class="flex justify-between items-center pb-4 border-b border-border">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Roti Canai</h4>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Flaky flatbread with dhal</p>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">RM 2.00</span>
</div>
<div class="flex justify-between items-center pb-4 border-b border-border">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Teh Tarik</h4>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Pulled milk tea</p>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">RM 2.50</span>
</div>
<div class="flex justify-between items-center pb-4">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Maggi Goreng</h4>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Fried instant noodles</p>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">RM 5.50</span>
</div>
</div>
</div>
<!-- Bottom spacing for sticky footer -->
<div class="h-8"></div>
</div>
<!-- Sticky Footer -->
<div class="fixed bottom-0 left-0 w-full bg-white border-t border-border p-4 pb-safe z-50">
<button class="w-full bg-primary text-white h-12 rounded-[12px] font-button text-button flex items-center justify-center gap-2 shadow-sm">
<span class="material-symbols-outlined text-[20px]" data-icon="directions">directions</span>
            Get Directions
        </button>
<p class="text-center font-caption text-caption text-grey-600 mt-2">Opens Google Maps</p>
</div>
</body></html>

<!-- 1B — Home (Cook-In Visible) -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Urban Wellness - Home</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-1 antialiased min-h-screen flex flex-col pb-safe">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 bg-surface dark:bg-surface-dim border-b border-border dark:border-outline-variant transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<button class="text-primary dark:text-primary-fixed-dim hover:bg-grey-100 dark:hover:bg-tertiary-container p-2 rounded-full flex items-center justify-center transition-colors">
<span class="material-symbols-outlined" data-icon="menu">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary dark:text-primary-fixed-dim">Home</h1>
<button class="text-primary dark:text-primary-fixed-dim hover:bg-grey-100 dark:hover:bg-tertiary-container p-2 rounded-full flex items-center justify-center transition-colors">
<span class="material-symbols-outlined" data-icon="search">search</span>
</button>
</div>
</header>
<!-- Main Content Canvas -->
<main class="flex-grow pt-[calc(var(--spacing-input-height)+var(--spacing-stack-lg))] px-margin-mobile pb-[calc(80px+var(--spacing-stack-lg))] md:px-margin-tablet max-w-7xl mx-auto w-full space-y-stack-lg">
<!-- Welcome Section -->
<section class="flex flex-col gap-stack-sm">
<h2 class="font-display text-display text-on-background">Good Morning.</h2>
<p class="font-body-1 text-body-1 text-grey-600">Ready to explore healthy options today?</p>
</section>
<!-- Top Pick Card -->
<section class="flex flex-col gap-stack-md">
<div class="flex justify-between items-end">
<h3 class="font-headline-2 text-headline-2 text-on-background">Today's Top Pick</h3>
</div>
<div class="bg-white border border-border rounded-xl overflow-hidden shadow-sm flex flex-col">
<div class="h-48 w-full bg-surface-variant relative overflow-hidden" data-alt="A beautifully plated healthy salad bowl featuring fresh greens, cherry tomatoes, avocado slices, and grilled chicken breast. The dish is presented on a clean white ceramic bowl, resting on a light wooden table. The lighting is bright and natural, creating a fresh, appetizing, and modern aesthetic. The color palette emphasizes vibrant greens, crisp whites, and warm earthy tones." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBNGOfTXREwqjtp45ZnUS8xthHhI6y_JTV6Hz1FMpBvRZxQ_pn36bV24YmqoSXwtjBzBpGPxbfpbGFoFamANjw0EfhUNvHJGwOro2WOAvJOy613PpOUiq-1lWYlLkbn1qrqCLHus4t2PYbfPeEjHX1WQRTA9eDrnGcYCR0lrDEaTdwiOknj5yi64GNrMBtFKRAIQogwdNoavBc9ol3Lxj0su5V_kjZxkBTTPF6Y0cVb8lqm5RYNnh2UN3X0RLDhO2C6PnQuVreWJSE'); background-size: cover; background-position: center;">
<!-- Image via background for better fluid handling -->
<div class="absolute top-4 left-4 flex gap-2">
<span class="bg-primary-container text-white px-2 py-1 rounded-[4px] font-label text-label inline-block">Halal</span>
<span class="bg-success text-white px-2 py-1 rounded-[4px] font-label text-label inline-block">Healthy</span>
</div>
</div>
<div class="p-stack-lg flex flex-col gap-stack-sm">
<div class="flex justify-between items-start">
<h4 class="font-headline-2 text-headline-2 text-on-background">Green Bowl Cafe</h4>
<span class="font-headline-3 text-headline-3 text-primary flex items-center"><span class="material-symbols-outlined text-[16px] mr-1" data-icon="star" data-weight="fill" style="font-variation-settings: 'FILL' 1;">star</span> 4.8</span>
</div>
<p class="font-body-2 text-body-2 text-grey-600">Healthy Bowls • Salads • Smoothies</p>
<div class="flex items-center gap-2 mt-2">
<span class="material-symbols-outlined text-grey-400 text-[16px]" data-icon="location_on">location_on</span>
<span class="font-body-2 text-body-2 text-grey-600">1.2 km away • Est. RM 25.00</span>
</div>
</div>
</div>
</section>
<!-- Cook-In Section -->
<section class="flex flex-col gap-stack-md mt-stack-lg">
<div class="flex justify-between items-center">
<h3 class="font-headline-3 text-headline-3 text-on-background">Cook Something?</h3>
<a class="font-body-2 text-body-2 text-[#0E7490] hover:underline" href="#">Browse Recipes</a>
</div>
<div class="flex overflow-x-auto hide-scrollbar gap-gutter pb-2 -mx-margin-mobile px-margin-mobile md:mx-0 md:px-0">
<!-- Recipe Card 1 -->
<div class="min-w-[160px] w-[160px] bg-white border border-border rounded-xl flex flex-col shrink-0 overflow-hidden">
<div class="h-[100px] w-full bg-primary-light flex items-center justify-center">
<span class="material-symbols-outlined text-primary text-4xl" data-icon="restaurant">restaurant</span>
</div>
<div class="p-[12px] flex flex-col gap-stack-sm flex-grow">
<h4 class="font-headline-3 text-headline-3 text-on-background line-clamp-2">Nasi Goreng Kampung</h4>
<div class="flex items-center gap-2 mt-auto">
<span class="font-body-2 text-body-2 text-grey-600">30 min</span>
<span class="text-grey-400 text-[10px]">•</span>
<span class="font-body-2 text-body-2 text-grey-600">450 kcal</span>
</div>
<div class="flex flex-wrap gap-1 mt-1">
<span class="bg-primary-container text-white px-2 py-[2px] rounded-[4px] font-label text-label">Halal</span>
</div>
</div>
</div>
<!-- Recipe Card 2 -->
<div class="min-w-[160px] w-[160px] bg-white border border-border rounded-xl flex flex-col shrink-0 overflow-hidden">
<div class="h-[100px] w-full bg-primary-light flex items-center justify-center">
<span class="material-symbols-outlined text-primary text-4xl" data-icon="restaurant">restaurant</span>
</div>
<div class="p-[12px] flex flex-col gap-stack-sm flex-grow">
<h4 class="font-headline-3 text-headline-3 text-on-background line-clamp-2">Mee Goreng Mamak</h4>
<div class="flex items-center gap-2 mt-auto">
<span class="font-body-2 text-body-2 text-grey-600">25 min</span>
<span class="text-grey-400 text-[10px]">•</span>
<span class="font-body-2 text-body-2 text-grey-600">520 kcal</span>
</div>
<div class="flex flex-wrap gap-1 mt-1">
<span class="bg-primary-container text-white px-2 py-[2px] rounded-[4px] font-label text-label">Halal</span>
<span class="bg-secondary text-white px-2 py-[2px] rounded-[4px] font-label text-label">Vegan</span>
</div>
</div>
</div>
</div>
</section>
<!-- Nearby Restaurants List -->
<section class="flex flex-col gap-stack-md mt-stack-lg">
<div class="flex justify-between items-end">
<h3 class="font-headline-3 text-headline-3 text-on-background">Nearby Options</h3>
<a class="font-body-2 text-body-2 text-primary hover:underline" href="#">See All</a>
</div>
<div class="flex flex-col gap-stack-md">
<!-- Nearby Item 1 -->
<div class="bg-white border border-border rounded-xl p-stack-md flex gap-stack-md items-center">
<div class="w-16 h-16 rounded-lg bg-surface-variant flex-shrink-0 bg-cover bg-center" data-alt="A close up view of a modern restaurant interior focusing on a wooden table with a plate of gourmet food. The lighting is warm and inviting, suggesting a cozy dining experience. The background features slightly blurred elements of an urban eatery." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuAdFBKstKS7656h0pN6kOiyC1vRau6mI3PV9IX4lhx54PgaEAE7dVFTUlHrC-pA39IxXCpGjPKWPNp-S7b14MWX1dxP-OlF-OcQp9F8qkVA6wo_JFZ5DzmKy0JVp8faICCo0TcloJ1g3cLmBAo_QoawYVcVc3H8iVKECThHF0RwWsBQL_P0avcj_RFCBmmQgAWNY-MYyVLzCUQ3Q2eOiONgBEPBEPYRtj0-AGuD41T7hOuj01Umxg9VnL8Uwu0tswBdZS4JqWyM9FI');">
</div>
<div class="flex flex-col flex-grow">
<h4 class="font-headline-3 text-headline-3 text-on-background">Urban Eatery</h4>
<p class="font-body-2 text-body-2 text-grey-600">Local Cuisine • 0.8 km</p>
<div class="flex items-center gap-2 mt-1">
<span class="font-body-2 text-body-2 text-primary flex items-center"><span class="material-symbols-outlined text-[14px] mr-1" data-icon="star" data-weight="fill" style="font-variation-settings: 'FILL' 1;">star</span> 4.5</span>
<span class="bg-primary-container text-white px-2 py-[2px] rounded-[4px] font-label text-[9px]">Halal</span>
</div>
</div>
</div>
<!-- Nearby Item 2 -->
<div class="bg-white border border-border rounded-xl p-stack-md flex gap-stack-md items-center">
<div class="w-16 h-16 rounded-lg bg-surface-variant flex-shrink-0 bg-cover bg-center" data-alt="A vibrant, fresh salad bowl displayed elegantly on a rustic wooden table top. The bowl is filled with mixed greens, colorful vegetables, and a light dressing. The lighting is bright, natural daylight, creating a fresh, healthy, and inviting visual aesthetic." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCouBTVfzWAWMD0-nommlVYN8YkjoxKmHCGjOqdQQ32nLREVrNG38CYqf-GYIypBAwKTx6_gdaA9ghTRZe2JE5nFj4_bCLYRHPm_O_GOWy5CId0OcTuvE5JhQJ2ZXsxQUdEknrGjv9YIGr6UCJIKu4DzItNpgGAJBDHcHn-3tGPpo-jXP_oQ6aW1ymSM8PeixkYsqrFn_wFueKNrWeKGUDEbAMJYXtO22uC8Gi-yvIs1m_GK9c7DnGGoN7zWCBcwg2tsUf5l4tr80I');">
</div>
<div class="flex flex-col flex-grow">
<h4 class="font-headline-3 text-headline-3 text-on-background">Fresh Daily Salad</h4>
<p class="font-body-2 text-body-2 text-grey-600">Healthy • Vegan • 1.5 km</p>
<div class="flex items-center gap-2 mt-1">
<span class="font-body-2 text-body-2 text-primary flex items-center"><span class="material-symbols-outlined text-[14px] mr-1" data-icon="star" data-weight="fill" style="font-variation-settings: 'FILL' 1;">star</span> 4.9</span>
<span class="bg-secondary text-white px-2 py-[2px] rounded-[4px] font-label text-[9px]">Vegan</span>
</div>
</div>
</div>
</div>
</section>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe bg-surface dark:bg-surface-container-lowest shadow-[0_-4px_12px_rgba(0,0,0,0.08)] dark:shadow-none z-50 md:hidden">
<a class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-semibold scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1" data-icon="home" data-weight="fill" style="font-variation-settings: 'FILL' 1;">home</span>
<span class="font-label text-label">Home</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1" data-icon="explore">explore</span>
<span class="font-label text-label">Explore</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1" data-icon="payments">payments</span>
<span class="font-label text-label">Budget</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1" data-icon="person">person</span>
<span class="font-label text-label">Profile</span>
</a>
</nav>
<!-- Desktop Nav Placeholder (Hidden on Mobile) -->
<aside class="hidden md:flex fixed left-0 top-0 h-full w-72 z-[60] bg-surface dark:bg-surface-container-low shadow-xl flex-col py-4 border-r border-border">
<div class="px-6 py-4 border-b border-border mb-4">
<h2 class="font-headline-1 text-headline-1 text-primary dark:text-primary-fixed-dim font-bold">Urban Wellness</h2>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Account &amp; Preferences</p>
</div>
<nav class="flex-grow flex flex-col gap-2">
<a class="bg-primary-container text-on-primary-container rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300 ease-in-out" href="#">
<span class="material-symbols-outlined" data-icon="home" data-weight="fill" style="font-variation-settings: 'FILL' 1;">home</span>
<span class="font-body-1 text-body-1 font-semibold">Home</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300 ease-in-out" href="#">
<span class="material-symbols-outlined" data-icon="explore">explore</span>
<span class="font-body-1 text-body-1">Explore</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300 ease-in-out" href="#">
<span class="material-symbols-outlined" data-icon="payments">payments</span>
<span class="font-body-1 text-body-1">Budget</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300 ease-in-out" href="#">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-body-1 text-body-1">Profile</span>
</a>
</nav>
</aside>
</body></html>

<!-- 3A — Cook-In Feed -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Urban Wellness - Cook-In</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "tertiary": "#333f39",
                    "on-secondary": "#ffffff",
                    "surface-container-lowest": "#ffffff",
                    "grey-600": "#6B7280",
                    "primary": "#004532",
                    "secondary": "#006781",
                    "inverse-primary": "#8bd6b6",
                    "surface-variant": "#d9e3f6",
                    "surface-bright": "#f8f9ff",
                    "inverse-on-surface": "#eaf1ff",
                    "primary-container": "#065f46",
                    "surface-container-highest": "#d9e3f6",
                    "error": "#EF4444",
                    "outline": "#6f7973",
                    "primary-light": "#D1FAE5",
                    "on-primary-fixed": "#002116",
                    "tertiary-fixed-dim": "#bdcac1",
                    "secondary-container": "#8fdfff",
                    "surface-container": "#e6eeff",
                    "on-tertiary-fixed-variant": "#3e4943",
                    "surface-dim": "#d0dbed",
                    "warning": "#F59E0B",
                    "surface-container-low": "#eff4ff",
                    "surface": "#f8f9ff",
                    "primary-fixed-dim": "#8bd6b6",
                    "secondary-fixed": "#b9eaff",
                    "inverse-surface": "#27313f",
                    "outline-variant": "#bec9c2",
                    "on-primary": "#ffffff",
                    "on-error": "#ffffff",
                    "on-surface": "#121c2a",
                    "grey-400": "#9CA3AF",
                    "tertiary-fixed": "#d9e6dd",
                    "on-tertiary": "#ffffff",
                    "on-secondary-container": "#00647d",
                    "secondary-fixed-dim": "#81d1f0",
                    "tertiary-container": "#4a564f",
                    "surface-tint": "#1b6b51",
                    "error-container": "#ffdad6",
                    "success": "#10B981",
                    "background": "#f8f9ff",
                    "on-primary-fixed-variant": "#00513b",
                    "on-tertiary-fixed": "#131e19",
                    "on-surface-variant": "#3f4944",
                    "on-error-container": "#93000a",
                    "on-primary-container": "#8bd6b7",
                    "border": "#E5E7EB",
                    "surface-container-high": "#dee9fc",
                    "white": "#FFFFFF",
                    "on-background": "#121c2a",
                    "on-secondary-fixed-variant": "#004d62",
                    "on-tertiary-container": "#becac2",
                    "on-secondary-fixed": "#001f29",
                    "grey-100": "#F3F4F6",
                    "primary-fixed": "#a6f2d1"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "margin-tablet": "24px",
                    "stack-sm": "4px",
                    "gutter": "12px",
                    "stack-lg": "16px",
                    "margin-mobile": "16px",
                    "stack-md": "8px",
                    "input-height": "56px"
            },
            "fontFamily": {
                    "label": ["Inter"],
                    "button": ["Inter"],
                    "headline-1": ["Inter"],
                    "body-1": ["Inter"],
                    "headline-2": ["Inter"],
                    "body-2": ["Inter"],
                    "caption": ["Inter"],
                    "headline-3": ["Inter"],
                    "display": ["Inter"]
            },
            "fontSize": {
                    "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                    "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                    "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                    "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                    "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                    "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                    "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
            }
          }
        }
      }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background min-h-screen pb-24 md:pb-0 pt-[56px]">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border flex items-center justify-between px-margin-mobile h-input-height w-full transition-colors duration-200">
<button class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 text-primary transition-colors duration-200">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary">Cook-In</h1>
<button class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 text-primary transition-colors duration-200">
<span class="material-symbols-outlined" data-icon="tune">tune</span>
</button>
</header>
<main class="px-margin-mobile md:px-margin-tablet py-stack-lg max-w-4xl mx-auto space-y-stack-lg">
<!-- Search Bar -->
<div class="relative">
<span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-grey-600">search</span>
<input class="w-full h-input-height pl-12 pr-4 bg-white border border-border rounded-xl font-body-1 text-body-1 text-on-surface focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-shadow" placeholder="Search recipes or ingredients..." type="text"/>
</div>
<!-- Filter Chips -->
<div class="flex gap-gutter overflow-x-auto pb-2 scrollbar-hide">
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-primary-container text-white font-label text-label flex-shrink-0">All</button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container-low border border-border text-on-surface-variant font-label text-label flex-shrink-0">Halal</button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container-low border border-border text-on-surface-variant font-label text-label flex-shrink-0">Vegan</button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container-low border border-border text-on-surface-variant font-label text-label flex-shrink-0">Vegetarian</button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container-low border border-border text-on-surface-variant font-label text-label flex-shrink-0">Allergen-Free</button>
</div>
<!-- Section Header -->
<div class="flex items-center justify-between pt-stack-md">
<h2 class="font-headline-2 text-headline-2 text-on-background">Explore Recipes</h2>
<div class="flex items-center gap-2">
<span class="font-label text-label text-grey-600">Sort:</span>
<button class="font-label text-label text-primary flex items-center gap-1 bg-surface-container px-3 py-1.5 rounded-lg">
                    Newest
                    <span class="material-symbols-outlined text-[16px]">expand_more</span>
</button>
</div>
</div>
<!-- Recipe Grid -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-stack-lg">
<!-- Recipe Card 1 -->
<div class="bg-white border border-border rounded-xl overflow-hidden flex flex-col group cursor-pointer hover:shadow-md transition-shadow">
<div class="relative h-48 w-full">
<img alt="Nasi Goreng Kampung" class="w-full h-full object-cover" data-alt="A beautifully plated portion of Nasi Goreng Kampung (village-style fried rice) in a rustic ceramic bowl, topped with a perfectly fried sunny-side-up egg and crispy anchovies. The scene is lit with warm, inviting natural light, emphasizing a fresh, healthy, and appetizing culinary experience consistent with a modern, clean urban lifestyle app aesthetic." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBdGxCFEYco3-1wheuOXlbWzo9MbiI1jJqwOSt7yVh1yZk7cxF3JIWFFkMmDh9BPCdrqmVSh_x1h_DEpJA8fBjlVfgN8jIHBAum71EPdmgVKmFpXrAA4XLFyNoILYH6VQ1g6DIWU9nJxY2fkqQQmpuWA99fLSFndmCGgiX0TTGyTdciXjzd4OyRd6MPN70uDdbZiCiVj7PrYT2Q8MtnKBPyTRNOeXGP9Na5kTES28PyIV-SWBW6BRUbmBAQ3yY2ulQeCB3dADHzyKU"/>
<button class="absolute top-3 right-3 p-2 bg-white/80 backdrop-blur-sm rounded-full text-grey-600 hover:text-error transition-colors">
<span class="material-symbols-outlined text-[20px]" data-icon="favorite_border">favorite_border</span>
</button>
</div>
<div class="p-stack-lg flex-1 flex flex-col">
<div class="flex gap-2 mb-2">
<span class="px-2 py-1 rounded-[4px] bg-primary text-white font-label text-label">Halal</span>
</div>
<h3 class="font-headline-3 text-headline-3 text-on-surface mb-2 line-clamp-1">Nasi Goreng Kampung</h3>
<div class="flex items-center gap-4 mb-4 text-grey-600 font-caption text-caption">
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">timer</span> 25m
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">local_fire_department</span> 450 kcal
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">signal_cellular_alt</span> Medium
                        </div>
</div>
<div class="mt-auto flex items-center gap-2 pt-3 border-t border-border/50">
<img alt="Author" class="w-6 h-6 rounded-full" data-alt="Small circular avatar profile picture placeholder with a green background and white initials, representing a user profile in a clean, modern interface." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD6pHcUOdQP7c_YePJF5Oerek1VpGUbqkKnZD0YhQabqyebW0gAi389LNJgp77d0QhSp2hWGC9QeC3dATxRDoZAjqtqA_calXIBTknnXVP1Kbo-u5fM-rna4omPJk-QNX11362gZttobTAwPbvRMKSF8f0LI0ctRm69MBfcWZpRwmRCbquJnaqdcGmvaWA2k5HoFtJa3jRj-plXupSUHd7gBCMCjq3aI0AtY48qv-4Kf7MS6x-nLaWKpoWT8w-luQgC2kChpLfFCWA"/>
<span class="font-caption text-caption text-grey-600">By Chef Wan</span>
</div>
</div>
</div>
<!-- Recipe Card 2 -->
<div class="bg-white border border-border rounded-xl overflow-hidden flex flex-col group cursor-pointer hover:shadow-md transition-shadow">
<div class="relative h-48 w-full">
<img alt="Mee Goreng Mamak" class="w-full h-full object-cover" data-alt="A vibrant plate of Mee Goreng Mamak (spicy fried noodles) with tofu, potatoes, and fresh garnishes, presented on a minimalist wooden table. The lighting is bright and soft, creating a fresh, appetizing, and healthy mood suitable for a modern health-conscious lifestyle application." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD-gxcF5VPnuAg1kDKGaMxKuq77ILY8NDXfs-Umm_qp3j5KyVS1FQL9jVa0OtJROO5CyOO3nxxQJ4cSM63HxcS_y1F7x6-ayZcmXy0MXx2SXdJ802fgJAZMjNGViiz1tRl-6hZBbeJNmyeWtLG4iDqUz0ccnASb1fom6phULiQvasZmF4MlCh-hx_aRtkV7O28a6LG2DgbZ3m4cMVHR6xfDFarfakX54Un0RKccsLlvZCU_I-bROITsoFhy83wPYgH4oDpiRLjX1lU"/>
<button class="absolute top-3 right-3 p-2 bg-white/80 backdrop-blur-sm rounded-full text-grey-600 hover:text-error transition-colors">
<span class="material-symbols-outlined text-[20px]" data-icon="favorite_border">favorite_border</span>
</button>
</div>
<div class="p-stack-lg flex-1 flex flex-col">
<div class="flex flex-wrap gap-2 mb-2">
<span class="px-2 py-1 rounded-[4px] bg-primary text-white font-label text-label">Halal</span>
<span class="px-2 py-1 rounded-[4px] bg-secondary text-white font-label text-label">Vegan</span>
</div>
<h3 class="font-headline-3 text-headline-3 text-on-surface mb-2 line-clamp-1">Mee Goreng Mamak</h3>
<div class="flex items-center gap-4 mb-4 text-grey-600 font-caption text-caption">
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">timer</span> 20m
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">local_fire_department</span> 380 kcal
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">signal_cellular_alt</span> Easy
                        </div>
</div>
<div class="mt-auto flex items-center gap-2 pt-3 border-t border-border/50">
<img alt="Author" class="w-6 h-6 rounded-full" data-alt="Small circular avatar profile picture placeholder with a teal background and white initials, representing a user profile in a clean, modern interface." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCT498BBGU5pgYdx6GfGapTs97opKLHI2vYFl1ndcx-9MyTSSnmljpJa_IOfg3ws4Mdex1rRmP67Y-fofbDFzP-BiArfs4LYFKDgnrCl8b4rEuedBkjibae8sCTDlOc0uL-sOJxWEfOLglFXocrx0E6wqwfeFq7VLbIK5oJvVqMZsUGAKCjXtYcGItixNKd3bZ7-nztRb5NdG4R_1GfHp7uzn4SakIw3ZKmOnqjP73j3XEKOPCAa751xMWnrvejShCdfG7Jgd_cyTc"/>
<span class="font-caption text-caption text-grey-600">By Aisha</span>
</div>
</div>
</div>
<!-- Recipe Card 3 -->
<div class="bg-white border border-border rounded-xl overflow-hidden flex flex-col group cursor-pointer hover:shadow-md transition-shadow">
<div class="relative h-48 w-full">
<img alt="Smoothie Bowl" class="w-full h-full object-cover" data-alt="A bright, colorful smoothie bowl topped with neatly arranged fresh berries, kiwi slices, chia seeds, and coconut flakes in a clean white ceramic bowl. The scene is brightly lit with high-key lighting, conveying a modern, energetic, and ultra-healthy lifestyle aesthetic perfectly aligned with a wellness application." src="https://lh3.googleusercontent.com/aida-public/AB6AXuD10LAokC-iO-OHTz-JPzAkp4rfLVA4s3FC0vgEuMy7cclNvJB1nkbm1NoLP1UfZgsnU8iSZ_a9xN9Vxrn5oRt7ofy7sfcJHXFrCrt8yXTeyNntP29ZVVXvbCNggnE-VMAkGJ2zvLgJxNL_Ttde6Li5g2LCbnSfpS4j7j3O021MMqfCQv2ydbdCKJm77mhGQwCNL7QzZrtyThXqnrv_YaKgIZA8j7CsATCExO-PBM67BLydXEjH_-k0hJMRr7Np8rYRUL3SmKKgPJ4"/>
<button class="absolute top-3 right-3 p-2 bg-white/80 backdrop-blur-sm rounded-full text-grey-600 hover:text-error transition-colors">
<span class="material-symbols-outlined text-[20px]" data-icon="favorite_border">favorite_border</span>
</button>
</div>
<div class="p-stack-lg flex-1 flex flex-col">
<div class="flex flex-wrap gap-2 mb-2">
<span class="px-2 py-1 rounded-[4px] bg-secondary text-white font-label text-label">Vegan</span>
<span class="px-2 py-1 rounded-[4px] bg-success text-white font-label text-label">Vegetarian</span>
</div>
<h3 class="font-headline-3 text-headline-3 text-on-surface mb-2 line-clamp-1">Tropical Smoothie Bowl</h3>
<div class="flex items-center gap-4 mb-4 text-grey-600 font-caption text-caption">
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">timer</span> 10m
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">local_fire_department</span> 250 kcal
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">signal_cellular_alt</span> Easy
                        </div>
</div>
<div class="mt-auto flex items-center gap-2 pt-3 border-t border-border/50">
<img alt="Author" class="w-6 h-6 rounded-full" data-alt="Small circular avatar profile picture placeholder with an emerald green background and white initials, representing a user profile in a clean, modern interface." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDYz2aCch-yEbwqYc779M4QHXFduu-5ryDcN34wIv03NaFKw9z_UUx2weX66D0BO1H481QuYlDFMqfFM_gb8Z8l9UiBKKAyUwgUhmngL1eTB1Z3qyQJPTWpvL_TO9ts28QZD9Dyvi7nangQ-wRmPNLCn-hgxCyewfAN3DjgpES2XkLJFMWoBUcSDBTnU6gf2Y_F3Pb0_z4jpaBJIl3c0q63aXzfw0E1yAMMv7RxzwsT7rSQU0pP7er3P32sSzNz3qAOFUzE6SSEuI0"/>
<span class="font-caption text-caption text-grey-600">By Urban Wellness</span>
</div>
</div>
</div>
<!-- Recipe Card 4 -->
<div class="bg-white border border-border rounded-xl overflow-hidden flex flex-col group cursor-pointer hover:shadow-md transition-shadow">
<div class="relative h-48 w-full">
<img alt="Roti John" class="w-full h-full object-cover" data-alt="A close-up of a freshly made Roti John (omelette sandwich) cut into neat sections, showing the juicy meat and egg filling, garnished with fresh herbs and a drizzle of sauce. The lighting is warm and appetizing, highlighting the texture of the bread and the rich colors of the filling, fitting for a premium food and lifestyle app." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDKscAwLmQXD_cC49QqCo6TrwgTm4CRiOszfYqOQQImZsD2Ii5MEuIvV3bA3kyIxG6JbKHYiHq__KJGCTezxNXPEHZnqvDrlgtEm9qz4q6z5dMPqptrGykdCfHA55cFMfKUyrmyiJm3yl1XdZ7kujY1Z4SHaniO7A91uEbhJ8vSDcw01T2qDPz1Ee_-GHauGskOzZCrggv_xZdLg_fdWPtTE81FVfzedxtIJYs2XXzyP35wiKOACT2IPezp3-k9SIDfZGMevzLBnq4"/>
<button class="absolute top-3 right-3 p-2 bg-white/80 backdrop-blur-sm rounded-full text-grey-600 hover:text-error transition-colors">
<span class="material-symbols-outlined text-[20px]" data-icon="favorite_border">favorite_border</span>
</button>
</div>
<div class="p-stack-lg flex-1 flex flex-col">
<div class="flex gap-2 mb-2">
<span class="px-2 py-1 rounded-[4px] bg-primary text-white font-label text-label">Halal</span>
</div>
<h3 class="font-headline-3 text-headline-3 text-on-surface mb-2 line-clamp-1">Classic Roti John</h3>
<div class="flex items-center gap-4 mb-4 text-grey-600 font-caption text-caption">
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">timer</span> 15m
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">local_fire_department</span> 420 kcal
                        </div>
<div class="flex items-center gap-1">
<span class="material-symbols-outlined text-[14px]">signal_cellular_alt</span> Easy
                        </div>
</div>
<div class="mt-auto flex items-center gap-2 pt-3 border-t border-border/50">
<img alt="Author" class="w-6 h-6 rounded-full" data-alt="Small circular avatar profile picture placeholder with a dark tertiary background and white initials, representing a user profile in a clean, modern interface." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDeof9nQCEHRBE7Kl74fg60tis9vjG5tp123dynlpc0-TQOVDqUK-RH6Ssw5j8kle4rn913XwyTKNl5veOVrnjUaTDV7hpiF88VkhqZy_jUTzxN3taH7xRSt9KdGDGGTeAE-cyC2IqVdqpLeC9ZTrRlb2RDs0zlFsel5J57DGtee42knxxAws1g1Wjc2SorEUqcJ3qeEXwLk1CXLM6BZ3-1Md62jTK7DWJW0Lj71LT07Bsd1zPwT9Z-2lEczzRmQvQN5G48HcIXLO4"/>
<span class="font-caption text-caption text-grey-600">By KL Street Food</span>
</div>
</div>
</div>
</div>
</main>
<!-- FAB -->
<button class="fixed bottom-[88px] right-margin-mobile w-14 h-14 bg-primary-container text-white rounded-[16px] shadow-lg flex items-center justify-center hover:bg-primary-container/90 transition-colors z-40 hidden md:flex">
<span class="material-symbols-outlined text-[24px]" data-icon="add">add</span>
</button>
<button class="fixed bottom-[88px] right-margin-mobile w-14 h-14 bg-primary-container text-white rounded-[16px] shadow-lg flex items-center justify-center hover:bg-primary-container/90 transition-colors z-40 md:hidden">
<span class="material-symbols-outlined text-[24px]" data-icon="add">add</span>
</button>
<!-- BottomNavBar -->
<nav class="md:hidden fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe shadow-[0_-4px_12px_rgba(0,0,0,0.08)] bg-surface z-50">
<button class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined mb-1" data-icon="home" data-weight="fill" style="font-variation-settings: 'FILL' 1;">home</span>
<span class="font-label text-label">Home</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined mb-1" data-icon="explore">explore</span>
<span class="font-label text-label">Explore</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined mb-1" data-icon="payments">payments</span>
<span class="font-label text-label">Budget</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined mb-1" data-icon="person">person</span>
<span class="font-label text-label">Profile</span>
</button>
</nav>
</body></html>

<!-- 3B — Recipe Detail -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport"/>
<title>Recipe Detail - Nasi Goreng Kampung</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "tertiary": "#333f39",
                    "on-secondary": "#ffffff",
                    "surface-container-lowest": "#ffffff",
                    "grey-600": "#6B7280",
                    "primary": "#004532",
                    "secondary": "#006781",
                    "inverse-primary": "#8bd6b6",
                    "surface-variant": "#d9e3f6",
                    "surface-bright": "#f8f9ff",
                    "inverse-on-surface": "#eaf1ff",
                    "primary-container": "#065f46",
                    "surface-container-highest": "#d9e3f6",
                    "error": "#EF4444",
                    "outline": "#6f7973",
                    "primary-light": "#D1FAE5",
                    "on-primary-fixed": "#002116",
                    "tertiary-fixed-dim": "#bdcac1",
                    "secondary-container": "#8fdfff",
                    "surface-container": "#e6eeff",
                    "on-tertiary-fixed-variant": "#3e4943",
                    "surface-dim": "#d0dbed",
                    "warning": "#F59E0B",
                    "surface-container-low": "#eff4ff",
                    "surface": "#f8f9ff",
                    "primary-fixed-dim": "#8bd6b6",
                    "secondary-fixed": "#b9eaff",
                    "inverse-surface": "#27313f",
                    "outline-variant": "#bec9c2",
                    "on-primary": "#ffffff",
                    "on-error": "#ffffff",
                    "on-surface": "#121c2a",
                    "grey-400": "#9CA3AF",
                    "tertiary-fixed": "#d9e6dd",
                    "on-tertiary": "#ffffff",
                    "on-secondary-container": "#00647d",
                    "secondary-fixed-dim": "#81d1f0",
                    "tertiary-container": "#4a564f",
                    "surface-tint": "#1b6b51",
                    "error-container": "#ffdad6",
                    "success": "#10B981",
                    "background": "#f8f9ff",
                    "on-primary-fixed-variant": "#00513b",
                    "on-tertiary-fixed": "#131e19",
                    "on-surface-variant": "#3f4944",
                    "on-error-container": "#93000a",
                    "on-primary-container": "#8bd6b7",
                    "border": "#E5E7EB",
                    "surface-container-high": "#dee9fc",
                    "white": "#FFFFFF",
                    "on-background": "#121c2a",
                    "on-secondary-fixed-variant": "#004d62",
                    "on-tertiary-container": "#becac2",
                    "on-secondary-fixed": "#001f29",
                    "grey-100": "#F3F4F6",
                    "primary-fixed": "#a6f2d1"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "margin-tablet": "24px",
                    "stack-sm": "4px",
                    "gutter": "12px",
                    "stack-lg": "16px",
                    "margin-mobile": "16px",
                    "stack-md": "8px",
                    "input-height": "56px"
            },
            "fontFamily": {
                    "label": ["Inter"],
                    "button": ["Inter"],
                    "headline-1": ["Inter"],
                    "body-1": ["Inter"],
                    "headline-2": ["Inter"],
                    "body-2": ["Inter"],
                    "caption": ["Inter"],
                    "headline-3": ["Inter"],
                    "display": ["Inter"]
            },
            "fontSize": {
                    "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                    "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                    "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                    "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                    "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                    "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                    "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
            }
          }
        }
      }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background antialiased pb-12">
<!-- Top Navigation (Task-Focused / Transactional -> No bottom Nav, has back button) -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<button class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<div class="flex gap-2">
<button class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="favorite_border">favorite_border</span>
</button>
<button class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="share">share</span>
</button>
</div>
</div>
</header>
<main class="pt-[56px]">
<!-- Hero Section -->
<div class="relative w-full h-[200px] bg-grey-100 flex items-center justify-center">
<img alt="Nasi Goreng Kampung" class="absolute inset-0 w-full h-full object-cover" data-alt="A highly detailed top-down view of Nasi Goreng Kampung served on a traditional rustic plate. The fried rice is rich in color, garnished with crispy anchovies, fresh cucumber slices, and a perfectly cooked sunny-side-up egg on top. The lighting is warm and inviting, highlighting the textures of the dish against a clean, modern table setting. The overall aesthetic feels healthy, appetizing, and culturally authentic, fitting a high-end food application." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCvLzHPxM4_mf2jh_aztGQp1cwCtSMlyjVg08R57dWyeXYOC4UaTQKX9m4pLPAm1ffEH4EICN5BxYmV3ATvWxgvZSZGw6joFjfyClfxHNqaCcfUPUr8BjL-UcLJ7pnmskOktoXv54jNZBhZjGq0N-Kxy9WVGPgPlp3_g3cDkS0tiiToHrEA33twvNA3DKnlS4RBd94RmpY0vlKDQVi5_qfWBQ3C-1qy4sHHRMDgGDD-TWrv9ddspT3P01imtSAfI3Mm_HXKuXVMOn8"/>
<!-- Fallback overlay if image fails or loading -->
<div class="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent"></div>
</div>
<div class="px-margin-mobile mt-stack-lg space-y-stack-lg">
<!-- Header Info -->
<div class="space-y-stack-sm">
<div class="flex gap-2 mb-2">
<span class="bg-primary-container text-white px-2 py-1 rounded-[4px] font-label text-label">Halal</span>
<span class="bg-warning text-white px-2 py-1 rounded-[4px] font-label text-label">Spicy</span>
</div>
<h1 class="font-headline-1 text-headline-1 text-on-surface">Nasi Goreng Kampung</h1>
<p class="font-body-1 text-body-1 text-grey-600">By Ahmad Razali</p>
</div>
<!-- Quick Stats -->
<div class="grid grid-cols-3 gap-3">
<div class="bg-surface-container-lowest border border-border rounded-lg p-3 flex flex-col items-center justify-center">
<span class="material-symbols-outlined text-primary mb-1" data-icon="schedule" style="font-variation-settings: 'FILL' 0;">schedule</span>
<span class="font-button text-button text-on-surface">30 min</span>
</div>
<div class="bg-surface-container-lowest border border-border rounded-lg p-3 flex flex-col items-center justify-center">
<span class="material-symbols-outlined text-primary mb-1" data-icon="local_fire_department" style="font-variation-settings: 'FILL' 0;">local_fire_department</span>
<span class="font-button text-button text-on-surface">450 kcal</span>
</div>
<div class="bg-surface-container-lowest border border-border rounded-lg p-3 flex flex-col items-center justify-center">
<span class="material-symbols-outlined text-primary mb-1" data-icon="restaurant" style="font-variation-settings: 'FILL' 0;">restaurant</span>
<span class="font-button text-button text-on-surface">2 servings</span>
</div>
</div>
<div class="h-px bg-border w-full"></div>
<!-- Ingredients -->
<section class="space-y-stack-md">
<div class="flex justify-between items-end mb-4">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Ingredients</h2>
<span class="font-body-2 text-body-2 text-grey-600">6 items</span>
</div>
<div class="space-y-3">
<!-- Ingredient 1 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Cooked Rice</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 2.00 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">2 cups</span>
</div>
<!-- Ingredient 2 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Eggs</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 1.20 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">2 pcs</span>
</div>
<!-- Ingredient 3 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Anchovies (Ikan Bilis)</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 3.50 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">50g</span>
</div>
<!-- Ingredient 4 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Water Spinach (Kangkung)</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 1.50 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">1 bunch</span>
</div>
<!-- Ingredient 5 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Bird's Eye Chilli</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 0.80 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">4 pcs</span>
</div>
<!-- Ingredient 6 -->
<div class="flex items-center justify-between p-3 bg-surface-container-lowest border border-border rounded-lg">
<div class="flex items-center gap-3">
<input class="w-5 h-5 rounded border-grey-400 text-primary focus:ring-primary" type="checkbox"/>
<div>
<p class="font-button text-button text-on-surface">Garlic &amp; Shallots</p>
<p class="font-body-2 text-body-2 text-grey-600">Jaya Grocer · RM 1.00 est.</p>
</div>
</div>
<span class="font-body-1 text-body-1 text-on-surface">Paste</span>
</div>
</div>
<button class="w-full h-12 bg-primary-container text-white rounded-[12px] font-button text-button mt-4 flex items-center justify-center gap-2">
<span class="material-symbols-outlined" data-icon="store">store</span>
                    Find Grocery Store
                </button>
</section>
<div class="h-px bg-border w-full"></div>
<!-- Steps -->
<section class="space-y-stack-md pb-8">
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-4">Steps</h2>
<div class="space-y-4">
<!-- Step 1 (Collapsed) -->
<div class="flex gap-4 opacity-70">
<div class="flex-shrink-0 w-8 h-8 rounded-full bg-surface-variant flex items-center justify-center font-button text-button text-primary">1</div>
<div class="pt-1">
<p class="font-button text-button text-on-surface">Prepare ingredients</p>
</div>
</div>
<!-- Step 2 (Expanded) -->
<div class="flex gap-4 bg-surface-container-low p-4 rounded-lg border border-border">
<div class="flex-shrink-0 w-8 h-8 rounded-full bg-primary-container flex items-center justify-center font-button text-button text-white">2</div>
<div class="pt-1 space-y-2">
<p class="font-button text-button text-on-surface">Fry garlic and chilli</p>
<p class="font-body-1 text-body-1 text-on-surface-variant">Heat oil in a wok over medium-high heat. Add the pounded paste of garlic, shallots, and bird's eye chilies. Stir-fry until fragrant and golden brown, ensuring it doesn't burn.</p>
</div>
</div>
<!-- Step 3 (Collapsed) -->
<div class="flex gap-4">
<div class="flex-shrink-0 w-8 h-8 rounded-full bg-surface-variant flex items-center justify-center font-button text-button text-primary">3</div>
<div class="pt-1">
<p class="font-button text-button text-on-surface">Add rice and mix</p>
</div>
</div>
<!-- Step 4 (Collapsed) -->
<div class="flex gap-4">
<div class="flex-shrink-0 w-8 h-8 rounded-full bg-surface-variant flex items-center justify-center font-button text-button text-primary">4</div>
<div class="pt-1">
<p class="font-button text-button text-on-surface">Garnish and serve</p>
</div>
</div>
</div>
</section>
</div>
</main>
</body></html>

<!-- 3D — Grocery Match -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Find Ingredients - Grocery Match Screen</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style type="text/tailwindcss">
        @layer utilities {
            .glass-card {
                @apply bg-white/80 backdrop-blur-md border border-white/20 shadow-lg;
            }
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background min-h-screen text-on-background pb-8 antialiased">
<!-- Top App Bar -->
<header class="bg-surface border-b border-border fixed top-0 w-full z-50 h-[56px] flex items-center justify-between px-margin-mobile">
<button aria-label="Go Back" class="flex items-center justify-center p-2 rounded-full hover:bg-grey-100 transition-colors text-primary">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="font-headline-1 text-headline-1 text-primary flex-1 text-center font-bold absolute left-1/2 -translate-x-1/2 w-max">Find Ingredients</h1>
<div class="w-10"></div> <!-- Placeholder for balance -->
</header>
<main class="pt-[72px] px-margin-mobile md:px-margin-tablet max-w-3xl mx-auto space-y-stack-lg">
<!-- Recipe Summary Card -->
<section class="bg-surface-container-lowest border border-border rounded-[12px] p-stack-lg shadow-sm flex items-start gap-stack-md relative overflow-hidden">
<div class="absolute top-0 right-0 w-24 h-24 bg-primary-light rounded-bl-full -z-10 opacity-50"></div>
<img alt="Healthy Salad Bowl" class="w-16 h-16 rounded-lg object-cover border border-border shrink-0" data-alt="A vibrant, fresh salad bowl filled with mixed greens, avocado slices, cherry tomatoes, and quinoa. The lighting is bright and airy, typical of a modern health-conscious kitchen. The colors are popping, particularly the greens and reds, conveying freshness and vitality in a modern urban setting." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDaEFZ24KgCnjMzk7CLbHfAN3nuegQIdpR0oKsi6499V4Ou4z4LMvJfTc2O0SxGVsDa2Fn0zmxDB-r0XEGTtu4DlNXPJeICgAqZWQ_rg0Efo2fEZCNevHgeBYkRgGKZImLe0sLDSiydGx5Vw6G_uA2LN4-uu4wiZaO8oLKg2ESGx6pqxaWvPd8pixsohFMw4cYHSsHgMmHzBjlVXBiuQlo0A0a9TVWA4LzMJCPN2hs2Uuzt_7XpjkOmK5_z7LcHtYkLa0ezsGBgcTk"/>
<div>
<h2 class="font-headline-2 text-headline-2 text-on-surface">Avocado Quinoa Salad</h2>
<p class="font-body-2 text-body-2 text-grey-600 mt-1">Requires 6 specific ingredients.</p>
</div>
<div class="ml-auto flex flex-col items-end">
<span class="inline-flex items-center gap-1 bg-primary-container text-white px-2 py-1 rounded-[4px] font-label text-label">
<span class="material-symbols-outlined text-[14px]">eco</span> Vegan
                </span>
</div>
</section>
<!-- Best Match Store Card -->
<section class="mt-8">
<h3 class="font-headline-3 text-headline-3 text-grey-600 mb-stack-md flex items-center gap-2">
<span class="material-symbols-outlined text-success" data-icon="verified">verified</span> Best Match
            </h3>
<div class="bg-surface-container-lowest border-2 border-success rounded-[12px] p-stack-lg shadow-sm relative overflow-hidden">
<div class="flex justify-between items-start mb-stack-md">
<div>
<h4 class="font-headline-2 text-headline-2 text-on-surface">Jaya Grocer</h4>
<p class="font-body-2 text-body-2 text-grey-600 flex items-center gap-1 mt-1">
<span class="material-symbols-outlined text-[14px]">location_on</span> 1.2 km away
                        </p>
</div>
<div class="text-right">
<span class="font-headline-2 text-headline-2 text-primary block">RM 8.40</span>
<span class="font-caption text-caption text-grey-600">est. cost</span>
</div>
</div>
<!-- Match Progress -->
<div class="mb-stack-lg">
<div class="flex justify-between font-label text-label text-on-surface mb-1">
<span>Items Available</span>
<span class="text-success font-semibold">6 / 6 (100%)</span>
</div>
<div class="w-full bg-surface-container-high rounded-full h-2.5 overflow-hidden">
<div class="bg-success h-2.5 rounded-full" style="width: 100%"></div>
</div>
</div>
<button class="w-full bg-primary-container text-white rounded-[12px] h-[48px] font-button text-button flex justify-center items-center gap-2 hover:opacity-90 transition-opacity">
<span class="material-symbols-outlined" data-icon="storefront">storefront</span>
                    View Store &amp; Add to List
                </button>
</div>
</section>
<!-- Other Nearby Stores -->
<section class="mt-8">
<h3 class="font-headline-3 text-headline-3 text-grey-600 mb-stack-md">Other Nearby Stores</h3>
<div class="space-y-stack-md">
<!-- Store 1 -->
<div class="bg-surface-container-lowest border border-border rounded-[12px] p-stack-lg hover:bg-surface-container-low transition-colors cursor-pointer">
<div class="flex justify-between items-center mb-stack-md">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">99 Speedmart</h4>
<p class="font-body-2 text-body-2 text-grey-600 flex items-center gap-1 mt-1">
<span class="material-symbols-outlined text-[14px]">location_on</span> 0.5 km away
                            </p>
</div>
<div class="text-right">
<span class="font-headline-3 text-headline-3 text-on-surface">RM 5.20</span>
<span class="font-caption text-caption text-grey-600 block">est. cost</span>
</div>
</div>
<div>
<div class="flex justify-between font-label text-label text-grey-600 mb-1">
<span>Items Available</span>
<span class="font-semibold text-warning">4 / 6 (67%)</span>
</div>
<div class="w-full bg-surface-container-high rounded-full h-2 overflow-hidden">
<div class="bg-warning h-2 rounded-full" style="width: 67%"></div>
</div>
</div>
</div>
<!-- Store 2 -->
<div class="bg-surface-container-lowest border border-border rounded-[12px] p-stack-lg hover:bg-surface-container-low transition-colors cursor-pointer">
<div class="flex justify-between items-center mb-stack-md">
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Village Grocer</h4>
<p class="font-body-2 text-body-2 text-grey-600 flex items-center gap-1 mt-1">
<span class="material-symbols-outlined text-[14px]">location_on</span> 2.1 km away
                            </p>
</div>
<div class="text-right">
<span class="font-headline-3 text-headline-3 text-on-surface">RM 7.80</span>
<span class="font-caption text-caption text-grey-600 block">est. cost</span>
</div>
</div>
<div>
<div class="flex justify-between font-label text-label text-grey-600 mb-1">
<span>Items Available</span>
<span class="font-semibold text-primary">5 / 6 (83%)</span>
</div>
<div class="w-full bg-surface-container-high rounded-full h-2 overflow-hidden">
<div class="bg-primary h-2 rounded-full" style="width: 83%"></div>
</div>
</div>
</div>
</div>
</section>
</main>
</body></html>

<!-- 4A — Shopping List -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>My List - Shopping</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "tertiary": "#333f39",
                      "on-secondary": "#ffffff",
                      "surface-container-lowest": "#ffffff",
                      "grey-600": "#6B7280",
                      "primary": "#004532",
                      "secondary": "#006781",
                      "inverse-primary": "#8bd6b6",
                      "surface-variant": "#d9e3f6",
                      "surface-bright": "#f8f9ff",
                      "inverse-on-surface": "#eaf1ff",
                      "primary-container": "#065f46",
                      "surface-container-highest": "#d9e3f6",
                      "error": "#EF4444",
                      "outline": "#6f7973",
                      "primary-light": "#D1FAE5",
                      "on-primary-fixed": "#002116",
                      "tertiary-fixed-dim": "#bdcac1",
                      "secondary-container": "#8fdfff",
                      "surface-container": "#e6eeff",
                      "on-tertiary-fixed-variant": "#3e4943",
                      "surface-dim": "#d0dbed",
                      "warning": "#F59E0B",
                      "surface-container-low": "#eff4ff",
                      "surface": "#f8f9ff",
                      "primary-fixed-dim": "#8bd6b6",
                      "secondary-fixed": "#b9eaff",
                      "inverse-surface": "#27313f",
                      "outline-variant": "#bec9c2",
                      "on-primary": "#ffffff",
                      "on-error": "#ffffff",
                      "on-surface": "#121c2a",
                      "grey-400": "#9CA3AF",
                      "tertiary-fixed": "#d9e6dd",
                      "on-tertiary": "#ffffff",
                      "on-secondary-container": "#00647d",
                      "secondary-fixed-dim": "#81d1f0",
                      "tertiary-container": "#4a564f",
                      "surface-tint": "#1b6b51",
                      "error-container": "#ffdad6",
                      "success": "#10B981",
                      "background": "#f8f9ff",
                      "on-primary-fixed-variant": "#00513b",
                      "on-tertiary-fixed": "#131e19",
                      "on-surface-variant": "#3f4944",
                      "on-error-container": "#93000a",
                      "on-primary-container": "#8bd6b7",
                      "border": "#E5E7EB",
                      "surface-container-high": "#dee9fc",
                      "white": "#FFFFFF",
                      "on-background": "#121c2a",
                      "on-secondary-fixed-variant": "#004d62",
                      "on-tertiary-container": "#becac2",
                      "on-secondary-fixed": "#001f29",
                      "grey-100": "#F3F4F6",
                      "primary-fixed": "#a6f2d1"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "margin-tablet": "24px",
                      "stack-sm": "4px",
                      "gutter": "12px",
                      "stack-lg": "16px",
                      "margin-mobile": "16px",
                      "stack-md": "8px",
                      "input-height": "56px"
              },
              "fontFamily": {
                      "label": [
                              "Inter"
                      ],
                      "button": [
                              "Inter"
                      ],
                      "headline-1": [
                              "Inter"
                      ],
                      "body-1": [
                              "Inter"
                      ],
                      "headline-2": [
                              "Inter"
                      ],
                      "body-2": [
                              "Inter"
                      ],
                      "caption": [
                              "Inter"
                      ],
                      "headline-3": [
                              "Inter"
                      ],
                      "display": [
                              "Inter"
                      ]
              },
              "fontSize": {
                      "label": [
                              "11px",
                              {
                                      "lineHeight": "14px",
                                      "letterSpacing": "0.02em",
                                      "fontWeight": "500"
                              }
                      ],
                      "button": [
                              "14px",
                              {
                                      "lineHeight": "20px",
                                      "fontWeight": "600"
                              }
                      ],
                      "headline-1": [
                              "22px",
                              {
                                      "lineHeight": "28px",
                                      "fontWeight": "600"
                              }
                      ],
                      "body-1": [
                              "14px",
                              {
                                      "lineHeight": "20px",
                                      "fontWeight": "400"
                              }
                      ],
                      "headline-2": [
                              "18px",
                              {
                                      "lineHeight": "24px",
                                      "fontWeight": "600"
                              }
                      ],
                      "body-2": [
                              "12px",
                              {
                                      "lineHeight": "16px",
                                      "fontWeight": "400"
                              }
                      ],
                      "caption": [
                              "10px",
                              {
                                      "lineHeight": "12px",
                                      "fontWeight": "400"
                              }
                      ],
                      "headline-3": [
                              "15px",
                              {
                                      "lineHeight": "20px",
                                      "fontWeight": "500"
                              }
                      ],
                      "display": [
                              "28px",
                              {
                                      "lineHeight": "34px",
                                      "letterSpacing": "-0.02em",
                                      "fontWeight": "700"
                              }
                      ]
              }
      },
          },
        }
      </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface antialiased pb-32">
<!-- Top App Bar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary" data-icon="menu">menu</span>
<h1 class="font-headline-1 text-headline-1 font-bold text-primary">My List</h1>
<span class="bg-primary-container text-on-primary-container px-2 py-0.5 rounded-full font-label text-label ml-2">7 items</span>
</div>
<span class="material-symbols-outlined text-grey-600 hover:bg-grey-100 rounded-full p-2 cursor-pointer transition-colors duration-200" data-icon="more_vert">more_vert</span>
</div>
</header>
<main class="pt-[72px] px-margin-mobile md:px-margin-tablet max-w-3xl mx-auto space-y-stack-lg">
<!-- Recipe Source Card -->
<section class="bg-white border border-border rounded-lg p-4 flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-surface-container-high flex items-center justify-center text-primary">
<span class="material-symbols-outlined" data-icon="restaurant">restaurant</span>
</div>
<div>
<p class="font-label text-label text-grey-600">From Recipe</p>
<h2 class="font-headline-3 text-headline-3 text-on-surface">Nasi Goreng Kampung</h2>
</div>
</section>
<!-- Shopping List Items -->
<section class="bg-white border border-border rounded-lg overflow-hidden">
<!-- Unchecked Items -->
<div class="divide-y divide-border">
<label class="flex items-center p-4 hover:bg-surface-bright cursor-pointer transition-colors">
<input class="form-checkbox h-5 w-5 text-primary-container rounded border-outline-variant focus:ring-primary-container mr-4" type="checkbox"/>
<div class="flex-1">
<span class="font-body-1 text-body-1 text-on-surface block">Soy sauce</span>
<span class="font-body-2 text-body-2 text-grey-600">2 tbsp</span>
</div>
</label>
<label class="flex items-center p-4 hover:bg-surface-bright cursor-pointer transition-colors">
<input class="form-checkbox h-5 w-5 text-primary-container rounded border-outline-variant focus:ring-primary-container mr-4" type="checkbox"/>
<div class="flex-1">
<span class="font-body-1 text-body-1 text-on-surface block">Spring onions</span>
<span class="font-body-2 text-body-2 text-grey-600">1 bunch</span>
</div>
</label>
<label class="flex items-center p-4 hover:bg-surface-bright cursor-pointer transition-colors">
<input class="form-checkbox h-5 w-5 text-primary-container rounded border-outline-variant focus:ring-primary-container mr-4" type="checkbox"/>
<div class="flex-1">
<span class="font-body-1 text-body-1 text-on-surface block">Garlic</span>
<span class="font-body-2 text-body-2 text-grey-600">3 cloves</span>
</div>
</label>
</div>
<!-- Checked Items -->
<div class="bg-surface-bright divide-y divide-border opacity-70">
<div class="p-4 border-t border-border flex items-center">
<span class="material-symbols-outlined text-success mr-4" data-icon="check_circle" data-weight="fill" style="font-variation-settings: 'FILL' 1;">check_circle</span>
<div class="flex-1">
<span class="font-body-1 text-body-1 text-grey-600 line-through block">Cooked rice</span>
<span class="font-body-2 text-body-2 text-grey-600">3 cups</span>
</div>
</div>
<div class="p-4 flex items-center">
<span class="material-symbols-outlined text-success mr-4" data-icon="check_circle" data-weight="fill" style="font-variation-settings: 'FILL' 1;">check_circle</span>
<div class="flex-1">
<span class="font-body-1 text-body-1 text-grey-600 line-through block">Egg</span>
<span class="font-body-2 text-body-2 text-grey-600">2 large</span>
</div>
</div>
</div>
</section>
<!-- Summary & Action Footer -->
<section class="bg-surface-container-low p-4 rounded-lg flex flex-col gap-2 mb-20">
<div class="flex justify-between items-center">
<span class="font-body-2 text-body-2 text-grey-600">Estimated total</span>
<span class="font-headline-2 text-headline-2 text-on-surface">RM 5.20</span>
</div>
<div class="flex items-center gap-1 text-primary">
<span class="material-symbols-outlined text-sm" data-icon="storefront">storefront</span>
<span class="font-caption text-caption">2 stores: Jaya Grocer + Village Grocer</span>
</div>
</section>
</main>
<!-- Sticky Action Button -->
<div class="fixed bottom-[80px] w-full px-margin-mobile md:px-margin-tablet max-w-3xl mx-auto left-0 right-0 z-40 bg-gradient-to-t from-surface to-transparent pt-4 pb-2">
<button class="w-full bg-primary-container text-white font-button text-button h-12 rounded-lg flex items-center justify-center gap-2 hover:bg-opacity-90 transition-opacity">
<span class="material-symbols-outlined" data-icon="route">route</span>
            Plan Shopping Route
        </button>
</div>
<!-- Bottom Nav Bar -->
<nav class="fixed bottom-0 w-full z-50 bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] hidden md:hidden block">
<div class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe bg-surface">
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-label text-label mt-1">Home</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined" data-icon="explore">explore</span>
<span class="font-label text-label mt-1">Explore</span>
</a>
<a class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined" data-icon="receipt_long" data-weight="fill" style="font-variation-settings: 'FILL' 1;">receipt_long</span>
<span class="font-label text-label mt-1">My List</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label text-label mt-1">Profile</span>
</a>
</div>
</nav>
</body></html>

<!-- 4B — Route Optimiser -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Shopping Route</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "tertiary": "#333f39",
                    "on-secondary": "#ffffff",
                    "surface-container-lowest": "#ffffff",
                    "grey-600": "#6B7280",
                    "primary": "#004532",
                    "secondary": "#006781",
                    "inverse-primary": "#8bd6b6",
                    "surface-variant": "#d9e3f6",
                    "surface-bright": "#f8f9ff",
                    "inverse-on-surface": "#eaf1ff",
                    "primary-container": "#065f46",
                    "surface-container-highest": "#d9e3f6",
                    "error": "#EF4444",
                    "outline": "#6f7973",
                    "primary-light": "#D1FAE5",
                    "on-primary-fixed": "#002116",
                    "tertiary-fixed-dim": "#bdcac1",
                    "secondary-container": "#8fdfff",
                    "surface-container": "#e6eeff",
                    "on-tertiary-fixed-variant": "#3e4943",
                    "surface-dim": "#d0dbed",
                    "warning": "#F59E0B",
                    "surface-container-low": "#eff4ff",
                    "surface": "#f8f9ff",
                    "primary-fixed-dim": "#8bd6b6",
                    "secondary-fixed": "#b9eaff",
                    "inverse-surface": "#27313f",
                    "outline-variant": "#bec9c2",
                    "on-primary": "#ffffff",
                    "on-error": "#ffffff",
                    "on-surface": "#121c2a",
                    "grey-400": "#9CA3AF",
                    "tertiary-fixed": "#d9e6dd",
                    "on-tertiary": "#ffffff",
                    "on-secondary-container": "#00647d",
                    "secondary-fixed-dim": "#81d1f0",
                    "tertiary-container": "#4a564f",
                    "surface-tint": "#1b6b51",
                    "error-container": "#ffdad6",
                    "success": "#10B981",
                    "background": "#f8f9ff",
                    "on-primary-fixed-variant": "#00513b",
                    "on-tertiary-fixed": "#131e19",
                    "on-surface-variant": "#3f4944",
                    "on-error-container": "#93000a",
                    "on-primary-container": "#8bd6b7",
                    "border": "#E5E7EB",
                    "surface-container-high": "#dee9fc",
                    "white": "#FFFFFF",
                    "on-background": "#121c2a",
                    "on-secondary-fixed-variant": "#004d62",
                    "on-tertiary-container": "#becac2",
                    "on-secondary-fixed": "#001f29",
                    "grey-100": "#F3F4F6",
                    "primary-fixed": "#a6f2d1"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "margin-tablet": "24px",
                    "stack-sm": "4px",
                    "gutter": "12px",
                    "stack-lg": "16px",
                    "margin-mobile": "16px",
                    "stack-md": "8px",
                    "input-height": "56px"
            },
            "fontFamily": {
                    "label": ["Inter"],
                    "button": ["Inter"],
                    "headline-1": ["Inter"],
                    "body-1": ["Inter"],
                    "headline-2": ["Inter"],
                    "body-2": ["Inter"],
                    "caption": ["Inter"],
                    "headline-3": ["Inter"],
                    "display": ["Inter"]
            },
            "fontSize": {
                    "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                    "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                    "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                    "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                    "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                    "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                    "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                    "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                    "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
            }
          }
        }
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background min-h-screen pb-24">
<!-- TopAppBar (Adapted from Shared Component) -->
<header class="bg-surface dark:bg-surface-dim fixed top-0 w-full z-50 border-b border-border dark:border-outline-variant flex items-center justify-between px-margin-mobile h-input-height w-full">
<button class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-grey-100 dark:hover:bg-tertiary-container transition-colors duration-200">
<span class="material-symbols-outlined text-primary dark:text-primary-fixed-dim" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="text-primary dark:text-primary-fixed-dim font-headline-1 text-headline-1">Shopping Route</h1>
<div class="w-10 h-10"></div> <!-- Placeholder to balance flex-between -->
</header>
<!-- Map Area (260dp) -->
<div class="relative w-full h-[260px] mt-[56px] bg-grey-100 overflow-hidden">
<img alt="Map view" class="w-full h-full object-cover opacity-80" data-alt="A clean, modern digital map interface displaying an urban area. The map uses a light-mode aesthetic with soft grey and pale blue tones for roads and water, accented by a distinct, vibrant green route line connecting three locations. Three clean, modern map pins are visible along the route. The lighting is bright and even, simulating a high-quality smartphone application display focused on clear navigation and modern smart-city utility." data-location="Kuala Lumpur" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCwTF10HJoAQhPcQhpsThhtHYki9uhVdsiHAIPBTYZGG0P-J8ghDis9yGi-vJW7cCiptbE0MRpmGOTAh3WFMQg-0g0KVaLUhoSz2g_eZJF3wXQrgNq6GENuvgn66vBVdzge9_ABCzAD8KcMwnSxSfpq2pG_nNidYXJ78wHtKDjveBIUEY0jaifjnwtv9LFsb8NaLK940oohHcWRhrvqDRTdZudqo8_Yq3ejGbEu1tdH41IrFb7e99sLvMJi8s_WYysk7dcoQIFvHeg"/>
<!-- Overlay Card -->
<div class="absolute bottom-4 left-margin-mobile right-margin-mobile bg-white shadow-lg rounded-xl p-4 flex justify-between items-center z-10 border border-border">
<div class="flex flex-col">
<span class="font-headline-3 text-headline-3 text-on-surface">Estimated: 22 min</span>
<span class="font-body-2 text-body-2 text-grey-600">1.4 km · Walking route</span>
</div>
<!-- Walking/Driving Toggle -->
<div class="flex bg-grey-100 rounded-full p-1 border border-border">
<button class="bg-white shadow rounded-full w-8 h-8 flex items-center justify-center text-primary-container">
<span class="material-symbols-outlined text-[18px]" style="font-variation-settings: 'FILL' 1;">directions_walk</span>
</button>
<button class="w-8 h-8 flex items-center justify-center text-grey-400">
<span class="material-symbols-outlined text-[18px]">directions_car</span>
</button>
</div>
</div>
</div>
<!-- Stop List -->
<main class="px-margin-mobile pt-stack-lg flex flex-col gap-0 relative">
<!-- Stop 1: Location -->
<div class="flex relative">
<div class="w-8 flex flex-col items-center shrink-0">
<div class="w-4 h-4 rounded-full bg-primary-container z-10 border-4 border-surface shadow-sm mt-1"></div>
<div class="w-0.5 bg-primary-container h-full absolute top-5 bottom-0 opacity-30"></div>
</div>
<div class="pb-stack-lg pt-0.5 flex-1">
<p class="font-headline-3 text-headline-3 text-on-surface">Your Location</p>
<p class="font-body-2 text-body-2 text-grey-600">Starting point</p>
</div>
</div>
<!-- Stop 2: Jaya Grocer (Expanded) -->
<div class="flex relative">
<div class="w-8 flex flex-col items-center shrink-0">
<div class="w-4 h-4 rounded-full bg-primary-container z-10 border-4 border-surface shadow-sm mt-5"></div>
<div class="w-0.5 bg-primary-container h-full absolute top-9 bottom-0 opacity-30"></div>
</div>
<div class="pb-stack-lg flex-1">
<div class="bg-white border border-border rounded-xl p-4 shadow-sm">
<div class="flex justify-between items-start mb-2">
<div>
<h3 class="font-headline-2 text-headline-2 text-on-surface">Jaya Grocer</h3>
<p class="font-body-2 text-body-2 text-grey-600">750m away</p>
</div>
<span class="bg-surface-container-high text-primary-container font-label text-label px-2 py-1 rounded">Stop 1</span>
</div>
<div class="mt-stack-md pt-stack-md border-t border-border">
<p class="font-label text-label text-grey-600 mb-2 uppercase tracking-wider">To pick up here</p>
<ul class="flex flex-col gap-2">
<li class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary-container text-[16px]">check_circle</span>
<span class="font-body-1 text-body-1 text-on-surface">Soy sauce (Premium)</span>
</li>
<li class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary-container text-[16px]">check_circle</span>
<span class="font-body-1 text-body-1 text-on-surface">Spring onions</span>
</li>
<li class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary-container text-[16px]">check_circle</span>
<span class="font-body-1 text-body-1 text-on-surface">Cooked rice (Microwaveable)</span>
</li>
</ul>
</div>
</div>
</div>
</div>
<!-- Stop 3: Village Grocer (Collapsed) -->
<div class="flex relative">
<div class="w-8 flex flex-col items-center shrink-0">
<div class="w-6 h-6 bg-surface z-10 mt-3 flex items-center justify-center">
<span class="material-symbols-outlined text-primary-container" style="font-variation-settings: 'FILL' 1;">location_on</span>
</div>
</div>
<div class="pb-stack-lg flex-1">
<div class="bg-white border border-border rounded-xl p-4 shadow-sm flex items-center justify-between">
<div>
<h3 class="font-headline-2 text-headline-2 text-on-surface">Village Grocer</h3>
<p class="font-body-2 text-body-2 text-grey-600">Final stop · 650m further</p>
</div>
<div class="flex items-center gap-2 text-grey-600">
<span class="font-label text-label bg-surface-container text-on-surface-variant px-2 py-1 rounded">2 items</span>
<span class="material-symbols-outlined">expand_more</span>
</div>
</div>
</div>
</div>
</main>
<!-- Sticky Footer -->
<div class="fixed bottom-0 w-full p-margin-mobile bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] z-50 border-t border-border">
<button class="w-full bg-primary-container text-white rounded-xl h-[48px] flex justify-center items-center gap-2 hover:opacity-90 transition-opacity">
<span class="material-symbols-outlined text-[20px]">map</span>
<span class="font-button text-button">Open in Google Maps</span>
</button>
</div>
</body></html>

<!-- 7A — Budget Overview -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" name="viewport"/>
<title>Budget Overview</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "tertiary": "#333f39",
                      "on-secondary": "#ffffff",
                      "surface-container-lowest": "#ffffff",
                      "grey-600": "#6B7280",
                      "primary": "#004532",
                      "secondary": "#006781",
                      "inverse-primary": "#8bd6b6",
                      "surface-variant": "#d9e3f6",
                      "surface-bright": "#f8f9ff",
                      "inverse-on-surface": "#eaf1ff",
                      "primary-container": "#065f46",
                      "surface-container-highest": "#d9e3f6",
                      "error": "#EF4444",
                      "outline": "#6f7973",
                      "primary-light": "#D1FAE5",
                      "on-primary-fixed": "#002116",
                      "tertiary-fixed-dim": "#bdcac1",
                      "secondary-container": "#8fdfff",
                      "surface-container": "#e6eeff",
                      "on-tertiary-fixed-variant": "#3e4943",
                      "surface-dim": "#d0dbed",
                      "warning": "#F59E0B",
                      "surface-container-low": "#eff4ff",
                      "surface": "#f8f9ff",
                      "primary-fixed-dim": "#8bd6b6",
                      "secondary-fixed": "#b9eaff",
                      "inverse-surface": "#27313f",
                      "outline-variant": "#bec9c2",
                      "on-primary": "#ffffff",
                      "on-error": "#ffffff",
                      "on-surface": "#121c2a",
                      "grey-400": "#9CA3AF",
                      "tertiary-fixed": "#d9e6dd",
                      "on-tertiary": "#ffffff",
                      "on-secondary-container": "#00647d",
                      "secondary-fixed-dim": "#81d1f0",
                      "tertiary-container": "#4a564f",
                      "surface-tint": "#1b6b51",
                      "error-container": "#ffdad6",
                      "success": "#10B981",
                      "background": "#f8f9ff",
                      "on-primary-fixed-variant": "#00513b",
                      "on-tertiary-fixed": "#131e19",
                      "on-surface-variant": "#3f4944",
                      "on-error-container": "#93000a",
                      "on-primary-container": "#8bd6b7",
                      "border": "#E5E7EB",
                      "surface-container-high": "#dee9fc",
                      "white": "#FFFFFF",
                      "on-background": "#121c2a",
                      "on-secondary-fixed-variant": "#004d62",
                      "on-tertiary-container": "#becac2",
                      "on-secondary-fixed": "#001f29",
                      "grey-100": "#F3F4F6",
                      "primary-fixed": "#a6f2d1",
                      "page-bg": "#F0FDF4"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px",
                      "card": "12px"
              },
              "spacing": {
                      "margin-tablet": "24px",
                      "stack-sm": "4px",
                      "gutter": "12px",
                      "stack-lg": "16px",
                      "margin-mobile": "16px",
                      "stack-md": "8px",
                      "input-height": "56px",
                      "safe-bottom": "env(safe-area-inset-bottom)",
                      "safe-top": "env(safe-area-inset-top)"
              },
              "fontFamily": {
                      "label": ["Inter"],
                      "button": ["Inter"],
                      "headline-1": ["Inter"],
                      "body-1": ["Inter"],
                      "headline-2": ["Inter"],
                      "body-2": ["Inter"],
                      "caption": ["Inter"],
                      "headline-3": ["Inter"],
                      "display": ["Inter"]
              },
              "fontSize": {
                      "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                      "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                      "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                      "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                      "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                      "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                      "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                      "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                      "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
              }
            }
          }
        }
    </script>
<style>
        body { background-color: theme('colors.page-bg'); }
        /* Circular Progress */
        .progress-ring__circle {
            transition: stroke-dashoffset 0.35s;
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="antialiased min-h-screen text-on-surface flex flex-col pb-24 md:pb-0 md:flex-row">
<!-- Top App Bar (Mobile) -->
<header class="fixed top-0 w-full z-50 bg-page-bg border-b border-border md:hidden pt-safe-top">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full transition-colors duration-200">
<div class="flex items-center gap-4">
<button class="text-primary hover:bg-grey-100 p-2 rounded-full flex items-center justify-center transition-colors">
<span class="material-symbols-outlined" data-icon="menu">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary">Budget</h1>
</div>
<button class="flex items-center gap-1 text-primary hover:bg-grey-100 px-3 py-1.5 rounded-full transition-colors">
<span class="font-button text-button">May 2026</span>
<span class="material-symbols-outlined text-sm" data-icon="expand_more">expand_more</span>
</button>
</div>
</header>
<!-- Side Nav (Desktop) -->
<aside class="hidden md:flex flex-col fixed left-0 top-0 h-full w-72 z-[60] bg-surface shadow-xl py-4 border-r border-border">
<div class="px-6 mb-8 flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-lg">UW</div>
<div>
<h2 class="font-headline-2 text-headline-2 text-primary">Urban Wellness</h2>
<p class="font-body-2 text-body-2 text-grey-600">Account &amp; Preferences</p>
</div>
</div>
<nav class="flex-1 px-2 space-y-1">
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300" href="#">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-body-1 text-body-1">Home</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300" href="#">
<span class="material-symbols-outlined" data-icon="explore">explore</span>
<span class="font-body-1 text-body-1">Explore</span>
</a>
<a class="bg-primary-container text-on-primary-container rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300" href="#">
<span class="material-symbols-outlined" data-icon="payments" data-weight="fill">payments</span>
<span class="font-body-1 text-body-1 font-semibold">Budget</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-all duration-300" href="#">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-body-1 text-body-1">Profile</span>
</a>
</nav>
<div class="px-6 mt-auto">
<p class="font-caption text-caption text-grey-600">RM 250.00 Saved this month</p>
</div>
</aside>
<!-- Main Content Canvas -->
<main class="flex-1 px-margin-mobile pt-[calc(theme(spacing.input-height)+theme(spacing.stack-lg))] md:pt-stack-lg md:ml-72 max-w-4xl mx-auto w-full space-y-stack-lg">
<!-- Desktop Header -->
<div class="hidden md:flex justify-between items-center mb-8">
<h1 class="text-display font-display text-primary">Budget Overview</h1>
<button class="flex items-center gap-2 text-primary bg-surface border border-border px-4 py-2 rounded-full hover:bg-grey-100 transition-colors shadow-sm">
<span class="material-symbols-outlined" data-icon="calendar_month">calendar_month</span>
<span class="font-button text-button">May 2026</span>
<span class="material-symbols-outlined text-sm" data-icon="expand_more">expand_more</span>
</button>
</div>
<!-- Budget Ring Card -->
<section class="bg-white border border-border rounded-card p-4 shadow-sm flex flex-col items-center justify-center relative overflow-hidden">
<div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary-light via-primary to-inverse-primary opacity-20"></div>
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-6 self-start w-full text-center md:text-left">Monthly Spend</h2>
<div class="relative flex items-center justify-center mb-4">
<svg class="w-48 h-48 drop-shadow-sm" viewbox="0 0 120 120">
<!-- Background Ring -->
<circle class="text-grey-100 stroke-current" cx="60" cy="60" fill="transparent" r="50" stroke-width="12"></circle>
<!-- Progress Ring (39% = 314.159 * 0.39 = ~122.5) -->
<circle class="text-primary stroke-current progress-ring__circle" cx="60" cy="60" fill="transparent" r="50" stroke-dasharray="314.159" stroke-dashoffset="191.6" stroke-linecap="round" stroke-width="12"></circle>
</svg>
<div class="absolute flex flex-col items-center justify-center text-center">
<span class="font-display text-display text-primary leading-tight">39%</span>
<span class="font-body-2 text-body-2 text-grey-600">Spent</span>
</div>
</div>
<div class="text-center">
<p class="font-headline-1 text-headline-1 text-on-surface">RM 234 <span class="font-body-1 text-body-1 text-grey-600">of RM 600</span></p>
<p class="font-caption text-caption text-success mt-1 flex items-center justify-center gap-1">
<span class="material-symbols-outlined text-[14px]" data-icon="trending_down">trending_down</span>
                    On track to save this month
                </p>
</div>
</section>
<div class="grid grid-cols-1 md:grid-cols-2 gap-stack-lg">
<!-- Category Breakdown Card -->
<section class="bg-white border border-border rounded-card p-4 shadow-sm flex flex-col gap-stack-md">
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-2">Categories</h2>
<!-- Category Item: Dining -->
<div class="flex flex-col gap-1">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<div class="w-8 h-8 rounded-full bg-primary-light text-primary flex items-center justify-center">
<span class="material-symbols-outlined text-sm" data-icon="restaurant">restaurant</span>
</div>
<span class="font-body-1 text-body-1 font-medium">Dining</span>
</div>
<span class="font-headline-3 text-headline-3">RM 140</span>
</div>
<div class="w-full bg-grey-100 rounded-full h-2 mt-1">
<div class="bg-primary h-2 rounded-full" style="width: 70%"></div>
</div>
</div>
<!-- Category Item: Groceries -->
<div class="flex flex-col gap-1 mt-2">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<div class="w-8 h-8 rounded-full bg-secondary-container text-on-secondary-container flex items-center justify-center">
<span class="material-symbols-outlined text-sm" data-icon="shopping_cart">shopping_cart</span>
</div>
<span class="font-body-1 text-body-1 font-medium">Groceries</span>
</div>
<span class="font-headline-3 text-headline-3">RM 68</span>
</div>
<div class="w-full bg-grey-100 rounded-full h-2 mt-1">
<div class="bg-secondary h-2 rounded-full" style="width: 34%"></div>
</div>
</div>
<!-- Category Item: Delivery -->
<div class="flex flex-col gap-1 mt-2">
<div class="flex justify-between items-center">
<div class="flex items-center gap-2">
<div class="w-8 h-8 rounded-full bg-[#fef3c7] text-[#92400e] flex items-center justify-center">
<span class="material-symbols-outlined text-sm" data-icon="two_wheeler">two_wheeler</span>
</div>
<span class="font-body-1 text-body-1 font-medium">Delivery</span>
</div>
<span class="font-headline-3 text-headline-3">RM 26</span>
</div>
<div class="w-full bg-grey-100 rounded-full h-2 mt-1">
<div class="bg-warning h-2 rounded-full" style="width: 13%"></div>
</div>
</div>
</section>
<!-- Recent Transactions Card -->
<section class="bg-white border border-border rounded-card p-4 shadow-sm flex flex-col gap-stack-md">
<div class="flex justify-between items-center mb-2">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Recent</h2>
<button class="font-button text-button text-primary hover:underline">See All</button>
</div>
<ul class="space-y-4">
<!-- Tx 1 -->
<li class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center border border-border">
<span class="material-symbols-outlined text-grey-600" data-icon="storefront">storefront</span>
</div>
<div>
<p class="font-body-1 text-body-1 font-medium">Nasi Kandar Ali</p>
<p class="font-caption text-caption text-grey-600">Today, 1:30 PM • Dining</p>
</div>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">-RM 8.50</span>
</li>
<!-- Tx 2 -->
<li class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center border border-border">
<span class="material-symbols-outlined text-grey-600" data-icon="local_mall">local_mall</span>
</div>
<div>
<p class="font-body-1 text-body-1 font-medium">Jaya Grocer</p>
<p class="font-caption text-caption text-grey-600">Yesterday • Groceries</p>
</div>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">-RM 12.40</span>
</li>
<!-- Tx 3 -->
<li class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center border border-border">
<span class="material-symbols-outlined text-grey-600" data-icon="delivery_dining">delivery_dining</span>
</div>
<div>
<p class="font-body-1 text-body-1 font-medium">GrabFood</p>
<p class="font-caption text-caption text-grey-600">May 12 • Delivery</p>
</div>
</div>
<span class="font-headline-3 text-headline-3 text-on-surface">-RM 18.90</span>
</li>
</ul>
</section>
</div>
<!-- Bottom spacing for FAB and Nav -->
<div class="h-24 md:h-8 w-full"></div>
</main>
<!-- FAB -->
<button class="fixed right-4 bottom-20 md:bottom-8 w-14 h-14 bg-primary-container text-white rounded-[16px] shadow-lg flex items-center justify-center hover:bg-primary transition-colors z-40 active:scale-95 md:right-8">
<span class="material-symbols-outlined" data-icon="add">add</span>
</button>
<!-- Bottom Nav Bar (Mobile) -->
<nav class="fixed bottom-0 left-0 w-full bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] md:hidden z-50 pb-safe-bottom">
<div class="flex justify-around items-center px-4 py-2">
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 p-2 w-16" href="#">
<span class="material-symbols-outlined mb-1" data-icon="home">home</span>
<span class="font-label text-label">Home</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 p-2 w-16" href="#">
<span class="material-symbols-outlined mb-1" data-icon="explore">explore</span>
<span class="font-label text-label">Explore</span>
</a>
<a class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150 p-2 w-16 relative" href="#">
<div class="absolute -top-1 w-12 h-8 bg-primary-light rounded-full -z-10 opacity-50"></div>
<span class="material-symbols-outlined mb-1" data-icon="payments" data-weight="fill">payments</span>
<span class="font-label text-label">Budget</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 p-2 w-16" href="#">
<span class="material-symbols-outlined mb-1" data-icon="person">person</span>
<span class="font-label text-label">Profile</span>
</a>
</div>
</nav>
<script>
        // Simple script to animate the ring on load if needed, though CSS handles the initial transition well.
        document.addEventListener('DOMContentLoaded', () => {
            const circle = document.querySelector('.progress-ring__circle');
            if(circle) {
                // Ensure it triggers after render
                setTimeout(() => {
                    circle.style.strokeDashoffset = '191.6'; // 39% of 314.159
                }, 100);
            }
        });
    </script>
</body></html>

<!-- 7B — Transaction Log -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Transaction Log</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .hide-scrollbar::-webkit-scrollbar { display: none; }
        .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface antialiased flex flex-col min-h-screen pb-[80px]">
<!-- TopAppBar -->
<header class="bg-surface dark:bg-surface-dim text-primary dark:text-primary-fixed-dim font-headline-1 text-headline-1 fixed top-0 w-full z-50 border-b border-border dark:border-outline-variant transition-colors duration-200 flex items-center justify-between px-margin-mobile h-input-height">
<button class="flex items-center justify-center w-10 h-10 rounded-full hover:bg-grey-100 dark:hover:bg-tertiary-container transition-colors duration-200 text-primary dark:text-primary-fixed-dim">
<span class="material-symbols-outlined" data-icon="menu">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary dark:text-primary-fixed-dim">Transactions</h1>
<button class="flex items-center justify-center w-10 h-10 rounded-full hover:bg-grey-100 dark:hover:bg-tertiary-container transition-colors duration-200 text-primary dark:text-primary-fixed-dim">
<span class="material-symbols-outlined" data-icon="ios_share">ios_share</span>
</button>
</header>
<main class="flex-1 mt-input-height flex flex-col w-full max-w-md mx-auto">
<!-- Search and Filters Section -->
<div class="px-margin-mobile py-stack-md flex flex-col gap-stack-md bg-surface z-40 sticky top-[56px] border-b border-border">
<!-- Search Bar -->
<div class="h-[48px] w-full border border-border rounded-xl px-4 flex items-center bg-white">
<span class="material-symbols-outlined text-grey-400 mr-2 text-[20px]" data-icon="search">search</span>
<input class="flex-1 bg-transparent border-none focus:ring-0 p-0 font-body-1 text-body-1 text-on-surface placeholder-grey-400 h-full w-full" placeholder="Search transactions..." type="text"/>
</div>
<!-- Filter Chips -->
<div class="flex overflow-x-auto hide-scrollbar gap-2 py-1">
<button class="px-4 py-1.5 rounded-full bg-primary-container text-white font-label text-label flex-shrink-0 border border-primary-container">All</button>
<button class="px-4 py-1.5 rounded-full bg-white text-grey-600 font-label text-label flex-shrink-0 border border-border hover:bg-grey-100 transition-colors">Dining</button>
<button class="px-4 py-1.5 rounded-full bg-white text-grey-600 font-label text-label flex-shrink-0 border border-border hover:bg-grey-100 transition-colors">Groceries</button>
<button class="px-4 py-1.5 rounded-full bg-white text-grey-600 font-label text-label flex-shrink-0 border border-border hover:bg-grey-100 transition-colors">Delivery</button>
</div>
</div>
<!-- Transaction List -->
<div class="flex flex-col">
<!-- Sticky Header -->
<div class="px-margin-mobile py-2 bg-surface-container-low font-headline-3 text-headline-3 text-on-surface-variant flex justify-between items-center sticky top-[136px] z-30 shadow-sm border-b border-border">
<span>May 2026</span>
<span class="font-bold">RM 234.40</span>
</div>
<div class="flex flex-col">
<!-- Swipe-to-delete Row 1 -->
<div class="relative w-full h-[72px] overflow-hidden bg-error">
<!-- Background Action (Delete) -->
<div class="absolute inset-y-0 right-0 w-[80px] flex flex-col items-center justify-center text-white cursor-pointer">
<span class="material-symbols-outlined mb-1" data-icon="delete">delete</span>
<span class="font-label text-label">Delete</span>
</div>
<!-- Foreground Content (Swiped left) -->
<div class="absolute inset-y-0 left-0 w-full bg-white border-b border-border flex items-center px-margin-mobile transform -translate-x-[80px] transition-transform duration-300">
<div class="w-10 h-10 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center mr-4 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="restaurant">restaurant</span>
</div>
<div class="flex-1 min-w-0">
<h3 class="font-body-1 text-body-1 text-on-surface font-semibold truncate">Nasi Kandar Ali</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate">Dining • Today, 12:30 PM</p>
</div>
<div class="font-body-1 text-body-1 text-on-surface font-semibold ml-4">
                            -RM 24.50
                        </div>
</div>
</div>
<!-- Normal Row 2 -->
<div class="w-full h-[72px] bg-white border-b border-border flex items-center px-margin-mobile hover:bg-grey-100 transition-colors cursor-pointer">
<div class="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-4 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="shopping_cart">shopping_cart</span>
</div>
<div class="flex-1 min-w-0">
<h3 class="font-body-1 text-body-1 text-on-surface font-semibold truncate">Jaya Grocer</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate">Groceries • Yesterday</p>
</div>
<div class="font-body-1 text-body-1 text-on-surface font-semibold ml-4">
                        -RM 112.90
                    </div>
</div>
<!-- Normal Row 3 -->
<div class="w-full h-[72px] bg-white border-b border-border flex items-center px-margin-mobile hover:bg-grey-100 transition-colors cursor-pointer">
<div class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center mr-4 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="two_wheeler">two_wheeler</span>
</div>
<div class="flex-1 min-w-0">
<h3 class="font-body-1 text-body-1 text-on-surface font-semibold truncate">GrabFood</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate">Delivery • May 24</p>
</div>
<div class="font-body-1 text-body-1 text-on-surface font-semibold ml-4">
                        -RM 45.00
                    </div>
</div>
<!-- Normal Row 4 -->
<div class="w-full h-[72px] bg-white border-b border-border flex items-center px-margin-mobile hover:bg-grey-100 transition-colors cursor-pointer">
<div class="w-10 h-10 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center mr-4 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="local_cafe">local_cafe</span>
</div>
<div class="flex-1 min-w-0">
<h3 class="font-body-1 text-body-1 text-on-surface font-semibold truncate">Kopitiam Old Town</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate">Dining • May 22</p>
</div>
<div class="font-body-1 text-body-1 text-on-surface font-semibold ml-4">
                        -RM 18.00
                    </div>
</div>
<!-- Normal Row 5 -->
<div class="w-full h-[72px] bg-white border-b border-border flex items-center px-margin-mobile hover:bg-grey-100 transition-colors cursor-pointer">
<div class="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-4 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="storefront">storefront</span>
</div>
<div class="flex-1 min-w-0">
<h3 class="font-body-1 text-body-1 text-on-surface font-semibold truncate">99 Speedmart</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate">Groceries • May 20</p>
</div>
<div class="font-body-1 text-body-1 text-on-surface font-semibold ml-4">
                        -RM 34.00
                    </div>
</div>
</div>
</div>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe bg-surface dark:bg-surface-container-lowest z-50 shadow-[0_-4px_12px_rgba(0,0,0,0.08)] dark:shadow-none shadow-lg">
<!-- Home (Inactive) -->
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant w-[72px] h-[56px] hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px] mb-1" data-icon="home">home</span>
<span class="font-label text-label">Home</span>
</a>
<!-- Explore (Inactive) -->
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant w-[72px] h-[56px] hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px] mb-1" data-icon="explore">explore</span>
<span class="font-label text-label">Explore</span>
</a>
<!-- Budget (Active) -->
<a class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-semibold w-[72px] h-[56px] hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<div class="bg-primary-container/20 rounded-xl px-4 py-1 mb-1 flex items-center justify-center">
<span class="material-symbols-outlined text-[24px]" data-icon="payments" data-weight="fill" style="font-variation-settings: 'FILL' 1;">payments</span>
</div>
<span class="font-label text-label">Budget</span>
</a>
<!-- Profile (Inactive) -->
<a class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant w-[72px] h-[56px] hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px] mb-1" data-icon="person">person</span>
<span class="font-label text-label">Profile</span>
</a>
</nav>
</body></html>

<!-- 8A — Notification Centre -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Notification Centre</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "tertiary": "#333f39",
                      "on-secondary": "#ffffff",
                      "surface-container-lowest": "#ffffff",
                      "grey-600": "#6B7280",
                      "primary": "#004532",
                      "secondary": "#006781",
                      "inverse-primary": "#8bd6b6",
                      "surface-variant": "#d9e3f6",
                      "surface-bright": "#f8f9ff",
                      "inverse-on-surface": "#eaf1ff",
                      "primary-container": "#065f46",
                      "surface-container-highest": "#d9e3f6",
                      "error": "#EF4444",
                      "outline": "#6f7973",
                      "primary-light": "#D1FAE5",
                      "on-primary-fixed": "#002116",
                      "tertiary-fixed-dim": "#bdcac1",
                      "secondary-container": "#8fdfff",
                      "surface-container": "#e6eeff",
                      "on-tertiary-fixed-variant": "#3e4943",
                      "surface-dim": "#d0dbed",
                      "warning": "#F59E0B",
                      "surface-container-low": "#eff4ff",
                      "surface": "#f8f9ff",
                      "primary-fixed-dim": "#8bd6b6",
                      "secondary-fixed": "#b9eaff",
                      "inverse-surface": "#27313f",
                      "outline-variant": "#bec9c2",
                      "on-primary": "#ffffff",
                      "on-error": "#ffffff",
                      "on-surface": "#121c2a",
                      "grey-400": "#9CA3AF",
                      "tertiary-fixed": "#d9e6dd",
                      "on-tertiary": "#ffffff",
                      "on-secondary-container": "#00647d",
                      "secondary-fixed-dim": "#81d1f0",
                      "tertiary-container": "#4a564f",
                      "surface-tint": "#1b6b51",
                      "error-container": "#ffdad6",
                      "success": "#10B981",
                      "background": "#f8f9ff",
                      "on-primary-fixed-variant": "#00513b",
                      "on-tertiary-fixed": "#131e19",
                      "on-surface-variant": "#3f4944",
                      "on-error-container": "#93000a",
                      "on-primary-container": "#8bd6b7",
                      "border": "#E5E7EB",
                      "surface-container-high": "#dee9fc",
                      "white": "#FFFFFF",
                      "on-background": "#121c2a",
                      "on-secondary-fixed-variant": "#004d62",
                      "on-tertiary-container": "#becac2",
                      "on-secondary-fixed": "#001f29",
                      "grey-100": "#F3F4F6",
                      "primary-fixed": "#a6f2d1"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "margin-tablet": "24px",
                      "stack-sm": "4px",
                      "gutter": "12px",
                      "stack-lg": "16px",
                      "margin-mobile": "16px",
                      "stack-md": "8px",
                      "input-height": "56px"
              },
              "fontFamily": {
                      "label": ["Inter"],
                      "button": ["Inter"],
                      "headline-1": ["Inter"],
                      "body-1": ["Inter"],
                      "headline-2": ["Inter"],
                      "body-2": ["Inter"],
                      "caption": ["Inter"],
                      "headline-3": ["Inter"],
                      "display": ["Inter"]
              },
              "fontSize": {
                      "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                      "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                      "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                      "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                      "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                      "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                      "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                      "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                      "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
              }
      },
          },
        }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .material-symbols-outlined.filled {
            font-variation-settings: 'FILL' 1;
        }
        
        /* Custom swipe reveal animation classes */
        .swipe-container {
            position: relative;
            overflow: hidden;
            border-bottom: 1px solid #E5E7EB;
        }
        .swipe-action {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100px;
            background-color: #EF4444; /* error color */
            color: white;
            z-index: 1;
        }
        .swipe-content {
            position: relative;
            z-index: 2;
            transition: transform 0.3s ease-out;
            background-color: inherit;
        }
        .swipe-revealed .swipe-content {
            transform: translateX(-100px);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface h-screen flex flex-col antialiased">
<!-- Top App Bar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<button aria-label="Go back" class="text-primary dark:text-primary-fixed-dim p-2 -ml-2 rounded-full hover:bg-grey-100 transition-colors">
<span class="material-symbols-outlined">arrow_back</span>
</button>
<h1 class="text-headline-1 font-headline-1 text-primary">Notifications</h1>
<button class="text-button font-button text-primary hover:text-primary-container transition-colors">
                Mark all read
            </button>
</div>
</header>
<!-- Main Content Canvas -->
<main class="flex-1 overflow-y-auto pt-[56px] pb-safe">
<div class="flex flex-col w-full">
<!-- Notification Item 1: Budget Alert (Swipe state) -->
<div class="swipe-container bg-primary-light">
<!-- Action Background -->
<div class="swipe-action">
<button class="flex flex-col items-center justify-center w-full h-full text-white">
<span class="material-symbols-outlined filled mb-1">delete</span>
<span class="font-label text-label">Dismiss</span>
</button>
</div>
<!-- Content Foreground -->
<div class="swipe-content swipe-revealed bg-primary-light px-margin-mobile py-4 flex gap-4 cursor-pointer">
<div class="flex-shrink-0 relative">
<div class="w-12 h-12 rounded-full bg-warning/20 flex items-center justify-center">
<span class="material-symbols-outlined text-warning filled">warning</span>
</div>
<div class="absolute top-0 right-0 w-3 h-3 bg-error rounded-full border-2 border-primary-light"></div>
</div>
<div class="flex-1 min-w-0">
<div class="flex justify-between items-start mb-1">
<h2 class="font-headline-3 text-headline-3 text-on-surface truncate pr-2">Budget Alert</h2>
<span class="font-caption text-caption text-grey-600 flex-shrink-0">Just now</span>
</div>
<p class="font-body-2 text-body-2 text-on-surface-variant line-clamp-2">
                            You've reached 90% of your RM500 dining budget for this month. Consider cooking at home to stay on track.
                        </p>
</div>
</div>
</div>
<!-- Notification Item 2: Near Jaya Grocer (Unread) -->
<div class="border-b border-border bg-primary-light px-margin-mobile py-4 flex gap-4 cursor-pointer hover:bg-grey-100 transition-colors">
<div class="flex-shrink-0 relative">
<div class="w-12 h-12 rounded-full bg-secondary/20 flex items-center justify-center">
<span class="material-symbols-outlined text-secondary filled">storefront</span>
</div>
<div class="absolute top-0 right-0 w-3 h-3 bg-error rounded-full border-2 border-primary-light"></div>
</div>
<div class="flex-1 min-w-0">
<div class="flex justify-between items-start mb-1">
<h2 class="font-headline-3 text-headline-3 text-on-surface truncate pr-2">Near Jaya Grocer</h2>
<span class="font-caption text-caption text-grey-600 flex-shrink-0">2 hrs ago</span>
</div>
<p class="font-body-2 text-body-2 text-on-surface-variant line-clamp-2">
                        You're near Jaya Grocer. Remember you have 3 items on your shopping list including Milk and Eggs.
                    </p>
</div>
</div>
<!-- Notification Item 3: New Recommendation (Read) -->
<div class="border-b border-border bg-white px-margin-mobile py-4 flex gap-4 cursor-pointer hover:bg-grey-100 transition-colors">
<div class="flex-shrink-0">
<div class="w-12 h-12 rounded-full bg-success/20 flex items-center justify-center">
<span class="material-symbols-outlined text-success filled">restaurant</span>
</div>
</div>
<div class="flex-1 min-w-0">
<div class="flex justify-between items-start mb-1">
<h2 class="font-body-1 text-body-1 font-medium text-on-surface truncate pr-2">New recommendation</h2>
<span class="font-caption text-caption text-grey-400 flex-shrink-0">Yesterday</span>
</div>
<p class="font-body-2 text-body-2 text-grey-600 line-clamp-2">
                        We found a new vegan-friendly spot near your workplace: 'Green Bowl Cafe'. Check it out!
                    </p>
</div>
</div>
<!-- Notification Item 4: Welcome (Read) -->
<div class="border-b border-border bg-white px-margin-mobile py-4 flex gap-4 cursor-pointer hover:bg-grey-100 transition-colors">
<div class="flex-shrink-0">
<div class="w-12 h-12 rounded-full bg-grey-100 flex items-center justify-center">
<span class="material-symbols-outlined text-grey-600 filled">celebration</span>
</div>
</div>
<div class="flex-1 min-w-0">
<div class="flex justify-between items-start mb-1">
<h2 class="font-body-1 text-body-1 font-medium text-on-surface truncate pr-2">Welcome to Mapetite</h2>
<span class="font-caption text-caption text-grey-400 flex-shrink-0">Oct 12</span>
</div>
<p class="font-body-2 text-body-2 text-grey-600 line-clamp-2">
                        Thanks for joining! Start by setting up your dietary preferences to get personalized food recommendations.
                    </p>
</div>
</div>
</div>
</main>
<script>
        // Simple JS to toggle swipe state for demonstration if clicked
        document.querySelector('.swipe-revealed').addEventListener('click', function() {
            this.classList.toggle('swipe-revealed');
            // Adding a small delay to simulate snap back before real implementation
            setTimeout(() => {
                if(!this.classList.contains('swipe-revealed')) {
                    this.style.transform = 'translateX(0)';
                }
            }, 50);
        });
    </script>
</body></html>

<!-- 9A — App Settings -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>App Settings</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#F0FDF4", /* Overridden per user request */
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-surface font-body-1 min-h-screen flex flex-col pt-input-height pb-safe">
<!-- TopAppBar from JSON -->
<header class="fixed top-0 w-full z-50 border-b border-border dark:border-outline-variant bg-surface dark:bg-surface-dim transition-colors duration-200 shadow-[0_-4px_12px_rgba(0,0,0,0.08)]">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<button class="p-2 -ml-2 text-primary dark:text-primary-fixed-dim hover:bg-grey-100 dark:hover:bg-tertiary-container rounded-full transition-colors duration-200 flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary dark:text-primary-fixed-dim">Settings</h1>
<div class="w-10"></div> <!-- Placeholder for balance -->
</div>
</header>
<main class="flex-1 px-margin-mobile py-stack-lg flex flex-col gap-stack-lg max-w-md mx-auto w-full">
<!-- Profile Card -->
<section class="bg-white border border-border rounded-xl p-stack-lg flex items-center gap-stack-lg shadow-sm">
<div class="w-16 h-16 rounded-full bg-primary-light text-primary flex items-center justify-center font-headline-1 text-headline-1">
                AS
            </div>
<div class="flex-1">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Aisha Salleh</h2>
<p class="font-body-1 text-body-1 text-grey-600">aisha.salleh@example.com</p>
</div>
<button class="text-primary hover:bg-surface-container rounded-full p-2 transition-colors">
<span class="material-symbols-outlined" data-icon="edit">edit</span>
</button>
</section>
<!-- Preferences Group -->
<section class="bg-white border border-border rounded-xl overflow-hidden shadow-sm flex flex-col">
<h3 class="font-headline-3 text-headline-3 px-stack-lg py-stack-md bg-surface-bright border-b border-border text-on-surface-variant">Preferences</h3>
<button class="flex items-center justify-between p-stack-lg border-b border-border hover:bg-surface-bright transition-colors text-left w-full group">
<div class="flex items-center gap-stack-md text-on-surface">
<span class="material-symbols-outlined text-grey-600 group-hover:text-primary transition-colors" data-icon="palette">palette</span>
<span class="font-body-1 text-body-1">Appearance</span>
</div>
<div class="flex items-center gap-stack-sm text-grey-600">
<span class="font-body-2 text-body-2">System default</span>
<span class="material-symbols-outlined" data-icon="chevron_right">chevron_right</span>
</div>
</button>
<button class="flex items-center justify-between p-stack-lg border-b border-border hover:bg-surface-bright transition-colors text-left w-full group">
<div class="flex items-center gap-stack-md text-on-surface">
<span class="material-symbols-outlined text-grey-600 group-hover:text-primary transition-colors" data-icon="language">language</span>
<span class="font-body-1 text-body-1">Language</span>
</div>
<div class="flex items-center gap-stack-sm text-grey-600">
<span class="font-body-2 text-body-2">English</span>
<span class="material-symbols-outlined" data-icon="chevron_right">chevron_right</span>
</div>
</button>
<button class="flex items-center justify-between p-stack-lg border-b border-border hover:bg-surface-bright transition-colors text-left w-full group">
<div class="flex items-center gap-stack-md text-on-surface">
<span class="material-symbols-outlined text-grey-600 group-hover:text-primary transition-colors" data-icon="location_on">location_on</span>
<span class="font-body-1 text-body-1">Location</span>
</div>
<span class="material-symbols-outlined text-grey-600" data-icon="chevron_right">chevron_right</span>
</button>
<button class="flex items-center justify-between p-stack-lg hover:bg-surface-bright transition-colors text-left w-full group">
<div class="flex items-center gap-stack-md text-on-surface">
<span class="material-symbols-outlined text-grey-600 group-hover:text-primary transition-colors" data-icon="notifications">notifications</span>
<span class="font-body-1 text-body-1">Notifications</span>
</div>
<span class="material-symbols-outlined text-grey-600" data-icon="chevron_right">chevron_right</span>
</button>
</section>
<!-- Account Actions -->
<section class="pt-stack-lg flex flex-col gap-stack-md">
<button class="w-full h-12 rounded-xl border border-error text-error font-button text-button flex items-center justify-center gap-stack-sm hover:bg-error-container transition-colors">
<span class="material-symbols-outlined text-[20px]" data-icon="logout">logout</span>
                Log Out
            </button>
</section>
<footer class="mt-auto py-stack-lg text-center">
<p class="font-caption text-caption text-grey-400">Urban Wellness App Version 2.4.1 (Build 890)</p>
</footer>
</main>
</body></html>

<!-- 2A-Empty — Dine-In Feed Empty State -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Dine-In Feed - Empty State</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-1 antialiased h-screen flex flex-col overflow-hidden">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 flex items-center justify-between px-margin-mobile h-input-height bg-surface border-b border-border transition-colors duration-200">
<button aria-label="Menu" class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-grey-100 text-primary transition-colors duration-200">
<span class="material-symbols-outlined" data-icon="menu">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary truncate flex-1 text-center">Settings</h1>
<button aria-label="Search" class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-grey-100 text-primary transition-colors duration-200">
<span class="material-symbols-outlined" data-icon="search">search</span>
</button>
</header>
<!-- Main Content Area -->
<main class="flex-1 flex flex-col pt-input-height pb-[72px] overflow-y-auto">
<!-- Filter Row -->
<div class="w-full px-margin-mobile py-stack-md flex items-center gap-2 overflow-x-auto no-scrollbar border-b border-border bg-surface">
<button class="flex items-center gap-1 px-3 py-1.5 rounded-full border border-outline text-on-surface-variant font-label text-label whitespace-nowrap hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined text-[16px]">tune</span>
                Filters
            </button>
<div class="w-px h-6 bg-border mx-1"></div>
<!-- Lifestyle & Dietary Tags from Style Guidance -->
<span class="px-2 py-1 rounded-[4px] bg-primary-container text-white font-label text-label whitespace-nowrap">Halal</span>
<span class="px-2 py-1 rounded-[4px] bg-success text-white font-label text-label whitespace-nowrap">Vegetarian</span>
<span class="px-2 py-1 rounded-[4px] bg-[#0E7490] text-white font-label text-label whitespace-nowrap flex items-center gap-1">
                Vegan
                <span class="material-symbols-outlined text-[12px] cursor-pointer">close</span>
</span>
<span class="px-2 py-1 rounded-[4px] bg-warning text-white font-label text-label whitespace-nowrap">Allergen Free</span>
</div>
<!-- Centered Empty State -->
<div class="flex-1 flex flex-col items-center justify-center px-margin-mobile text-center">
<div class="w-[80px] h-[80px] rounded-full bg-primary-light flex items-center justify-center mb-stack-lg shadow-sm">
<span class="material-symbols-outlined text-[48px] text-primary-container" style="font-variation-settings: 'FILL' 1;">restaurant</span>
</div>
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-stack-sm">No restaurants nearby</h2>
<p class="font-body-1 text-body-1 text-grey-600 mb-stack-lg max-w-[320px]">
                We couldn't find restaurants matching your preferences within 2 km. Try adjusting your filters.
            </p>
<button class="min-h-[48px] px-6 rounded-xl border border-outline text-primary font-button text-button flex items-center justify-center hover:bg-surface-variant transition-colors">
                Adjust Filters
            </button>
</div>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full z-50 bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] md:hidden">
<div class="flex justify-around items-center px-4 py-2 pb-safe w-full">
<button aria-label="Home" class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group">
<div class="px-4 py-1 rounded-full group-hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined">home</span>
</div>
<span class="font-label text-label mt-1">Home</span>
</button>
<!-- Active State: Explore -->
<button aria-label="Explore" class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150 w-16">
<div class="px-4 py-1 rounded-full bg-secondary-container transition-colors">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">explore</span>
</div>
<span class="font-label text-label mt-1">Explore</span>
</button>
<button aria-label="Budget" class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group">
<div class="px-4 py-1 rounded-full group-hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined">payments</span>
</div>
<span class="font-label text-label mt-1">Budget</span>
</button>
<button aria-label="Profile" class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group">
<div class="px-4 py-1 rounded-full group-hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined">person</span>
</div>
<span class="font-label text-label mt-1">Profile</span>
</button>
</div>
</nav>
<!-- NavigationDrawer (Hidden overlay, semantic presence) -->
<aside aria-hidden="true" class="fixed left-0 top-0 h-full w-72 z-[60] bg-surface shadow-xl transform -translate-x-full transition-all duration-300 ease-in-out flex flex-col py-4" id="nav-drawer">
<div class="px-margin-mobile mb-4">
<h2 class="font-headline-1 text-headline-1 text-primary">Urban Wellness</h2>
<p class="font-body-2 text-body-2 text-on-surface-variant">Account &amp; Preferences</p>
</div>
<div class="flex-1 overflow-y-auto">
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-colors" href="#">
<span class="material-symbols-outlined">shopping_cart</span>
<span class="font-body-1 text-body-1">Grocery</span>
</a>
<a class="bg-primary-container text-on-primary-container rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4" href="#">
<span class="material-symbols-outlined">restaurant_menu</span>
<span class="font-body-1 text-body-1">Recipes</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-colors" href="#">
<span class="material-symbols-outlined">receipt_long</span>
<span class="font-body-1 text-body-1">My List</span>
</a>
<a class="text-on-surface-variant hover:bg-surface-variant rounded-lg mx-2 my-1 px-4 py-3 flex items-center gap-4 transition-colors" href="#">
<span class="material-symbols-outlined">map</span>
<span class="font-body-1 text-body-1">Route Map</span>
</a>
</div>
</aside>
</body></html>

<!-- 3A-Empty — Cook-In Empty State -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Cook-In Empty State</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        body {
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-1 flex flex-col min-h-screen pb-safe">
<!-- Top App Bar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full max-w-screen-md mx-auto">
<button aria-label="Menu" class="p-2 -ml-2 text-primary hover:bg-grey-100 rounded-full transition-colors">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 0;">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary">Recipes</h1>
<button aria-label="Search" class="p-2 -mr-2 text-primary hover:bg-grey-100 rounded-full transition-colors">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 0;">search</span>
</button>
</div>
</header>
<!-- Main Content -->
<main class="flex-grow flex flex-col items-center justify-center pt-[72px] pb-[80px] px-margin-mobile md:px-margin-tablet max-w-screen-md mx-auto w-full h-full min-h-[884px]">
<div class="flex flex-col items-center text-center max-w-sm w-full animate-fade-in-up">
<!-- Icon Circle -->
<div class="w-20 h-20 rounded-full bg-primary-light flex items-center justify-center mb-6 shadow-sm">
<span class="material-symbols-outlined text-primary text-[48px]" style="font-variation-settings: 'FILL' 0;">restaurant</span>
</div>
<!-- Text Content -->
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-2">No recipes yet</h2>
<p class="font-body-1 text-body-1 text-grey-600 mb-8 max-w-[280px]">Create your first recipe to get started with Cook-In mode.</p>
<!-- Action Button -->
<button class="w-full h-12 bg-primary-container text-white font-button text-button rounded-xl hover:opacity-90 transition-opacity flex items-center justify-center shadow-sm">
<span class="material-symbols-outlined mr-2 text-[20px]" style="font-variation-settings: 'FILL' 0;">add</span>
                Create Recipe
            </button>
</div>
</main>
<!-- Bottom Navigation Bar (Mobile only) -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe shadow-[0_-4px_12px_rgba(0,0,0,0.08)] bg-surface z-50 md:hidden">
<a class="flex flex-col items-center justify-center text-grey-400 font-label text-label hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1 text-[24px]" style="font-variation-settings: 'FILL' 0;">home</span>
            Home
        </a>
<a class="flex flex-col items-center justify-center text-grey-400 font-label text-label hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1 text-[24px]" style="font-variation-settings: 'FILL' 0;">explore</span>
            Explore
        </a>
<a class="flex flex-col items-center justify-center text-primary font-semibold font-label text-label hover:opacity-80 scale-95 transition-transform duration-150 relative" href="#">
<div class="absolute -top-1 w-12 h-8 bg-primary-container/10 rounded-full -z-10"></div>
<span class="material-symbols-outlined mb-1 text-[24px]" style="font-variation-settings: 'FILL' 1;">restaurant_menu</span>
            Recipes
        </a>
<a class="flex flex-col items-center justify-center text-grey-400 font-label text-label hover:opacity-80 scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined mb-1 text-[24px]" style="font-variation-settings: 'FILL' 0;">person</span>
            Profile
        </a>
</nav>
<style>
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .animate-fade-in-up {
            animation: fadeInUp 0.6s ease-out forwards;
        }
    </style>
</body></html>

<!-- 3C — Create / Edit Recipe -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport"/>
<title>Create / Edit Recipe</title>
<!-- Google Fonts & Material Symbols -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<!-- Tailwind Configuration -->
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        /* Hide scrollbar for cleaner look */
        ::-webkit-scrollbar { display: none; }
        * { -ms-overflow-style: none; scrollbar-width: none; }
        /* Safe area adjustments */
        .pb-safe { padding-bottom: env(safe-area-inset-bottom); }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface antialiased min-h-screen relative pb-[100px]">
<!-- Top App Bar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200 flex items-center justify-between px-margin-mobile h-input-height">
<button class="text-primary hover:bg-grey-100 p-2 -ml-2 rounded-full flex items-center justify-center transition-colors">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="font-headline-1 text-headline-1 font-bold text-primary">New Recipe</h1>
<button class="font-button text-button text-primary font-semibold hover:opacity-80 transition-opacity">Save</button>
</header>
<!-- Main Content Area -->
<main class="pt-[calc(var(--spacing-input-height)+var(--spacing-margin-mobile))] px-margin-mobile flex flex-col gap-stack-lg max-w-2xl mx-auto">
<!-- Image Upload Zone -->
<div class="w-full h-[180px] border-2 border-dashed border-grey-400 rounded-xl flex flex-col items-center justify-center bg-surface-bright cursor-pointer hover:bg-grey-100 transition-colors">
<span class="material-symbols-outlined text-[32px] text-grey-600 mb-2" data-icon="photo_camera" style="font-variation-settings: 'FILL' 0;">photo_camera</span>
<span class="font-body-1 text-body-1 text-grey-600">Tap to upload cover photo</span>
</div>
<!-- Recipe Title -->
<div class="flex flex-col gap-stack-sm">
<label class="font-label text-label text-on-surface-variant ml-1">Recipe Title</label>
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary w-full transition-all" placeholder="e.g. Healthy Chicken Salad" type="text"/>
</div>
<!-- Details Grid -->
<div class="grid grid-cols-3 gap-gutter">
<div class="flex flex-col gap-stack-sm">
<label class="font-label text-label text-on-surface-variant ml-1">Prep (min)</label>
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary w-full transition-all" placeholder="15" type="number"/>
</div>
<div class="flex flex-col gap-stack-sm">
<label class="font-label text-label text-on-surface-variant ml-1">Servings</label>
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary w-full transition-all" placeholder="2" type="number"/>
</div>
<div class="flex flex-col gap-stack-sm">
<label class="font-label text-label text-on-surface-variant ml-1">Calories</label>
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary w-full transition-all" placeholder="350" type="number"/>
</div>
</div>
<!-- Dietary Tags -->
<div class="flex flex-col gap-stack-sm">
<label class="font-label text-label text-on-surface-variant ml-1">Dietary Tags</label>
<div class="flex flex-wrap gap-2">
<!-- Inactive Chip -->
<button class="px-3 py-1.5 rounded-[4px] font-label text-label bg-surface-container-lowest text-grey-600 border border-border hover:bg-grey-100 transition-colors">Halal</button>
<!-- Active Chip (Example: Vegan) -->
<button class="px-3 py-1.5 rounded-[4px] font-label text-label bg-secondary text-white border border-secondary transition-colors">Vegan</button>
<button class="px-3 py-1.5 rounded-[4px] font-label text-label bg-surface-container-lowest text-grey-600 border border-border hover:bg-grey-100 transition-colors">Vegetarian</button>
<button class="px-3 py-1.5 rounded-[4px] font-label text-label bg-surface-container-lowest text-grey-600 border border-border hover:bg-grey-100 transition-colors">Gluten-Free</button>
</div>
</div>
<div class="h-[1px] w-full bg-border my-2"></div>
<!-- Ingredients Section -->
<div class="flex flex-col gap-stack-md">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Ingredients</h2>
<!-- Ingredient Row 1 -->
<div class="flex gap-gutter items-center">
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest flex-1 min-w-0 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary" placeholder="Item name" type="text" value="Chicken Breast"/>
<input class="h-input-height rounded-xl border border-border px-3 font-body-1 text-body-1 bg-surface-container-lowest w-[72px] focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-center" placeholder="Qty" type="number" value="200"/>
<div class="relative w-[80px]">
<select class="h-input-height w-full appearance-none rounded-xl border border-border pl-3 pr-8 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary">
<option>g</option>
<option>kg</option>
<option>cup</option>
</select>
<span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none text-grey-600 text-sm">expand_more</span>
</div>
<button class="text-error p-2 hover:bg-error-container rounded-full transition-colors flex-shrink-0">
<span class="material-symbols-outlined" data-icon="delete">delete</span>
</button>
</div>
<!-- Ingredient Row 2 -->
<div class="flex gap-gutter items-center">
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest flex-1 min-w-0 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary" placeholder="Item name" type="text"/>
<input class="h-input-height rounded-xl border border-border px-3 font-body-1 text-body-1 bg-surface-container-lowest w-[72px] focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-center" placeholder="Qty" type="number"/>
<div class="relative w-[80px]">
<select class="h-input-height w-full appearance-none rounded-xl border border-border pl-3 pr-8 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary">
<option>pcs</option>
<option>tbsp</option>
<option>tsp</option>
</select>
<span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none text-grey-600 text-sm">expand_more</span>
</div>
<button class="text-error p-2 hover:bg-error-container rounded-full transition-colors flex-shrink-0">
<span class="material-symbols-outlined" data-icon="delete">delete</span>
</button>
</div>
<!-- Ingredient Row 3 -->
<div class="flex gap-gutter items-center">
<input class="h-input-height rounded-xl border border-border px-4 font-body-1 text-body-1 bg-surface-container-lowest flex-1 min-w-0 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary" placeholder="Item name" type="text"/>
<input class="h-input-height rounded-xl border border-border px-3 font-body-1 text-body-1 bg-surface-container-lowest w-[72px] focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-center" placeholder="Qty" type="number"/>
<div class="relative w-[80px]">
<select class="h-input-height w-full appearance-none rounded-xl border border-border pl-3 pr-8 font-body-1 text-body-1 bg-surface-container-lowest focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary">
<option>ml</option>
<option>L</option>
<option>dash</option>
</select>
<span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none text-grey-600 text-sm">expand_more</span>
</div>
<button class="text-error p-2 hover:bg-error-container rounded-full transition-colors flex-shrink-0">
<span class="material-symbols-outlined" data-icon="delete">delete</span>
</button>
</div>
<button class="font-button text-button text-primary self-start flex items-center gap-1 mt-1 hover:bg-surface-variant px-3 py-2 rounded-lg transition-colors">
<span class="material-symbols-outlined text-sm" data-icon="add">add</span> Add ingredient
            </button>
</div>
<div class="h-[1px] w-full bg-border my-2"></div>
<!-- Steps Section -->
<div class="flex flex-col gap-stack-md">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Steps</h2>
<!-- Step 1 -->
<div class="flex gap-gutter items-start bg-surface-container-lowest p-4 rounded-xl border border-border relative group">
<div class="w-6 h-6 rounded-full bg-primary-container text-white flex items-center justify-center font-label text-label flex-shrink-0 mt-0.5">1</div>
<textarea class="w-full bg-transparent border-none focus:ring-0 p-0 font-body-1 text-body-1 resize-none text-on-surface" placeholder="Describe this step..." rows="2">Preheat oven to 200°C. Season the chicken breast lightly.</textarea>
<button class="text-grey-400 cursor-grab hover:text-on-surface ml-2 transition-colors">
<span class="material-symbols-outlined" data-icon="drag_indicator">drag_indicator</span>
</button>
</div>
<!-- Step 2 -->
<div class="flex gap-gutter items-start bg-surface-container-lowest p-4 rounded-xl border border-border relative group">
<div class="w-6 h-6 rounded-full bg-primary-container text-white flex items-center justify-center font-label text-label flex-shrink-0 mt-0.5">2</div>
<textarea class="w-full bg-transparent border-none focus:ring-0 p-0 font-body-1 text-body-1 resize-none text-on-surface" placeholder="Describe this step..." rows="2"></textarea>
<button class="text-grey-400 cursor-grab hover:text-on-surface ml-2 transition-colors">
<span class="material-symbols-outlined" data-icon="drag_indicator">drag_indicator</span>
</button>
</div>
<button class="font-button text-button text-primary self-start flex items-center gap-1 mt-1 hover:bg-surface-variant px-3 py-2 rounded-lg transition-colors mb-4">
<span class="material-symbols-outlined text-sm" data-icon="add">add</span> Add step
            </button>
</div>
</main>
<!-- Sticky Footer Action -->
<div class="fixed bottom-0 left-0 w-full p-margin-mobile bg-surface/90 backdrop-blur-md border-t border-border z-50 pb-safe">
<div class="max-w-2xl mx-auto">
<button class="w-full min-h-[48px] bg-primary-container text-white rounded-[12px] font-button text-button flex items-center justify-center hover:bg-primary transition-colors shadow-sm">
                Save Recipe
            </button>
</div>
</div>
</body></html>

<!-- 4A-Empty — Shopping List Empty -->
<!DOCTYPE html>

<html class="light" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Shopping List - Empty</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface font-body-1 antialiased min-h-screen flex flex-col">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 bg-surface border-b border-border transition-colors duration-200">
<div class="flex items-center justify-between px-margin-mobile h-input-height w-full">
<button class="flex items-center justify-center p-2 text-primary hover:bg-grey-100 rounded-full transition-colors">
<span class="material-symbols-outlined">menu</span>
</button>
<h1 class="text-headline-1 font-headline-1 font-bold text-primary">Settings</h1>
<button class="flex items-center justify-center p-2 text-primary hover:bg-grey-100 rounded-full transition-colors">
<span class="material-symbols-outlined">search</span>
</button>
</div>
</header>
<!-- Main Content -->
<main class="flex-grow flex flex-col items-center justify-center px-margin-mobile pt-[56px] pb-[72px]">
<div class="flex flex-col items-center text-center max-w-sm w-full">
<!-- Basket Icon in Circle -->
<div class="w-24 h-24 bg-primary-light rounded-full flex items-center justify-center mb-stack-lg shadow-sm">
<span class="material-symbols-outlined text-primary" style="font-size: 48px;">shopping_basket</span>
</div>
<!-- Headline -->
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-stack-sm">
                Your list is empty
            </h2>
<!-- Body Text -->
<p class="font-body-1 text-body-1 text-grey-600 mb-stack-lg">
                Find a recipe to start adding ingredients.
            </p>
<!-- Outlined Button -->
<button class="border border-border text-primary font-button text-button h-input-height px-8 rounded-lg flex items-center justify-center hover:bg-surface-variant transition-colors w-full sm:w-auto">
                Browse Recipes
            </button>
</div>
</main>
<!-- NavigationDrawer (Hidden by default on mobile, handled by desktop layout if implemented fully, skipping rendering visually here as per BottomNavBar priority on mobile) -->
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] z-50 md:hidden">
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group w-16">
<span class="material-symbols-outlined group-hover:text-primary transition-colors">home</span>
<span class="font-label text-label mt-1 group-hover:text-primary transition-colors">Home</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group w-16">
<span class="material-symbols-outlined group-hover:text-primary transition-colors">explore</span>
<span class="font-label text-label mt-1 group-hover:text-primary transition-colors">Explore</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group w-16">
<span class="material-symbols-outlined group-hover:text-primary transition-colors">payments</span>
<span class="font-label text-label mt-1 group-hover:text-primary transition-colors">Budget</span>
</button>
<button class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150 w-16">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">person</span>
<span class="font-label text-label mt-1">Profile</span>
</button>
</nav>
</body></html>

<!-- 5A — Explore / Search -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Explore</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<style>
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface font-body-1 antialiased min-h-screen relative pb-24">
<!-- Header / Search Area -->
<header class="px-margin-mobile pt-6 pb-stack-sm sticky top-0 bg-surface z-40">
<h1 class="font-display text-display text-primary mb-stack-md">Explore</h1>
<div class="flex items-center gap-3 bg-white border border-border rounded-xl h-input-height px-4 shadow-sm focus-within:border-primary focus-within:ring-1 focus-within:ring-primary transition-all">
<span class="material-symbols-outlined text-grey-400">search</span>
<input class="flex-1 bg-transparent border-none outline-none font-body-1 text-body-1 text-on-surface placeholder-grey-400 w-full focus:ring-0 p-0" placeholder="Search restaurants, recipes, grocery stores..." type="text"/>
<div class="h-6 w-px bg-border mx-1"></div>
<button class="text-primary flex items-center justify-center p-1 rounded-full hover:bg-surface-container-low transition-colors">
<span class="material-symbols-outlined">tune</span>
</button>
</div>
</header>
<!-- Main Content Canvas -->
<main class="flex flex-col gap-stack-lg">
<!-- Category Tabs -->
<section class="px-margin-mobile pt-stack-sm">
<div class="flex gap-gutter overflow-x-auto snap-x no-scrollbar pb-1">
<button class="snap-start whitespace-nowrap px-5 py-2.5 rounded-full bg-primary-container text-on-primary-container font-button text-button shadow-sm transition-transform active:scale-95">Restaurants</button>
<button class="snap-start whitespace-nowrap px-5 py-2.5 rounded-full bg-white border border-border text-on-surface-variant font-button text-button hover:bg-surface-container-low transition-colors">Recipes</button>
<button class="snap-start whitespace-nowrap px-5 py-2.5 rounded-full bg-white border border-border text-on-surface-variant font-button text-button hover:bg-surface-container-low transition-colors">Groceries</button>
</div>
</section>
<!-- Dietary Filters -->
<section class="px-margin-mobile">
<h3 class="font-headline-3 text-headline-3 text-on-surface-variant mb-stack-sm">Dietary Preference</h3>
<div class="flex gap-2 flex-wrap">
<button class="bg-primary text-white px-3 py-1.5 rounded font-label text-label flex items-center gap-1.5 shadow-sm transition-transform active:scale-95">
<span class="material-symbols-outlined text-[16px]">check</span> Halal
                </button>
<button class="bg-white border border-border text-on-surface-variant px-3 py-1.5 rounded font-label text-label hover:bg-surface-container-low transition-colors">
                    Vegan
                </button>
<button class="bg-white border border-border text-on-surface-variant px-3 py-1.5 rounded font-label text-label hover:bg-surface-container-low transition-colors">
                    Vegetarian
                </button>
</div>
</section>
<!-- Radius Slider Card -->
<section class="px-margin-mobile">
<div class="bg-white border border-border rounded-xl p-4 shadow-sm">
<div class="flex justify-between items-center mb-stack-lg">
<span class="font-headline-3 text-headline-3 text-on-surface">Search Area</span>
<span class="font-button text-button text-primary bg-primary-light px-2 py-1 rounded">Within 2.0 km</span>
</div>
<div class="relative w-full h-2 bg-grey-100 rounded-full mt-2 mb-1">
<div class="absolute top-0 left-0 h-full bg-primary rounded-full" style="width: 40%;"></div>
<div class="absolute top-1/2 -translate-y-1/2 w-6 h-6 bg-white border-2 border-primary rounded-full shadow-md cursor-pointer flex items-center justify-center" style="left: 40%; transform: translate(-50%, -50%);">
<div class="w-2 h-2 bg-primary rounded-full"></div>
</div>
</div>
<div class="flex justify-between mt-stack-md font-caption text-caption text-grey-400">
<span>Nearby</span>
<span>Citywide</span>
</div>
</div>
</section>
<!-- Recent Searches -->
<section class="px-margin-mobile pt-stack-sm">
<div class="flex justify-between items-center mb-stack-md">
<h2 class="font-headline-2 text-headline-2 text-on-surface">Recent Searches</h2>
<button class="font-label text-label text-grey-600 hover:text-primary transition-colors">CLEAR</button>
</div>
<div class="bg-white border border-border rounded-xl overflow-hidden shadow-sm">
<ul class="flex flex-col">
<li class="flex items-center gap-4 p-4 border-b border-border last:border-0 hover:bg-surface-container-low transition-colors cursor-pointer group">
<span class="material-symbols-outlined text-grey-400 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">schedule</span>
<span class="flex-1 font-body-1 text-body-1 text-on-surface">Nasi lemak near me</span>
<button class="text-grey-400 hover:text-error transition-colors p-1"><span class="material-symbols-outlined text-[18px]">close</span></button>
</li>
<li class="flex items-center gap-4 p-4 border-b border-border last:border-0 hover:bg-surface-container-low transition-colors cursor-pointer group">
<span class="material-symbols-outlined text-grey-400 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">schedule</span>
<span class="flex-1 font-body-1 text-body-1 text-on-surface">Halal sushi</span>
<button class="text-grey-400 hover:text-error transition-colors p-1"><span class="material-symbols-outlined text-[18px]">close</span></button>
</li>
<li class="flex items-center gap-4 p-4 border-b border-border last:border-0 hover:bg-surface-container-low transition-colors cursor-pointer group">
<span class="material-symbols-outlined text-grey-400 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">schedule</span>
<span class="flex-1 font-body-1 text-body-1 text-on-surface">Recipe mee goreng</span>
<button class="text-grey-400 hover:text-error transition-colors p-1"><span class="material-symbols-outlined text-[18px]">close</span></button>
</li>
</ul>
</div>
</section>
</main>
<!-- Shared Component: BottomNavBar -->
<nav class="md:hidden fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe bg-surface shadow-[0_-4px_12px_rgba(0,0,0,0.08)] z-50">
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group" href="#">
<span class="material-symbols-outlined mb-1 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">home</span>
<span class="font-label text-label group-hover:text-primary transition-colors">Home</span>
</a>
<a class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150 w-16 relative" href="#">
<div class="absolute -top-1 w-8 h-1 bg-primary rounded-full"></div>
<span class="material-symbols-outlined mb-1" style="font-variation-settings: 'FILL' 1;">explore</span>
<span class="font-label text-label">Explore</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group" href="#">
<span class="material-symbols-outlined mb-1 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">payments</span>
<span class="font-label text-label group-hover:text-primary transition-colors">Budget</span>
</a>
<a class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 w-16 group" href="#">
<span class="material-symbols-outlined mb-1 group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">person</span>
<span class="font-label text-label group-hover:text-primary transition-colors">Profile</span>
</a>
</nav>
</body></html>

<!-- 5B — Category Browse -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Browse Categories</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&amp;display=swap" rel="stylesheet"/>
<style>
        .material-symbols-outlined {
            font-family: 'Material Symbols Outlined';
            font-weight: normal;
            font-style: normal;
            font-size: 24px;
            line-height: 1;
            letter-spacing: normal;
            text-transform: none;
            display: inline-block;
            white-space: nowrap;
            word-wrap: normal;
            direction: ltr;
            -webkit-font-feature-settings: 'liga';
            -webkit-font-smoothing: antialiased;
        }
    </style>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background min-h-screen font-sans antialiased selection:bg-primary-container selection:text-white">
<header class="bg-surface fixed top-0 w-full z-50 border-b border-border flex items-center justify-between px-margin-mobile h-input-height transition-colors duration-200">
<button class="material-symbols-outlined text-primary hover:bg-grey-100 transition-colors duration-200 rounded-full p-2 -ml-2 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-opacity-50" data-icon="arrow_back">arrow_back</button>
<h1 class="font-headline-1 text-headline-1 font-bold text-primary flex-1 text-center pr-8">Browse Categories</h1>
</header>
<main class="pt-[calc(56px+24px)] pb-[calc(70px+24px)] px-margin-mobile">
<div class="grid grid-cols-2 gap-stack-lg max-w-2xl mx-auto">
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🍛</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Mamak</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">☕</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Kopitiam</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🥢</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Chinese</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🌶️</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Indian</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🍣</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Japanese</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🍔</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Western</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">🛒</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">Groceries</span>
</button>
<button class="bg-white border border-border rounded-xl h-[120px] flex flex-col items-center justify-center gap-stack-md hover:bg-surface-container-low hover:border-primary-container hover:shadow-sm transition-all duration-200 group active:scale-95">
<span class="text-display group-hover:scale-110 transition-transform duration-300">📖</span>
<span class="font-headline-3 text-headline-3 text-on-surface group-hover:text-primary">My Recipes</span>
</button>
</div>
</main>
<nav class="fixed bottom-0 w-full z-50 shadow-[0_-4px_12px_rgba(0,0,0,0.08)] bg-surface fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe md:hidden">
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-label text-label mt-1">Home</span>
</button>
<button class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined text-primary" data-icon="explore" style="font-variation-settings: 'FILL' 1;">explore</span>
<span class="font-label text-label mt-1">Explore</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="payments">payments</span>
<span class="font-label text-label mt-1">Budget</span>
</button>
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label text-label mt-1">Profile</span>
</button>
</nav>
</body></html>

<!-- 6A — Map View -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Smart City - Map View</title>
<!-- Google Fonts -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<!-- Material Symbols -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<!-- Tailwind Config -->
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    borderRadius: {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    spacing: {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    fontFamily: {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    fontSize: {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background w-full h-screen overflow-hidden flex flex-col font-body-1 text-body-1 relative antialiased selection:bg-primary-light selection:text-primary">
<!-- Map Canvas (Full Screen Background) -->
<div class="absolute inset-0 z-0 bg-cover bg-center" data-alt="A clean, modern, high-contrast digital map interface displaying city streets, parks, and water bodies in a light-mode aesthetic. The map uses a sophisticated color palette of soft greys, subtle greens for parks, and crisp white for major roads to ensure high readability. Lighting is even and neutral, creating a professional, utilitarian mood perfect for navigation. The visual style is vector-based and highly structured, emphasizing clarity and modern urban planning over realistic satellite imagery." data-location="Kuala Lumpur" style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBEcrVWVN3OP8X6YggWCqIXbU8Y-4XW_6kqn9lmTt596NXz5NQyO-INSo6O4TiQAG11v9ZNH6LAUxf8J3gA8IBqG4liN-mX7F0IclLm0pHGYG1C3InlR1m7raiOmxCFFyCesB4amtgxMajdVr3a-bW_8x5H09f154SoaiLCmgtiU11Bn79xCBFmKQlbD5c8ZvMeuHAw4CbbNvZRT2DMPOeqo5ABu-odfVblfSJLSZcRKU-452T_9VmUBoaTP6WuH3_8747YWKylyzA');">
<!-- Map Markers Overlay -->
<div class="absolute inset-0 z-0 pointer-events-none">
<!-- Restaurant Marker 1 -->
<div class="absolute top-[30%] left-[25%] flex flex-col items-center animate-bounce" style="animation-duration: 2s; animation-iteration-count: infinite;">
<div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center shadow-md border-2 border-surface-container-lowest">
<span class="material-symbols-outlined text-white text-xl">restaurant</span>
</div>
<div class="w-0 h-0 border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent border-t-[8px] border-t-primary -mt-1"></div>
</div>
<!-- Restaurant Marker 2 -->
<div class="absolute top-[45%] right-[30%] flex flex-col items-center">
<div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center shadow-md border-2 border-surface-container-lowest">
<span class="material-symbols-outlined text-white text-xl">restaurant</span>
</div>
<div class="w-0 h-0 border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent border-t-[8px] border-t-primary -mt-1"></div>
</div>
<!-- Grocery Marker 1 -->
<div class="absolute top-[60%] left-[40%] flex flex-col items-center">
<div class="w-10 h-10 bg-secondary rounded-full flex items-center justify-center shadow-md border-2 border-surface-container-lowest">
<span class="material-symbols-outlined text-white text-xl">eco</span>
</div>
<div class="w-0 h-0 border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent border-t-[8px] border-t-secondary -mt-1"></div>
</div>
</div>
</div>
<!-- Top Overlay (Search & Filters) -->
<div class="absolute top-0 left-0 w-full z-10 pt-4 px-margin-mobile flex flex-col gap-stack-md pointer-events-none">
<!-- Search Bar -->
<div class="w-full bg-surface-container-lowest h-[56px] rounded-full shadow-[0_4px_16px_rgba(0,0,0,0.06)] border border-border flex items-center px-4 pointer-events-auto backdrop-blur-sm bg-opacity-95 transition-all focus-within:shadow-[0_4px_20px_rgba(0,0,0,0.12)]">
<span class="material-symbols-outlined text-grey-600 mr-3 select-none">search</span>
<input class="flex-1 bg-transparent border-none p-0 focus:ring-0 font-body-1 text-body-1 text-on-surface placeholder:text-grey-400 outline-none w-full" placeholder="Search nearby..." type="text"/>
<button class="ml-2 w-8 h-8 rounded-full bg-surface-bright flex items-center justify-center hover:bg-surface-variant transition-colors">
<span class="material-symbols-outlined text-grey-600 text-sm">tune</span>
</button>
</div>
<!-- Filter Chips -->
<div class="flex overflow-x-auto hide-scrollbar gap-2 pointer-events-auto pb-1 mt-1">
<button class="h-9 px-4 rounded-full bg-primary text-on-primary font-label text-label flex items-center justify-center whitespace-nowrap shadow-sm transition-transform active:scale-95">
                All
            </button>
<button class="h-9 px-4 rounded-full bg-surface-container-lowest border border-border text-on-surface font-label text-label flex items-center justify-center whitespace-nowrap shadow-sm hover:bg-grey-100 transition-colors active:scale-95">
                Restaurants
            </button>
<button class="h-9 px-4 rounded-full bg-surface-container-lowest border border-border text-on-surface font-label text-label flex items-center justify-center whitespace-nowrap shadow-sm hover:bg-grey-100 transition-colors active:scale-95">
                Groceries
            </button>
<button class="h-9 px-4 rounded-full bg-surface-container-lowest border border-border text-on-surface font-label text-label flex items-center justify-center whitespace-nowrap shadow-sm hover:bg-grey-100 transition-colors active:scale-95">
                Pharmacies
            </button>
</div>
</div>
<!-- Floating Action Button (My Location) -->
<div class="absolute right-margin-mobile bottom-[240px] z-10 pointer-events-auto">
<button class="w-12 h-12 bg-surface-container-lowest rounded-full shadow-[0_4px_16px_rgba(0,0,0,0.1)] border border-border flex items-center justify-center text-primary hover:bg-grey-100 transition-all active:scale-95">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">my_location</span>
</button>
</div>
<!-- Mini Bottom Sheet -->
<div class="absolute bottom-[64px] left-0 w-full bg-surface-container-lowest rounded-t-[16px] shadow-[0_-8px_32px_rgba(0,0,0,0.08)] z-20 flex flex-col pointer-events-auto border-t border-border pb-4 transition-transform duration-300">
<!-- Handle -->
<div class="w-full flex justify-center pt-3 pb-2 cursor-grab">
<div class="w-8 h-1 bg-grey-400 rounded-full"></div>
</div>
<!-- Header -->
<div class="px-margin-mobile flex items-center justify-between mb-3">
<h2 class="font-headline-3 text-headline-3 text-on-surface">3 restaurants · 2 grocery stores nearby</h2>
<button class="text-primary hover:bg-primary-light rounded-full p-1 transition-colors">
<span class="material-symbols-outlined text-sm">keyboard_arrow_up</span>
</button>
</div>
<!-- Horizontal Scroll Cards -->
<div class="flex overflow-x-auto hide-scrollbar gap-margin-mobile px-margin-mobile snap-x snap-mandatory">
<!-- Card 1 -->
<div class="w-[280px] flex-shrink-0 bg-surface-container-lowest rounded-xl border border-border p-3 flex gap-3 shadow-sm snap-center">
<div class="w-16 h-16 rounded-lg bg-cover bg-center flex-shrink-0" data-alt="A vibrant overhead shot of a healthy salad bowl sitting on a clean, light wood table. The bowl is filled with fresh greens, cherry tomatoes, and sliced avocado, bathed in soft, natural window light. The mood is fresh, organic, and appetizing, perfectly fitting a modern health-conscious lifestyle app. The color palette emphasizes bright greens, warm wood tones, and crisp white highlights." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuB3bKnqf2DsEHWjhzWZR7KTFjRfSvZIWQGrHRU_jwFyvKMp5IJgWsHizDXXznrwjfgzN6SVtm-7CtFlAzQMyp0JCqHqailT5L6D39yuPW9RLmu0VqIi1CRja7VV6KI4Jhz6egEzgDyJDC3Yjb0tgdRML2zV0n6_etLeXIErryVcrhYGdVxSjxrHlf9qJsh8uegAC8AJhwd1x2w0QM1cTA6ztSSAaOdWwL3be3iIqTPhUzAi2DtOkZ41qcYhGdk2Z6Yg8z-cLniPUlk');">
</div>
<div class="flex flex-col justify-center flex-1 min-w-0">
<h3 class="font-headline-3 text-headline-3 text-on-surface truncate">The Green Fork</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate mt-0.5">Healthy Bowls · 0.2km</p>
<div class="flex items-center gap-1 mt-1.5">
<span class="material-symbols-outlined text-warning text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="font-label text-label text-on-surface">4.8</span>
</div>
</div>
</div>
<!-- Card 2 -->
<div class="w-[280px] flex-shrink-0 bg-surface-container-lowest rounded-xl border border-border p-3 flex gap-3 shadow-sm snap-center">
<div class="w-16 h-16 rounded-lg bg-cover bg-center flex-shrink-0" data-alt="A brightly lit aisle of a modern organic grocery store. Shelves are neatly stocked with colorful fresh produce and artisan goods, illuminated by clean, even commercial lighting. The aesthetic is organized, premium, and inviting, conveying a sense of quality and abundance. The palette features fresh organic colors against a backdrop of crisp white shelving and polished floors." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCnvE4y73rsiEg6ihLD9Tw1vWOjH9sgaU4jjhO3hvYoxBP0VqQ_QAeDqF2spj_7ROP0I3UFJSJ5CB2X6_RZnMzRs1WkVmHYt0I01rRC0Fo95tRgvjvS4Y855dFFe-nfhOuILIy4MKJSDOQsOXQlPqnKm_-B1Xm57ahAHtskKIMhXgXwhWKsJm8e0BQedTOhVCpnUBbajBMI9X4_1iOiP0exZ0nNGZs3OsD4uOCDbYU1uU8Up-KvfKhFZnc8xwdUaJREtwAdPA-KDNY');">
</div>
<div class="flex flex-col justify-center flex-1 min-w-0">
<h3 class="font-headline-3 text-headline-3 text-on-surface truncate">Urban Grocer</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate mt-0.5">Organic Market · 0.5km</p>
<div class="flex flex-wrap gap-1 mt-1.5">
<span class="px-2 py-0.5 bg-primary text-white rounded font-caption text-caption">Halal</span>
<span class="px-2 py-0.5 bg-success text-white rounded font-caption text-caption">Vegan</span>
</div>
</div>
</div>
<!-- Card 3 -->
<div class="w-[280px] flex-shrink-0 bg-surface-container-lowest rounded-xl border border-border p-3 flex gap-3 shadow-sm snap-center pr-margin-mobile">
<div class="w-16 h-16 rounded-lg bg-cover bg-center flex-shrink-0" data-alt="A modern, minimalist cafe setting featuring a close-up of an artisanal avocado toast and a perfectly poured latte. The lighting is soft and warm, casting gentle shadows that highlight the textures of the food and the ceramic mug. The mood is relaxed and sophisticated, designed for a chic urban lifestyle aesthetic. Colors revolve around creamy whites, earthy browns, and the vibrant green of the avocado." style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBCetSNInQoa_P9Zvtr-DsvOL1VAwpk-TxwDk5vh_DyghIgOn-u37SvI_xy9nqT9FauB3N9qEJ4x7Ys98KKxyUPuy2Kmss0NgTvSOSBMaHyOjCHyiFhvU-cklEw7hxfBTq9Bnm17P_kxcR9E8UH8cnvaEDQUSMvQb-mQQ18i0Yi3cYamtAhr0zkwPMXmUC0jicK-Qt_Lxj2tA76CxjPcsnwmwJrsYVrkSoxrCIg-i14uHqBUjuVmz5gop0RT2jnYgwj6HvAVRIxTN8');">
</div>
<div class="flex flex-col justify-center flex-1 min-w-0">
<h3 class="font-headline-3 text-headline-3 text-on-surface truncate">Cafe Bloom</h3>
<p class="font-body-2 text-body-2 text-grey-600 truncate mt-0.5">Coffee &amp; Light Bites · 0.8km</p>
<div class="flex items-center gap-1 mt-1.5">
<span class="material-symbols-outlined text-warning text-[14px]" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="font-label text-label text-on-surface">4.5</span>
</div>
</div>
</div>
</div>
</div>
<!-- Bottom Navigation Shell (Shared Component Blueprint) -->
<nav class="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-6 shadow-[0_-4px_12px_rgba(0,0,0,0.08)] bg-surface z-50 border-t-0">
<!-- Home (Inactive) -->
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group">
<span class="material-symbols-outlined group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">home</span>
<span class="font-label text-label mt-1">Home</span>
</button>
<!-- Explore (Active - Semantically matches Map View) -->
<button class="flex flex-col items-center justify-center text-primary font-semibold hover:opacity-80 scale-95 transition-transform duration-150">
<div class="px-4 py-1 bg-primary-light rounded-full mb-1">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">explore</span>
</div>
<span class="font-label text-label">Explore</span>
</button>
<!-- Budget (Inactive) -->
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group">
<span class="material-symbols-outlined group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">payments</span>
<span class="font-label text-label mt-1">Budget</span>
</button>
<!-- Profile (Inactive) -->
<button class="flex flex-col items-center justify-center text-grey-400 hover:opacity-80 scale-95 transition-transform duration-150 group">
<span class="material-symbols-outlined group-hover:text-primary transition-colors" style="font-variation-settings: 'FILL' 0;">person</span>
<span class="font-label text-label mt-1">Profile</span>
</button>
</nav>
</body></html>

<!-- 7D — Budget Analytics -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Budget Analytics</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1",
                        "f0fdf4": "#F0FDF4"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", {"lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500"}],
                        "button": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                        "headline-1": ["22px", {"lineHeight": "28px", "fontWeight": "600"}],
                        "body-1": ["14px", {"lineHeight": "20px", "fontWeight": "400"}],
                        "headline-2": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
                        "body-2": ["12px", {"lineHeight": "16px", "fontWeight": "400"}],
                        "caption": ["10px", {"lineHeight": "12px", "fontWeight": "400"}],
                        "headline-3": ["15px", {"lineHeight": "20px", "fontWeight": "500"}],
                        "display": ["28px", {"lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700"}]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-[#F0FDF4] min-h-screen font-body-1 text-on-surface antialiased pb-24 md:pb-0 pt-input-height md:pt-0">
<!-- TopAppBar -->
<header class="bg-surface dark:bg-surface-dim font-headline-1 text-headline-1 fixed top-0 w-full z-50 border-b border-border dark:border-outline-variant flat no shadows transition-colors duration-200 flex items-center justify-between px-margin-mobile h-input-height md:hidden">
<div class="flex items-center gap-4">
<span class="material-symbols-outlined text-primary dark:text-primary-fixed-dim hover:bg-grey-100 dark:hover:bg-tertiary-container cursor-pointer rounded-full p-2" data-icon="arrow_back">arrow_back</span>
<span class="text-headline-1 font-headline-1 font-bold text-primary dark:text-primary-fixed-dim">Analytics</span>
</div>
<span class="material-symbols-outlined text-primary dark:text-primary-fixed-dim hover:bg-grey-100 dark:hover:bg-tertiary-container cursor-pointer rounded-full p-2" data-icon="more_vert">more_vert</span>
</header>
<div class="hidden md:flex bg-surface dark:bg-surface-dim font-headline-1 text-headline-1 fixed top-0 w-full z-50 border-b border-border dark:border-outline-variant flat no shadows transition-colors duration-200 items-center justify-between px-margin-tablet h-input-height">
<div class="flex items-center gap-4">
<span class="text-headline-1 font-headline-1 font-bold text-primary dark:text-primary-fixed-dim">Urban Wellness</span>
</div>
<div class="flex gap-8">
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant cursor-pointer hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-label text-label mt-1">Home</span>
</div>
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant cursor-pointer hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="explore">explore</span>
<span class="font-label text-label mt-1">Explore</span>
</div>
<div class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-semibold cursor-pointer hover:opacity-80 scale-95 transition-transform duration-150 border-b-2 border-primary">
<span class="material-symbols-outlined" data-icon="payments" data-weight="fill" style="font-variation-settings: 'FILL' 1;">payments</span>
<span class="font-label text-label mt-1">Budget</span>
</div>
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant cursor-pointer hover:opacity-80 scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label text-label mt-1">Profile</span>
</div>
</div>
</div>
<!-- Main Content Canvas -->
<main class="px-margin-mobile md:px-margin-tablet py-stack-lg max-w-4xl mx-auto space-y-stack-lg mt-4 md:mt-20">
<!-- Period Selector -->
<div class="flex gap-2">
<button class="px-4 py-2 rounded-full border border-border bg-white text-grey-600 font-button text-button">7D</button>
<button class="px-4 py-2 rounded-full border border-primary bg-primary text-white font-button text-button shadow-sm">30D</button>
<button class="px-4 py-2 rounded-full border border-border bg-white text-grey-600 font-button text-button">90D</button>
</div>
<!-- Weekly Bar Chart Card -->
<div class="bg-white border border-border rounded-xl p-4 shadow-sm flex flex-col gap-stack-md">
<div>
<h2 class="font-headline-2 text-headline-2 text-on-surface">Weekly Spending</h2>
<p class="font-body-2 text-body-2 text-grey-600">RM 420.50 this week</p>
</div>
<div class="flex items-end justify-between h-40 mt-4 px-2">
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-12"></div>
<span class="font-caption text-caption text-grey-600">Mon</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-20"></div>
<span class="font-caption text-caption text-grey-600">Tue</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-16"></div>
<span class="font-caption text-caption text-grey-600">Wed</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-24"></div>
<span class="font-caption text-caption text-grey-600">Thu</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-primary rounded-t-sm h-32 relative">
<div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-on-surface text-white font-caption text-caption px-2 py-1 rounded shadow-sm whitespace-nowrap">RM 120</div>
</div>
<span class="font-caption text-caption text-primary font-medium">Fri</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-8"></div>
<span class="font-caption text-caption text-grey-600">Sat</span>
</div>
<div class="flex flex-col items-center gap-2">
<div class="w-8 bg-surface-container-high rounded-t-sm h-4"></div>
<span class="font-caption text-caption text-grey-600">Sun</span>
</div>
</div>
</div>
<!-- AI Forecast Card -->
<div class="bg-[#F0FDF4] border border-primary-light rounded-xl p-4 shadow-sm flex items-start gap-4">
<div class="bg-primary-light text-primary rounded-full p-2 flex-shrink-0">
<span class="material-symbols-outlined" data-icon="temp_preferences_custom">temp_preferences_custom</span>
</div>
<div>
<h3 class="font-headline-3 text-headline-3 text-primary mb-1">AI Forecast</h3>
<p class="font-body-2 text-body-2 text-on-surface-variant leading-relaxed">At this rate, you will spend approximately <strong class="text-primary font-semibold">RM 570</strong> this week. Consider reducing dining out to stay under your RM 500 goal.</p>
</div>
</div>
<!-- Bento Grid for Categories & Venues -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-stack-lg">
<!-- Category Donut Card -->
<div class="bg-white border border-border rounded-xl p-4 shadow-sm flex flex-col h-full">
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-4">Categories</h2>
<div class="flex items-center gap-6 flex-1">
<div class="w-24 h-24 rounded-full border-8 border-primary border-r-surface-container-high border-b-secondary relative flex-shrink-0">
<div class="absolute inset-0 flex items-center justify-center flex-col">
<span class="font-headline-3 text-headline-3 font-semibold text-on-surface">30D</span>
</div>
</div>
<div class="flex flex-col gap-3 w-full">
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<div class="w-3 h-3 rounded-full bg-primary"></div>
<span class="font-body-2 text-body-2 text-on-surface">Dining</span>
</div>
<span class="font-button text-button text-on-surface">60%</span>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<div class="w-3 h-3 rounded-full bg-secondary"></div>
<span class="font-body-2 text-body-2 text-on-surface">Groceries</span>
</div>
<span class="font-button text-button text-on-surface">29%</span>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<div class="w-3 h-3 rounded-full bg-surface-container-high"></div>
<span class="font-body-2 text-body-2 text-on-surface">Delivery</span>
</div>
<span class="font-button text-button text-on-surface">11%</span>
</div>
</div>
</div>
</div>
<!-- Top Venues Card -->
<div class="bg-white border border-border rounded-xl p-4 shadow-sm flex flex-col h-full">
<h2 class="font-headline-2 text-headline-2 text-on-surface mb-4">Top Venues</h2>
<div class="flex flex-col gap-4">
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-surface-variant flex items-center justify-center text-primary">
<span class="material-symbols-outlined" data-icon="restaurant">restaurant</span>
</div>
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Nasi Kandar Ali</h4>
<p class="font-caption text-caption text-grey-600">Dining • 4 visits</p>
</div>
</div>
<span class="font-button text-button text-on-surface">RM 145</span>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-surface-variant flex items-center justify-center text-secondary">
<span class="material-symbols-outlined" data-icon="shopping_basket">shopping_basket</span>
</div>
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">Jaya Grocer</h4>
<p class="font-caption text-caption text-grey-600">Groceries • 1 visit</p>
</div>
</div>
<span class="font-button text-button text-on-surface">RM 120</span>
</div>
<div class="flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full bg-surface-variant flex items-center justify-center text-warning">
<span class="material-symbols-outlined" data-icon="two_wheeler">two_wheeler</span>
</div>
<div>
<h4 class="font-headline-3 text-headline-3 text-on-surface">GrabFood</h4>
<p class="font-caption text-caption text-grey-600">Delivery • 2 visits</p>
</div>
</div>
<span class="font-button text-button text-on-surface">RM 45</span>
</div>
</div>
</div>
</div>
</main>
<!-- BottomNavBar -->
<nav class="bg-surface dark:bg-surface-container-lowest font-label text-label fixed bottom-0 w-full z-50 shadow-[0_-4px_12px_rgba(0,0,0,0.08)] dark:shadow-none shadow-lg fixed bottom-0 left-0 w-full flex justify-around items-center px-4 py-2 pb-safe md:hidden">
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 cursor-pointer">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="mt-1">Home</span>
</div>
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 cursor-pointer">
<span class="material-symbols-outlined" data-icon="explore">explore</span>
<span class="mt-1">Explore</span>
</div>
<div class="flex flex-col items-center justify-center text-primary dark:text-primary-fixed-dim font-semibold hover:opacity-80 scale-95 transition-transform duration-150 cursor-pointer">
<span class="material-symbols-outlined" data-icon="payments" data-weight="fill" style="font-variation-settings: 'FILL' 1;">payments</span>
<span class="mt-1">Budget</span>
</div>
<div class="flex flex-col items-center justify-center text-grey-400 dark:text-on-surface-variant hover:opacity-80 scale-95 transition-transform duration-150 cursor-pointer">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="mt-1">Profile</span>
</div>
</nav>
</body></html>

<!-- 9B — About & Legal -->
<!DOCTYPE html>

<html lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>About &amp; Legal - Mapetite</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "tertiary": "#333f39",
                        "on-secondary": "#ffffff",
                        "surface-container-lowest": "#ffffff",
                        "grey-600": "#6B7280",
                        "primary": "#004532",
                        "secondary": "#006781",
                        "inverse-primary": "#8bd6b6",
                        "surface-variant": "#d9e3f6",
                        "surface-bright": "#f8f9ff",
                        "inverse-on-surface": "#eaf1ff",
                        "primary-container": "#065f46",
                        "surface-container-highest": "#d9e3f6",
                        "error": "#EF4444",
                        "outline": "#6f7973",
                        "primary-light": "#D1FAE5",
                        "on-primary-fixed": "#002116",
                        "tertiary-fixed-dim": "#bdcac1",
                        "secondary-container": "#8fdfff",
                        "surface-container": "#e6eeff",
                        "on-tertiary-fixed-variant": "#3e4943",
                        "surface-dim": "#d0dbed",
                        "warning": "#F59E0B",
                        "surface-container-low": "#eff4ff",
                        "surface": "#f8f9ff",
                        "primary-fixed-dim": "#8bd6b6",
                        "secondary-fixed": "#b9eaff",
                        "inverse-surface": "#27313f",
                        "outline-variant": "#bec9c2",
                        "on-primary": "#ffffff",
                        "on-error": "#ffffff",
                        "on-surface": "#121c2a",
                        "grey-400": "#9CA3AF",
                        "tertiary-fixed": "#d9e6dd",
                        "on-tertiary": "#ffffff",
                        "on-secondary-container": "#00647d",
                        "secondary-fixed-dim": "#81d1f0",
                        "tertiary-container": "#4a564f",
                        "surface-tint": "#1b6b51",
                        "error-container": "#ffdad6",
                        "success": "#10B981",
                        "background": "#f8f9ff",
                        "on-primary-fixed-variant": "#00513b",
                        "on-tertiary-fixed": "#131e19",
                        "on-surface-variant": "#3f4944",
                        "on-error-container": "#93000a",
                        "on-primary-container": "#8bd6b7",
                        "border": "#E5E7EB",
                        "surface-container-high": "#dee9fc",
                        "white": "#FFFFFF",
                        "on-background": "#121c2a",
                        "on-secondary-fixed-variant": "#004d62",
                        "on-tertiary-container": "#becac2",
                        "on-secondary-fixed": "#001f29",
                        "grey-100": "#F3F4F6",
                        "primary-fixed": "#a6f2d1"
                    },
                    "borderRadius": {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                    "spacing": {
                        "margin-tablet": "24px",
                        "stack-sm": "4px",
                        "gutter": "12px",
                        "stack-lg": "16px",
                        "margin-mobile": "16px",
                        "stack-md": "8px",
                        "input-height": "56px"
                    },
                    "fontFamily": {
                        "label": ["Inter"],
                        "button": ["Inter"],
                        "headline-1": ["Inter"],
                        "body-1": ["Inter"],
                        "headline-2": ["Inter"],
                        "body-2": ["Inter"],
                        "caption": ["Inter"],
                        "headline-3": ["Inter"],
                        "display": ["Inter"]
                    },
                    "fontSize": {
                        "label": ["11px", { "lineHeight": "14px", "letterSpacing": "0.02em", "fontWeight": "500" }],
                        "button": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
                        "headline-1": ["22px", { "lineHeight": "28px", "fontWeight": "600" }],
                        "body-1": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
                        "headline-2": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
                        "body-2": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
                        "caption": ["10px", { "lineHeight": "12px", "fontWeight": "400" }],
                        "headline-3": ["15px", { "lineHeight": "20px", "fontWeight": "500" }],
                        "display": ["28px", { "lineHeight": "34px", "letterSpacing": "-0.02em", "fontWeight": "700" }]
                    }
                }
            }
        }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface font-body-1 antialiased pb-safe min-h-screen flex flex-col">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 border-b border-border bg-surface flex items-center justify-between px-margin-mobile h-input-height w-full transition-colors duration-200">
<button class="text-primary hover:bg-grey-100 p-2 rounded-full transition-colors duration-200 flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="arrow_back">arrow_back</span>
</button>
<h1 class="font-headline-1 text-headline-1 font-bold text-primary">About</h1>
<div class="w-10"></div> <!-- Spacer to center title -->
</header>
<main class="flex-grow pt-input-height px-margin-mobile flex flex-col gap-stack-lg max-w-2xl mx-auto w-full mt-6 pb-24">
<!-- Header / Logo Area -->
<section class="flex flex-col items-center justify-center py-8 gap-stack-md text-center">
<div class="h-20 w-20 bg-primary-container rounded-2xl flex items-center justify-center shadow-sm mb-2">
<span class="material-symbols-outlined text-white text-4xl" data-icon="map">map</span>
</div>
<h2 class="font-display text-display text-primary">Mapetite</h2>
<p class="font-body-1 text-body-1 text-grey-600 max-w-xs mx-auto">Your smart companion for a healthier, more connected urban lifestyle.</p>
<p class="font-caption text-caption text-grey-400 mt-2">Version 2.4.1 (Build 492)</p>
</section>
<!-- Our Mission -->
<section class="bg-white rounded-xl border border-border p-4 shadow-sm flex flex-col gap-stack-md">
<h3 class="font-headline-2 text-headline-2 text-on-surface">Our Mission</h3>
<p class="font-body-1 text-body-1 text-grey-600 leading-relaxed">
                Mapetite aims to seamlessly integrate health, diet, and local exploration into the daily lives of urban professionals. We believe navigating the city's culinary landscape should be an empowering experience that supports your wellbeing.
            </p>
</section>
<!-- Our Commitments -->
<section class="flex flex-col gap-stack-md mt-4">
<h3 class="font-headline-2 text-headline-2 text-on-surface px-2">Our Commitments</h3>
<div class="grid grid-cols-1 gap-4">
<!-- SDG 3 -->
<div class="bg-white rounded-xl border border-border p-4 flex gap-4 items-start shadow-sm hover:border-primary transition-colors duration-200 cursor-default">
<div class="flex-shrink-0 w-12 h-12 bg-success rounded-lg flex items-center justify-center text-white font-headline-2 text-headline-2">
                        3
                    </div>
<div class="flex flex-col gap-1">
<h4 class="font-headline-3 text-headline-3 text-on-surface">Good Health &amp; Well-being</h4>
<p class="font-body-2 text-body-2 text-grey-600">Promoting healthy dietary choices and making allergen-safe options easily discoverable across the city.</p>
</div>
</div>
<!-- SDG 11 -->
<div class="bg-white rounded-xl border border-border p-4 flex gap-4 items-start shadow-sm hover:border-primary transition-colors duration-200 cursor-default">
<div class="flex-shrink-0 w-12 h-12 bg-warning rounded-lg flex items-center justify-center text-white font-headline-2 text-headline-2">
                        11
                    </div>
<div class="flex flex-col gap-1">
<h4 class="font-headline-3 text-headline-3 text-on-surface">Sustainable Cities</h4>
<p class="font-body-2 text-body-2 text-grey-600">Supporting local businesses and creating a more connected, walkable urban food ecosystem.</p>
</div>
</div>
<!-- SDG 12 -->
<div class="bg-white rounded-xl border border-border p-4 flex gap-4 items-start shadow-sm hover:border-primary transition-colors duration-200 cursor-default">
<div class="flex-shrink-0 w-12 h-12 bg-secondary rounded-lg flex items-center justify-center text-white font-headline-2 text-headline-2">
                        12
                    </div>
<div class="flex flex-col gap-1">
<h4 class="font-headline-3 text-headline-3 text-on-surface">Responsible Consumption</h4>
<p class="font-body-2 text-body-2 text-grey-600">Encouraging mindful eating and reducing food waste through better planning and portion awareness.</p>
</div>
</div>
</div>
</section>
<!-- Legal Links -->
<section class="mt-4 flex flex-col gap-stack-md">
<h3 class="font-headline-2 text-headline-2 text-on-surface px-2">Legal</h3>
<div class="bg-white rounded-xl border border-border overflow-hidden shadow-sm flex flex-col">
<button class="w-full flex items-center justify-between p-4 border-b border-border hover:bg-grey-100 transition-colors duration-200 text-left">
<span class="font-body-1 text-body-1 text-on-surface font-medium">Terms of Service</span>
<span class="material-symbols-outlined text-grey-400" data-icon="chevron_right">chevron_right</span>
</button>
<button class="w-full flex items-center justify-between p-4 border-b border-border hover:bg-grey-100 transition-colors duration-200 text-left">
<span class="font-body-1 text-body-1 text-on-surface font-medium">Privacy Policy</span>
<span class="material-symbols-outlined text-grey-400" data-icon="chevron_right">chevron_right</span>
</button>
<button class="w-full flex items-center justify-between p-4 hover:bg-grey-100 transition-colors duration-200 text-left">
<span class="font-body-1 text-body-1 text-on-surface font-medium">Open Source Licences</span>
<span class="material-symbols-outlined text-grey-400" data-icon="chevron_right">chevron_right</span>
</button>
</div>
</section>
<!-- Contact -->
<section class="mt-4 flex flex-col gap-stack-md">
<div class="bg-white rounded-xl border border-border p-4 shadow-sm">
<a class="flex items-center gap-4 hover:opacity-80 transition-opacity" href="mailto:hello@mapetite.app">
<div class="w-10 h-10 rounded-full bg-surface-variant flex items-center justify-center text-primary">
<span class="material-symbols-outlined" data-icon="mail">mail</span>
</div>
<div class="flex flex-col">
<span class="font-label text-label text-grey-600 uppercase">Contact Us</span>
<span class="font-body-1 text-body-1 text-primary font-medium">hello@mapetite.app</span>
</div>
</a>
</div>
</section>
</main>
</body></html>
