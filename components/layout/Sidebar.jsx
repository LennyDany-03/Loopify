"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import useAuthStore from "@/lib/store/useAuthStore";

const navItems = [
  { href: "/dashboard",  label: "Dashboard",  icon: "⚡" },
  { href: "/loops",      label: "My Loops",   icon: "🔁" },
  { href: "/analytics",  label: "Analytics",  icon: "📊" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { user, logout } = useAuthStore();

  return (
    <aside className="w-56 min-h-screen bg-[#0d0d14] border-r border-white/[0.06] flex flex-col">

      {/* Logo */}
      <div className="px-5 py-6 border-b border-white/[0.06]">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🔁</span>
          <span className="text-white font-bold text-lg tracking-tight">
            Loop<span className="text-violet-400">ify</span>
          </span>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                isActive
                  ? "bg-violet-600/20 text-violet-300 border border-violet-500/20"
                  : "text-zinc-400 hover:text-white hover:bg-white/[0.04]"
              }`}
            >
              <span className="text-base">{item.icon}</span>
              <span className="font-medium">{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* User section */}
      <div className="px-3 py-4 border-t border-white/[0.06]">
        <div className="flex items-center gap-3 px-3 py-2 mb-2">
          {/* Avatar */}
          <div className="w-8 h-8 rounded-full bg-violet-600/30 border border-violet-500/30 flex items-center justify-center text-violet-300 text-sm font-bold">
            {user?.full_name?.[0]?.toUpperCase() ?? "U"}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-white text-xs font-medium truncate">
              {user?.full_name ?? "User"}
            </p>
            <p className="text-zinc-500 text-[11px] truncate">{user?.email}</p>
          </div>
        </div>

        <button
          onClick={logout}
          className="w-full text-left flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-zinc-500 hover:text-red-400 hover:bg-red-500/[0.06] transition-colors"
        >
          <span>→</span>
          <span>Log out</span>
        </button>
      </div>

    </aside>
  );
}