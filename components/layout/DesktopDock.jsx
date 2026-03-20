"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import useAuthStore from "@/lib/store/useAuthStore";

const navItems = [
  { href: "/dashboard",  label: "Dashboard",  icon: "⚡" },
  { href: "/loops",      label: "My Loops",   icon: "🔁" },
  { href: "/analytics",  label: "Analytics",  icon: "📊" },
];

export default function DesktopDock() {
  const pathname = usePathname();
  const { user, logout } = useAuthStore();

  return (
    <nav className="fixed left-4 top-1/2 -translate-y-1/2 z-50 hidden md:flex flex-col items-center gap-6 glass-[0.8] border border-white/[0.08] p-3 rounded-full shadow-2xl shadow-black/50 animate-fade-in">
      
      {/* ── Brand Icon ─────────────────────────────────────────── */}
      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-indigo-600 flex items-center justify-center text-lg shadow-lg shadow-violet-500/30 shrink-0">
        🔁
      </div>

      <div className="w-8 h-px bg-white/[0.06] rounded-full" />

      {/* ── Nav Items ──────────────────────────────────────────── */}
      <div className="flex flex-col gap-3">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`group relative w-10 h-10 rounded-full flex items-center justify-center text-lg transition-all duration-300 ${
                isActive
                  ? "bg-violet-600/20 text-violet-300 shadow-[inset_0_0_12px_rgba(124,108,252,0.2)]"
                  : "text-zinc-500 hover:text-white hover:bg-white/[0.06]"
              }`}
            >
              <span className={`transition-transform duration-300 ${isActive ? 'scale-110' : 'group-hover:scale-110'}`}>
                {item.icon}
              </span>

              {/* Tooltip */}
              <div className="absolute left-full ml-3 px-3 py-1.5 rounded-lg glass-strong text-white text-xs font-medium opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-200 pointer-events-none whitespace-nowrap shadow-xl">
                {item.label}
              </div>

              {/* Active Dot */}
              {isActive && (
                <div className="absolute -left-1.5 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-violet-400 shadow-[0_0_8px_rgba(167,139,250,0.8)]" />
              )}
            </Link>
          );
        })}
      </div>

      <div className="w-8 h-px bg-white/[0.06] rounded-full" />

      {/* ── User / Avatar ──────────────────────────────────────── */}
      <Link href="/profile" className="relative group mt-2">
        <div className={`w-10 h-10 rounded-full flex items-center justify-center text-violet-300 font-bold transition-all duration-300 hover:scale-105 ${
          pathname === "/profile" 
            ? "bg-violet-600/40 border-violet-400 shadow-[0_0_12px_rgba(139,92,246,0.3)]" 
            : "bg-gradient-to-br from-violet-500/30 to-purple-600/30 border-violet-500/30"
        } border`}>
          {user?.full_name?.[0]?.toUpperCase() ?? "U"}
        </div>
        <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full bg-green-500 border-2 border-[#0d0d14]" />

        {/* Tooltip */}
        <div className="absolute left-full ml-3 px-3 py-1.5 rounded-lg glass-strong text-white text-xs font-medium opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-200 pointer-events-none whitespace-nowrap shadow-xl">
          Profile
        </div>
      </Link>

    </nav>
  );
}
