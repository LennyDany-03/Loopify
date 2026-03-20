"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import useAuthStore from "@/lib/store/useAuthStore";

const pageTitles = {
  "/dashboard": "Dashboard",
  "/loops":     "My Loops",
  "/analytics": "Analytics",
  "/profile":   "My Profile",
};

export default function Topbar() {
  const pathname  = usePathname();
  const { user }  = useAuthStore();

  const title = pageTitles[pathname] ?? (pathname.startsWith("/loops/") ? "Loop Detail" : "Loopify");

  const today = new Date().toLocaleDateString("en-IN", {
    weekday: "short", day: "numeric", month: "short",
  });

  return (
    <div className="sticky top-4 z-30 px-4 sm:px-6 w-full flex justify-center pointer-events-none">
      <header className="h-14 glass-strong border border-white/[0.08] px-5 sm:px-6 rounded-2xl flex items-center justify-between pointer-events-auto shadow-2xl shadow-black/40 w-full max-w-4xl transition-all duration-300">

        {/* Left: Breadcrumb / Title */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 text-sm">
            <span className="text-zinc-500 hidden sm:inline">Loopify</span>
            <span className="text-zinc-600 hidden sm:inline">/</span>
            <span className="text-white font-medium text-base sm:text-sm tracking-wide">{title}</span>
          </div>
        </div>

        {/* Right side */}
        <div className="flex items-center gap-4">
          <span className="text-zinc-500 text-xs hidden sm:block">{today}</span>
          
          <div className="w-px h-4 bg-white/[0.08] hidden sm:block" />

          <Link
            href="/loops"
            className="text-xs bg-gradient-to-r from-violet-600/20 to-purple-600/20 hover:from-violet-600/30 hover:to-purple-600/30 border border-violet-500/20 text-violet-300 px-4 py-1.5 rounded-full transition-all duration-300 hover:shadow-[0_0_12px_rgba(139,92,246,0.2)] hidden sm:block"
          >
            + New Loop
          </Link>

          {/* Avatar (Mobile Only) -> Links to Profile */}
          <Link href="/profile" className="md:hidden">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-violet-500/30 to-purple-600/30 border border-violet-500/30 flex items-center justify-center text-violet-300 text-sm font-bold shadow-[0_0_8px_rgba(139,92,246,0.2)]">
              {user?.full_name?.[0]?.toUpperCase() ?? "U"}
            </div>
          </Link>
        </div>

      </header>
    </div>
  );
}