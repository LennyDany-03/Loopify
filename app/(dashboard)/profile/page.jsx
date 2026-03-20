"use client";

import { useState } from "react";
import useAuthStore from "@/lib/store/useAuthStore";
import { usersAPI } from "@/lib/api";
import Button from "@/components/ui/Button";

export default function ProfilePage() {
  const { user, logout } = useAuthStore();
  const [fullName, setFullName] = useState(user?.full_name || "");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ text: "", type: "" });

  const handleUpdate = async (e) => {
    e.preventDefault();
    if (!fullName.trim() || fullName === user?.full_name) return;

    setLoading(true);
    setMessage({ text: "", type: "" });
    try {
      const res = await usersAPI.updateMe({ full_name: fullName });
      // Update global store directly
      useAuthStore.setState((state) => ({
        user: { ...state.user, full_name: res.data.full_name },
      }));
      setMessage({ text: "Profile updated successfully ✨", type: "success" });
    } catch (err) {
      setMessage({ text: err.response?.data?.detail || "Failed to update profile", type: "error" });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-xl mx-auto mt-6 md:mt-12 space-y-6 animate-fade-up">

      <div className="glass-card rounded-3xl p-6 md:p-8 flex flex-col gap-6 relative overflow-hidden">
        {/* Glow effect */}
        <div className="absolute -top-24 -right-24 w-64 h-64 bg-violet-600/10 blur-[64px] rounded-full pointer-events-none" />

        <div className="flex items-center gap-5">
          <div className="w-20 h-20 rounded-[2.5rem] bg-gradient-to-br from-violet-500/20 to-purple-600/20 border border-violet-500/30 flex items-center justify-center text-4xl font-bold text-violet-300 shadow-[0_0_32px_rgba(139,92,246,0.15)] shrink-0">
            {user?.full_name?.[0]?.toUpperCase() ?? "U"}
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-white mb-1">
              My Profile
            </h1>
            <p className="text-sm text-zinc-400">Manage your account and preferences.</p>
          </div>
        </div>

        <form onSubmit={handleUpdate} className="space-y-4 mt-4">
          
          {/* Name Field */}
          <div className="space-y-1.5">
            <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 ml-1">
              Display Name
            </label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full bg-white/[0.03] border border-white/[0.08] text-white px-4 py-3 rounded-2xl focus:outline-none focus:border-violet-500/50 focus:bg-white/[0.05] transition-all duration-300"
              placeholder="Your name"
            />
          </div>

          {/* Email Field (Static) */}
          <div className="space-y-1.5">
            <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 ml-1">
              Email Address
            </label>
            <input
              type="email"
              value={user?.email || "No email available"}
              disabled
              className="w-full bg-white/[0.02] border border-white/[0.06] text-zinc-400 cursor-not-allowed px-4 py-3 rounded-2xl focus:outline-none"
            />
          </div>

          {message.text && (
            <div className={`p-4 rounded-2xl text-sm font-medium border ${
              message.type === 'error' ? 'bg-red-500/10 text-red-400 border-red-500/20' : 'bg-green-500/10 text-green-400 border-green-500/20'
            }`}>
              {message.text}
            </div>
          )}

          <div className="pt-4 flex items-center justify-end gap-3 border-t border-white/[0.06]">
            <Button
              type="submit"
              disabled={loading || fullName === user?.full_name}
              className={`px-6 py-2.5 rounded-xl shadow-lg transition-all ${
                fullName !== user?.full_name
                  ? "bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-violet-500/25 hover:shadow-violet-500/40"
                  : "bg-white/[0.05] text-zinc-500 hover:bg-white/[0.05]"
              }`}
            >
              {loading ? "Saving..." : "Save Changes"}
            </Button>
          </div>
        </form>
      </div>

      {/* Danger Zone */}
      <div className="glass-card rounded-3xl p-6 md:p-8 flex items-center justify-between border border-red-500/10">
        <div>
          <h2 className="text-red-400 font-bold mb-1">Sign Out</h2>
          <p className="text-xs text-zinc-500 pr-4">You will need to log back in to access your habits.</p>
        </div>
        <button
          onClick={logout}
          className="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 hover:border-red-500/30 px-5 py-2.5 rounded-xl font-semibold transition-all duration-200 shrink-0"
        >
          Sign Out →
        </button>
      </div>
    
    </div>
  );
}
