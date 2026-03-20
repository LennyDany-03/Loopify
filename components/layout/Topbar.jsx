"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import useAuthStore from "@/lib/store/useAuthStore";

const pageTitles = {
  "/dashboard": "Dashboard",
  "/loops":     "My Loops",
  "/analytics": "Analytics",
};

export default function Topbar() {
  const pathname  = usePathname();
  const { user }  = useAuthStore();

  // Resolve title — handle dynamic routes like /loops/[id]
  const title =
    pageTitles[pathname] ??
    (pathname.startsWith("/loops/") ? "Loop Detail" : "Loopify");

  const today = new Date().toLocaleDateString("en-IN", {
    weekday: "short", day: "numeric", month: "short",
  });

  return (
    <header className="h-14 bg-[#0d0d14] border-b border-white/[0.06] px-6 flex items-center justify-between shrink-0">

      {/* Page title + breadcrumb */}
      <div className="flex items-center gap-2 text-sm">
        <span className="text-zinc-500">Loopify</span>
        <span className="text-zinc-600">/</span>
        <span className="text-white font-medium">{title}</span>
      </div>

      {/* Right side */}
      <div className="flex items-center gap-4">
        {/* Date */}
        <span className="text-zinc-500 text-xs hidden sm:block">{today}</span>

        {/* New loop shortcut */}
        <Link
          href="/loops"
          className="text-xs bg-violet-600/20 hover:bg-violet-600/30 border border-violet-500/20 text-violet-300 px-3 py-1.5 rounded-lg transition-colors"
        >
          + New Loop
        </Link>

        {/* Avatar */}
        <div className="w-8 h-8 rounded-full bg-violet-600/30 border border-violet-500/30 flex items-center justify-center text-violet-300 text-sm font-bold">
          {user?.full_name?.[0]?.toUpperCase() ?? "U"}
        </div>
      </div>

    </header>
  );
}