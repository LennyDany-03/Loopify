"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { isAuthenticated } from "@/lib/auth";

export default function RootPage() {
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated()) {
      router.replace("/dashboard");
    } else {
      router.replace("/login");
    }
  }, [router]);

  // Show nothing while redirecting
  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <span className="text-5xl animate-spin" style={{ animationDuration: "2s" }}>🔁</span>
        <p className="text-zinc-600 text-sm">Loading Loopify...</p>
      </div>
    </div>
  );
}