"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/dashboard",  label: "Dashboard",  icon: "⚡" },
  { href: "/loops",      label: "Loops",      icon: "🔁" },
  { href: "/analytics",  label: "Analytics",  icon: "📊" },
  { href: "/profile",    label: "Profile",    icon: "👤" },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 w-full z-50 md:hidden glass-strong border-t border-white/[0.08] pb-safe pt-2 px-6">
      <div className="flex items-center justify-between max-w-sm mx-auto h-14">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className="relative flex flex-col items-center justify-center w-16 h-full gap-1"
            >
              {/* Active glow background */}
              {isActive && (
                <div className="absolute inset-0 bg-violet-600/10 rounded-2xl blur-md" />
              )}
              
              {/* Icon */}
              <span
                className={`text-xl z-10 transition-transform duration-300 ${
                  isActive ? "scale-110 drop-shadow-[0_0_8px_rgba(167,139,250,0.5)]" : "text-zinc-500 scale-100"
                }`}
              >
                {item.icon}
              </span>
              
              {/* Label */}
              <span
                className={`z-10 text-[10px] font-medium tracking-wide transition-colors ${
                  isActive ? "text-violet-300" : "text-zinc-500"
                }`}
              >
                {item.label}
              </span>

              {/* Active Indicator Line */}
              {isActive && (
                <div className="absolute -top-2 left-1/2 -translate-x-1/2 w-8 h-1 rounded-b-full bg-gradient-to-r from-violet-400 to-purple-500 shadow-[0_2px_8px_rgba(167,139,250,0.8)]" />
              )}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
