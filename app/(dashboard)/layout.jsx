"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import DesktopDock from "@/components/layout/DesktopDock";
import BottomNav from "@/components/layout/BottomNav";
import Topbar from "@/components/layout/Topbar";
import useAuthStore from "@/lib/store/useAuthStore";

export default function DashboardLayout({ children }) {
  const router = useRouter();
  const { isLoggedIn } = useAuthStore();

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!isLoggedIn) router.replace("/login");
  }, [isLoggedIn, router]);

  if (!isLoggedIn) return null;

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex relative">
      
      {/* ── Navigation Components ─────────────────────────────── */}
      <DesktopDock />
      <BottomNav />

      {/* ── Main Content Area ─────────────────────────────────── */}
      {/* Add padding for Desktop Dock (pl-24) and Mobile BottomNav (pb-16) */}
      <div className="flex-1 flex flex-col min-w-0 md:pl-24 pb-16 md:pb-0 transition-all duration-300">
        <Topbar />
        <main className="flex-1 px-4 py-5 sm:px-6 sm:py-6 overflow-y-auto w-full">
          {children}
        </main>
      </div>
    </div>
  );
}